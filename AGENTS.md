# Agent instructions for py-rocket-geospatial-2

Edit `AGENTS.md`, not `CLAUDE.md`. `CLAUDE.md` holds only `@AGENTS.md`, so
Claude Code and Antigravity read the same file.

This repository builds the py-rocket-geospatial-2 Docker image: a Python + R
geospatial image for NMFS OpenSci JupyterHubs, layered on
[py-rocket-base](https://github.com/nmfs-opensci/py-rocket-base).

## Read first

- `agent/handoff.md`: where things stand right now. It is orientation, not a task
  list.
- `.github/copilot-instructions.md`: repository layout and conventions (env files,
  `install.R`, pins, Dockerfile rules). They apply to every agent. This file does
  not repeat them.
- `docs/design/`: decisions and why. `docs/NOTES.md`: the user-facing changelog.

## Working rules

- **The env files are installed one after another on purpose.** The conda solve
  became impossible as one file (2026-02). Do not merge them. A package goes in the
  file that installs after its dependencies, including pip-only packages.
- **`reproducibility/` is written by CI.** Do not edit the pins or `build.log` by
  hand. They come back in a `ci/update-pins-*` PR after each build on `main`.
- **A push to `main` publishes `:latest`.** `build-and-push.yml` runs on every push
  to `main` that touches the image files. Never push to `main`; open a PR.
- **Test a change on a branch before it reaches `main`.** Use the `test`-branch
  build (`test-build.yml`, added in #70), which pushes only to the `.../test`
  image. A clean build is the real check: this hub cannot run the full conda solve,
  which runs out of memory.
- **Verify by running.** Say what a build or test printed. If something was not
  run, say so.
- **Name new dependencies in the PR body**, with a link and the reason. Check the
  exact name on conda-forge, PyPI or CRAN first; conda-forge names sometimes
  differ from PyPI's (`obspec_utils`).
- **Base-image problems go to py-rocket-base.** Ask before opening an issue or PR
  there.
