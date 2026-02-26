---
name: pr
description: Create a GitHub pull request for the current branch
user-invocable: true
---

# Pull Request

Create a GitHub pull request for the current branch using `gh pr create`. Push the branch first if needed.

If the branch has a single commit, use its message directly as the PR title and description—don't rewrite it.

If there are multiple commits, ask whether to run `git copy-log` (which formats the commits as a bulleted list and copies to clipboard) and use that as the body, or write a new summary.

When writing a new summary, follow the same style as the `/commit` skill—first person, conversational, focused on why not what. Don't append a "Generated with Claude Code" line.
