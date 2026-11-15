import platform
import sys

MIN_VERSION = "3.9"
RECOMMENDED = "3.14"


def in_virtualenv(prefix, base_prefix):
    return prefix != base_prefix


def check_version(version_text):
    if tuple(int(p) for p in version_text.split(".")) >= (3, 9):
        return "ok"
    hint = f"uv python install {RECOMMENDED}"
    return f"too old (need {MIN_VERSION}+), run: {hint}"


def describe_interpreter():
    version = platform.python_version()
    print(f"interpreter: Python {version} at {sys.executable}")
    return version


def main():
    print("== env check ==")
    version = describe_interpreter()
    if in_virtualenv(sys.prefix, sys.base_prefix):
        print("venv: active (.venv)")
    else:
        print("venv: NOT active - try: uv run python env_check.py")
    print("version check:", check_version(version))
    print("all checks done")


if __name__ == "__main__":
    main()
