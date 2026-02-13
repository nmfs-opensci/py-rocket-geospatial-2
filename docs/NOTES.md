# Changes

## 2026-02-13

* Removed `rsession-ld-library-path=/srv/conda/envs/notebook/lib` freom `/etc/rstudio/rserver.conf` in `py-rocket-base`. This caused this to fail in RStudio:
  ```
  library(terra) 
  url = "https://storage.googleapis.com/nmfs_odp_nwfsc/CB/fish-pace-datasets/chla-z/netcdf/chla_z_20240305_v2.nc" 
  r <- rast(url, vsi = TRUE)
  ```
* added mirai and tigris to R packages


## 2026-02-08

* In January 2026, the solver stopped solving. It was also getting long, over an hour. I broke the main environment file into 5 smaller files (conda-env/env-*.yml) and add these sequentially to the conda notebook env. This seemed to fix the impossible to solve environment.
* Removed some unneeded packages
* The R package installs were messed up. First install_geospatial.sh needs to be run first. Then other packages.
    - When I fixed the problem of installs going to /home (and then getting wiped out), I caused installs via install-r-packages.sh to go to source rather than binary.
    - There were a bunch of OHW R packages that I needed to add.
* Added tests for Python and R packages all installed.
 
## 2026-02-07

Moved py-rocket-geospatial-2 to its own dedicated directory here.
