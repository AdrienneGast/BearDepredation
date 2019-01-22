This is the folder to compute variables for depredation factor analysis between France and Italy.

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
    2. In QGis, create raster from raster calculation with 0/1 for only FASDL(3) and vineyard (which is CLC(15))
   ```
    "FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1
    ```
    => It brings fruit trees and vineyards (as agricultural trees) as one raster 0/1

AgriTree_largePYR.tif

3. **SHRUB**

    1. Get CorineLandCover 2012 shapefile
    2. Select only Shrub category (322, 323, 324) in shapefile in QGis
     ```
     "code_12"  = '324' OR
     "code_12"  = '323' OR
     "code_12" ='322'
     ```
    clc12_shrub.shp
    
    3. Cut the shapefile on the raster_base extent 
    (QGis : 
    ```
    ogr2ogr.exe -spat 3186415.47 2039945.56 3840091.56 2535652.0 -clipsrc spat_extent "\"[fichier temporaire]\"" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/CLC12/Create Shrub/clc12_Shrub.shp" clc12_Shrub)
    ```
    4. Rasterize Shrub shapefile at 20m resolution for Pyrenees large area in QGis (gdal::rasterize)
    ```
    gdal_rasterize -a OBJECTID -l Shrub_largePYR "C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Shrub_largePYR.shp"
    ```
    5. In R (please see script Shrub.R), put 0/1 as shrub non shrub
    6. Exclude cells (put zero values) in raster layer shrub that are also TCD > 0 (crop with TCD please see script Shrub.R)


