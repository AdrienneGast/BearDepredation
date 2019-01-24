This repository contains workflow and R codes to compute variables for depredation factor analysis between France and Italy.

## STUDY AREA


## LandCover variables computed for analysis

1. **TREE COVER DENSITY**
    1. From Copernicus download E30N20 raster for TCD at 20m resolution (2015)  
    https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-density/status-maps/2015

    2. Reduce raster (crop and mask) to the large area of analysis (raster_base.tif)   
    to see how raster_base is created please refer to [STUDY AREA](#Study_area)  
    and for reducing the raster please see part I of script R TCD.R
    
    3. *Create raster of non tcd* :   
        From Copernicus download E30N20 raster for FADSL at 20m resolution (2015)  
        https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015  
        Create raster (crop and mask) for the large area of analysis (raster_base.tif) please see part II of script TCD.R  
        This is all trees that are non forest (urban and agricultural trees such as fruit trees)  
        
        But there is also vineyard that are not taken into account into FADSL (from quick visualization exploration) 
        Then get CorineLandCover 2012 shapefile https://land.copernicus.eu/pan-european/corine-land-cover/clc-2012
        In QGis, select only vineyards (code_clc12 = 15 / 221), rasterize at 20m resolution to match FADSL layer then crop and mask at the Pyrenees large area of analysis (please see part II of script TCD.R)
        
        Then in QGis, 
        A) load both raster layers FADSL and Vineyards (20m resolution, at Pyrenees large area)
        B) create a new raster 0/1 from the combination of those two rasters in rastor calculator (20m resolution, at Pyrenees large area, proj = +proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs)
        ```
        "FASDL_maskrasterbase@1"  = 3  OR 
        "FASDL_maskrasterbase@1"  = 4  OR 
        "FASDL_maskrasterbase@1"  = 5 OR 
        "vine_maskrasterbase@1" = 1
        ```
        
    4. Exclude non forest trees from the TCD layer please see part II of script TCD.R

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

    1. Get CorineLandCover 2012 shapefile
    2. Select only Shrub category (322, 323, 324 / code for transitional areas) in shapefile in QGis
     ```
     "code_12"  = '324' OR
     "code_12"  = '323' OR
     "code_12" ='322'
     ```
    clc12_shrub.shp
    
   3. Rasterize the shapefile at 20m resolution (QGis gdal::rasterize, EPSG+3035/ETRS LAEA)
   4. Cut the raster to the extent of raster_base (please see script Shrub.R)
   5. Put right number 0/1 for non shrub/shrub into the raster (please see script Shrub.R)
   6. Exclude forest (TCD) from the shrub raster (please see script Shrub.R) to create the transitional area.

4. **ELEVATION**
    1. Get Copernicus raster for E30N20 (PYR)  
    https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1
    It is at 25x25m resolution
    
    It is the only one raster with a lower resolution so we are going to downscale the resolution to 20x20m
    
    2. Resample at the large area of analysis (raster_base) at 20m resolution please see script Elevation.R  
    Resample with bilinear method :  
    "Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average."
    
5. **ESM EUROPEAN SETTLEMENT MAP**
    1. Get Copernicus raster layers   
    https://land.copernicus.eu/pan-european/GHSL/european-settlement-map/esm-2012-release-2017-urban-green  
        for N24E32, N24E34, N24E36, N22E36, N22E34 and N22E32 (PYR)
        for (IT)
    CAREFUL VERY LARGE RASTER LAEYRS!
    2. Crop each large raster layers to the study area for both Pyrenees and Alps
    3. Merge cropped raster layers in ArcGIS through Mosaic to New Raster tool (because of memory issues and bug in latest version of QGis)
        For PYR
        For IT
    4. Quick visualization (with TCD, roads etc) slection of
    Distances will be computed at 2.5m then the raster will be resampled at 20x20m.

5. **ROADS**
    1. from overpass turbo https://overpass-turbo.eu/      
    https://wiki.openstreetmap.org/wiki/Key:highway
    For PYR  
    we extract 
               track, footway, path 
               motorway, trunk, primary, secondary, tertiary, unclassified, road 
    For ALP  
    we extract  
                track, footway, path
                motorway, trunk, primary, secondary, tertiary, unclassified, road      
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
     2. Quick visualization to see each category. We will then categorize roads/traisl as 3 1:paved roads, 2:unpaved roads, 3:path and footways          
     4. Merge the data with 3 categories 1:paved roads, 2:unpaved roads, 3:foot trails
     5. Do we rasterize? Or do we keep it as shapefiles to compute "true" distances?
     
6. **WATERBODIES AND WATERS**
    1. From Copernicus   
    https://land.copernicus.eu/pan-european/high-resolution-layers/water-wetness/status-maps/2015  
    2. From OpenStreet Map data with https://overpass-turbo.eu/    
    we extracted natural=water  
    https://wiki.openstreetmap.org/wiki/Tag:natural%3Dwater
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
    3.  
    
    
## Grassland LANDCOVER TYPE SPECIFICATION

1. **Bare rocks land cover**
From https://overpass-turbo.eu/   
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
rock is not used either because it is not the type of rocks we are looking for, i.e. bare rocks on top of mountains, rather than those are in forest area  
cliff could be used because it adds to screen areas.  
  
IN FRANCE  
cliff cannot be used as it is only line material  
rocks not used eaither  
stone not used either  

Check for overlapping the downloaded files (in order to have all the rocks) because it is heavy on mozilla so I had to cut for 3 areas (North, middle, South for the ALps and North SOuth for the Pyrenees)  
Check overlap ALP OK  
Check overlap PYR OK    

**=> Compute one shapefile containing all the type of rocks**
**=> Then rasterize at 20m**

2. **Clip grassland raster with bare rock raster (see before)**  
Where there are bare_rock there is not grassland.  
Tool:

3. **Lakes and waterbodies raster**
    Lakes and waterbodies raster are computed from copernicus and openstreet map (see before)  
    quick visualization with the grassland raster 
    
4. **Clip grassland with waterbodies or only lake raster**

=> Grassland_largePYR.tif


## WHAT NEAREST NEIGHBOUR DISTANCE TO COMPUTE

1. **package(raster)** **distance()**  
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
              
This can be done for TCD, AgriTree, Shrub, ESM, Waterbodies  

ESM: distance to nearest settlement will be computed at 2.5m (if possible) then resample at 20m resolution for more exactitude
However, how do we do for roads ? do we rasterize or not?


2. **package(raster)** **distanceFromPoints()
https://www.rdocumentation.org/packages/raster/versions/2.1-41/topics/distanceFromPoints

3. package(proxy) dist()  
https://www.rdocumentation.org/packages/proxy/versions/0.4-22/topics/dist

4. **package(regos)** **gDistance()**  
https://www.rdocumentation.org/packages/rgeos/versions/0.4-2/topics/gDistance

5. **package(spdep)** **dnearneigh**
https://www.rdocumentation.org/packages/spdep/versions/0.8-1/topics/dnearneigh

6. package(geosphere) dist2Line()
https://www.rdocumentation.org/packages/geosphere/versions/1.5-5/topics/dist2Line

## PROPORTION

1. **package(raster)** **buffer()**
2. **package(raster)** **focal()**


## Some notes:
# boundaries() in package raster
# click() in package raster Click on a map (plot) to get values
# clump() in package raster detect patches of connected cells
# cv() in package raster Compute the coefficient of variation (expressed as a percentage
# density() in package raster create density plots

# canProcessInMemory() in package raster

Before using resample, you may want to consider using these other functions instead:
aggregate, disaggregate, crop, extend, merge. 
