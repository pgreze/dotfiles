---
name: opening-pull-requests
description: |
  INVOKE WHEN: User asks to open a PR, create a pull request, submit a PR, push and open PR, or similar.
  COVERS: Creating GitHub pull requests with gh CLI following pgreze's personal workflow: draft by default, branch naming (pgreze/ prefix), PR description with WHAT/WHY/HOW TO TEST sections, always asking for ticket/issue/Slack links to include in the description.
  DO NOT INVOKE FOR: Reviewing existing PRs, merging PRs, or updating PR metadata after creation.
---

# Opening Pull Requests

You are helping pgreze open a GitHub PR. Follow this workflow every time, without exception.

## Step 1 — Branch Name

If not already on a feature branch, ensure the branch name starts with `pgreze/`.

```bash
# Check current branch
git branch --show-current
```

If the branch doesn't start with `pgreze/`, rename it or ask the user to confirm the intended branch name before proceeding.

## Step 2 — Gather Required Info (ALWAYS ask these)

Before creating the PR, always ask for the following if not already provided:

1. Ticket / issue link — Jira, GitHub Issue, or Linear URL (any is valid). Ask: "Do you have a Jira/GitHub Issue/Linear ticket link to include in the PR description?"
2. Slack thread link — If relevant. Ask: "Is there a Slack thread to reference?"
3. Draft or ready? — Default is DRAFT unless the user explicitly says "not draft", "ready for review", or "merge-ready".

## Step 3 — Find or Build the PR Description Template

Check if the repo has a PR template:

```bash
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "NO_TEMPLATE"
```

- If template exists: Use it as the base for the PR body.
- If no template: Use the default template below.

### Default PR Description Template

Use the template from `PULL_REQUEST_TEMPLATE.md` in this skill's directory (`~/.claude/skills/opening-pull-requests/PULL_REQUEST_TEMPLATE.md`).

## Step 4 — Fill in the Description

Fill in the template sections:

- WHAT: Summarize the code changes (what was added/changed/removed).
- WHY: Explain the motivation (ticket context, bug being fixed, feature being added).
- HOW TO TEST: Include testing steps if applicable.

Always append the ticket/issue and Slack thread links on top of the PR description before the WHAT/WHY/HOW TO TEST sections, formatted like this:

```
- Ticket: <ticket-link>
- Slack: <slack-thread-link>  (only if provided)
```

## Step 5 — Create the PR with gh CLI

Use the `gh pr create` command to open the PR after having pushed the new branch, passing the filled description and setting the draft status based on user input.

```bash
gh pr create --draft --title "..." --body "$(cat <<'EOF'
...
EOF
)"
```

## Step 6 — Confirm and Share

After creation, output the PR URL and confirm:
- Whether it was created as draft or ready
- The base branch it targets
- A reminder to add reviewers when ready (if draft)

## Key Rules Summary

| Rule | Default |
| --- | --- |
| Draft? | Yes (unless user says otherwise) |
| Branch Prefix | pgreze/ |
| Template source | .github/PULL_REQUEST_TEMPLATE.md or default template |
| Required link | ALWAYS ask - jira / github issue / linear / etc |
| Slack link | Ask - include if provided |
| CLI tool | gh CLI |
