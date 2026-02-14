This release provides a cloud-ready Docker image for Python–R geospatial and earth-science workflows, designed for use in shared JupyterHub and similar multi-user environments.

**py-rocket-geospatial-2** integrates modern Python and R geospatial stacks with tools commonly used across oceanography, climate science, hydrology, and remote sensing. The image follows design patterns from the Pangeo ecosystem and emphasizes scalable, array-based analysis of large spatiotemporal datasets.

### What this image provides
- **Python geospatial stack** optimized for large datasets, distributed computing, and cloud-native object storage
- **R + RStudio** with geospatial packages installed using Rocker Project scripts
- **JupyterLab** with both Python and R kernel support
- **Desktop environment (VNC)** for GUI-based tools such as QGIS and Panoply
- **VS Code OSS** configured for scientific notebooks and Quarto
- **Publishing toolchain** including Quarto, JupyterBook, MyST, Pandoc, and TeX Live
- **Helper scripts** (`pyrocket_scripts`, `rocker_scripts`) to support customization and extension

### Intended use
This image is intended to lower barriers for reproducible, cloud-ready analysis of large earth-system datasets, including workflows that authenticate and access data from NASA Earthdata, NOAA and other major earth-observation archives.

### Licensing & attribution
The resulting container image is released under the **Apache-2.0 License**.  
Rocker installation scripts retain their original **GPL-2.0-or-later** licensing.

Attribution is appreciated when this container image is used, adapted, or redistributed.
