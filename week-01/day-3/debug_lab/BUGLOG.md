# BUGLOG - Day 3 Debug Lab (env_check.py)

Four bugs were hidden in `env_check.py`. Found with: reading the Traceback
from the bottom up, running the functions in the REPL, and the VS Code
Problems panel (Ctrl+Shift+M).

---

## Bug 1 - `in_virtualenv()` answers the opposite

- **Symptom:** system `python3` (no venv) printed `venv: active (.venv)`;
  inside the project it printed `venv: NOT active`.
- **Predicted:** `in_virtualenv("/usr", "/usr")` -> False, `in_virtualenv("/home/sara/proj/.venv", "/usr")` -> True.
- **Observed (before fix):**
  `in_virtualenv("/usr", "/usr")` -> True and the venv call -> False.
- **Root cause:** inside a venv, `sys.prefix` (the venv) is DIFFERENT from
  `sys.base_prefix` (the real Python). The code returned `prefix == base_prefix`,
  so the answer was inverted.
- **Fix:** `==` changed to `!=`.
- **Test:** `test_inside_venv`, `test_outside_venv`.
- **Lesson:** a function can run without any error and still be wrong. Only a
  test with a known right answer finds a silent logic bug.

## Bug 2 - versions compared as text

- **Symptom:** a new Python (3.14.0) was treated as "too old".
- **Predicted:** `check_version("3.14.0")` -> "ok".
- **Observed (before fix):** it entered the "too old" branch (and then crashed, see Bug 3).
- **Root cause:** `version_text >= MIN_VERSION` compares two STRINGS character by
  character. `"3.14.0"` vs `"3.9"`: the first difference is `"1"` vs `"9"`, and
  `"1" < "9"`, so `"3.14.0" < "3.9"`. Text order is not number order.
- **Fix:** compare tuples of numbers:
  `tuple(int(p) for p in version_text.split(".")) >= (3, 9)`.
- **Test:** `test_new_python_is_ok`, `test_two_digit_minor_is_ok`.
- **Lesson:** always compare versions as numbers (tuples), never as text.

## Bug 3 - typo `hnit` (the bug that only appears on one path)

- **Symptom:** `NameError: name 'hnit' is not defined` on the last line of the Traceback.
- **Predicted:** `check_version("3.8.10")` -> "too old (need 3.9+), run: uv python install 3.14".
- **Observed (before fix):** `NameError` (the variable was created as `hint` but used as `hnit`).
- **Root cause:** a typo inside the "too old" branch. Python does not check names
  before running; it only finds a wrong name when that exact line is reached.
  The branch had never been executed by anybody, so nobody saw the error.
  (VS Code/Pylance showed it as a red underline in the Problems panel.)
- **Fix:** `{hnit}` changed to `{hint}`.
- **Test:** `test_old_python_gets_hint` (it runs the OLD-version path on purpose).
- **Lesson:** an untested branch is a hidden bug. Test the rare path too.

## Bug 4 - an f-string that prints nothing

- **Symptom:** the line `interpreter: Python X.Y.Z at /path` never appeared.
- **Predicted:** the script prints the interpreter line right after `== env check ==`.
- **Observed (before fix):** the line was missing, no error at all.
- **Root cause:** `describe_interpreter()` contained only the expression
  `f"interpreter: ..."`. Python builds the string and throws it away.
  In the REPL a lone expression is printed automatically, so typing it there looks fine;
  in a script nothing prints unless you call `print`.
  (VS Code/Pylance showed a warning: "Expression value is unused".)
- **Fix:** wrapped it in `print(...)`.
- **Test:** checked by running the script: the interpreter line is now printed.
- **Lesson:** see "REPL vs Script" below.

---

## Evidence

Before the fix, system Python:

```text
== env check ==
venv: active (.venv)
Traceback (most recent call last):
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 37, in <module>
    main()
    ~~~~^^
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 32, in main
    print("version check:", check_version(version))
                            ~~~~~~~~~~~~~^^^^^^^^^
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 16, in check_version
    return f"too old (need {MIN_VERSION}+), run: {hnit}"
                                                  ^^^^
NameError: name 'hnit' is not defined
```

Before the fix, inside the project (`uv run python`):

```text
Using CPython 3.14.8
Creating virtual environment at: .venv
== env check ==
venv: NOT active - try: uv run python env_check.py
Traceback (most recent call last):
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 37, in <module>
    main()
    ~~~~^^
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 32, in main
    print("version check:", check_version(version))
                            ~~~~~~~~~~~~~^^^^^^^^^
  File "/home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/env_check.py", line 16, in check_version
    return f"too old (need {MIN_VERSION}+), run: {hnit}"
                                                  ^^^^
NameError: name 'hnit' is not defined
```

`test_bug.py` before the fix (red):

```text
FAIL test_inside_venv -> AssertionError: 
FAIL test_new_python_is_ok -> NameError: name 'hnit' is not defined
FAIL test_old_python_gets_hint -> NameError: name 'hnit' is not defined
FAIL test_outside_venv -> AssertionError: 
FAIL test_two_digit_minor_is_ok -> NameError: name 'hnit' is not defined
0 passed, 5 failed
```

After the fix, `python3 env_check.py` (system Python, venv NOT active):

```text
== env check ==
interpreter: Python 3.14.4 at /usr/bin/python3
venv: NOT active - try: uv run python env_check.py
version check: ok
all checks done
```

After the fix, `uv run python env_check.py` (inside the project, venv active):

```text
== env check ==
interpreter: Python 3.14.8 at /home/paytakht/code/intern-alpha/week-01/day-3/debug_lab/.venv/bin/python
venv: active (.venv)
version check: ok
all checks done
```

`test_bug.py` after the fix (green):

```text
PASS test_inside_venv
PASS test_new_python_is_ok
PASS test_old_python_gets_hint
PASS test_outside_venv
PASS test_two_digit_minor_is_ok
5 passed, 0 failed
```

---

## Lesson: REPL vs Script

- The **REPL** runs ONE line at a time and prints the value of every expression
  immediately. Each line is a tiny separate experiment, so a mistake shows up
  exactly when I type that line.
- A **Script** is read as a whole file and then runs from top to bottom. A function
  body does not run until the function is called, and an `if/else` branch does not run
  until the condition sends Python there. A lone expression prints nothing.
- That is why my code "worked" in the REPL (I tested pieces one by one, and the
  f-string printed by itself) but "lied" as a script (the typo sat in a branch
  nobody ran, and the f-string was silent).
- **Python only understands a name mistake when it reaches the line.** A wrong name
  is not found at the start; it crashes at the moment that line is executed.
- Also: `python3 file.py` uses the system Python, while `uv run python file.py`
  uses the project's `.venv`. Same file, different interpreter, different answer to
  "is a venv active?".
