# weather-card

A tiny Python project managed by **uv**. It prints a green panel with the
**rich** library.

Run it:

    uv run main.py

## What each file does

| File / folder | Role | Commit to Git? |
|---|---|---|
| `pyproject.toml` | The project's ID card: name, version, required Python, and the `dependencies` list (here: `rich`). You edit it (or `uv add` edits it for you). | YES |
| `uv.lock` | The exact versions of every package (rich and the packages rich needs) with hashes. It makes every computer install the SAME versions. Never edit by hand. | YES |
| `.python-version` | Says which Python version this project uses (now: `3.14`). uv reads it to pick the right interpreter. | YES |
| `.venv/` | The virtual environment: a private folder with the interpreter link and the installed packages for THIS project only. It is generated, so it can be deleted and rebuilt any time. | NO (add to .gitignore) |

Short version: `pyproject.toml` = what I want, `uv.lock` = exactly what I got,
`.venv` = the installed result.

## Rebuild time of .venv

I deleted `.venv` with `rm -rf .venv` and ran `uv run main.py` again.
uv rebuilt everything from `uv.lock`:

- total time: **0.15 seconds**
- uv output: `Creating virtual environment at: .venv;Installed 5 packages in 6ms`

It is fast because uv is written in Rust and caches downloaded packages,
so a deleted `.venv` is never a problem.

## VS Code

The interpreter is set to this project's `.venv/bin/python`
(Ctrl+Shift+P -> "Python: Select Interpreter" -> pick the one inside `weather-card/.venv`),
so `import rich` has no red line.
