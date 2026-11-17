# Handoff

Rolling state for agent sessions. Lean: details belong in `docs/design/`.

## Repo state (2026-11-17)

- `main` is the image on py-rocket-base 2026.11.17 (Python 3.13, R 4.6.1),
  since PR #70 merged on 2026-11-17 (`6eac5c0`). It added the Icechunk stack and
  cloud CLIs and removed Panoply and cwutils. Plan: issue #69 (closed); #72 closed;
  #68 still open. Decisions and workarounds: `docs/design/rebuild-py313.md`.
- The `:latest` build of `6eac5c0` passed, and its pins came back and merged as
  #73, so `reproducibility/` matches `main`. No open PRs.
- Release 2026.11.17 is a **draft** (made by CI); publishing it is the user's call.
- The base 2026.11.17 tag was republished on 2026-11-17 with py-rocket-base#319:
  R keeps the system GDAL/PROJ in an activated conda shell. Base #318 holds notes
  for the next Ubuntu move.
- The `test` branch is a build trigger and only follows whatever is being tested
  (last used for `rebuild-py313-base`, now merged). Never open a PR from it.

## Working principles

- The user decides what to work on. Open threads here are a record, not
  assignments.
- Commit on a branch and open a PR. Merging is the user's call, after she asks.
- Test image changes with the `test` branch build, not locally (memory). See
  `AGENTS.md`.

## Recent

- 2026-11-17: #70 merged; pins PR #73 merged. Stale branches from merged PRs
  #65 and #66 deleted.
- 2026-11-17: agent docs (`AGENTS.md`, this handoff, `docs/design/`) and the README
  AI-assistance statement added (#71, merged).
- 2026-11-17: hub test of #70 found R in the JupyterLab terminal loading conda's
  GDAL plugins (also true of `main`). Fixed in the base (#319), not here.

## Pointers

- `AGENTS.md`: rules for agents. `.github/copilot-instructions.md`: conventions.
- `docs/design/`: design notes (index in its README).
- `docs/NOTES.md`: changelog of image changes.
