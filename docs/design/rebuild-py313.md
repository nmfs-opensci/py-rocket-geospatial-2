# Rebuild on py-rocket-base 2026.11.17 (Python 3.13, R 4.6.1)

Plan and decisions: issue #69 (see its decisions comment of 2026-11-16). PR #70.
This note records what the code alone does not explain: workarounds, choices that
look wrong, and facts found during the five test builds (runs 43977764370 through
43986044579).

## What stays in the image and what users install

Rule of thumb from #69: put a tool in the image if it is stable, does not update
itself, and keeps its credentials in the user's home. Leave it out if it updates
itself, changes quickly, or is large but only a few people use it.

- **In the image:** `awscli`, `gcloud`, `source-coop` (pinned), `rclone`, `s5cmd`, `gh`
  (from the base).
- **Users install them (`install-user-tools`):** Claude Code and Antigravity. They
  update themselves about weekly. A root-owned copy in the image could not update,
  and a user's own copy in `~/.local/bin` would shadow it anyway. Keeping them out
  also avoids a shared NOAA image appearing to endorse particular AI tools.
- **gcloud stays** (an earlier comment proposed removing it, and the decisions
  reversed that): GCS is used regularly, and `gcloud auth application-default
  login` is how users get credentials for `gcsfs` and `rclone`. It is installed
  with `--no-install-recommends` to drop `google-cloud-cli-anthoscli` (~120 MB).
  The conda-forge `google-cloud-sdk` was measured at 792 MB, no smaller.
- **Panoply and CoastWatch Utilities** move to their own derivative image. Java
  stays in the base.

## Things that look wrong but are deliberate

- **`awscli>=2` from conda-forge.** The conda-forge package `awscli` is AWS CLI v2
  (2.38.x). The #69 comments call it "v1", which is out of date. `awscliv2` plus
  `awsv2 --install` was dropped because it runs the CLI in Docker, which fails on
  a hub (py-rocket-base#305).
- **`obspec_utils`, with an underscore.** That is its conda-forge name. Under the
  hyphenated name it looks as if it is on PyPI only, so the first attempt installed
  it with pip. The build then installed it from conda-forge anyway, and validation
  reported it missing.
- **`point-collocation` is in `env-ioos.yml`, not `env-core2.yml`.** It is
  pip-only and needs `cf-xarray`, which `env-ioos.yml` installs. From core2, pip
  would pull `cf-xarray` from PyPI ahead of the conda one (see
  [env-file-split.md](env-file-split.md)). #68 calls it "points-collocation";
  the package is `point-collocation` (fish-pace).
- **Base 2026.11.17, not 2026.11.16.** 2026.11.16 had lost the R package
  `remotes`, so the first test build failed with `there is no package called
  'remotes'`. `devtools` 2.5 (CRAN `noble/2026-10-28`) moved `remotes` from
  Imports to Suggests, so it stopped arriving with rocker's
  `install_tidyverse.sh`. `install.R` installed it as a stopgap. The base fixed
  it in 2026.11.17 (py-rocket-base#316, #317), which installs it into R's system
  library, and the stopgap was removed (#72). Do not add it back to `install.R`:
  a second copy in the site-library would hide the base's copy.
- **`gdalcubes` comes from the 2026-11-16 snapshot.** Every other R package uses
  the 2026-10-28 snapshot, which matches the base. gdalcubes was off CRAN on
  2026-10-28 ("not available for this version of R") and came back as 0.7.6 on
  2026-10-30. Its dependencies (Rcpp, jsonlite, ncdf4) were already installed.
  Once a later base moves its snapshot past 2026-10-30, put it back in the main
  list.
- **The GitHub token is passed as a BuildKit secret** (`--secret
  id=github_pat,env=GITHUB_PAT`, mounted only for the `install.R` step). The old
  `--build-arg GITHUB_PAT` never had an `ARG` in the Dockerfile, so
  `install_github` ran without a token. Runners share IP addresses, so GitHub's
  limit for unauthenticated requests sometimes fails it with HTTP 403 (run
  43984719875; run 43982555552 got through the same code). A plain `ARG` would
  leave the token in the published image's history. `install.R` logs whether a
  token is set, never its value; run 43986044579 printed `TRUE`, so the token
  survives the switch to `jovyan` in `install-r-packages.sh`.
  `.github/actions/build-and-push/action.yml`, the template for derivative images,
  still passes the unused `--build-arg`. That is harmless.
- **`ENV PROJ_LIB=<conda>` stays in the Dockerfile, and R ignores it.** R must
  use the system GDAL/PROJ, never conda's. On a hub, R started in the JupyterLab
  terminal, where the conda env is activated, loaded conda's GDAL plugins
  (`undefined symbol: GEOSCoverageCleanParams_setGapMaximumWidth_r`, `OPENSSL_3.4.0
  not found`). The current `main` image has the same problem, as 50+ warnings.
  RStudio, its terminal, R notebooks, and any shell after `conda deactivate` were
  fine. The base fixed it in its republished 2026.11.17 (py-rocket-base#319): it
  sets `GDAL_DATA`, `GDAL_DRIVER_PATH`, `PROJ_DATA` and `PROJ_LIB` to the system
  paths in `Renviron.site`, which overrides values R inherits. That also covers
  this image's `PROJ_LIB`, which is probably there for conda QGIS on the desktop
  (not tested, so left alone). Do not point R at conda's libraries to fix a
  missing R dependency.
- **The test notebook searches `PACE_OCI_L3M_AOP`.** OB.DAAC folded
  `PACE_OCI_L3M_RRS` into the AOP collection with processing version 3.2. The
  old name returns 0 granules with any earthaccess version. This broke the test
  on `main` too.

## Testing approach

- `test-build.yml` runs on a push to the `test` branch. Push events use the
  workflow file from the pushed commit, so it works before the file is on `main`.
  A `workflow_dispatch`-only workflow cannot be started until it is on the default
  branch.
- Solves were checked on the GitHub runner, not on the hub. Combined dry runs were
  killed for lack of memory on a 7.8 GB hub. The runner installed all six env
  files one after another in about 5 minutes.
- Image from run 43986044579: 5.73 GB content, 23.4 GB on disk.
