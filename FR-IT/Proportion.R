##########################  %%%%%%%%%%%%%%%%%%%%%%  ###########################

#          CREATE PROPORTION LAYERS FOR GRASS AND SHRUB (RESPECTIVELY)    ####

##########################  %%%%%%%%%%%%%%%%%%%%%%  ###########################

  # 1° Proportion of shrubland ----

# import layers ----

shrub <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/Shrubtrue2_largePYR.tif")


# Create weight matrix ----

?focalWeight
fw<-focalWeight(shrub, # gives the size of the raster
                250, # radius in meter 
                "circle")  #type of filter

# creates circular filter with a radius of 250m
# which provides 25cell*25cells 
fw


# Create proportion raster ----

?focal

ShrubProp <- focal(shrub,w=fw,fun="sum",na.rm=T,pad=TRUE,padValue=F)  
# Gives the proportion of shrubland in a radius of 250m
# for each pixel of 20m
# values are thus between 0 and 1

plot(ShrubProp)

# extract raster ----
writeRaster(ShrubProp,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/Shrubprop250m_largePYR.tif")


# 2° Proportion of grassland ----

 # import layers ----

grass <- raster("C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/GrasslandcutT2_largePYR.tif")


# Create weight matrix ----

?focalWeight
fw<-focalWeight(grass, # gives the size of the raster
                250, # radius in meter 
                "circle")  #type of filter

# creates circular filter with a radius of 250m
# which provides 25cell*25cells 
fw


# Create proportion raster ----

?focal

GrassProp <- focal(grass,w=fw,fun="sum",na.rm=T,pad=TRUE,padValue=F)  
# Gives the proportion of grassland in a radius of 250m
# for each pixel of 20m
# values are thus between 0 and 1

plot(GrassProp)

# extract raster ----
writeRaster(GrassProp,"C:/Users/cazam/Desktop/OBJECTIF 2/Creation variables IT FR/rasterStack IT FR/rastersComplete/Grassprop250m_largePYR.tif")
