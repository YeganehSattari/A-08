# REPL Detective - Day 3

Format: expression | my guess (before Enter) | real output | why.

> NOTE: the "My guess" column is the part you must fill in with YOUR OWN
> honest prediction BEFORE running each line in `uv run python`.
> The real outputs and reasons below come from running them in Python.

| # | Expression | My guess | Real output | Why |
|---|------------|----------|-------------|-----|
| 1 | `10 / 3` | _write yours_ | `3.3333333333333335` | `/` is true division, it always returns a float. 1/3 has no exact binary form, so the last digits are noise. |
| 2 | `10 // 3` | _write yours_ | `3` | `//` is floor division: the quotient rounded down. |
| 3 | `10 % 3` | _write yours_ | `1` | `%` is the remainder: 10 = 3*3 + 1. |
| 4 | `2 ** 10` | _write yours_ | `1024` | `**` is power: 2 multiplied by itself 10 times. |
| 5 | `"5" + "5"` | _write yours_ | `'55'` | Both are strings, so `+` joins (concatenates) them. It is not math. |
| 6 | `"5" * 3` | _write yours_ | `'555'` | `str * int` repeats the string 3 times. |
| 7 | `len("INTERN.EXE")` | _write yours_ | `10` | Counts characters: 6 letters + dot + 3 letters = 10. |
| 8 | `type(3.0)` | _write yours_ | `<class 'float'>` | A number with a decimal point is a float, even if it is a whole number. |
| 9 | `type("3")` | _write yours_ | `<class 'str'>` | Anything inside quotes is a string, even digits. |
| 10 | `round(2.675, 2)` | _write yours_ | `2.67` | Surprise! Looks like it should be 2.68. See explanation below. |
| 11 | `0.1 + 0.2` | _write yours_ | `0.30000000000000004` | Surprise! See explanation below. |
| 12 | `"Hello".upper()` | _write yours_ | `'HELLO'` | `.upper()` is a string method that returns a new upper-case string. |

## Why `0.1 + 0.2` is not exactly `0.3`

Computers store floats in binary (base 2). Just like 1/3 = 0.333... never
ends in base 10, the number 0.1 never ends in base 2. Python stores the
closest value it can: `0.1` is really `0.1000000000000000055511151231257827...`
and `0.2` has a similar tiny error. When they are added, the tiny errors
add up and the result is `0.30000000000000004`.
To compare floats use `math.isclose(a, b)` or the `decimal` module.

## Why `round(2.675, 2)` gives `2.67` and not `2.68`

The number `2.675` cannot be stored exactly in binary either. The real
stored value is `2.67499999999999982236431605997495353221893310546875`,
which is slightly BELOW 2.675. So rounding to 2 digits correctly goes down
to `2.67`. The problem is not `round()`, it is the float storage.

## My own 3 experiments

| # | Expression | My guess | Real output | Why |
|---|------------|----------|-------------|-----|
| 13 | `7 / 2` | _write yours_ | `3.5` | True division always gives a float. |
| 14 | `-7 // 2` | _write yours_ | `-4` | Floor division rounds toward minus infinity (down), not toward zero. |
| 15 | `"abc"[::-1]` | _write yours_ | `'cba'` | Slice with step -1 walks the string backwards. |
