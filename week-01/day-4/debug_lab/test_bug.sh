#!/usr/bin/env bash
# test_bug.sh - runs save_day.sh in a fresh throw-away repo and checks the result.
# usage: ./test_bug.sh [path/to/save_day.sh]     (default: save_day.sh next to this file)
export GIT_TERMINAL_PROMPT=0 GIT_PAGER=cat

here=$(cd "$(dirname "$0")" && pwd)
script="${1:-$here/save_day.sh}"
msg="docs(week-01): add day-4 notes"
fails=0

pass() { echo "ok:   $*"; }
fail() { echo "FAIL: $*"; fails=$((fails + 1)); }
check() { local text="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$text"; else fail "$text"; fi; }

# helper checks (each one succeeds when the situation is GOOD)
env_not_tracked()    { ! git ls-files --error-unmatch .env; }
venv_not_tracked()   { [ -z "$(git ls-files | grep '\.venv/')" ]; }
one_commit()         { [ "$(git rev-list --count HEAD)" = "1" ]; }
message_is_full()    { [ "$(git log -1 --format=%s)" = "$msg" ]; }
remote_has_main()    { [ -n "$(git ls-remote origin main)" ]; }
only_allowed_files() {
  [ "$(git ls-tree -r --name-only HEAD | sort | tr '\n' ' ')" = ".gitignore week-01/day-4/debug_lab/save_day.sh week-01/day-4/notes.md " ]
}

make_lab() {   # $1 = origin url
  git init -q -b main lab && cd lab || exit 1
  git config user.name "tester"; git config user.email "tester@example.com"
  git remote add origin "$1"
  mkdir -p week-01/day-4/debug_lab week-01/day-3/weather-card/.venv/bin
  echo "# day 4" > week-01/day-4/notes.md
  echo "home = /usr/bin" > week-01/day-3/weather-card/.venv/pyvenv.cfg
  echo "FAKE_API_KEY=not-a-real-key-123" > .env
  cp "$script" week-01/day-4/debug_lab/save_day.sh
  chmod +x week-01/day-4/debug_lab/save_day.sh
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "--- scenario A: everything should work ---"
cd "$tmp" && git init -q --bare remote.git
make_lab "$tmp/remote.git"
out=$(./week-01/day-4/debug_lab/save_day.sh 01 4 "$msg" 2>&1); rc=$?
check ".env is ignored by .gitignore"            git check-ignore -q .env
check ".venv is ignored by .gitignore"           git check-ignore -q week-01/day-3/weather-card/.venv/pyvenv.cfg
check ".env is not tracked"                      env_not_tracked
check ".venv files are not tracked"              venv_not_tracked
check "exactly one commit was created"           one_commit
check "commit message is the full message"       message_is_full
check "only the allowed files are in the commit" only_allowed_files
check "origin/main has the commit"               remote_has_main
[ "$rc" = "0" ] && pass "exit code is 0" || fail "exit code is $rc (expected 0)"

echo "--- scenario B: the push fails (origin does not exist) ---"
cd "$tmp" && rm -rf lab
make_lab "$tmp/does-not-exist.git"
out=$(./week-01/day-4/debug_lab/save_day.sh 01 4 "$msg" 2>&1); rc=$?
[ "$rc" != "0" ] && pass "exit code is not 0 when push fails" || fail "exit code is 0 although the push failed"
case "$out" in
  *saved*) fail "script printed 'saved' although the push failed" ;;
  *)       pass "script did not print 'saved'" ;;
esac

echo "--- result ---"
echo "$fails FAIL"
[ "$fails" -eq 0 ]
