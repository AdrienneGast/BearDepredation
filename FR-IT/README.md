This is the folder to compute variables for depredation factor analysis between France and Italy.

## STUDY AREA


## LandCover variables computed for analysis

1. **TREE COVER DENSITY**
    1. From Copernicus download E30N20 raster for TCD at 20m resolution (2015)
    https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-density/status-maps/2015

    2. Reduce raster (crop and mask) to the large area of analysis (raster_base.tif) 
    to see how raster_base is created please refer to [STUDY AREA](#Study_area)
    
    3. *Create raster of non tcd* : 
        From Copernicus download E30N20 raster for FADSL at 20m resolution (2015)
        https://land.copernicus.eu/pan-european/high-resolution-layers/forests/forest-type-1/expert-products/forest-additional-support-layer/2015
        Create raster (crop and mask) for the large area of analysis (raster_base.tif)
        This is all trees that are non forest (urban and agricultural trees such as fruit trees)
        see
        
        Then get from CorineLandCover 2012 => Vineyards

    4. Exclude non forest trees from the TCD layer please see script

2. **AGRICULTURAL TREES**

    1. Get raster of FADSL at large Pyrenees and Vineyards at large Pyrenees
    2. In QGis, create raster from raster calculation with 0/1 for only FASDL(3) and vineyard (which is CLC(15))
   ```
    "FASDL_maskrasterbase@1"  = 3  OR 
    "vine_maskrasterbase@1" = 1
    ```
    => It brings fruit trees and vineyards (as agricultural trees) as one raster 0/1
    
3. ** SHRUB **



