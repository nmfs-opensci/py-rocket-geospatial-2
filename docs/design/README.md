# Design notes

Decisions about this image and the reasons for them, with evidence. They are for
people and agents reviewing changes. A note records what a future reader could
not work out from the code or git history: things that look wrong but are
deliberate, workarounds, and facts from outside the repository.

`docs/NOTES.md` is the user-facing changelog; it says what changed, not why.

## Notes

| Note | Topic |
|---|---|
| [env-file-split.md](env-file-split.md) | Why the conda environment is installed from several files, one after another |
| [rebuild-py313.md](rebuild-py313.md) | Rebuild on py-rocket-base 2026.11.16 (#69, #70): what is in the image, workarounds and their evidence |
