
# Note: To run this script, you need PCRaster (https://pcraster.geo.uu.nl/). To install it, see e.g.  

INPUT_TABLE="../datasets/version_20230509/geospatialmodel_latlon_trimmedparams_20230522_header_lat_lon_dwt_ratio-aet-p_ratio-pet-p.txt"

rm dwt.map ratio_aet_p.map ratio_pet_p.map
col2map --clone cellsize05min.correct.map -x 2 -y 1 -v 3 ${INPUT_TABLE} dwt.map
col2map --clone cellsize05min.correct.map -x 2 -y 1 -v 4 ${INPUT_TABLE} ratio_aet_p.map
col2map --clone cellsize05min.correct.map -x 2 -y 1 -v 5 ${INPUT_TABLE} ratio_pet_p.map

#~ # simple model
#~ Intercept	-12.5
#~ pet_p	2.5
#~ Dwt	0.4
#~ (pet_p-2.31136)*(dwt-110.477)	-0.1

pcrcalc validity_simple.map = "-12.5 + 2.5* (ratio_pet_p.map) + 0.4 * (dwt.map) +  -0.1 * ((ratio_pet_p.map - 2.31136) * (dwt.map - 110.477))"

