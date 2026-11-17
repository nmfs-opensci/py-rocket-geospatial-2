# Handoff

Rolling state for agent sessions. Lean: details belong in `docs/design/`.

## Repo state (2026-11-17)

- `main` is the image on py-rocket-base 2026.02.12 (Python 3.11, R 4.5.1).
- **Open: PR #70** (`rebuild-py313-base`, ready for review, not merged). It
  rebuilds on py-rocket-base 2026.11.17 (Python 3.13, R 4.6.1), adds the Icechunk
  stack and cloud CLIs, and removes Panoply and cwutils. Plan and decisions are in
  issue #69; #68 and #72 are covered too. Test build run 44009526507 (`501bd72`)
  passed. The user tested that image on a hub: CLIs, Python, RStudio, and R in a
  JupyterLab terminal all OK. The PR body has the test record. Decisions and
  workarounds: `docs/design/rebuild-py313.md`.
- The base 2026.11.17 tag was republished on 2026-11-17 with py-rocket-base#319:
  R keeps the system GDAL/PROJ in an activated conda shell. Base #318 holds notes
  for the next Ubuntu move.
- The `test` branch is a build trigger and only follows whatever is being tested
  (now `rebuild-py313-base`). Never open a PR from it.

## Working principles

- The user decides what to work on. Open threads here are a record, not
  assignments.
- Commit on a branch and open a PR. Merging is the user's call, after she asks.
- Test image changes with the `test` branch build, not locally (memory). See
  `AGENTS.md`.

## Recent

- 2026-11-17: agent docs (`AGENTS.md`, this handoff, `docs/design/`) and the README
  AI-assistance statement added (#71, merged).
- 2026-11-17: hub test of #70 found R in the JupyterLab terminal loading conda's
  GDAL plugins (also true of `main`). Fixed in the base (#319), not here.

## Pointers

- `AGENTS.md`: rules for agents. `.github/copilot-instructions.md`: conventions.
- `docs/design/`: design notes (index in its README).
- `docs/NOTES.md`: changelog of image changes.
