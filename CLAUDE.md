When writing PR descriptions and commit messages:

- Write in first person as if explaining the change to a teammate
- Describe what the change enables, not what it does—"This allows X" rather than "X now does Y." The diff already shows the mechanics
- Be honest about motivations and uncertainty—say "I think" or "I'm hoping" when appropriate
- Name new methods or concepts the reader should know about, but don't walk through the implementation
- Keep the tone conversational and the length proportional to the change—a small fix needs a sentence, a larger refactor might need a couple of paragraphs
- Use a short subject line followed by a blank line and body text
- Don't use structured sections, bullet lists, or test plan checklists
- Use backticks when referencing specific method or class names in code
- When referring to codebase concepts in prose (model names, features, etc.), only capitalize the first mention if it's a new concept

Never use spaces around em dashes—use them like this, not like " — " this.
