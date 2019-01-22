##############  %%%%%%%%%%%%  ################

####    CREATION OF RASTERS FOR ANALYSIS  ####

##############  %%%%%%%%%%%%  ################

# rasterization at 20m resolution is heavy computation both for Pyrenees and Trention
# then the raster at 20m resolution (large area and area of analysis) are made in QGis
# from 

# projection has to be similar to CLC and Copernicus

# thus projection true is:
# +proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 


    # 1? PYRENEES RASTERS BASICS ----

# import raster from QGis ----
raster_decoup_laeaV <- raster("C:/Users/cazam/Desktop/raster_decoup_laeaV.tif")
unique(getValues(raster_decoup_laeaV))
plot(raster_decoup_laeaV)
raster_decoup_laeaV

# raster at 20m resolution
# created in QGis
# through the objectif 1 grid area + pasture
# 2010-2017

# same raster but projection different
# raster_decoup_laea : +proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs
# raster_decoup_laeaV : +proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 

raster_base_LAEAF <- raster("C:/Users/cazam/Desktop/raster_base_LAEAF.tif")
unique(getValues(raster_base_LAEAF))
plot(raster_base_LAEAF)
raster_base_LAEAF

# good projection
# large area for PYRENEES
# raster crop "by hand"
# from which we do all the calculation
# to avoid edge effects

# THEY CAN BE PLOTTED BECAUSE OF VALUES INSIDE THAT ARE ACTUALLY VALUES FROM SHAPEFILES (random)


    # 2? PUT RIGHT VALUES INTO RASTERS ----

  # raster decoup? FR PYR ----
raster_decoup_laeaV

unique(getValues(raster_decoup_laeaV))
plot(raster_decoup_laeaV)

# put NAs where there is zeros
raster_decoup_laeaV[raster_decoup_laeaV==0] <- NA
plot(raster_decoup_laeaV)

# put value 1 where there is false values
raster_decoup_laeaV[raster_decoup_laeaV>0] <- 1
plot(raster_decoup_laeaV)

  # raster large area PYR ----
raster_base_LAEAF

unique(getValues(raster_base_LAEAF))
plot(raster_base_LAEAF)

# zeros here are part of the area so let's put 1 in place of values > 0
# put value 1 where there is false values
raster_base_LAEAF[raster_base_LAEAF>0] <- 1
plot(raster_base_LAEAF)

# let's put 1 even where there is 0
raster_base_LAEAF[raster_base_LAEAF==0] <- 1
plot(raster_base_LAEAF)


    # 3? WRITE THE RASTERS ----
writeRaster(raster_base_LAEAF,"C:/Users/cazam/Desktop/Raster_Base_LAEAV_20m.tif")
writeRaster(raster_decoup_laeaV,"C:/Users/cazam/Desktop/Raster_Base_DecoupFRPYR_LAEAV_20m.tif")
