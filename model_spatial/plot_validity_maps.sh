
# Note: To run this script, you need PCRaster (https://pcraster.geo.uu.nl/). To install it, see e.g.  

INPUT_TABLE="../datasets/version_20230509/geospatialmodel_latlon_trimmedparams_20230522_header_lat_lon_dwt_ratio-aet-p_ratio-pet-p.txt"

rm dwt.map ratio_aet_p.map ratio_pet_p.map
col2map -a --clone cellsize05min.correct.map -x 2 -y 1 -v 3 ${INPUT_TABLE} dwt.map
col2map -a --clone cellsize05min.correct.map -x 2 -y 1 -v 4 ${INPUT_TABLE} ratio_aet_p.map
col2map -a --clone cellsize05min.correct.map -x 2 -y 1 -v 5 ${INPUT_TABLE} ratio_pet_p.map

#~ # simple model
#~ Parameter	Estimate
#~ Intercept	-12.5
#~ pet_p	2.5
#~ Dwt	0.4
#~ (pet_p-2.31136)*(dwt-110.477)	-0.1

rm validity_simple*
pcrcalc validity_simple.map = "
                               -12.5 
                            +    2.5*(ratio_pet_p.map) 
                            +    0.4*(dwt.map) 
                            +   -0.1*((ratio_pet_p.map-2.31136)*(dwt.map-110.477))
                              "
gdal_translate validity_simple.map validity_simple.tif

#~ # complex model
#~ Parameter	Estimate
#~ Intercept	-56.6
#~ aet_p	83.0
#~ pet_p	-4.7
#~ Dwt	0.5
#~ (aet_p-0.82955)*(pet_p-2.31136)	119.6
#~ (aet_p-0.82955)*(dwt-110.477)	-5.4
#~ (pet_p-2.31136)*(dwt-110.477)	-0.1

rm validity_complex*
pcrcalc validity_complex.map = "
                                -56.6 
                             +   83.0*(ratio_aet_p.map) 
                             +   -4.7*(ratio_pet_p.map) 
                             +    0.5*(dwt.map) 
                             +  119.6*(ratio_aet_p.map-0.82955)*(ratio_pet_p.map -2.31136) 
                             +   -5.4*(ratio_aet_p.map-0.82955)*(dwt.map-110.477)
                             +   -0.1*(ratio_pet_p.map-2.31136)*(dwt.map-110.477)
                               " 
gdal_translate validity_complex.map validity_complex.tif

rm *.xml
