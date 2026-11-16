# Security - the secret experiment

I created `week-01/day-4/.env` with a FAKE key (`FAKE_API_KEY=not-a-real-key-123`).
Git never sees it, because `.gitignore` has a rule for it. Only the safe template
`config.example.env` (`FAKE_API_KEY=your-key-here`) is committed.

## Evidence (real output)

Which line of `.gitignore` ignores the file:

```text
$ git check-ignore -v week-01/day-4/.env
.gitignore:1:.env	week-01/day-4/.env
```

Git status shows nothing for it (clean), only `--ignored` reveals it with `!!`:

```text
$ git status --short -- week-01/day-4/.env
```

```text
$ git status --short --ignored -- week-01/day-4/.env
!! week-01/day-4/.env
```

The file is in no commit of any branch (empty output = never committed):

```text
$ git log --all --oneline -- week-01/day-4/.env
```

## Why deleting a secret in a later commit is not enough

Git keeps the full history, so a commit that deletes the secret only changes the newest snapshot, while the old commit that contains it stays forever. Anyone who clones the repository can run `git log -p` or `git show <old-hash>` and read the key from that old commit. After a push you must assume the key is public, because bots scan GitHub for keys within minutes and forks and caches keep their own copies. Even `git rm --cached` or `git commit --amend` after a push does not help, since the old commit may already be copied elsewhere.

## What to do instead

1. **Revoke the key first.** Go to the provider, delete the leaked key and create a new one. This is the only step that really fixes the leak.
2. Only then clean the history (for example with `git filter-repo` or BFG) and force-push, and ask everyone to clone again. Treat the old key as dead anyway.
3. **Prevent it:** put `.env` in `.gitignore` BEFORE the first `git add`, commit only an example file like `config.example.env`, and read `git diff --staged` before every commit.
