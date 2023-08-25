
# remove previous existing files
rm *.map
ls

#~ sutan101@node032.cluster:/scratch/depfg/sutan101/data/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_05min/routing/ldd_and_cell_area$ ls -lah
#~ total 188M
#~ drwxr-xr-x 2 sutan101 depfg    7 Dec 12  2020 .
#~ drwxr-xr-x 5 sutan101 depfg    3 Dec 12  2020 ..
#~ -rwxr-xr-- 1 sutan101 depfg  36M Dec 12  2020 cellsize05min.correct.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Dec 12  2020 cellsize05min_correct.nc
#~ -rw-r--r-- 1 sutan101 depfg  36M Dec 12  2020 cellsize05min.correct.nc
#~ -rw-r--r-- 1 sutan101 depfg  129 Dec 12  2020 hydroworld_source.txt
#~ -rwxr-xr-- 1 sutan101 depfg 8.9M Dec 12  2020 lddsound_05min.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Dec 12  2020 lddsound_05min.nc
#~ -rw-r--r-- 1 sutan101 depfg  36M Dec 12  2020 lddsound_05min_unmask.nc

# cell area map (as used in Sutanudjaja et al, 2018)
cp -r /scratch/depfg/sutan101/data/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_05min/routing/ldd_and_cell_area/cellsize05min.correct.map .

# ldd map (as used in Sutanudjaja et al., 2018) for defining the landmask area extent
cp -r /scratch/depfg/sutan101/data/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_05min/routing/ldd_and_cell_area/lddsound_05min.map .


#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ ls -lah ../model_spatial/
#~ total 36M
#~ drwxr-xr-x 2 sutan101 depfg    2 Aug 25 12:31 .
#~ drwxr-xr-x 7 sutan101 depfg    6 Aug 25 11:36 ..
#~ -rw-r--r-- 1 sutan101 depfg 1.7K Aug 25 12:31 plot_validity_maps.sh
#~ -rw-r--r-- 1 sutan101 depfg  36M Aug 25 12:31 validity_simple_v20230805.tif

# using the following validity_simple.map
gdal_translate -of PCRaster ../model_spatial/validity_simple_v20230805.tif validity_simple_original.map
rm *.xml
mapattr -c lddsound_05min.map validity_simple_original.map

# constrain values to maximum 83 year
pcrcalc validity_simple.map = "min(validity_simple_original.map, 83)"
aguila validity_simple.map

# and using only values greater than zero year
pcrcalc validity_simple_gt_zero.map      = "if(validity_simple.map gt 0.0 , boolean(1.0))"
pcrcalc validity_global_gt_zero_only.map = "if(validity_simple_gt_zero.map, validity_simple.map)"

# global size of land mask
pcrcalc maptotal_global.map = "maptotal(if(defined(lddsound_05min.map), cellsize05min.correct.map))"

# calculate global percentage of validity - using validity_global_gt_zero_only.map
pcrcalc maptotal_valid_simple_gt_zero.map = "maptotal(if(defined(validity_simple_gt_zero.map), cellsize05min.correct.map))"

# calculate global percentage of model coverage - using validity_simple.map
pcrcalc maptotal_valid_simple.map = "maptotal(if(defined(validity_simple.map), cellsize05min.correct.map))"

# unique ids for every model cells within the coverage
pcrcalc unique_ids_valid_simple.map = "uniqueid(if(defined(validity_simple.map), boolean(1.0)))"

#~ mapattr -p maptotal_global.map maptotal_valid_simple_gt_zero.map maptotal_valid_simple.map unique_ids_valid_simple.map

