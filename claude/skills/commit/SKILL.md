---
name: commit
description: Stage and commit changes with a well-written message
user-invocable: true
---

# Commit

Create a git commit for the current changes. Make sure you understand what's being committed before writing the message—check the status and diff if you don't already have that context. Stage files by name rather than using `git add -A` or `git add .`.

## Writing the commit message

The commit message should explain *why* the change exists, not what the diff already shows. Write in first person as if explaining the change to a teammate.

- **Subject line**: short, imperative, under ~70 characters.
- **Body** (after a blank line): describe what the change enables and the motivation behind it. Mention alternatives you considered and why you chose this approach. Name new methods or concepts the reader should know about, but don't walk through the implementation.
- Keep the tone conversational and the length proportional to the change—a small fix needs a sentence, a larger refactor might need a couple of paragraphs.
- Don't use structured sections, bullet lists, or test plan checklists.
- Use backticks when referencing specific method or class names in code.
- When referring to codebase concepts in prose, only capitalize the first mention if it's a new concept.

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
