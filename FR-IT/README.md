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
    
   3. Rasterize the shapefile at 20m resolution (QGis gdal::rasterize, EPSG+3035/ETRS LAEA)
   4. Cut the raster to the extent of raster_base (please see script Shrub.R)
   5. Put right number 0/1 for non shrub/shrub into the raster (please see script Shrub.R)
   6. Exclude forest (TCD) from the shrub raster (please see script Shrub.R)

4. **ELEVATION**
    1. Get Copernicus raster for E30N20 (PYR)  
    https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1
    It is at 25x25m resolution
    
    It is the only one raster with a lower resolution so we are going to downscale the resolution to 20x20m
    
    2. Resample at the large area of analysis (raster_base) at 20m resolution please see script Elevation.R  
    Resample with bilinear method :  
    "Bilinear interpolation is a technique for calculating values of a grid location-based on nearby grid cells. The key difference is that it uses the FOUR closest cell centers. Using the four nearest neighboring cells, bilinear interpolation assigns the output cell value by taking the weighted average."
    
5. **ESM EUROPEAN SETTLEMENT MAP**
    1. Get Copernicus raster layers https://land.copernicus.eu/pan-european/GHSL/european-settlement-map/esm-2012-release-2017-urban-green for N24E32, N24E34, N24E36, N22E36, N22E34 and N22E32
    2. Merge raster layers in QGis through rgdal :   
     ```
    gdal_merge.bat -a_nodata -9999 -ot Float32 -o "[fichier temporaire]" -of GTiff "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N24E36/200km_2p5m_N24E36/200km_2p5m_N24E36.TIF" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N22E34/200km_2p5m_N22E34/200km_2p5m_N22E34.TIF" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N24E34/200km_2p5m_N24E34/200km_2p5m_N24E34.TIF" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N22E32/200km_2p5m_N22E32/200km_2p5m_N22E32.TIF" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N22E36/200km_2p5m_N22E36/200km_2p5m_N22E36.TIF" "C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/ESM settlements/b57ee1647f03804dc5f85fd244b0690982f54a89/ESM2012_Rel2017_200km_2p5m_N24E32/200km_2p5m_N24E32/200km_2p5m_N24E32.TIF"  
     ```
    3. Quick visualization (with TCD, roads etc)
    4. 
