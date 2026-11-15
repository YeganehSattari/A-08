# test_bug.py - tests for env_check.py
# run:  uv run python test_bug.py
import sys

from env_check import check_version, in_virtualenv


def test_new_python_is_ok():
    assert check_version("3.14.0") == "ok"


def test_two_digit_minor_is_ok():
    # text comparison says "3.10.1" < "3.9" (wrong!), numbers say it is newer
    assert check_version("3.10.1") == "ok"


def test_old_python_gets_hint():
    # the OLD-version path: the one nobody had ever run before
    result = check_version("3.8.10")
    assert "uv python install 3.14" in result


def test_inside_venv():
    assert in_virtualenv("/home/sara/proj/.venv", "/usr") is True


def test_outside_venv():
    assert in_virtualenv("/usr", "/usr") is False


if __name__ == "__main__":
    tests = [(n, f) for n, f in sorted(globals().items()) if n.startswith("test_")]
    failed = 0
    for name, fn in tests:
        try:
            fn()
            print("PASS", name)
        except Exception as error:
            failed += 1
            print("FAIL", name, "->", type(error).__name__ + ":", error)
    print(f"{len(tests) - failed} passed, {failed} failed")
    sys.exit(1 if failed else 0)
