This repository contains workflow and R codes to compute variables for depredation factor analysis between France and Italy.

* [Study area](#study-area)
* [Landcover variables](#LandCover-variables-computed-for-analysis)
* [Grassland landcover type](#Grassland-LANDCOVER-TYPE-SPECIFICATION) 

## STUDY AREA


## LandCover variables computed for analysis

1. **TREE COVER DENSITY**
    1. From Copernicus download E30N20 raster for TCD at 20m resolution (2015)  
    please see the [Copernicus website](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-density/status-maps/2015)

    2. Reduce raster (crop and mask) to the large area of analysis (raster_base.tif)   
    to see how raster_base is created please refer to [STUDY AREA](#study_area) 
    and for reducing the raster please see part I of the script [TCD.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/TCD.R)
    
    3. *Create raster of non tcd* :   
        From Copernicus download E30N20 raster for FADSL at 20m resolution (2015)  
        please see the [Copernicus website](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015)  
        Create raster (crop and mask) for the large area of analysis (raster_base.tif) please see part II of script TCD.R  
        This is all trees that are non forest (urban and agricultural trees such as fruit trees)  
        
        But there is also vineyard that are not taken into account into FADSL (from quick visualization exploration)   
        Then get CorineLandCover 2012 shapefile [CLC SHP](https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012)  
        In QGis, select only vineyards (code_clc12 = 15 / 221),  
        rasterize at 20m resolution to match FADSL layer   
        then crop and mask at the Pyrenees large area of analysis (please see part II of script [TCD.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/TCD.R))
        
        Then in QGis,   
        A) load both raster layers FADSL and Vineyards (20m resolution, at Pyrenees large area)  
        B) create a new raster 0/1 from the combination of those two rasters in rastor calculator (20m resolution, at Pyrenees large area, proj = +proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs)  
        ```
        "FASDL_maskrasterbase@1"  = 3  OR 
        "FASDL_maskrasterbase@1"  = 4  OR 
        "FASDL_maskrasterbase@1"  = 5 OR 
        "vine_maskrasterbase@1" = 1
        ```
        
    4. Exclude non forest trees from the TCD layer please see part II of script [TCD.R](https://github.com/AdrienneGast/BearDepredation/blob/master/FR-IT/TCD.R)

TCDtrue_largePYR.tif

2. **AGRICULTURAL TREES**

    1. Get raster of FADSL at large Pyrenees and Vineyards at large Pyrenees
    2. In QGis, create raster from raster calculation with 0/1 for only FASDL(code 3 agricultural trees) and vineyard (which is CLC(15) constructed before see non tcd raster before)
   ```
    "FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1
    ```
    => It brings fruit trees and vineyards (as agricultural trees) as one raster 0/1

AgriTree_largePYR.tif

3. **SHRUB OR TRANSITIONAL WOODLAND-SHRUB AREA**

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

## SELECTION OF PRESENCES

**As 99% of attacks happen on sheep, our presence occurence data set contains only attacks on sheep by brown bear. (n=).**
Moreover, attacks information (such as GPS location, municipality, species, pastoral units...) will be extracted to explore the data set.

```
> datashp@data %>% group_by(libelle__1) %>% summarize(count=n())
# A tibble: 4 x 2
  libelle__1 count
  <fct>      <int>
1 Bovins         2
2 Caprins        1
3 Equins         1
4 Ovins        762
```


## SELECTION OF ABSENCES (script 17)

1. To select for absences, we chose to randomly take points inside a specific annual area.
This specific area is the annual area of presence of brown bear combined with the presence area of sheep

**First step** select for pastoral units inside brown bear annual presence area (every year) (script create pastoral data)
```
> nbestive
 [1]    0    0    0    0    0    0    0   NA   NA   NA   NA   NA   NA   NA   NA   NA
[17]   NA   NA   NA   NA   NA   NA   NA 1269 1119  844 1123 1029 1055 1908
```
**Second step** Select for annual data (script create pastoral data)
```
> nbestive_v1
                                   2010 2011 2012 2013 2014 2015 2016 
   0    0    0    0    0    0    0  148  134   94  143  131  127  255 
```

**Third step** select only patoral units containing domestic animals (script create pastoral data)
```
> nbestive_v2
                                   2010 2011 2012 2013 2014 2015 2016 
   0    0    0    0    0    0    0  144  129   93  139  127  122  245 
```
**Fourth step** we make the presence data points +/- 1367m (all data on domestic animals not only sheep) buffer with the presence area pastures containing domestic animals (we did not chose only for those containing sheep!!) (script 17)

## CREATING DATA FRAME FOR ANALYSIS

**1** we extract (st_join) the pastoral data information for each attacks using shapefiles and attacks information (no need to rasterize pastoral data) (script 17)
**2** we extract for each point environmental data (per annual attack data) (script 18)
**3** we extract for each point per year bear density activity per annual attack data (script 18)
**4** we make only one data frame considering all of this information (script 18)

2. To select for absences, we take presence of brown bear's attacks buffered (1367m) randomly inside a square in Central Pyrenees (not only inside brown bear presence and sheep presence  
(here the random effect Pastures name will not be taken into account)

## EXPLORE DATA
*explore environmental data*  
See script 19

*how many times attacks happen in unguarded pastures : 
```
tab2%>%group_by(Occurence,nbGard)%>%summarise(compteur=n())
# A tibble: 11 x 3
# Groups:   Occurence [2]
   Occurence nbGard compteur
   <fct>      <int>    <int>
 1 0              0      204
 2 0              1      202
 3 0              2       79
 4 0              3       28
 5 0              4        6
 6 0              5        3
 7 1              0       17
 8 1              1      356
 9 1              2      100
10 1              3       37
11 1              4       12
```

## ENVIRONMENTAL DREDGE

# For **pseudo-absences** selection :

if threshold for multicolinearity at r>0.6, we do not have to exclude pairs of variables from the same models. Actually, only ruggedness and slope are correlated at 0.98. Thus, based on several references on brown bear habitat use, we chose to display model selection only with the ruggedness. Moreover, the elevation was also removed from model selection as it is inherent part of our biologic models.  

1. Chose for random effect: we have an annual response variable thus we have the Year as random factor
```
> r.squaredGLMM(mran)
     R2m          R2c
[1,]   0 2.003815e-10
```  
2. Complete model 

```
> summary(MCenvtri)
 Family: binomial  ( logit )
Formula:          
Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + tri.std +  
    grass.std + ndwater.std + BA.std + patchdens.std + I(patchdens.std^2) +  
    ndtcd.std + I(ndtcd.std^2) + ndshrub.std + ndagri.std + (1 |      Annee)
Data: tab2

     AIC      BIC   logLik deviance df.resid 
   331.6    405.8   -150.8    301.6     1029 

Random effects:

Conditional model:
 Groups Name        Variance Std.Dev.
 Annee  (Intercept) 0.48     0.6928  
Number of obs: 1044, groups:  Annee, 7

Conditional model:
                    Estimate Std. Error z value Pr(>|z|)    
(Intercept)         -1.63329    0.52699  -3.099 0.001940 ** 
ndRoads.std          1.24754    0.43384   2.876 0.004033 ** 
ndbuild.std         -2.00060    0.75937  -2.635 0.008425 ** 
ndfoot.std          -2.44726    0.66718  -3.668 0.000244 ***
tri.std              0.03567    0.36935   0.097 0.923054    
grass.std            3.44886    0.41940   8.223  < 2e-16 ***
ndwater.std          0.13345    0.38372   0.348 0.728014    
BA.std               2.27892    0.66980   3.402 0.000668 ***
patchdens.std      -12.80946    2.83937  -4.511 6.44e-06 ***
I(patchdens.std^2) -24.83493    5.53679  -4.485 7.28e-06 ***
ndtcd.std            1.66930    0.54286   3.075 0.002105 ** 
I(ndtcd.std^2)      -1.04608    0.43225  -2.420 0.015518 *  
ndshrub.std          1.07632    0.62974   1.709 0.087422 .  
ndagri.std           5.11434    0.75105   6.810 9.79e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```  
3. Dredge  
the 13 first models are in a delta AICc <=2

4. Averaging on those 13 first models

5. Cheking model's assumption (spatial correlation) with bubble plot, corrplot and global moran's I on both full model and best model of dredge
Full model :
```
> tab <- tab2
> coordinates(tab) <- ~ X + Y
> xy <- coordinates(tab)
> tab2.nb <- dnearneigh(xy,0, 1367)
> tab2.listw <- nb2listw(tab2.nb,style='B',zero.policy=TRUE)
> tes.mor <- moran.test(residuals(MCenvtri,type="response"),listw=tab2.listw,randomisation=T,zero.policy = TRUE)
> tes.mor

	Moran I test under randomisation

data:  residuals(MCenvtri, type = "response")  
weights: tab2.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.3508, p-value = 9.853e-14
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
     0.0742726570     -0.0016638935      0.0001067176 
```  
Best model :
``` 
> tes.mor

	Moran I test under randomisation

data:  residuals(best.mod, type = "response")  
weights: tab2.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.0052, p-value = 1.233e-12
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
      0.070734485      -0.001663894       0.000106812 
 ```  
 
    
     

# For **true absences** selection :   

if threshold for multicolinearity at r>0.6, we do not have to exclude pairs of variables from the same models. Actually, only ruggedness and slope are correlated at 0.98. Thus, based on several references on brown bear habitat use, we chose to display model selection only with the ruggedness. Moreover, the elevation was also removed from model selection as it is inherent part of our biologic models.  

1. Chose for random effect: we have an annual response variable thus we have the Year as random factor but also attacks happen in pastures that possess particular characteristics thus we also have the PasturesID as random factor.  
```
mran.complet <- glmmTMB(Occurence ~ 1 + (1|Annee) + (1|Nom_Estive),data=tab2,family=binomial,REML=T)
summary(mran.complet)
mran.year <- glmmTMB(Occurence ~ 1 + (1|Annee),data=tab2,family=binomial,REML=T)
summary(mran.year)
mran.past <- glmmTMB(Occurence ~ 1 + (1|Nom_Estive),data=tab2,family=binomial,REML=T)
summary(mran.past)
```

```
> AIC(mran.complet)
[1] 707.2745
> AIC(mran.year)
[1] 1455.018
> AIC(mran.past)
[1] 706.4264
```

Delta AIC between mran.complet and mran.past is less than 1. Thus, choosing for the biological random effects is okay (year and pastures' ID).  
However, I would like to point out that 
```
> r.squaredGLMM(mran.past)
            R2m       R2c
theoretical   0 0.8361185
```  
It means that this random factor of pastures ID captures a lot of the pattern of the response variable... (spatial correlation).


2. Thus, the **complete model** for environment selection is: 

```
> summary(MCenvtri)
 Family: binomial  ( logit )
Formula:          
Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + tri.std +  
    grass.std + ndwater.std + BA.std + patchdens.std + I(patchdens.std^2) +  
    ndtcd.std + I(ndtcd.std^2) + ndshrub.std + ndagri.std + (1 |  
    Annee) + (1 | Nom_Estive)
Data: tab2

     AIC      BIC   logLik deviance df.resid 
   560.7    639.9   -264.4    528.7     1028 

Random effects:

Conditional model:
 Groups     Name        Variance  Std.Dev. 
 Annee      (Intercept) 5.885e-09 7.672e-05
 Nom_Estive (Intercept) 4.846e+01 6.961e+00
Number of obs: 1044, groups:  Annee, 7; Nom_Estive, 72

Conditional model:
                   Estimate Std. Error z value Pr(>|z|)    
(Intercept)        -5.78462    2.14019  -2.703  0.00687 ** 
ndRoads.std         0.05308    0.46642   0.114  0.90939    
ndbuild.std        -0.65539    0.41558  -1.577  0.11479    
ndfoot.std         -1.56323    0.39169  -3.991 6.58e-05 ***
tri.std            -0.52953    0.26340  -2.010  0.04439 *  
grass.std           2.27924    0.33265   6.852 7.30e-12 ***
ndwater.std         0.52483    0.33632   1.560  0.11864    
BA.std              0.46140    0.24820   1.859  0.06303 .  
patchdens.std      -0.08546    0.83484  -0.102  0.91847    
I(patchdens.std^2) -1.76168    1.45502  -1.211  0.22599    
ndtcd.std           1.59548    0.63091   2.529  0.01144 *  
I(ndtcd.std^2)     -1.01580    0.53534  -1.897  0.05777 .  
ndshrub.std         0.87650    0.39254   2.233  0.02556 *  
ndagri.std          0.36033    0.95621   0.377  0.70630    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

> r.squaredGLMM(MCenvtri)
                     R2m          R2c
theoretical 9.820576e-02 9.426671e-01
```
3. Dredge  
We computed the dredge on the complete model's formula. And we gave the specific information of quadratic relationships in the subset.
We select for averaging the 16 first models as they have a delta AICc<=2 with the best model (smallest AICc).

```
MSenvtriTrueA0.6[c(1:16)]
Global model call: glmmTMB(formula = Occurence ~ ndRoads.std + ndbuild.std + ndfoot.std + 
    tri.std + grass.std + ndwater.std + BA.std + patchdens.std + 
    I(patchdens.std^2) + ndtcd.std + I(ndtcd.std^2) + ndshrub.std + 
    ndagri.std + (1 | Annee) + (1 | Nom_Estive), data = tab2, 
    family = binomial, REML = F, ziformula = ~0, dispformula = ~1)
---
Model selection table 
     cnd((Int)) dsp((Int)) cnd(BA.std) cnd(grs.std) cnd(ndb.std) cnd(ndf.std) cnd(ndR.std) cnd(nds.std) cnd(ndt.std)
4563     -7.312          +      0.4830        2.250                    -1.541                    0.9102       1.5430
4571     -7.267          +      0.4663        2.287      -0.5443       -1.488                    0.8140       1.7540
5083     -7.479          +      0.5036        2.293      -0.5932       -1.577                    0.8614       1.7020
5075     -7.511          +      0.5163        2.251                    -1.628                    0.9602       1.4830
5587     -7.080          +      0.4809        2.278                    -1.526                    0.8941       1.4740
5595     -7.015          +      0.4629        2.316      -0.5626       -1.467                    0.7932       1.6870
6107     -7.235          +      0.4989        2.319      -0.6114       -1.554                    0.8356       1.6380
4570     -7.338          +                    2.212      -0.5727       -1.480                    0.8541       1.6440
8155     -5.855          +      0.4684        2.299      -0.6462       -1.540                    0.8651       1.6590
4562     -7.385          +                    2.173                    -1.535                    0.9532       1.4190
475      -7.135          +      0.4565        2.326      -0.6255       -1.567                    0.7835       1.8140
4819     -7.735          +      0.4886        2.486                    -1.592                    0.9387       0.7417
6099     -7.285          +      0.5129        2.276                    -1.610                    0.9401       1.4180
4307     -7.535          +      0.4498        2.502                    -1.497                    0.8856       0.7644
7643     -5.724          +      0.4314        2.298      -0.5871       -1.446                    0.8128       1.7130
4595     -7.350          +      0.4857        2.266                    -1.525      -0.1409       0.8892       1.6560
     cnd(I(ndt.std^2)) cnd(ndw.std) cnd(ptc.std) cnd(I(ptc.std^2)) cnd(tri.std) df   logLik  AICc weight
4563           -0.9849                                                  -0.5217 10 -267.763 555.7  0.111
4571           -1.1110                                                  -0.4833 11 -266.814 555.9  0.104
5083           -1.0540       0.4666                                     -0.5140 12 -265.811 555.9  0.102
5075           -0.9254       0.4202                                     -0.5540 11 -266.939 556.1  0.091
5587           -0.9582                  -0.57100                        -0.5367 11 -267.406 557.1  0.057
5595           -1.0890                  -0.61220                        -0.4985 12 -266.393 557.1  0.057
6107           -1.0330       0.4573     -0.58230                        -0.5275 13 -265.436 557.2  0.053
4570           -1.0540                                                  -0.4796 10 -268.518 557.2  0.052
8155           -1.0340       0.5056     -0.07998            -1.780      -0.5202 14 -264.446 557.3  0.051
4562           -0.9213                                                  -0.5198  9 -269.579 557.3  0.050
475            -1.1220                                                          10 -268.568 557.3  0.050
4819                         0.4681                                     -0.5524 10 -268.652 557.5  0.046
6099           -0.9008       0.4088     -0.53500                        -0.5670 12 -266.631 557.6  0.045
4307                                                                    -0.5160  9 -269.696 557.6  0.045
7643           -1.0960                  -0.16300            -1.486      -0.4880 13 -265.622 557.6  0.044
4595           -1.0160                                                  -0.5217 11 -267.713 557.7  0.042
Models ranked by AICc(x) 
Random terms (all models): 
‘cond(1 | Annee)’, ‘cond(1 | Nom_Estive)’
```

4. Averaging on the 16 first models (delta AICc <= 2) :   
```
Model-averaged coefficients:  
(full average) 
                          Estimate Std. Error Adjusted SE z value Pr(>|z|)    
cond((Int))              -7.189840   1.684295    1.686109   4.264 2.01e-05 ***
cond(BA.std)              0.432307   0.275693    0.275924   1.567   0.1172    
cond(grass.std)           2.293886   0.329739    0.330107   6.949  < 2e-16 ***
cond(ndfoot.std)         -1.539105   0.381305    0.381744   4.032 5.54e-05 ***
cond(ndshrub.std)         0.875314   0.384690    0.385132   2.273   0.0230 *  
cond(ndtcd.std)           1.538450   0.584083    0.584619   2.632   0.0085 ** 
cond(I(ndtcd.std^2))     -0.929565   0.580988    0.581487   1.599   0.1099    
cond(tri.std)            -0.493070   0.277855    0.278124   1.773   0.0763 .  
cond(ndbuild.std)        -0.300923   0.409013    0.409244   0.735   0.4621    
cond(ndwater.std)         0.175585   0.302384    0.302548   0.580   0.5617    
cond(patchdens.std)      -0.133530   0.467323    0.467736   0.285   0.7753    
cond(I(patchdens.std^2)) -0.156302   0.650650    0.650991   0.240   0.8103    
cond(ndRoads.std)        -0.005947   0.095158    0.095260   0.062   0.9502    
 
(conditional average) 
                         Estimate Std. Error Adjusted SE z value Pr(>|z|)    
cond((Int))               -7.1898     1.6843      1.6861   4.264 2.01e-05 ***
cond(BA.std)               0.4817     0.2468      0.2470   1.950   0.0512 .  
cond(grass.std)            2.2939     0.3297      0.3301   6.949  < 2e-16 ***
cond(ndfoot.std)          -1.5391     0.3813      0.3817   4.032 5.54e-05 ***
cond(ndshrub.std)          0.8753     0.3847      0.3851   2.273   0.0230 *  
cond(ndtcd.std)            1.5385     0.5841      0.5846   2.632   0.0085 ** 
cond(I(ndtcd.std^2))      -1.0221     0.5259      0.5265   1.941   0.0522 .  
cond(tri.std)             -0.5189     0.2605      0.2608   1.990   0.0466 *  
cond(ndbuild.std)         -0.5876     0.3978      0.3982   1.476   0.1401    
cond(ndwater.std)          0.4530     0.3320      0.3324   1.363   0.1729    
cond(patchdens.std)       -0.4351     0.7618      0.7627   0.570   0.5683    
cond(I(patchdens.std^2))  -1.6437     1.4167      1.4184   1.159   0.2465    
cond(ndRoads.std)         -0.1409     0.4422      0.4427   0.318   0.7503    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Relative variable importance: 
                     cond(grass.std) cond(ndfoot.std) cond(ndshrub.std) cond(ndtcd.std) cond(tri.std)
Importance:          1.00            1.00             1.00              1.00            0.95         
N containing models:   16              16               16                16              15         
                     cond(I(ndtcd.std^2)) cond(BA.std) cond(ndbuild.std) cond(ndwater.std) cond(patchdens.std)
Importance:          0.91                 0.90         0.51              0.39              0.31               
N containing models:   14                   14            8                 6                 6               
                     cond(I(patchdens.std^2)) cond(ndRoads.std)
Importance:          0.10                     0.04             
N containing models:    2                        1  
```

5. Checking model assumptions with bubble plot and correlogram and moran's I test on the full model and best model : 
For full model : 
```
> tes.mor

	Moran I test under randomisation

data:  res.mod  
weights: tabV.listw  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 7.3251, p-value = 1.193e-13
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
     7.207171e-02     -1.059322e-03      9.967218e-05 
``` 



*Brown bear activity for the complete period*
To predict at the pyrenees, we computed the mean of brown bear activity in QGis::RastorCalculator as:
```
("Raster20_buf2000_2010OursAct@1" + "Raster20_buf2000_2011OursAct_nona@1" + "Raster20_buf2000_2012OursAct@1" + "Raster20_buf2000_2013OursAct@1" + "Raster20_buf2000_2014OursAct@1" + "Raster20_buf2000_2015OursAct@1" + "Raster20_buf2000_2016OursAct@1")/7
```


To do the next step of modeling with the pastoral activity, we divided the number of sheep per the area of the pasture (m2) in QGis, using the field calculator for vector layer (nb ovin/ area). The area was calculated with the geometry calculation in QGis
