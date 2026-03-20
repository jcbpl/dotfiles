---
name: commit
description: Stage and commit changes with a well-written message
user-invocable: true
---

# Commit

Create a git commit for the current changes. Make sure you understand what's being committed before writing the message—check the status and diff if you don't already have that context. Stage files by name rather than using `git add -A` or `git add .`.

## Writing the commit message

The commit message should explain *why* the change exists. Write as if explaining the change to a teammate.

- **Subject line**: short, imperative, under ~70 characters. Communicate the intent of the change at a high level—leave specifics like file paths and method names for the body.
- **Body** (after a blank line): explain what was wrong and why this approach. State the change plainly at the level a teammate would in conversation—don't explain how the code works. The reader has the diff; they need the *why*, not a walkthrough of *what* you changed. If you catch yourself narrating the implementation, stop and rewrite.
- Use active voice. The default subject is "this" (the commit)—e.g., "This removes the migration layer." Use first person freely, especially for decisions, trade-offs, and alternatives—e.g., "I went with X over Y because..."
- Be concise. A small fix needs a sentence or two, not a paragraph. A larger change might need a couple of paragraphs—but only if the *reasoning* warrants it. When in doubt, err short.
- Wrap the body at 72 characters.
- Don't use structured sections or test plan checklists. Bullet lists are fine when they're the natural format (e.g., listing a few discrete items), but don't default to them—prefer prose.
- Always use backticks for method names, class names, and other code references.
- When referring to codebase concepts in prose, use lowercase unless you're introducing something new to the reader. Use backticks and the actual class name when precision matters.

Always pass the message via a HEREDOC and append the co-author trailer:

```
git commit -m "$(cat <<'EOF'
Subject line here

Body text here.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

After committing, run `git status` to confirm success.
