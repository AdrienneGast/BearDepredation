############### %%%%%%%%%%%%%%%%%%% ##################

#        CREATE TCD RASTER FOR LARGE PYRENEES     ####
#      raster to create distance and grassland

############### %%%%%%%%%%%%%%%%%%% ##################

  # 1? Import rasters ----

library(raster)

# import raster large pyrenees ----

raster_base <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterBase IT FR/Raster_Base_LAEAV_20m.tif")

# import TCD raster from Copernicus ----

TCD_2015_020 <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/TCD/TCD_2015_020m_eu_03035_d05_E30N20 (1).TIF")
plot(TCD_2015_020)
TCD_2015_02

  # 2? Create TCD raster for large pyrenees ----

projection(raster_base) == projection(TCD_2015_020)


# reduce ----
tcd.c <- crop(TCD_2015_020,raster_base)
plot(tcd.c)
extent(tcd.c) <- extent(raster_base)
tcd.c
ncell(tcd.c)
ncell(raster_base)
# on est bon suite au crop

# add NAs outside study area ----
tcd.c.d <- mask(tcd.c,raster_base)
plot(tcd.c.d)
val <- getValues(tcd.c.d)
unique(val)
tcd.c.d
ncell(tcd.c.d)
res(tcd.c.d)
projection(tcd.c.d)

# Write raster ----
writeRaster(tcd.c.d,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/tcd_decoup_LAEA_PYRlarge.tif")

############################# %%%%%%%%%%%%%% #############################

####    CREATE RASTERS AT PYRENEES FOR NON FOREST TREES AND VINEYARDS ####

############################ %%%%%%%%%%%%%%%% ############################

  # 1° Import rasters ----

library(raster)

# load raster layer for type of trees (from copernicus FASDL) ----

tr <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/copernicus/Forest Add Support Layer/73d594cd06c5764cbfbe4780e29e69b1dfebc97d/FADSL_2015_020m_eu_03035_d03_E30N20/FADSL_2015_020m_eu_03035_d03_E30N20/FADSL_2015_020m_eu_03035_d03_E30N20.TIF")

plot(tr)
tr

# load the vineyard raster layer (from CLC shapefile rasterized at 20m) ----

vine <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/analyses/data/CLC12/Vineyards_020m_CLC12.tif")
plot(vine,add=T)
vine

# load basic raster for large area PYRENEES ----

raster_base <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterBase IT FR/Raster_Base_LAEAV_20m.tif")

  # With this layer that contains the bounding box of the raster layer that we want to obtain, we can crop both of the raster layers



  # 2° Clipping rasters for pyrenees large area ----

## FOR VINYARDS ----
# reduce ----
vine.c <- crop(vine,raster_base)
plot(vine.c,add=T)
extent(vine.c) <- extent(raster_base)
vine.c
ncell(vine.c)
ncell(raster_base)

# add NAs outside area ----
vine.c.d <- mask(vine.c,raster_base)
plot(vine.c.d)
val <- getValues(vine.c.d)
unique(val)
vine.c.d[vine.c.d==221] <- 1
ncell(vine.c.d)
res(vine.c.d)
projection(vine.c.d)

writeRaster(vine.c.d,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/create TCD/vine_maskrasterbase.tif")

## FOR NON FOREST TREES ----
# reduce ----
tr.c <- crop(tr,raster_base)
plot(tr.c)
extent(tr.c) <- extent(raster_base)
tr.c
ncell(tr.c)
ncell(raster_base)

# add NAs outside area ----
tr.c.d <- mask(tr.c,raster_base)
plot(tr.c.d)
val <- getValues(tr.c.d)
unique(val)
tr.c.d[tr.c.d==3] <- 1
ncell(tr.c.d)
res(tr.c.d)
projection(tr.c.d)


writeRaster(tr.c.d,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/create TCD/FASDL_maskrasterbase.tif")

# those 2 rasters are integrated into QGis to create only one raster 0/1 for vineyards and non forest trees (FADSL 3 agricultural trees, 4 and 5 urban trees)

############################# %%%%%%%%%%%%%% #############################

####    CREATE RASTER LAYER OF TCD PYR WITHOUT NON FOREST TREES       ####

############################ %%%%%%%%%%%%%%%% ############################



  # 1° Import raster layers ----

library(raster)

# import raster layer of non forest trees ----
# created in QGis with vine and fadsl from script 2

nonTCD <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/merge_NOT_TCD2.tif")
nonTCD
val <- getValues(nonTCD)
unique(val)

# import tcd large pyr ----
# created from script 1

tcd <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/tcd_decoup_LAEA_PYRlarge.tif")
tcd
plot(tcd)
val <- getValues(tcd)
unique(val)
# check in QGis why I have a 255 value into my raster that I cannot see on the plot
# we have a little part on mediterranean sea this is why there is 250 value



  # 2° Exclude non forest trees from TCD raster ----


# introduce 0 in raster 1 (tcd) for all locations that are 1 in raster 2 (nonTCD)
#https://gis.stackexchange.com/questions/95481/in-r-set-na-cells-in-one-raster-where-another-raster-has-values

?overlay
rst1_mod <- overlay(tcd, nonTCD, fun = function(x, y) {
  x[y==1] <- 0
  return(x)
})

plot(rst1_mod)

writeRaster(rst1_mod,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/TCDtrue_PYRlarge.tif")


