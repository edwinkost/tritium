
# Note: To run this script, you need PCRaster (https://pcraster.geo.uu.nl/). To install it, see e.g. https://pcraster.geo.uu.nl/pcraster/4.4.0/documentation/pcraster_project/install.html 

set -x

# input variables (on a table)
INPUT_TABLE="../datasets/version_20230812/geospatialmodel_latlon_trimmedparams_20230522_header_lat_lon_dwt_ratio-aet-p_ratio-pet-p.txt"

# convert the input variables to raster maps
# - remove previous/existing files (if any)
rm clone.map dwt.map ratio_aet_p.map ratio_pet_p.map
# - create a clone map (global 5 arcmin)
mapattr -s -R 2160 -C 4320 -S -P yb2t -x -180 -y 90 -l 0.083333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333 clone.map
# - convert table to raster maps
col2map -a --clone clone.map -x 2 -y 1 -v 3 ${INPUT_TABLE} dwt.map
col2map -a --clone clone.map -x 2 -y 1 -v 4 ${INPUT_TABLE} ratio_aet_p.map
col2map -a --clone clone.map -x 2 -y 1 -v 5 ${INPUT_TABLE} ratio_pet_p.map


# plot the validity map
rm validity_simple*
pcrcalc validity_simple.map = "
                               -17.8 
                            +    3.92*(ratio_pet_p.map) 
                            +    0.36*(dwt.map) 
                            +   -0.08*((ratio_pet_p.map-2.36136)*(dwt.map-116.15))
                              "
#~ # simple model
#~ Parameter	Estimate
#~ Intercept	-17.8
#~ pet_p	3.92
#~ Dwt	0.36
#~ (pet_p-2.36136)*(dwt-116.15)	-0.08


# convert the validity map to a tif (and give it a version) 
gdal_translate validity_simple.map validity_simple_v2023085.tif


# remove temporary files
rm *.xml validity_simple.map dwt.map ratio_aet_p.map ratio_pet_p.map clone.map

set +x
