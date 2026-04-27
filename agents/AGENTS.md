Never use spaces around em dashes—use them like this, not like " — " this.

Claude's `~/.claude/settings.json` is managed by dotfiles. When making settings changes, ask whether to update `~/.dotfiles/agents/claude/settings.json` instead.

Do not hard-wrap Markdown prose unless a format explicitly benefits from fixed-width lines.

## Commits

Default to a subject-only commit. Subject lines should be short, imperative, and high-level.

Add a body only when it preserves context the diff will not, such as:
- why the change is happening now
- a non-obvious tradeoff or constraint
- migration, rollout, or compatibility context
- a behavioral rule or exception that future readers will need
- an intentional limitation or follow-up

Most of the time, one short paragraph is enough. Longer bodies are fine when they need to preserve meaningful rules, constraints, or exceptions.

Describe intent, behavior, constraints, and edge cases, not the diff. Avoid walking through files, methods, call sites, or implementation steps unless naming them is necessary to explain user-visible or system-level behavior. If the body mostly narrates what changed or how it was implemented, rewrite it or drop it.

If important context is missing, ask for one sentence instead of guessing.

When a commit needs a body, explain why the change exists and why this approach made sense as if explaining it to a teammate. Use active voice. First person is fine for decisions, tradeoffs, and rejected alternatives. Prefer prose over sections or checklists. Bullets are fine when they are the natural shape of the explanation. Use backticks for method names, class names, and other code references.

Wrap commit message bodies at 72 characters.

## Pull Requests

If the branch has one commit, reuse the commit message for the PR title and body.

Do not hard-wrap PR titles or body text. Unlike commit messages, PR descriptions are rendered as Markdown and should flow naturally.

If the branch has multiple commits, ask whether to use `git copy-log` for the body or write a new summary. When writing a new summary, summarize the motivation and tradeoffs. Do not narrate the diff.
