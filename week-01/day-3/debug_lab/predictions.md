# Predictions (written BEFORE running anything)

I read the code of `env_check.py` and predicted what each function
SHOULD return and what it returns NOW (with the bugs).

| Call | Should return | Returns NOW | Why it is wrong now |
|------|---------------|-------------|---------------------|
| `check_version("3.14.0")` | `"ok"` | crashes: `NameError: name 'hnit' is not defined` | `"3.14.0" >= "3.9"` compares TEXT character by character: `"1"` < `"9"`, so it is False and Python goes into the "too old" branch, where the typo `hnit` crashes. |
| `check_version("3.8.10")` | `"too old (need 3.9+), run: uv python install 3.14"` | crashes: `NameError: name 'hnit' is not defined` | The old-version branch is correct in meaning, but it has the typo `hnit` (should be `hint`). |
| `in_virtualenv("/home/sara/proj/.venv", "/usr")` | `True` (prefix and base_prefix are different inside a venv) | `False` | The code uses `==` but a venv means the two are NOT equal. The test is inverted. |
| `in_virtualenv("/usr", "/usr")` | `False` (same prefix = no venv) | `True` | Same inverted `==`. |

Also predicted: the line `interpreter: Python X.Y.Z at /path` will NOT be printed,
because the f-string in `describe_interpreter()` is only evaluated and thrown away
(no `print`).
