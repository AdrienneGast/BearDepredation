############################# %%%%%%%%%%%%%% #############################

####                   CREATE RASTER LAYER OF SHRUB                   ####

############################ %%%%%%%%%%%%%%%% ############################

  
  # 1° Import raster layers ----

library(raster)

# created before (see TCD)
tcd <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/TCDtrue_largePYR.tif")

# created before(see Raster bascis)
raster_base <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterBase IT FR/Raster_Base_LAEAV_20m.tif")

shrub <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Create Shrub/shrub_020_clc.tif")
plot(shrub)

  # 2° Check extent ----

extent(raster_base) == extent(tcd)
shrub
raster_base
tcd

  # 3° Clipping rasters for pyrenees large area ----

# reduce ----
shrub.c <- crop(shrub,raster_base)
extent(shrub.c) <- extent(raster_base)
shrub.c
ncell(shrub.c)
ncell(raster_base)

# add NAs outside area ----
# and put right values 0/1 ----
shrub.c.d <- mask(shrub.c,raster_base)
plot(shrub.c.d)
val <- getValues(shrub.c.d)
unique(val)
shrub.c.d[shrub.c.d>0] <- 1
ncell(shrub.c.d)
res(shrub.c.d)
projection(shrub.c.d)

writeRaster(shrub.c.d,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Shrub_largePYR.tif")

  # 4° Exclude forest TCD from the raster ----

# introduce 0 in raster 1 (shrub.c.d) for all locations that are not zero in raster 2 (tcd)

rst1_mod <- overlay(shrub.c.d, tcd, fun = function(x, y) {
  x[y!=0] <- 0
  return(x)
})

plot(rst1_mod)


writeRaster(rst1_mod,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Shrubtrue_largePYR.tif")

  # 5° Exclude Grasslandcut true from the shurb raster ----

# introduce 0 in raster 1 (shrub) for all locaions that are 1 in raster 2 (grassland)

shrub <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Shrubtrue_largePYR.tif")
grass <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Grasslandcut_largePYR.tif")

rst2 <- overlay(shrub,grass,fun = function(x, y) {
  x[y==1] <- 0
  return(x)
})

writeRaster(rst2,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Shrubtrue2_largePYR.tif")
