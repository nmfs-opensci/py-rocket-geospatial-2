# Handoff

Rolling state for agent sessions. Lean: details belong in `docs/design/`.

## Repo state (2026-11-17)

- `main` is the image on py-rocket-base 2026.02.12 (Python 3.11, R 4.5.1).
- **Open: PR #70** (`rebuild-py313-base`, draft). Rebuilds on py-rocket-base
  2026.11.16 (Python 3.13, R 4.6.1), adds the Icechunk stack and cloud CLIs, and
  removes Panoply and cwutils. Plan and decisions are in issue #69; #68 is the
  package requests it covers. Test build run 43986044579 passed build, notebook
  tests and validation. Not yet tried on a hub. The PR body has the details and
  the list of untested items.
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
  AI-assistance statement added, on branch `agent-docs`, separate from #70.

## Pointers

- `AGENTS.md`: rules for agents. `.github/copilot-instructions.md`: conventions.
- `docs/design/`: design notes (index in its README).
- `docs/NOTES.md`: changelog of image changes.
