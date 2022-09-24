This repository contains workflow and R codes to compute variables for depredation factor analysis between France and Italy.

* [Study area](#Study-area)  
* [Landcover variables](#LandCover-covariates)  
* [Nearest distance computation](#compute-nearest-distance-rasters)  
* [Proportion computation](#compute-proportion-rasters)    
* [Brown bear activity](#compute-brown-bear-activity-density-covariate)  
* [Pastoral covariates](#pastoral-covariates)  

# Study area  

## Pyrenees study area  

The Pyrenees are a large mountain chain ranging from France to Spain and Andorra. Those mountains are separated from others, such as the Cantabrian, and are thus containing an isolated brown bear population. Thus, we chose an area large enough to contain all the brown bear range and possible dispersal areas in order to be able to predict at large scale even in areas not yeat colonized by brown bears.

(add an image with script giving the image shp)

## Alps study area  

Please refer to [Andrea's GitHub page](https://github.com/andreacorra/AlpBearConnect/tree/master/variables)   



For ecological and management reasons, the study area in the Alps has been selected accroding to the following criteria:

1. An area large enough to produce biologically meaningful results (Center/Eastern Alps);
2. An area environmentally meaningful for the presence (and future expansion) of the bear (Alpine Convention area);
3. An area administratively homogeneous (Italy).
For these reasons, the area selected is the intersection between the Alpine Convetion area, and the Italian regions of Lombardia, Trentino Alto Adige, Veneto e Friuli Venezia Giulia. The generated shapefile is found here

(add an image with script giving the image shp)

A buffer of 5 km is built around the study area, in order to avoid the 'edge effect' while calculating distances from land types (i.e. human settlments just outside the study area will not be seen without a buffer). The buffer has been calcualted with the QGIS buffer function, with a buffer distance set to 5000 m.
  
# Landcover covariates

We first compute landscape rasters from which we will calculate nearest distances and proportions.
Thus, we had computed:
- [Elevation and derived terrain index](#elevation)
- [Tree Cover Density](#tree-cover-density)  
- [Bare Rocks](#bare-rocks)
- [Waterbodies](#waterbodies-and-rivers)
- [Agricultural and artificial areas](#agricultural-and-artificial-areas)
- [Grassland](#grassland)  
- [Shrubland](#shrub-and-transitional-woodland-shrub-area)  


- [Agricultural trees](#agricultural-trees)

- [Buildings](#human-buildings)
- [Roads](#roads)





- [Patch Density](#patch-density-as-a-fragmentation-index)  


## Elevation

 - Load [Copernicus DEM raster layer](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1) for E30N20. This raster is at 25m resolution
 - Resample the elevation layer at 20m resolution with the bilinear method ("Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average.") at the large study area.
 
 Slope and Ruggedness were derived from this layer thanks to the [*terrain()*](https://www.rdocumentation.org/packages/raster/versions/2.9-5/topics/terrain) function in R (with neighbors=8 for rough terrain).
 
(andrea) The elevation has been derived from the EU Digital Elevation Model. All the corresponding derived variables (slope, aspect, etc) are derived with the function terrain() in the package raster.


## Tree Cover Density 

The tree cover density (TCD) will allow us to compute nearest distance to forest. Thus, we keep attention to details for the forest areas but not for the type of forest. Thus, we exclude trees that are urban and agricultural trees, as they do not represent good quality habitat for bears as well as not a "wild" mountainous habitat.   

1. Non forest raster:  
        - From [Copernicus website](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015), download the forest additional support layer (FADSL, E30N20, 20m resolution, LAEA)and then crop and mask the raster for the large area of analysis
=> Creation of FADSL raster layer  
        - From [CorineLandCover 2012 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012), we select only vineyards ``` code_clc12 = 15 / 221 ```, and rasterize at 20m resolution to match raster layers. Then, we crop and mask this vineyard raster at the Pyrenees large area of analysis.
=> Creation of the Vineyard raster layer
        - Load FADSL and Vineyard raster layers in QGis (20m resolution, LAEA proj, large area)  
        - Combine both rasters into one binary raster layer of *non forest trees* (QGis::Raster Calculator)        
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
        - Exclude non forest trees from the TCD layer 
=> Creation of the forest raster layer


(andrea)
The forest presence in the landscape has been derived using the Copernicus forest layers (tile E40N20) and the Corine Land Cover vector data. In detail:

Tree cover density (TCD), Forest type product (FTY), and Corine Land Cover (CLC) vector layers are downloaded for the reference area;

The CLC vector is rasterized to match the Copernicus resolution (20 m);

Given the aim of the study, two layers have been derived:

Agricultural Forest Cover: Using the QGIS raster calculator, the layer is generated accounting for both orchards and olive tree as derived from the FTY layer (x = 3), and the vineyards as derived form CLC layer (x = 221):
```
CLC@1" = 221  OR "FTY@1" = 3   
```

Non-urban and non-agricultural Tree Cover Density: First, using the QGIS raster calculator and the procedure above-mentioned, a layer of all the urban and agricultural tree cover is generated. In detail, we considered in the FTY layer the orchards and olive tree (x = 3), as well as the urban trees (x = 4, 5). To account for vineyards, we included the corresponding class of CLC (x = 221). Hence, we generated the new layer (say non_forest_TCD) of urban and agricultural tree cover:
```
CLC@1" = 221  OR "FTY@1" = 3  OR "FTY@1" = 4  OR "FTY@1" = 5 
```
Using the GRASS raster calculator r.mapcalc, we 'clip' the TCD taking into account only non-urban and non-agricultural tree associations.

```
new_map = not(if(non_forest_TCD)) * TCD
```
With the following function, if non_forest_TCD is NOT 1 (i.e. 0), then it returns 1, which is then multiplied by percentage of cover. The resulting map is a Tree Cover Density (0 to 100) without non-urban and non-agricultural tree associations.


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

(andrea) add better description => So we can use mine


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

(andrea)
(add better description)

The water bodies were retrived from two different sources: EU-Hydro and Open Street Map. The first source contains the complete network of rivers and lakes for the main European watersheds (Danube, Po, etc), while the second source contains a detailed mapping of the inland water bodies (lakes). We paired the OpenStreetMap data with the EU dataset because the accurancy for the inland water body was higher. This information was thus used for retrive the water bodies distributuion in the reference area, as well as crop all the 'noise' derived from the water bodies within pastures.

Inland Water

The OSM data is downloaded (GeoJSON file);
A new column containing the value 1 (as integer) is generated for the subsequent rasterization;
The layers are merged using the 'Merge vector layers' function...
The layer is rasterized...
The generated layer is clipped by mask layer (the bufferede reference area)
Ready to go...
River_net_I 1.


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

(andrea) no description


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
 
(andrea) add better description so use this one is ok

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

## Agricultural trees
   - Load the non forest raster layer [constructed before](#non-forest-raster)  
   - Create a binar raster layer of agricultural trees by selecting only agricultural trees and vineyard in the previous raster (QGis::Raster Calculator) 
   
    ```"FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1```  
    
=> Creation of the agricultural trees raster layer

(andrea) add better description so we can use mine


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

   - Buffer the polygon of the building vector layer to ease the rasterization (GRASS::v.buffer with d=0)
   - Dissolve the polygon thanks to the NewField equal to 1 (GRASS::v.dissolve)
   - Rasterize the previous layer (dissolved buffered and merged building layer) at 20m resolution at the large study area (projection LAEA)
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


## Patch density as a fragmentation index  

To compute patch density and to ease and speed calculations of this fragmentation index, we used the [CorineLandCover raster file at 100 m resolution for 2012](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012) (as our study period is from 2010 to 2017).
The next steps are developed in the script R.

# Compute nearest distance rasters

Those kind of calculations can be done both on GIS softwares (as QGis) and R. However, the fastest computation is in QGis as it ias designed to handle spatial layers. Thus, we computed the nearest distance to feature cell with QGis (QGis::Proximity(distance raster)).    
**Compute all the distances from each centroid of cell to nearest target values cell, i.e. here compute the distance between cell value 0 to nearest cell value != 0.**    
The cells that are at 0m distance are the cells containing the feature (so the closest)!   

ok TCD ALPS / PYRENEES
ok AgriTree ALPS / PYRENEES 
ok FootTrails ALPS / PYRENEES  
ok Waterbodies ALPS / PYRENEES 
ok PavedRoads ALPS / PYRENEES
ok Track ALPS / PYRENEES  
ok Shrub ALPS / PYRENEES    
ok Building (OSM) ALPS / PYRENEES


# Compute proportion rasters

It is not fastest in R however, the computation was easiest. :)  
Please see script Proportion.R
(R::focal and R::focalWeight)

Radius define as 250m (buffer of radius 250m) to have a proportion of cell that are the feature around each focal cell (proportion of feature neighbor)
 

# Compute Brown Bear Activity Density covariate
*Brown bear activity for the complete period*
To predict at the pyrenees, we computed the mean of brown bear activity in QGis::RastorCalculator as:
```
("Raster20_buf2000_2010OursAct@1" + "Raster20_buf2000_2011OursAct_nona@1" + "Raster20_buf2000_2012OursAct@1" + "Raster20_buf2000_2013OursAct@1" + "Raster20_buf2000_2014OursAct@1" + "Raster20_buf2000_2015OursAct@1" + "Raster20_buf2000_2016OursAct@1")/7
```

# Pastoral covariates
To do the next step of modeling with the pastoral activity, we divided the number of sheep per the area of the pasture (m2) in QGis, using the field calculator for vector layer (nb ovin/ area). The area was calculated with the geometry calculation in QGis



**Some random notes**

**package(raster)**  *function distance()*  
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

*boundaries()*   
*click()* : Click on a map (plot) to get values   
*clump()* : Detect patches of connected cells   
*cv()* : Compute the coefficient of variation (expressed as a percentage)   
*density()* : Create density plots   
[*distanceFromPoints()*](https://www.rdocumentation.org/packages/raster/versions/2.1-41/topics/distanceFromPoints)     
*canProcessInMemory()*     
*resample()* : Before using resample, you may want to consider using these other functions instead: aggregate, disaggregate, crop, extend, merge.   
*buffer()*  
*focal()*   

**package(proxy)** [*function dist()*](https://www.rdocumentation.org/packages/proxy/versions/0.4-22/topics/dist)

**package(regos)** [*function gDistance()*](https://www.rdocumentation.org/packages/rgeos/versions/0.4-2/topics/gDistance)  
Code example:  
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
 
**package(spdep)** [*function dnearneigh()*](https://www.rdocumentation.org/packages/spdep/versions/0.8-1/topics/dnearneigh)

**package(geosphere)** [*dist2Line()*](https://www.rdocumentation.org/packages/geosphere/versions/1.5-5/topics/dist2Line)









