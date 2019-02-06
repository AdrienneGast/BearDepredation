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

   # 3° Crop raster with agricultural artifical areas CLC12 ----

# it is to get out of cities and villages which are agricultural areas
# taken into account in ESM and which do not correspond to true grassland
# with vizualisation in QGis there will still be some "noise"
# I mean that some agricultural areas will still be taken into account in Grassland
# but it will be less than before

# shapefile CLC12 rasterized in 20x20m

# import grass cut ----
grass <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Grasslandcut_largePYR.tif")

# import artiagri ----
artif <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Create Grass/ArtiAgri020_largePYR.tif")

# introduce 0 in raster 1 (grass) for all locations that are 1 in raster 2 (artifical areas)
#https://gis.stackexchange.com/questions/95481/in-r-set-na-cells-in-one-raster-where-another-raster-has-values

?overlay
grass4 <- overlay(grass, artif, fun = function(x, y) {
  x[y==1] <- 0
  return(x)
})

plot(grass4)

writeRaster(grass4,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/GrasslandcutT_largePYR.tif",overwrite=T)
