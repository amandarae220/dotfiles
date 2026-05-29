# Global Claude Defaults

## Communication
- Be concise and direct. No fluff, no preamble.
- Show code first, explain after — only if explanation adds value.
- When there are tradeoffs, state them in one line each.
- Never apologize. Never over-explain. Just solve.

## Loaded Skills
The following skills apply to every session regardless of project.
Reference them before acting on any task of that type.

- Commit review: ~/.claude/skills/global/commit-review.md
- Accessibility: ~/.claude/skills/global/accessibility.md
- Code quality: ~/.claude/skills/global/code-quality.md
- Security: ~/.claude/skills/global/security.md
- Anti-patterns: ~/.claude/skills/global/anti-patterns.md
- PR template: ~/.claude/skills/global/pr-template.md
- Decision log: ~/.claude/skills/global/decision-log-template.md
- README (personal projects): ~/.claude/skills/global/readme-personal.md

## General Rules
- Always check if a solution already exists in the codebase before creating new.
- Never use raw values — defer to tokens, constants, or config.
- Every component must meet WCAG 2.1 AA minimum.
- Never commit secrets, tokens, or credentials in any form.
- Atomic commits only. One concern per commit.
