FROM ghcr.io/nmfs-opensci/py-rocket-base:2026.11.17

LABEL org.opencontainers.image.maintainers="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.author="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.source=https://github.com/nmfs-opensci/py-rocket-geospatial-2
LABEL org.opencontainers.image.description="Geospatial Python (3.13) and R (4.6.1) image with Desktop (QGIS) and cloud CLIs (gcloud, aws, source-coop, rclone, s5cmd)"
LABEL org.opencontainers.image.licenses=Apache2.0
LABEL org.opencontainers.image.version=2026.11.17

ENV PROJ_LIB=/srv/conda/envs/notebook/share/proj

USER root
# Install Zotero; must be run before apt since apt install zotero requires this script be run first
RUN wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | bash

# Copy the repo files into /tmp (conda-env/*.yml, install.R, etc)
COPY . /tmp/
# Fix permissions so NB_USER can write to /tmp/conda-env during package installs
RUN chown -R ${NB_USER}:${NB_USER} /tmp/conda-env && chmod -R 755 /tmp/conda-env

# Update conda env sequentially to prevent hairy solve
RUN set -eux; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-core1.yml; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-core2.yml; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-geo.yml; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-ioos.yml; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-viz.yml; \
    /pyrocket_scripts/install-conda-packages.sh /tmp/conda-env/env-qgis.yml

RUN set -eux; \
    /pyrocket_scripts/install-apt-packages.sh /tmp/apt.txt

RUN set -eux; \
    /pyrocket_scripts/install-desktop.sh /tmp/Desktop
    
USER root
# install the geospatial libraries and R spatial; the rocker script is copied into py-rocket-base as part of that image build
# need to ensure that it installs to the site-library (that user can control) and with a clean PATH
# Ensure packages go to site-library whether installed via R, Rscript, or littler (r)
RUN echo '.libPaths("/usr/local/lib/R/site-library")' > /etc/littler.r && \
    echo '.libPaths("/usr/local/lib/R/site-library")' > /tmp/rprofile.site && \
    R_PROFILE=/tmp/rprofile.site \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /rocker_scripts/install_geospatial.sh && \
    rm /etc/littler.r /tmp/rprofile.site

# Any packages that have gdal dependency should be installed after install_geospatial.sh is run
# remotes::install_github needs a token, or GitHub's unauthenticated API limit (shared
# by runner IPs) fails it with HTTP 403. The token comes in as a BuildKit secret, so it
# exists only during this step and is not stored in the image or its history.
# CI: docker build --secret id=github_pat,env=GITHUB_PAT ...  Local builds work without it.
RUN --mount=type=secret,id=github_pat \
    GITHUB_PAT="$(cat /run/secrets/github_pat 2>/dev/null || true)" \
    /pyrocket_scripts/install-r-packages.sh /tmp/install.R || (echo "install-r-package.sh failed" && exit 1)

# Google Cloud CLI (gcloud, gsutil, bq) from Google's apt repo.
# --no-install-recommends drops google-cloud-cli-anthoscli (~120 MB) that apt would otherwise pull in.
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends google-cloud-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Source Cooperative CLI, pinned release, checksum verified.
# A user who needs a newer version can put one in ~/.local/bin, which comes first on PATH.
ARG SOURCE_COOP_VERSION=0.3.0
ARG SOURCE_COOP_SHA256=213f8d0d2525d66fa8b8a022ecea397847b15c3d42c8bd87470f370b9b3236c0
RUN set -eux; \
    cd /tmp; \
    f=source-coop-cli-x86_64-unknown-linux-gnu.tar.xz; \
    curl -fsSLO "https://github.com/source-cooperative/source-coop-cli/releases/download/v${SOURCE_COOP_VERSION}/${f}"; \
    echo "${SOURCE_COOP_SHA256}  ${f}" | sha256sum -c -; \
    tar -xJf "${f}"; \
    install -m 0755 source-coop-cli-x86_64-unknown-linux-gnu/source-coop /usr/local/bin/source-coop; \
    rm -rf "${f}" source-coop-cli-x86_64-unknown-linux-gnu

# Opt-in installer for tools that update themselves (Claude Code, Antigravity).
# Users run it themselves; it installs into their home, not the image.
RUN install -m 0755 /tmp/scripts/install-user-tools.sh /usr/local/bin/install-user-tools

# Clear out files put in /tmp
RUN rm -rf /tmp/*

USER ${NB_USER}
WORKDIR ${HOME}
