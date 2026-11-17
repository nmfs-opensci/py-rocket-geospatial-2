# Changes

## 2026-11-17

Rebuild on py-rocket-base 2026.11.17 (Python 3.13, R 4.6.1). Plan and decisions: #69; reasons in `docs/design/rebuild-py313.md`.

* Base `py-rocket-base:2026.11.17` (2026.11.16 plus R `remotes`, py-rocket-base#316, and R kept on the system GDAL/PROJ in the JupyterLab terminal, py-rocket-base#319); CRAN snapshot `noble/2026-10-28`; added R `zarr`, `rerddap`. `gdalcubes` comes from the 2026-11-16 snapshot (it was off CRAN on 2026-10-28).
* QGIS bumped to `~=3.44.0` (3.40 cannot be installed on Python 3.13).
* Removed Panoply and CoastWatch Utilities (and their `Desktop/` entries); they move to their own derivative image. Java stays in the base.
* Removed `xarray-datatree` (DataTree is in xarray).
* Icechunk stack folded into `env-core2.yml` with minimum versions; `obspec_utils` from conda-forge; `point-collocation` via pip (PyPI only), in `env-ioos.yml` after `cf-xarray`. Added `xoak`, `argopy`, `jupyter-cache` (#68).
* Cloud CLIs: conda-forge `awscli>=2` (AWS CLI v2, 2.38.x at the time) replaces `awscliv2` + `awsv2 --install` (needed Docker; py-rocket-base#305); added `rclone`, `s5cmd`; `source-coop` v0.3.0 in `/usr/local/bin` (checksum pinned); gcloud kept, installed with `--no-install-recommends` (drops the ~120 MB anthoscli package).
* Claude Code and Antigravity are not in the image: `install-user-tools` (from `scripts/install-user-tools.sh`) installs them into the user's home.
* Test notebook: `PACE_OCI_L3M_RRS` became `PACE_OCI_L3M_AOP` with OB.DAAC v3.2.
* New `test-build.yml`: builds on push to the `test` branch or by manual run, pushed only to the `.../test` image.

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
