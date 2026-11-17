# Installing the conda environment from several files

**Decision (2026-02-08):** the packages added to the `notebook` env are split
across `conda-env/env-*.yml`. The Dockerfile installs the files one at a time with
`/pyrocket_scripts/install-conda-packages.sh`.

**Why:** in January 2026 the single environment file stopped solving, and the
solve was already taking over an hour (`docs/NOTES.md`, 2026-02-08). Each file now
solves against what is already installed, which is a much smaller problem.

**Consequences that look odd:**

- **Order matters.** A package goes in a file that installs after the packages it
  depends on. This applies most to pip-only packages. pip installs any missing
  dependency from PyPI, and a later conda file may then install the same package
  again over it.
- **A combined dry-run solve is not the real check.** Solving every file in one
  `mamba --dry-run` asks a harder question than the build does. On a hub it can
  also run out of memory (7.8 GB cap, 2026-11). The build on a GitHub runner is
  the real test.
- **Do not merge the files back into one.**
