# Time Machine - Day 4

Every command below was really run, and the output is copied as it was printed.
An empty output block means the command printed nothing (that is normal for a clean state).

## 1. The history of story.txt

```text
$ git log --oneline -- week-01/day-4/story.txt
3cc1853 docs(day-4): add line 5 - the push
c20b0a6 docs(day-4): add line 4 - the fix
6989076 docs(day-4): add line 3 - the first bug
48bc5a0 docs(day-4): add line 2 - the first command
affab45 docs(day-4): start story.txt with the first line
```

## 2. Break a line on purpose and look at it with git diff

```text
$ sed -i '3d' week-01/day-4/story.txt
```

```text
$ git diff -- week-01/day-4/story.txt
diff --git a/week-01/day-4/story.txt b/week-01/day-4/story.txt
index 47e92f1..f5e437f 100644
--- a/week-01/day-4/story.txt
+++ b/week-01/day-4/story.txt
@@ -1,5 +1,4 @@
 Once upon a time, an intern opened a terminal for the first time.
 She typed her first command and the computer answered.
-Then a bug appeared, and it looked scary.
 She read the error from the bottom up and fixed it.
 She pushed her work to GitHub and slept well.
```

The line starting with `-` is the line I deleted. Nothing is committed yet.

## 3. Go back with git restore

```text
$ git restore week-01/day-4/story.txt
```

```text
$ git status --short
?? week-01/day-4/README.md
?? week-01/day-4/time_machine.md
```

```text
$ cat week-01/day-4/story.txt
Once upon a time, an intern opened a terminal for the first time.
She typed her first command and the computer answered.
Then a bug appeared, and it looked scary.
She read the error from the bottom up and fixed it.
She pushed her work to GitHub and slept well.
```

## 4. git diff vs git diff --staged

```text
$ sed -i '2s/.*/THIS LINE IS BROKEN/' week-01/day-4/story.txt
```

```text
$ git add week-01/day-4/story.txt
```

```text
$ git diff -- week-01/day-4/story.txt
```

```text
$ git diff --staged -- week-01/day-4/story.txt
diff --git a/week-01/day-4/story.txt b/week-01/day-4/story.txt
index 47e92f1..85a1f31 100644
--- a/week-01/day-4/story.txt
+++ b/week-01/day-4/story.txt
@@ -1,5 +1,5 @@
 Once upon a time, an intern opened a terminal for the first time.
-She typed her first command and the computer answered.
+THIS LINE IS BROKEN
 Then a bug appeared, and it looked scary.
 She read the error from the bottom up and fixed it.
 She pushed her work to GitHub and slept well.
```

```text
$ git restore --staged week-01/day-4/story.txt
```

```text
$ git restore week-01/day-4/story.txt
```

```text
$ git status --short
?? week-01/day-4/README.md
?? week-01/day-4/time_machine.md
```

**Explanation:** `git diff` compares the working folder with the staging area (changes I have NOT staged yet). `git diff --staged` compares the staging area with the last commit (what WILL go into the next commit). After `git add` the first one is empty and the second one shows the change, as seen above.

## 5. The second commit (48bc5a0): what exactly was added

```text
$ git show 48bc5a0
commit 48bc5a0bf0849921a114c7b48cfbb40c8714ee17
Author: YeganehSattari <yeganeh.s9889@yahoo.com>
Date:   Mon Nov 16 18:18:17 2026 +0330

    docs(day-4): add line 2 - the first command

diff --git a/week-01/day-4/story.txt b/week-01/day-4/story.txt
index 44e1c9e..c46a47e 100644
--- a/week-01/day-4/story.txt
+++ b/week-01/day-4/story.txt
@@ -1 +1,2 @@
 Once upon a time, an intern opened a terminal for the first time.
+She typed her first command and the computer answered.
```

## 6. The whole file as it was at that moment

```text
$ git show 48bc5a0:week-01/day-4/story.txt
Once upon a time, an intern opened a terminal for the first time.
She typed her first command and the computer answered.
```

Only the first two lines existed back then, so the time machine really works.

