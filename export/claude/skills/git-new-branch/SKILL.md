---
name: git-new-branch
description: |
  INVOKE WHEN: User asks to start a new branch, create a branch, begin new work, start a new feature/task, or switch to a fresh branch.
  COVERS: Cleaning up the current branch with pr_merged (after confirmation), ensuring main is up-to-date via git-sync, and creating a new branch with the user's name prefix convention.
  DO NOT INVOKE FOR: Opening PRs, reviewing code, or branch operations that don't involve starting fresh work.
---

# Starting a New Git Branch

You are helping the user start a new git branch for fresh work.
Follow this workflow every time, without exception.
You can find all the mentioned user scripts in ~/.my/bin/ (e.g., `pr_merged`, `git-sync`).

## Step 0 — Determine the User's Branch Prefix

```bash
whoami
```

Use the output as the branch prefix (e.g., `pgreze/`).

## Step 1 — Check Current State

```bash
git branch --show-current
```

If the user is NOT on the main branch, ask: "You're currently on `<branch>`. Should I clean it up with `pr_merged`? This will switch to main, pull latest, and delete the current branch."

- If user says yes: run `pr_merged` (this switches to main, syncs via `git-sync`, and deletes the old branch). Skip Step 2.
- If user says no: run `git-sync` to update main without switching. Continue to Step 2.
- If already on main: continue to Step 2.

## Step 2 — Ensure Main Is Up-to-Date

If `pr_merged` was not run in Step 1, sync now:

```bash
git-sync
```

## Step 3 — Create the New Branch

Ask the user for a branch name if not already provided. The branch MUST start with `<whoami>/`.

If the user provides a name without the prefix, add it automatically. For example:
- User says "fix-login" -> `<whoami>/fix-login`
- User says "<whoami>/fix-login" -> use as-is

```bash
git checkout -b <whoami>/<branch-name>
```

## Key Rules Summary

| Rule | Default |
| --- | --- |
| Branch prefix | `<whoami>/` (always enforced) |
| Cleanup tool | `pr_merged` (ask before running) |
| Sync tool | `git-sync` (pull + fetch prune) |
| Base branch | Always branch from up-to-date main |
