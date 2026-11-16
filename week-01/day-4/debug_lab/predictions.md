# Predictions (written BEFORE running anything)

Command: `./week-01/day-4/debug_lab/save_day.sh 01 4 "docs(week-01): add day-4 notes"`
in a practice repo that has `notes.md`, `save_day.sh`, a fake `.env` and a fake `.venv/pyvenv.cfg`.

## What the script is SUPPOSED to do

- `git diff --cached --name-only` shows only the allowed files:
  `.gitignore`, `week-01/day-4/debug_lab/save_day.sh`, `week-01/day-4/notes.md`
- One commit with the full message `docs(week-01): add day-4 notes`
- Push to `origin` branch `main`, and print `saved` only if everything worked.

## What I predict it does NOW (after reading the code)

**Staged files** (`git diff --cached --name-only`), in this order:

```text
.env
.gitignore
week-01/day-3/weather-card/.venv/pyvenv.cfg
week-01/day-4/debug_lab/save_day.sh
week-01/day-4/notes.md
```

Reason: `git add -A` runs BEFORE `write_gitignore`, so at that moment no ignore rule
exists and Git stages everything, including the secret `.env` and the `.venv` folder.

**Commit message:** no commit is made. `-m $msg` has no quotes, so the shell splits the
message into words: only `docs(week-01):` becomes the message, and `add`, `day-4`, `notes`
are treated as file names (pathspecs) -> `error: pathspec 'add' did not match any file(s)`.

**Push:** it fails, because there is no commit and the branch is called `main`, not `master`.

**Last line and exit code:** the script still prints `saved week-01/day-4` and exits with 0,
because nothing stops it after a failed command.

**Extra:** the `.gitignore` it writes would have 4 spaces before every pattern, so even
the late rule would not match `.env` (the spaces are part of the pattern).