#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ mapattr -p maptotal_global.map maptotal_valid_simple_gt_zero.map maptotal_valid_simple.map unique_ids_valid_simple.map
#~ mapattr version: 4.4.0 (linux/x86_64)
#~ attributes  maptotal_global.map maptotal_valid_simple_gt_zero.map maptotal_valid_simple.map unique_ids_valid_simple.map
#~ rows        2160                2160                              2160                      2160
#~ columns     4320                4320                              4320                      4320
#~ cell_length 0.0833333           0.0833333                         0.0833333                 0.0833333
#~ data_type   scalar              scalar                            scalar                    scalar
#~ cell_repr   single              single                            single                    single
#~ projection  yb2t                yb2t                              yb2t                      yb2t
#~ angle(deg)  0                   0                                 0                         0
#~ xUL         -180                -180                              -180                      -180
#~ yUL         90                  90                                90                        90
#~ min_val     1.32476e+14         2.6753e+13                        3.70986e+13               1
#~ max_val     1.32476e+14         2.6753e+13                        3.70986e+13               518237
#~ version     2                   2                                 2                         2
#~ file_id     0                   0                                 0                         0
#~ native      y                   y                                 y                         y
#~ attr_tab    n                   n                                 n                         n
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ python
#~ Python 3.10.6 | packaged by conda-forge | (main, Aug 22 2022, 20:35:26) [GCC 10.4.0] on linux
#~ Type "help", "copyright", "credits" or "license" for more information.
#~ >>> 3.70986e+13 / 1.32476e+14
#~ 0.28004015821733746
#~ >>> 2.6753e+13 / 1.32476e+14
#~ 0.20194601286270722
#~ >>>


