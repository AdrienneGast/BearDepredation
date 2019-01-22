############################# %%%%%%%%%%%%%% #############################

####                 CREATE RASTER LAYER OF ELEVATION                 ####

############################ %%%%%%%%%%%%%%%% ############################

  # 1° Import rasters ----

library(raster)

raster_base <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterBase IT FR/Raster_Base_LAEAV_20m.tif")

dem <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/DEM/d12a1e71f3f8cddb87d8c86553d5fe89ebb2a23e/eu_dem_v11_E30N20/eu_dem_v11_E30N20.TIF")
plot(dem)
dem



  # 2° Resample DEM at 20x20m resolution ----

?resample
dem_resa <- resample(x = dem, y = raster_base, method="bilinear")
plot(dem_resa)
dem_resa

extent(dem_resa) == extent(raster_base)
ncell(dem_resa) == ncell(raster_base)

writeRaster(dem_resa,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Elevation020m_largePYR.tif")
