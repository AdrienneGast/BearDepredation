This repository contains workflow and R codes to compute variables for depredation factor analysis between France and Italy.

* [Study area](#Study-area)
* [Landcover variables](#LandCover-covariates)
* [Proportion computation](#compute-proportion-rasters)
* [Nearest distance computation](#compute-nearest-distance-rasters)

# Study area  

## Pyrenees study area  

The Pyrenees are a large mountain chain ranging from France to Spain and Andorra. Those mountains are separated from others, such as the Cantabrian, and are thus containing an isolated brown bear population. Thus, we chose an area large enough to contain all the brown bear range and possible dispersal areas in order to be able to predict at large scale even in areas not yeat colonized by brown bears.

(add an image)

## Alps study area  

Please refer to [Andrea's GitHub page](https://github.com/andreacorra/AlpBearConnect/tree/master/variables)   
  
# Landcover covariates

We first compute landscape rasters from which we will calculate nearest distances and proportions.
Thus, we had computed:
- [Tree Cover Density](#tree-cover-density)  
- [Agricultural trees](#agricultural-trees)
- [Elevation and derived terrain index](#elevation)
- [Buildings](#human-buildings)
- [Roads](#roads)
- [Waterbodies](#waterbodies-and-rivers)
- [Bare Rocks](#bare-rocks)
- [Agricultural and artificial areas](#agricultural-and-artificial-areas)
- [Grassland](#grassland)  
- [Shrubland](#shrub-and-transitional-woodland-shrub-area)  

## Tree Cover Density 

The tree cover density (TCD) will allow us to compute nearest distance to forest. Thus, we keep attention to details for the forest areas but not for the type of forest. Thus, we exclude trees that are urban and agricultural trees, as they do not represent good quality habitat for bears as well as not a "wild" mountainous habitat.   

1. Non forest raster:  
        - From [Copernicus website](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015), download the forest additional support layer (FADSL, E30N20, 20m resolution, LAEA)and then crop and mask the raster for the large area of analysis
=> Creation of FADSL raster layer  
        - From [CorineLandCover 2012 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012), we select only vineyards ``` code_clc12 = 15 / 221 ```, and rasterize at 20m resolution to match raster layers. Then, we crop and mask this vineyard raster at the Pyrenees large area of analysis.
=> Creation of the Vineyard raster layer
        - Load FADSL and Vineyard raster layers in QGis (20m resolution, LAEA proj, large area)  
        - Combine both rasters into one binary raster layer  of non forest trees (QGis::Raster Calculator)        
```
"FASDL_maskrasterbase@1"  = 3  OR   
"FASDL_maskrasterbase@1"  = 4  OR   
"FASDL_maskrasterbase@1"  = 5 OR   
"vine_maskrasterbase@1" = 1  
```      
=> Creation of non forest raster layer  
 
 2. Create tree cover density raster layer   
        - Download [Copernicus TCD layer 2015](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-density/status-maps/2015) for E30N20  
        - Crop and mask the TCD layer with the large area of analysis  
        - Exclude non forest trees from the TCD layer (add script)      
=> Creation of the forest raster layer

## Agricultural trees
   - Load the non forest raster layer [constructed before](#non-forest-raster)  
   - Create a binar raster layer of agricultural trees by selecting only agricultural trees and vineyard in the previous raster (QGis::Raster Calculator) 
   
    ```"FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1```  
    
=> Creation of the agricultural trees raster layer

## Elevation
 - Load [Copernicus DEM raster layer](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1) for E30N20. This raster is at 25m resolution
 - Resample the elevation layer at 20m resolution with the bilinear method ("Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average.") at the large study area.
 
 Slope and Ruggedness were derived from this layer thanks to the [*terrain()*](https://www.rdocumentation.org/packages/raster/versions/2.9-5/topics/terrain) function in R (with neighbors=8 for rough terrain).

## Human buildings  

At first, the use of the [European Settlement Map from Copernicus](https://land.copernicus.eu/pan-european/GHSL/european-settlement-map/esm-2012-release-2017-urban-green) seems handy. However, after thorough visualization on both areas (Pyrenees and Alps), we identified some discrepancies in natural areas. For example, as the ESM is from remote sensing computation in some areas it qualified a rock as a building. Thus, we chose to extract national cadastral information from [Open Street Map (OSM)](https://www.openstreetmap.org/#map=5/46.449/2.210).  

   - Extract buildings for both areas (France, Spain, Italy) from [overpass turbo website](https://overpass-turbo.eu/) thanks to the [code information](https://wiki.openstreetmap.org/wiki/Key:highway) provided. Below is the overpass turbo code for extraction:

```/*
This has been generated by the overpass-turbo wizard.
The original search was:
“natural=bare_rock”
*/
[out:json][timeout:2500];
// gather results
(
  // query part for: “natural=bare_rock
  node["building"="yes"]({{bbox}});
  way["building"="yes"]({{bbox}});
  relation["building"="yes"]({{bbox}});
);
// print results
out body;
>;
out skel qt;
```       
The extraction might take time and has to been done in several parts for large area.

   - Merge all the extracted OSM data to create a shapefile of buildings. To do so, we combine all the buildings GeoJson files (extracted from overpass turbo), create a unique new field with the value 1 (QGis::Field Calculator), suppress all the other field for each vector layer (attribute table), reproject the shapefile into LAEA projection (EPSG+3035, QGis::Reproject layer), then merge the vector layers created (SAGA::MergeVectorLayers). 
   
*The process described above is going to be repeated several times for several different covariates and thus can be computed sometimes in QGis and sometimes in R.*

   - Buffer the polygon of the building vector layer to ease the rasterization (GRASS::v.buffer)
   - Rasterize the previous layer (merged buffered building layer) at 20m resolution at the large study area (projection LAEA)
After rasterizing the OSM national cadastral information we did another visualization check for discrepancies. Even though, there are still some differences it is less obvious and they are less numerous. 

=> Creation of Buildings raster layer.

## Roads  

- Extract roads from [overpass turbo](https://overpass-turbo.eu/) with the provided [code information](https://wiki.openstreetmap.org/wiki/Key:highway). The overpass turbo code is provided below:
    ```/*
    This has been generated by the overpass-turbo wizard.
    The original search was:
    “natural=bare_rock”
    */
    [out:json][timeout:2500];
    // gather results
    (
    // query part for: “"highway"="path"”       #just have to change the code path to the others
    node["highway"="path"]({{bbox}});           #the bbox is defined by hand on the website
    way["highway"="path"]({{bbox}});            # it is very large files to compute so we cut the area into several files
    relation["highway"="path"]({{bbox}});
    );
    // print results
    out body;
    >;
    out skel qt;```  
The [wiki page](https://wiki.openstreetmap.org/wiki/Key:highway) provides information and description of the highway layer in OSM data. Then, thanks to each description for both areas, we extracted the [footways](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dfootway), the [paths](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dpath), the [tracks](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtrack), the [motorways](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway), the [trunks](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtrunk), the [primary](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dprimary), [secondary](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dsecondary), and [tertiary](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtertiary) roads, the [unclassified roads](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dunclassified) and the [roads](https://wiki.openstreetmap.org/wiki/Tag:highway%3Droad). The extraction is done by replacing in the above code the word path 
with each category.   
As described for [Buildings](#human-buildings), the extraction is done in several parts for each area and each category.

*same process than [Buildings](#human-buildings) for each category* 
- Merge all the extracted OSM data to create a shapefile of roads in each category. To do so, we combine all the roads GeoJson files (extracted from overpass turbo), create a unique new field with the value 1 (QGis::Field Calculator), suppress all the other field for each vector layer (attribute table), reproject the shapefile into LAEA projection (EPSG+3035, QGis::Reproject layer), then merge the vector layers created (SAGA::MergeVectorLayers). 
*The process described above is going to be repeated several times for several different covariates and thus can be computed sometimes in QGis and sometimes in R.*
=> Creation of separated shapefiles of path, footway, track, motorway, trunk, primary, secondary, tertiary, unclassified and road.  
        
- Merge vector layer per created category for the study: a) Roads (motorway, trunk, primary, secondary, tertiary, unclassified, road and track), b) foot trails (path and footway).  
- Rasterize roads and foot trails vector layers (GRASS::v.to.rast.value) at 20m resolution (LAEA projection) for the large study area.   

=> Creation of Roads raster layer and Foot trails raster layer.     

## Waterbodies and rivers  

- Download the [Copernicus folder for Garonne, Ebro, and Rhone](https://land.copernicus.eu/pan-european/high-resolution-layers/water-wetness/status-maps/2015)".  
- Select only InlandWater and River_Net_I (QGis)   
- Create a new field for both vector layers (QGis::Field Calculator) and suppress the other fields  
- Merge for the three areas the two vector types separatly (inland and river, QGis::MergeVectorLayers)  
- Rasterize both shapefiles independently (GRASS::v.to.rast.value) at 20m resolution for the large study area (LAEA projection)  
=> Creation of two rasters one of inland water and another of rivers  
      
- Extract From [OpenStreet Map data](https://overpass-turbo.eu/) the waterbodies with [the provided code natural=water](https://wiki.openstreetmap.org/wiki/Tag:natural%3Dwater):     
 ```
 /*
    This has been generated by the overpass-turbo wizard.
    The original search was:
    “natural=bare_rock”
    */
    [out:json][timeout:2500];
    // gather results
    (
    // query part for: “"highway"="path"”       
    node["natural"="water"]({{bbox}});           # the bbox is defined by hand on the website
    way["natural"="water"]({{bbox}});            # it is very large files to compute so we cut the area into several files
    relation["natural"="water"]({{bbox}});
    );
    // print results
    out body;
    >;
    out skel qt;
```  
*same process than [Buildings](#human-buildings) for each category*   
- Merge all the extracted OSM data to create a shapefile of waterbodies. To do so, we combine all the waterbodies GeoJson files (extracted from overpass turbo), create a unique new field with the value 1 (QGis::Field Calculator), suppress all the other field for each vector layer (attribute table), reproject the shapefile into LAEA projection (EPSG+3035, QGis::Reproject layer), then merge the vector layers created (SAGA::MergeVectorLayers).   
*The process described above is going to be repeated several times for several different covariates and thus can be computed sometimes in QGis and sometimes in R.*  

- Rasterize the waterbodies OSM shapefile at 20m resolution over the large area (GRASS::v.to.rast.value)  

Thus we have two things:  
- Inland water raster layer from Copernicus and OSM data. We merge the two raster layers (GRASS::r.patch). *this raster will be used to clip the grassland raster*  
- Waterbodies complete raster layer with both inland waters and rivers. We merge (GRASS::r.patch) the previous raster layer of inland water (Copernicus+OSM) and the rivers (Copernicus) at 20m resolution for the large study area (LAEA projection).  

=> Creation of the Waterbodies020m_largePYR.tif that combines inland waters and rivers net from both copernicus shapefile EU-Hydro and Open Street Map data for lakes (more precise).  

## Bare rocks    

- Extract from [OSM data overpass turbo](https://overpass-turbo.eu/) the rocky structure of our mountainous areas (Alps and Pyrenees). Thanks to the decription provided on the [wiki page](https://wiki.openstreetmap.org/wiki/Tag%3Anatural%3Dbare_rock), we choose to extract OSM data for bare_rock, scree, glacuer, cliff, stone, and rock and do a visual exploration for each study area. As before, the code is provided below and you should change the word "bare_rock" to the other categories. 
```
/*
This has been generated by the overpass-turbo wizard.
The original search was:
“natural=bare_rock”
*/
[out:json][timeout:2500];
// gather results
(
  // query part for: “natural=bare_rock”
  node["natural"="bare_rock"]({{bbox}});
  way["natural"="bare_rock"]({{bbox}});
  relation["natural"="bare_rock"]({{bbox}});
);
// print results
out body;
>;
out skel qt;
```
From visual exploration, we will not use: a) stone because screen contains it, b) rock because it is not the type of rocks we are looking for, i.e. bare rocks on top of mountains, rather than those are in forest area and c) cliff will be extracted only for the Italian Alps.    

*same process than [Buildings](#human-buildings) for each category*   
- Merge all the extracted OSM data to create a shapefile of each rock category. To do so, we combine all the rock GeoJson files for each category (extracted from overpass turbo), create a unique new field with the value 1 (QGis::Field Calculator), suppress all the other field for each vector layer (attribute table), reproject the shapefile into LAEA projection (EPSG+3035, QGis::Reproject layer), then merge the vector layers created (SAGA::MergeVectorLayers).   
*The process described above is going to be repeated several times for several different covariates and thus can be computed sometimes in QGis and sometimes in R.*    

- Merge then all the vector layers (categories bare_rock, screen, glacier) into one vector layer (QGis::MergeVectorLayers)    
- Rasterize the total rock vector layer at 20m resolution for the large study area Pyrenees (GRASS::v.to.rast.value)     
*this raster will only be used for creating a well-defined grassland raster layer.*    

=> Creation of the Bare Rock raster layer  

## Agricultural and artificial areas

After having visualize the ESM map with all the other layers (mostly grassland, shrub, tcd, roads), we realize there were some areas that were not defined well in comparison with the satellite picture. As such, near villages, some agricultural lands were defined as grassland. However, in CLC12 those were defined as agricultural and/or artificial areas. And those areas are not in moutainous areas and do not represent mountainous grazing pastures. Thus, in order to produce a map of grassland with the less noise possible. *the raster created below will only be used for creating a well-defined grassland raster layer.*    
We decided to rerasterize the agricultural and artificial areas of CLC12 at 20m to exclude them from the grassland. However, it would not have been a problem for modeling, it could have increased the noise for prediction!      

- Select for agricultural and artificial areas in [CLC12 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012) for the large study area (of course vineyards, fruit trees and pastures have been excluded from this selection as they already have been used for other raster layers and definition):  
    
```
"code_12"  = '111' OR 
"code_12"  = '112' OR
"code_12"  = '121' OR
"code_12"  = '122' OR
"code_12"  = '123' OR
"code_12"  = '124' OR
"code_12"  = '131' OR
"code_12"  = '132' OR
"code_12"  = '133' OR
"code_12"  = '141' OR
"code_12"  = '142' OR
"code_12"  = '211' OR
"code_12"  = '212' OR
"code_12"  = '213' OR
"code_12"  = '223' OR
"code_12"  = '241' OR
"code_12"  = '242' OR
"code_12"  = '243' OR
"code_12"  = '244'
```  
- Rasterize (GRASS:v.to.rast.value) the artificial and agricultural vector layer at 20m resolution for the large study area.  

=> Creation of the Agricultural and Artificial raster layer     

## Grassland  

**Grassland raster layer = CLC(231,321,333) + copernicus(grassland) - Barerocks - waterbodies - artificial and agricultural areas - TCDcut**
*Remark: roads can be in grassland. That is okay. I can be in grassland and have a distance = 0 to a foot trail for example because it crosses the area.*

Compute Grassland cover from Shapefile of CLC and Copernicus
 
- Select grassland in the [CLC12 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012):  
```
"code_12"  = '231' OR
"code_12"  = '321' OR
"code_12" ='333'
```  

- Rasterize (GRASS::v.to.rast.value) the CLC grassland shapefile created above at 20m resolution for the large study area (projection LAEA).   

- Merge the two layers of grassland (from CLC(231,321,333) and [Copernicus](https://land.copernicus.eu/pan-european/high-resolution-layers/grassland/status-maps)) (GRASS::r.patch)  

- Clip Grassland layer with the [Inland waterbodies](#waterbodies-and-rivers)    

- Clip Grassland layer with the [Bare Rock layer](#bare-rocks)  

- Clip Grassland with [forest layer](#tree-cover-density)    

From visualization in QGis, some TCD >50% were inside grassland areas. In order to compute a grassland that represents very open areas I decided to exclude cells that are TCD>0 from grassland layer.    
As such, with the final layer of grassland proportion, those areas inside a grassland but with tcd>0 would be represented as a high proportion of grassland but with a very little distance to forest. It should be particular areas as it represent areas where domestic animals can graze but where there is some trees, thus making areas where probability of attacks could be high.    
Please see script.  
 
## Shrub and transitional woodland-shrub area    

- Select Shrub category (322, 323, 324) in the [CLC 2012 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012)  
```  
"code_12"  = '324' OR
"code_12"  = '323' OR
"code_12" ='322'
```   
- Rasterize (GRASS::v.to.rast.value) the shrubland shapefile at 20m resolution for the large study area (LAEA projection) (please see script)   
- Clip (exclude) [forest layer](#tree-cover-density) from the shrub raster (please see script) to create the transitional area  
- Clip (exclude) [Grassland](#grassland) to create true transitional area  

=> Creation of the shrubland layer    

## Patch density as a fragmentation index  

To compute patch density (add description)

## COMPUTE NEAREST DISTANCE TO FEATURE CELL

1. package(raster) distance()  
https://www.rdocumentation.org/packages/raster/versions/2.8-4/topics/distance

First option: Compute distance to nearest cell that is not NA (that contains the category we are interested in).  
              We assume then that 
              ```
              raster[raster==0] <-  NAs 
              ```
              and those that are 
              ```
              raster[raster != 0]
              ```
              their distance if 0 because they are the targeted category.

2. **Proximity (distance raster) QGis**

It is faster than in R. Compute all the distances from each centroid of cell to nearest target values cell, i.e. here compute the distance between cell value 0 to nearest cell value != 0.
The cells that are at 0m distance are the cells containing the feature (so the closest)!  
ok TCD  
ok AgriTree  
ok FootTrails  
ok Waterbodies  
ok PavedRoads
ok Track  
ok Shrub    
ok Building (OSM)
Distance done

 
 

## COMPUTE PROPORTION OF LANDCOVER TYPE IN BUFFER

Please see script Proportion.R
(R::focal and R::focalWeight)

Radius define as 250m (buffer of radius 250m) to have a proportion of cell that are the feature around each focal cell (proportion of feature neighbor)
 




## Some notes:
* boundaries() in package raster
* click() in package raster Click on a map (plot) to get values
* clump() in package raster detect patches of connected cells
* cv() in package raster Compute the coefficient of variation (expressed as a percentage
* density() in package raster create density plots
* **package(raster)** **distanceFromPoints()
https://www.rdocumentation.org/packages/raster/versions/2.1-41/topics/distanceFromPoints

* package(proxy) dist()  
https://www.rdocumentation.org/packages/proxy/versions/0.4-22/topics/dist

* **package(regos)** **gDistance()**  
https://www.rdocumentation.org/packages/rgeos/versions/0.4-2/topics/gDistance
 ```
library(raster)
m <- matrix(4,10)
m
mr <- raster(m)
mr
plot(mr)
res(mr) <- c(0.1,0.1)
mr[] <- 1
plot(mr)

site <- c("a","b","c","d")
prop <- c(0.88,0.99,0.13,0.65)
x <- c(0.1,0.45,0.8,0.7)
y <- c(0.2,0.7,0.3,0.5)
da <- data.frame(site,prop,x,y)
da

library(rgdal)
library(maptools)
coordinates(da) <- ~ x + y
plot(da,add=T)

library(rgeos)
dd <- gDistance(da,as(mr,"SpatialPoints"),byid=T)
dd
mr[] <- apply(dd,1,min)
plot(mr)
plot(da,add=T)
 ```  
 
* **package(spdep)** **dnearneigh**
https://www.rdocumentation.org/packages/spdep/versions/0.8-1/topics/dnearneigh

* package(geosphere) dist2Line()
https://www.rdocumentation.org/packages/geosphere/versions/1.5-5/topics/dist2Line

* canProcessInMemory() in package raster

Before using resample, you may want to consider using these other functions instead:
aggregate, disaggregate, crop, extend, merge. 

## PROPORTION

* **package(raster)** **buffer()**
* **package(raster)** **focal()**



*Brown bear activity for the complete period*
To predict at the pyrenees, we computed the mean of brown bear activity in QGis::RastorCalculator as:
```
("Raster20_buf2000_2010OursAct@1" + "Raster20_buf2000_2011OursAct_nona@1" + "Raster20_buf2000_2012OursAct@1" + "Raster20_buf2000_2013OursAct@1" + "Raster20_buf2000_2014OursAct@1" + "Raster20_buf2000_2015OursAct@1" + "Raster20_buf2000_2016OursAct@1")/7
```


To do the next step of modeling with the pastoral activity, we divided the number of sheep per the area of the pasture (m2) in QGis, using the field calculator for vector layer (nb ovin/ area). The area was calculated with the geometry calculation in QGis
