# BUGLOG - Day 4 Debug Lab (save_day.sh)

Script under test: `save_day.sh WEEK DAY "type(scope): message"`.
It was run ONLY in a practice repo (`~/playground`), never in this repository.
Tools used: `bash -x` (real arguments), `git check-ignore -v`, `git ls-files --cached`,
`git branch --show-current`, `cat -A` (shows invisible spaces).

Symptom of all four together: the script printed `saved` and exited with 0, but
no commit existed, nothing was on the remote, and `.env` + `.venv` were staged.

---

## Bug 1 - stage BEFORE the ignore rules exist

- **Symptom:** `.env` and `week-01/day-3/weather-card/.venv/pyvenv.cfg` appeared in `== staged files ==`.
- **Predicted:** only `.gitignore`, `save_day.sh`, `notes.md` are staged.
- **Observed (before fix):** `.env`, `.gitignore`, the `.venv` file, `save_day.sh`, `notes.md` were all staged.
- **Root cause:** `git add -A` ran first and `write_gitignore` second. `.gitignore` only
  affects files that are not staged yet, so everything was already in the index.
- **Fix:** call `write_gitignore` first, then `git add -A`.
- **Test:** `.env is not tracked`, `.venv files are not tracked`, `only the allowed files are in the commit`.
- **Lesson:** the order of operations is part of the logic: first the rules, then the staging.

## Bug 2 - spaces inside the heredoc made the patterns useless

- **Symptom:** even after the rules were written, `git check-ignore -v .env` printed nothing.
- **Predicted:** `.env` matches the `.env` rule.
- **Observed (before fix):** `cat -A .gitignore` showed `    .venv/$` - four spaces before every line.
- **Root cause:** the heredoc lines were indented. In `.gitignore` the spaces at the start
  of a line are part of the pattern, so the pattern was `"    .env"`, which matches no file.
- **Fix:** remove the indentation inside the heredoc (the lines start at column 0).
- **Test:** `.env is ignored by .gitignore`, `.venv is ignored by .gitignore`.
- **Lesson:** in config files whitespace is data. Look at invisible characters with `cat -A`.

## Bug 3 - `$msg` without double quotes

- **Symptom:** `error: pathspec 'add' did not match any file(s) known to git` (also for `day-4` and `notes`) and no commit.
- **Predicted:** one commit with the full message.
- **Observed (before fix):** `bash -x` showed `git commit -q -m 'docs(week-01):' add day-4 notes` - the message was split into 4 words.
- **Root cause:** an unquoted variable is split by spaces (word splitting). Git got
  `-m docs(week-01):` as the message and `add day-4 notes` as file names.
- **Fix:** `git commit -q -m "$msg"`.
- **Test:** `exactly one commit was created`, `commit message is the full message`.
- **Lesson:** always put variables in double quotes (same rule as Day 2).

## Bug 4 - wrong branch name `master`

- **Symptom:** `error: src refspec master does not match any`, and nothing arrived on the remote.
- **Predicted:** the push sends the commit to `origin/main`.
- **Observed (before fix):** `git branch --show-current` printed `main`, but the script pushed `master`.
- **Root cause:** the practice repo uses `main` (`git init -b main`), the script hard-coded the old default name `master`.
- **Fix:** `git push -q origin main`.
- **Test:** `origin/main has the commit`.
- **Lesson:** do not assume a branch name; check with `git branch --show-current`.

---

## Why did it still print `saved` with exit code 0?

A shell script keeps going after a failed command unless you tell it to stop. The last
command was `echo`, which always succeeds, so the exit code was 0. The safety net is
`set -euo pipefail` at the top (`-e` stop at the first failing command, `-u` error on
unset variables, `-o pipefail` fail if any command in a pipe fails). With it, a failed
push stops the script, `saved` is not printed and the exit code is not 0
(tested in `test_bug.sh`, scenario B).

## Evidence

Before the fix, real run in the practice repo:

