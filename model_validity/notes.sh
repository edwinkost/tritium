
#~ sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ ls -lah ../model_spatial/
#~ total 285M
#~ drwxr-xr-x 2 sutan101 depfg    9 Jun  8 12:16 .
#~ drwxr-xr-x 8 sutan101 depfg    7 Jun  8 10:16 ..
#~ -r-xr-xr-- 1 sutan101 depfg  36M Dec 12  2020 cellsize05min.correct.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 dwt.map
#~ -rw-r--r-- 1 sutan101 depfg 1.9K Jun  8 12:16 plot_validity_maps.sh
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 ratio_aet_p.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 ratio_pet_p.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 validity_complex.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 validity_complex.tif
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun 14 00:31 validity_simple.map
#~ -rw-r--r-- 1 sutan101 depfg  36M Jun  8 12:16 validity_simple.tif

rm *.map

# using the following validity_simple.map
cp -r ../model_spatial/validity_simple.map validity_simple_original.map

# constrain values to maximum 83 year
pcrcalc validity_simple.map = "min(validity_simple_original.map, 83)"
aguila validity_simple.map

# using/focussing  
pcrcalc validity_simple_gt_zero.map      = "if(validity_simple.map gt 0.0 , boolean(1.0))"
pcrcalc validity_global_gt_zero_only.map = "if(validity_simple_gt_zero.map, validity_simple.map)"

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

# ldd map (as used in Sutanudjaja et al., 2018) for defining the landmask area extent
cp -r /scratch/depfg/sutan101/data/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_05min/routing/ldd_and_cell_area/lddsound_05min.map .

# cell area map (as used in Sutanudjaja et al, 2018)
cp -r /scratch/depfg/sutan101/data/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_05min/routing/ldd_and_cell_area/cellsize05min.correct.map .


# calculate global percentage of validity
pcrcalc maptotal_global.map = "maptotal(if(defined(lddsound_05min.map), cellsize05min.correct.map))"
pcrcalc maptotal_valid_simple.map = "maptotal(if(validity_simple_gt_zero.map, cellsize05min.correct.map))"

mapattr -p maptotal_global.map maptotal_valid_simple.map

#~ sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ mapattr -p maptotal_global.map maptotal_valid_simple.map
#~ mapattr version: 4.4.0 (linux/x86_64)
#~ attributes  maptotal_global.map maptotal_valid_simple.map
#~ rows        2160                2160
#~ columns     4320                4320
#~ cell_length 0.0833333           0.0833333
#~ data_type   scalar              scalar
#~ cell_repr   single              single
#~ projection  yb2t                yb2t
#~ angle(deg)  0                   0
#~ xUL         -180                -180
#~ yUL         90                  90
#~ min_val     1.32476e+14         2.89466e+13
#~ max_val     1.32476e+14         2.89466e+13
#~ version     2                   2
#~ file_id     0                   0
#~ native      y                   y
#~ attr_tab    n                   n
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ python
#~ Python 3.10.6 | packaged by conda-forge | (main, Aug 22 2022, 20:35:26) [GCC 10.4.0] on linux
#~ Type "help", "copyright", "credits" or "license" for more information.
#~ >>> 2.89466e+13 / 1.32476e+14
#~ 0.21850448383103355


# calculate stats (median and IQR) of validity_global_gt_zero_only.map
import pcraster as pcr
import numpy as np
map = pcr.readmap("validity_global_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ >>> import numpy as np
#~ >>> map = pcr.readmap("validity_global_gt_zero_only.map")
#~ >>> np_values = pcr.pcr2numpy(map, 1e20)
#~ >>> mask = np_values < 1e20
#~ >>> np_values = np_values[mask]
#~ >>> np.median(np_values)
#~ 29.542212
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 36.46290969848633


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

#~ sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ mapattr -p maptotal_conus*.map
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
#~ min_val     8.08691e+12        3.04705e+12
#~ max_val     8.08691e+12        3.04705e+12
#~ version     2                  2
#~ file_id     0                  0
#~ native      y                  y
#~ attr_tab    n                  n
#~ (pcrglobwb_python3_2022-10-17)
#~ sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity$ python
#~ Python 3.10.6 | packaged by conda-forge | (main, Aug 22 2022, 20:35:26) [GCC 10.4.0] on linux
#~ Type "help", "copyright", "credits" or "license" for more information.
#~ >>> 3.04705e+12 / 8.08691e+12
#~ 0.37678792023158414



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

# conus
map = pcr.readmap("validity_simple_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ >>> np.median(np_values)
#~ 25.910164
#~ >>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
#~ 35.41327929496765

map = pcr.readmap("validity_north_eastern_us_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
>>> np.median(np_values)
25.892141
>>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
19.7247257232666

map = pcr.readmap("validity_western_us_conus_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
>>> np.median(np_values)
42.38822
>>> np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
39.59140968322754


#####################################

# complex model


# validity complex
pcrcalc validity_complex_gt_zero.map = "if(validity_complex.map gt 0, boolean(1.0))"
pcrcalc maptotal_valid_complex.map = "maptotal(if(validity_complex_gt_zero.map, cellsize05min.correct.map))"
mapattr -p maptotal_global.map maptotal_valid_complex.map
sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity/complex$ mapattr -p maptotal_global.map maptotal_valid_complex.map
mapattr version: 4.4.0 (linux/x86_64)
attributes  maptotal_global.map maptotal_valid_complex.map
rows        2160                2160
columns     4320                4320
cell_length 0.0833333           0.0833333
data_type   scalar              scalar
cell_repr   single              single
projection  yb2t                yb2t
angle(deg)  0                   0
xUL         -180                -180
yUL         90                  90
min_val     1.32476e+14         3.37319e+13
max_val     1.32476e+14         3.37319e+13
version     2                   2
file_id     0                   0
native      y                   y
attr_tab    n                   n
(pcrglobwb_python3_2022-10-17)
sutan101@node032.cluster:/eejit/home/sutan101/github/edwinkost/tritium/model_validity/complex$ python
Python 3.10.6 | packaged by conda-forge | (main, Aug 22 2022, 20:35:26) [GCC 10.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 3.37319e+13/1.32476e+14
0.25462649838461304

# validity complex global
pcrcalc validity_complex_global_gt_zero_only.map = "if(validity_complex_gt_zero.map, validity_complex.map)"
import pcraster as pcr
import numpy as np
map = pcr.readmap("validity_complex_global_gt_zero_only.map")
np_values = pcr.pcr2numpy(map, 1e20)
mask = np_values < 1e20
np_values = np_values[mask]
np.median(np_values)
np.quantile(np_values, 0.75) - np.quantile(np_values, 0.25)
