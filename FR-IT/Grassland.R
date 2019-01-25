############################# %%%%%%%%%%%%%% #############################

####                 CREATE RASTER GRASSLAND CLIPPED                 ####

############################ %%%%%%%%%%%%%%%% ############################


  # 1° Import rasters ----

library(raster)

# Grassland copernicus + clc ----
grass <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Grasslandtot_largePYR.tif")

# Rocks ----
rock <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/openstreetmap/PYRS/natural/rocks_FR_open/rocks_PYRlarge_LAEA_20.tif")

# Inland water ----
INLAND <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Create Water/InlandWatermerge_PYR_LAEA_20.tif")

  # 2° Crop raster grassland to exclude other land ----

# introduce 0 in raster 1 (grass) for all locations that are 1 in raster 2 (rock)
#https://gis.stackexchange.com/questions/95481/in-r-set-na-cells-in-one-raster-where-another-raster-has-values

?overlay
grass2 <- overlay(grass, rock, fun = function(x, y) {
  x[y==1] <- 0
  return(x)
})

# introduce 0 in raster 1 (grass) for all locations that are 1 in raster 2 (rock)
#https://gis.stackexchange.com/questions/95481/in-r-set-na-cells-in-one-raster-where-another-raster-has-values

?overlay
grass3 <- overlay(grass2, INLAND, fun = function(x, y) {
  x[y==1] <- 0
  return(x)
})

writeRaster(grass3,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Grasslandcut_largePYR.tif")