```text
$ ./week-01/day-4/debug_lab/save_day.sh 01 4 "docs(week-01): add day-4 notes"
== staged files ==
.env
.gitignore
week-01/day-3/weather-card/.venv/pyvenv.cfg
week-01/day-4/debug_lab/save_day.sh
week-01/day-4/notes.md
error: pathspec 'add' did not match any file(s) known to git
error: pathspec 'day-4' did not match any file(s) known to git
error: pathspec 'notes' did not match any file(s) known to git
error: src refspec master does not match any
error: failed to push some refs to '/home/paytakht/playground/remote.git'
saved week-01/day-4
$ echo $?
0
$ git log --oneline
fatal: your current branch 'main' does not have any commits yet
$ git log origin/main --oneline
fatal: ambiguous argument 'origin/main': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
$ cat -A .gitignore
    .venv/$
    __pycache__/$
    .env$
$ git status --short
A  .env
A  .gitignore
A  week-01/day-3/weather-card/.venv/pyvenv.cfg
A  week-01/day-4/debug_lab/save_day.sh
A  week-01/day-4/notes.md
$ git check-ignore -v .env  (no output = no rule matched)
$ git ls-files --cached
.env
.gitignore
week-01/day-3/weather-card/.venv/pyvenv.cfg
week-01/day-4/debug_lab/save_day.sh
week-01/day-4/notes.md
$ git branch --show-current
main
```

What git really received (`bash -x`):

```text
+ git commit -q -m 'docs(week-01):' add day-4 notes
+ git push -q origin master
```

`test_bug.sh` before the fix:

```text
--- scenario A: everything should work ---
FAIL: .env is ignored by .gitignore
FAIL: .venv is ignored by .gitignore
FAIL: .env is not tracked
FAIL: .venv files are not tracked
FAIL: exactly one commit was created
FAIL: commit message is the full message
FAIL: only the allowed files are in the commit
FAIL: origin/main has the commit
ok:   exit code is 0
--- scenario B: the push fails (origin does not exist) ---
FAIL: exit code is 0 although the push failed
FAIL: script printed 'saved' although the push failed
--- result ---
10 FAIL
```

The fix:

```diff
--- /tmp/save_day.buggy.sh	2026-11-16 23:28:26.597063857 +0330
+++ /home/paytakht/code/a-08/week-01/day-4/debug_lab/save_day.sh	2026-11-16 23:28:26.755623739 +0330
@@ -1,10 +1,11 @@
 #!/usr/bin/env bash
+set -euo pipefail
 # save_day.sh - stage, commit and push today's work
 # usage: ./save_day.sh WEEK DAY "type(scope): message"
 
-week=$1
-day=$2
-msg=$3
+week=${1:-}
+day=${2:-}
+msg=${3:-}
 
 if [ -z "$msg" ]; then
   echo "usage: ./save_day.sh WEEK DAY \"type(scope): message\""
@@ -13,19 +14,19 @@
 
 write_gitignore() {
   cat > .gitignore <<EOF
-    .venv/
-    __pycache__/
-    .env
+.venv/
+__pycache__/
+.env
 EOF
 }
 
-git add -A
 write_gitignore
+git add -A
 git add .gitignore
 
 echo "== staged files =="
 git diff --cached --name-only
 
-git commit -q -m $msg
-git push -q origin master
+git commit -q -m "$msg"
+git push -q origin main
 echo "saved week-$week/day-$day"
```

`test_bug.sh` after the fix:

```text
--- scenario A: everything should work ---
ok:   .env is ignored by .gitignore
ok:   .venv is ignored by .gitignore
ok:   .env is not tracked
ok:   .venv files are not tracked
ok:   exactly one commit was created
ok:   commit message is the full message
ok:   only the allowed files are in the commit
ok:   origin/main has the commit
ok:   exit code is 0
--- scenario B: the push fails (origin does not exist) ---
ok:   exit code is not 0 when push fails
ok:   script did not print 'saved'
--- result ---
0 FAIL
```

Fixed script in the practice repo:

```text
$ ./week-01/day-4/debug_lab/save_day.sh 01 4 "docs(week-01): add day-4 notes"
== staged files ==
.gitignore
week-01/day-4/debug_lab/save_day.sh
week-01/day-4/notes.md
saved week-01/day-4
$ echo $?
0
$ git log --oneline
df33794 docs(week-01): add day-4 notes
$ git log origin/main --oneline
df33794 docs(week-01): add day-4 notes
$ cat -A .gitignore
.venv/$
__pycache__/$
.env$
$ git status --short
$ git check-ignore -v .env  (no output = no rule matched)
.gitignore:3:.env	.env
$ git ls-files --cached
.gitignore
week-01/day-4/debug_lab/save_day.sh
week-01/day-4/notes.md
$ git branch --show-current
main
```

shellcheck: `shellcheck is not installed (install: sudo apt install shellcheck). Skipped.`

## Lesson: what this lab taught me

A script that prints `saved` proves nothing; only the result proves it (`git log origin/main`).
Four small mistakes (order, spaces, quotes, branch name) each look harmless, but together
they leak a secret while the script reports success. Fix: make the script fail loudly
(`set -euo pipefail`), and test the result, not the message.
