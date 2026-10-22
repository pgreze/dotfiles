# Agent instructions

Never use git worktrees in this repository unless the user asks for one.
Edit files directly in this checkout.

Commit each logical change on its own, as soon as it works.
Stage only the files of that change, and say what changed and why in the message.

After changing export/ghostty or export/herdr, run `~/bin/reload-ghostty-herdr` to validate and live-reload both apps.