# calculate stats (median and IQR) of validity_global_gt_zero_only.map
import pcraster as pcr
import numpy as np
map = pcr.readmap("validity_global_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ #
#~ >>> import pcraster as pcr
#~ >>> import numpy as np
#~ >>> map = pcr.readmap("validity_global_gt_zero_only.map")
#~ >>> np_values = pcr.pcr2numpy(map, 1e20)
#~ >>> mask = np_values < 1e20
#~ >>> np_values = np_values[mask]
#~ >>> np.median(np_values)
#~ 26.737137
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 38.24571132659912
#~ >>>


########################################################################

# analysis for the conus  
########################################################################


# rasterize the shape file and obtain the geoid for every state
# - rasterizing
gdal_rasterize -a GEOID -te -180 -90 180 90 -tr 0.08333333333333333333333333333333333333333333333333333333333333333333333 0.08333333333333333333333333333333333333333333333333333333333333333333333 tl_2021_us_state.shp tl_2021_us_state_geoid_5min.tif
# - convert it to a PCRaster map file (scalar)
gdal_translate -of PCRaster tl_2021_us_state_geoid_5min.tif tl_2021_us_state_geoid_5min_scalar.map
# - remove xml file as we do not need it
rm *.xml
# - make sure mapattr is the same as others
mapattr -c cellsize05min.correct.map tl_2021_us_state_geoid_5min_scalar.map
# - convert to a nominal map
pcrcalc tl_2021_us_state_geoid_5min.map = "if(tl_2021_us_state_geoid_5min_scalar.map gt 0.0 , nominal(tl_2021_us_state_geoid_5min_scalar.map))"

# get conus area
pcrcalc clump_tl_2021_us_state_geoid_5min.map = "clump(defined(tl_2021_us_state_geoid_5min.map))"
 aguila clump_tl_2021_us_state_geoid_5min.map
pcrcalc conus.map = "if(clump_tl_2021_us_state_geoid_5min.map eq 38, boolean(1.0))"
 aguila conus.map
 

# calculate percentage validity of conus
pcrcalc maptotal_conus.map = "maptotal(if(conus.map, cellsize05min.correct.map))"
pcrcalc maptotal_conus_valid_simple.map = "maptotal(if(conus.map, if(validity_simple_gt_zero.map, cellsize05min.correct.map)))"
mapattr -p maptotal_conus*.map

#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ mapattr -p maptotal_conus*.map
#~ mapattr version: 4.4.0 (linux/x86_64)
#~ attributes  maptotal_conus.map maptotal_conus_valid_simple.map
#~ rows        2160               2160
#~ columns     4320               4320
#~ cell_length 0.0833333          0.0833333
#~ data_type   scalar             scalar
#~ cell_repr   single             single
#~ projection  yb2t               yb2t
#~ angle(deg)  0                  0
#~ xUL         -180               -180
#~ yUL         90                 90
#~ min_val     8.08691e+12        2.76406e+12
#~ max_val     8.08691e+12        2.76406e+12
#~ version     2                  2
#~ file_id     0                  0
#~ native      y                  y
#~ attr_tab    n                  n
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@gpu030.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ python
#~ Python 3.10.6 | packaged by conda-forge | (main, Aug 22 2022, 20:35:26) [GCC 10.4.0] on linux
#~ Type "help", "copyright", "credits" or "license" for more information.
#~ >>> 2.76406e+12 / 8.08691e+12
#~ 0.3417943318276078
#~ >>>



# get western_us and north_eastern_us_states
 
# xcoordinate and ycoordinate maps
pcrcalc xcoordinate.map = "xcoordinate(defined(tl_2021_us_state_geoid_5min.map))"
pcrcalc ycoordinate.map = "ycoordinate(defined(tl_2021_us_state_geoid_5min.map))"

# xmax, ymax, ymin and xmin maps
pcrcalc xmax_states.map = "areamaximum(xcoordinate.map, tl_2021_us_state_geoid_5min.map)"
pcrcalc ymax_states.map = "areamaximum(ycoordinate.map, tl_2021_us_state_geoid_5min.map)"
pcrcalc ymin_states.map = "areaminimum(ycoordinate.map, tl_2021_us_state_geoid_5min.map)"
pcrcalc xmin_states.map = "areaminimum(xcoordinate.map, tl_2021_us_state_geoid_5min.map)"

# western us, but excluding Alaska and Hawaii
pcrcalc western_us.map = "if(xmin_states.map gt -126, if(xmax_states.map lt -100, boolean(1.0)))"
# PS: the 13 Western states, including Alaska (AK) and Hawaii (HI) are: AK, AZ, CA, CO, HI, ID, MT, NV, NM, OR, UT, WA, and WY

# northeastern states are: CT, ME, MA, NH, NJ, NY, PA, RI, and VT.
pcrcalc north_eastern_us.map = "if(xmin_states.map gt -81, if(ymin_states.map gt 38.737, boolean(1.0)))"
pcrcalc north_eastern_us_states.map = "if(north_eastern_us.map, tl_2021_us_state_geoid_5min.map)"
# remove DC
pcrcalc north_eastern_us_states.map = "if(north_eastern_us_states.map ne 11, tl_2021_us_state_geoid_5min.map)"

aguila western_us.map + north_eastern_us_states.map




# get some stats (median and IQR values) for conus, western_us.map and north_eastern_us_states.map
pcrcalc validity_simple_conus_gt_zero_only.map = "if(conus.map, if(validity_simple_gt_zero.map, validity_simple.map))"
pcrcalc validity_north_eastern_us_conus_gt_zero_only.map = "if(defined(north_eastern_us_states.map), if(validity_simple_gt_zero.map, validity_simple.map))"
pcrcalc validity_western_us_conus_gt_zero_only.map = "if(defined(western_us.map), if(validity_simple_gt_zero.map, validity_simple.map))"

import pcraster as pcr
import numpy as np

map = pcr.readmap("validity_simple_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ >>> np.median(np_values)
#~ 23.786543
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 37.13852643966675
#~ >>>

map = pcr.readmap("validity_north_eastern_us_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ >>> np.median(np_values)
#~ 18.814137
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 16.05710220336914
#~ >>>

map = pcr.readmap("validity_western_us_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ >>> np.median(np_values)
#~ 39.839314
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 40.12320518493652
#~ >>>

