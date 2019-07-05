This repository contains workflow and R codes to compute variables for depredation factor analysis between France and Italy.

* [Study area](#Study-area)
* [Landcover variables](#LandCover-covariates)
* [Grassland landcover type](#Grassland-LANDCOVER-TYPE-SPECIFICATION) 

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
- [Buildings](#human-buildings-from-national-cadastre)
- [Roads](#roads)
- [Waterbodies](#waterbodies-and-waters)
- [Bare Rocks](#bare-rocks-land-cover)
- [Agricultural and artificial areas](#agriculture-and-artificial-areas)
- [Grassland](#grassland-landcover-type-specification)  
- [Shrubland](#shrub-and-transitional-woodland-shrub-area)  

## Tree Cover Density 

The tree cover density (TCD) will allow us to compute nearest distance to forest. Thus, we keep attention to details for the forest areas but not for the type of forest. Thus, we exclude trees that are urban and agricultural trees, as they do not represent good quality habitat for bears as well as not a "wild" mountainous habitat.   

1. Non forest raster:  
        - From [Copernicus website](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015), download the forest additional support layer (FADSL, E30N20, 20m resolution, LAEA)and then crop and mask the raster for the large area of analysis
=> Creation of FADSL raster layer  
        - From [CorineLandCover 2012 shapefile](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012), we select only vineyards ``` code_clc12 = 15 / 221 ```, and rasterize at 20m resolution to match raster layers. Then, we crop and mask this vineyard raster at the Pyrenees large area of analysis.
=> Creation of the Vineyard raster layer
        - Load FADSL and Vineyard raster layers in QGis (20m resolution, LAEA proj, large area)  
        - Combine both rasters into one binary raster layer  of non(QGis::Raster Calculator) 
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

## Agricultural trees
   - Load the non forest raster layer [constructed before](#non-forest-raster)  
   - Create a binar raster layer of agricultural trees by selecting only agricultural trees and vineyard in the previous raster (QGis::Raster Calculator) 
   
    ```"FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1```  
    
=> Creation of the agricultural trees raster layer

## Elevation
 - Load [Copernicus DEM raster layer](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1) for E30N20. This raster is at 25m resolution
 - Resample the elevation layer at 20m resolution with the bilinear method ("Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average.") at the large study area.
 
 Slope and Ruggedness were derived from this layer thanks to the [*terrain()*](https://www.rdocumentation.org/packages/raster/versions/2.9-5/topics/terrain) function in R.
  

## Shrub and transitional woodland-shrub area  

    1. Get CorineLandCover 2012 shapefile [CLC SHP](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012)
    2. Select only Shrub category (322, 323, 324 / code for transitional areas) in shapefile in QGis
     ```
     "code_12"  = '324' OR
     "code_12"  = '323' OR
     "code_12" ='322'
     ```
    clc12_shrub.shp
    
   3. Rasterize the shapefile at 20m resolution (QGis gdal::rasterize, EPSG+3035/ETRS LAEA)
   4. Cut the raster to the extent of raster_base (please see script [Shrub.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/Shrub.R)
   5. Put right number 0/1 for non shrub/shrub into the raster (please see script [Shrub.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/Shrub.R)
   6. Exclude forest (TCD) from the shrub raster (please see script [Shrub.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/Shrub.R) to create the transitional area 
   7. And exclude grassland cut true to create true transitional area (once the grassland layer is done, please see [Shrub.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/Shrub.R)

4. **ELEVATION**
    1. Get Copernicus raster for E30N20 (PYR)  [Copernicus raster](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1)
    It is at 25x25m resolution
    It is the only one raster with a lower resolution so we are going to downscale the resolution to 20x20m
    
    2. Resample at the large area of analysis (raster_base) at 20m resolution please see script Elevation.R  
    Resample with bilinear method :  
    "Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average."
  
5. **HUMAN BUILDINGS FROM NATIONAL CADASTRE**

This comes from Open Street Map data which uses the national cadastre.
    1. From [overpass turbo](https://overpass-turbo.eu/) and frome the [code information](https://wiki.openstreetmap.org/wiki/Key:highway), for the Pyrenees we extract the buildings both on the French and the Spanish parts.
     * extract from open street map building = yes

```
/*
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
    
   2. In Qgis, we combine all the parts of JGson layers for the buildings data
    * create a unique field of 1 in each vector layer (QGis::Field Calculator)
    * suppress all the other field for each vector layer (attribute table)
    * Reproject in LAEA CRS (EPSG+3035) (QGis::Reproject layer)
    * merge the vector layers (SAGA::MergeVectorLayers)
    * Extract this shapefile and save it as LAEA projection

   3. In Qgis, we then create a raster layer for the builings
    * Create a buffer around each polygon in order to have them rasterized (GRASS::v.buffer)
    * rasterize the merged vector layer at 20m resolution over large Pyrenees area (raster_base.tif) (GRASS::v.to.rast)    

This data is from the French cadastre. Thus, there is less problems than with the [ESM raster from Copernicus](https://land.copernicus.eu/pan-european/GHSL/european-settlement-map/esm-2012-release-2017-urban-green) (true buildings) but there are still somes discrepancies. However, it is better to use this one!
Another check with openstreet map after rasterizing was done.

6. **ROADS**
    1. From [overpass turbo](https://overpass-turbo.eu/) and from the [code information](https://wiki.openstreetmap.org/wiki/Key:highway), for the Pyrenees we extract : 
                            * footway, path, 
                            * track,
                            * motorway, trunk, primary, secondary, tertiary, unclassified, road  
     ```
    /*
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
    out skel qt;
    ```
     2. Quick visualization to see each category (in QGis).    
     If anything is missing reload from overpass turbo
     3. Reprojection in LAEA
        * load geoJSON files in QGis
        * create a new field with "1" in it (field calculator)
        * suppress field columns (too much too heavy) from attribute table/editor 
        
     4. Merge the data into a shapefile per categories (SAGA::MergeVectorLayers)  
     track: roads for mostly agricultural use, forest tracks etc.; usually unpaved (unsealed) but may apply to paved tracks as well, that are suitable for two-track vehicles, such as tractors or jeeps. from:https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtrack  
     
     path: multi-use or unspecified usage, open to all non-motorized vehicles and not intended for motorized vehicles unless tagged so separately. The path may have any type of surface. This includes walking and hiking trails, bike trails and paths, horse and stock trails, mountain bike trails as well as combinations of the above.https://wiki.openstreetmap.org/wiki/Tag:highway%3Dpath  
     
     footway: minor pathways which are used mainly or exclusively by pedestrians. https://wiki.openstreetmap.org/wiki/Tag:highway%3Dfootway    
     
     road: tag is used for a road/way/path/street/alley/motorway/etc. with an unknown classification. https://wiki.openstreetmap.org/wiki/Tag:highway%3Droad  
     From visualization in our area (PYR) it is only restricted to urban areas.     
       
     unclassified: The least important through roads in a country's system – i.e. minor roads of a lower classification than tertiary, but which serve a purpose other than access to properties. (Often link villages and hamlets). used for minor public roads typically at the lowest level of the interconnecting grid network. Unclassified roads have lower importance in the road network than tertiary roads, and are not residential streets or agricultural tracks. https://wiki.openstreetmap.org/wiki/Tag:highway%3Dunclassified    
       
     motorway: A restricted access major divided highway, normally with 2 or more running lanes plus emergency hard shoulder. used only on ways, to identify the highest-performance roads within a territory.https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway    
       
     trunk: The most important roads in a country's system that aren't motorways. (Need not necessarily be a divided highway.  high performance or high importance roads that don't meet the requirement for motorway. In different countries, either performance or importance is used as the defining criterion for trunk. https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtrunk   
     
     primary: The next most important roads in a country's system. (Often link larger towns.A major highway linking large towns, in developed countries normally with 2 lanes. In areas with worse infrastructure road quality may be far worse. The traffic for both directions is usually not separated by a central barrier.https://wiki.openstreetmap.org/wiki/Tag:highway%3Dprimary    
     
     secondary: The next most important roads in a country's system. (Often link town). A highway which is not part of a major route, but nevertheless forming a link in the national route network.https://wiki.openstreetmap.org/wiki/Tag:highway%3Dsecondary  
     
     tertiary: The next most important roads in a country's system. (Often link smaller towns and villages). used for roads connecting smaller settlements, and within large settlements for roads connecting local centres. In terms of the transportation network, OpenStreetMap "tertiary" roads commonly also connect minor streets to more major roads. https://wiki.openstreetmap.org/wiki/Tag:highway%3Dtertiary    
     
     5. Merge per field  (MergeVectorLayers)
                                        * 1:paved and unpaved roads, == motorway, trunk, primary, secondary, tertiary, unclassified, road,track 
                                        * 2:foot trails, == path, footway
     
     6. We rasterize because shapefiles are very heavy and caluclations in R are too much to handle (20x20m, LAEA) (GRASS::v.to.rast.value) for the raster_base extent.
                                        * 1: Roads (paved and unpaved)
                                        * 2: FootTrails
Remark: roads can be in grassland. That is okay. I can be in grassland and have a distance = 0 to a foot trail for example because it crosses the area.
    
7. **WATERBODIES AND WATERS**
    1. From [Copernicus](https://land.copernicus.eu/pan-european/high-resolution-layers/water-wetness/status-maps/2015)    
    
      1. Load the ".gdb" folder for Garonne, Ebro, and Rhone into QGis
      2. Select only InlandWater, River_Net_I
      3. Calculate a new field (QGis::field calculator) for each vector layers
      4. Suppress fields unecessary for each vector layers
      5. Merge InlandWater for the 3 areas (QGis::Merge vector layers)
      => Rasterize this shapefile at 20m for large area Pyrenees (GRASS::v.to.rast.value)
      6. Merge River_Net for the 3 areas (QGis::Merge vector layers)
      => Rasterize this shapefile at 20m for large area Pyrenees (GRAS::v.to.rast.value)
      
    2. From [OpenStreet Map data](https://overpass-turbo.eu/)    
      1. We extracted [natural=water](https://wiki.openstreetmap.org/wiki/Tag:natural%3Dwater)  
            
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
      2. Load it in QGis and Create a new field in the data with only number 1 (Qgis::field calculator)
      3. Suppress field columns not needed (attribute table)
      4. Reproject in LAEA CRS (EPSG+3035) (QGis::Reproject layer)
      5. Rasterize at 20m resolution over large area Pyrenees (raster_base.tif) (GRASS::v.to.rast.value)
    
     3. Merge the rasters of **INLAND WATER** from *Copernicus* (InlandWater) and *Openstreet map data* (GRASS::r.patch)
     *this raster will be used to clip the grassland raster*
     4. Merge rasters of **INLAND WATERS** AND **RIVERS** == raster of waterbodies total 
        and crop it at the pyrenees 20m large area (raster_base)
        (GRASS::r.patch)
     
 **Waterbodies020m_largePYR.tif (combine inland waters and rivers net from both copernicus shapefile EU-Hydro and Open Street Map data for lakes because of more detailed data)**
     
8. **GRASSLAND LANDCOVER TYPE SPECIFICATION** 
**Grassland = CLC(231,321,333) + copernicus(grassland) - Barerocks - waterbodies - artificial and agricultural areas (CLCartiandagri -231 - 221 -222) - TCDcut**

   1. Compute Grassland cover from Shapefile of CLC and Copernicus
 
    1. From CLC 12 shapefile :  
    Select only Grassland category (231 pastures, 321 natural grasslands, 333 semi open areas) in shapefile in QGis
     ```
    "code_12"  = '231' OR
    "code_12"  = '321' OR
    "code_12" ='333'
     ```
    2. Rasterize the shapefile at 20m resolution and clip it for PYR large area (raster_base.tif) (GRASS::v.to.rast.value, EPSG+3035/ETRS LAEA)  
  
    3. Add to QGis the raster at 20m of Grassland from [Copernicus](https://land.copernicus.eu/pan-european/high-resolution-layers/grassland/status-maps)  
    
    4. Merge the 2 rasters of grassland **RASTER GRASSLAND CLC (231,321,333) AND COPERNICUS** (GRASS::r.patch)  
    
=> Grasslandtot_largePYR.tif

   2. **Bare rocks land cover**
        * From https://overpass-turbo.eu/   
        we extracted data for bbox ~ our study area (the bbox is defined on the website by the map you chose to see)   

        definition from https://wiki.openstreetmap.org/wiki/Tag%3Anatural%3Dbare_rock
        bare_rock
        scree  
        glacier

    and also extracted cliff, stone, rock to see (quick visual exploration) if it is of any importance.  
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

    Visulization:     
    IN ITALY  

   stone is not used because screen contains it,     
   rock is not used either because it is not the type of rocks we are looking for, i.e. bare rocks on top of mountains, rather          than those are in forest area  
    cliff could be used because it adds to screen areas.  
  
   IN FRANCE  
   cliff cannot be used as it is only line material  
   rocks not used eaither  
   stone not used either  

   Check for overlapping the downloaded files (in order to have all the rocks) because it is heavy on mozilla so I had to cut for 3 areas (North, middle, South for the ALps and North SOuth for the Pyrenees)  
   Check overlap ALP OK  
   Check overlap PYR OK  

   * Quick visualization to see each category (in QGis) so **bare_rock, screen, glacier and rock**     
     If anything is missing reload from overpass turbo
     
   * Reprojection in LAEA (QGis::Reproject layer)
        * load geoJSON files in QGis
        * create a new field with "1" in it (field calculator)
        * suppress field columns (too much too heavy) from attribute table/editor 
        
   * Merge all the vectors into 1 raster layer 20m for large area PYRENEES (QGis::Merge vector layers)
   * Rasterize at 20m resolution over large area Pyrenees (raster_base.tif) (GRASS::v.to.rast.value)


   3. **INLAND waterbodies raster**
    Use InlandWater_PYR_LAEA_20.tif (created for waterbodies variable) [WATERBODIES AND WATERS](6.Waterbodies and waters)  
    
   4. **Clip grassland with inland waterbodies and bare_rock**
please see script 6 Grassland.R

=> Grasslandcut_largePYR.tif
    
   5. **AGRICULTURE AND ARTIFICIAL AREAS**

After having visualize the ESM map with all the other layers (mostly grassland, shrub, tcd, roads), we realize there were some areas that were not defined well in comparison with the satellite picture.  

As such, near villages, some agricltural lands were defined as grassland with our Grasslandcut. However, in CLC12 those were defined as agricultural and/or artificial areas. And those areas are not in moutainous areas.

Thus, in order to produce a map of grassland with the less noise possible. We decided to rerasterize the agricultural and artificial areas of CLC12 at 20m to exclude them from the grassland. However, it would not have been a problem for modeling, it could have increased the noise for prediction!  

  * Select for agricultural and artificial areas in CLC12 shapefile in the large Pyrenees area  (of course vineyards, fruit trees and pastures have been excluded from this selection)
    
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
   * Rasterize this selection at 20m resolution on the pyrenees large area (raster_base) (GRASS:v.to.rast.value)
   * Exclude those areas from grassland cut (please see script grassland)
             
=> GrasslandcutT_largePYR.tif

   6. Clip grassland with TCD cut  

From visualization in QGis, some TCD >50% were inside grassland areas. In order to compute a grassland that represents very open areas I decided to cut exclude cells that are TCD>0 from grassland layer.  
As such, with the final layer of grassland proportion, those areas inside a grassland but with tcd>0 would be represented as a high proportion of grassland but with a very little distance to forest. It should be particular areas as it represent areas where domestic animals can graze but where there is some trees, thus making areas where probability of attacks could be high.  
Please see script [Grassland.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/Grassland.R)

9. **PATCH DENSITY as a fragmentation index**  

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
