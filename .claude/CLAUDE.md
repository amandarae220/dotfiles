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
- Testing anti-patterns: ~/.claude/skills/global/testing-anti-patterns.md
- PR template: ~/.claude/skills/global/pr-template.md
- Decision log: ~/.claude/skills/global/decision-log-template.md
- README (personal projects): ~/.claude/skills/global/readme-personal.md
- Portfolio writing (data-journalism voice & structure): ~/.claude/skills/global/portfolio-writing.md
- Writing voice (Amanda's tone across everything she writes): ~/.claude/skills/global/voice.md
- Brainstorming (design-first before any feature work): ~/.claude/skills/global/brainstorming.md
- Writing plans (implementation plans before touching code): ~/.claude/skills/global/writing-plans.md
- Test-driven development (TDD red-green-refactor): ~/.claude/skills/global/test-driven-development.md
- Systematic debugging (root cause before any fix): ~/.claude/skills/global/systematic-debugging.md
- Verification before completion (evidence before claims): ~/.claude/skills/global/verification-before-completion.md
- Receiving code review (technical rigor, not performative agreement): ~/.claude/skills/global/receiving-code-review.md
- Finishing a branch (tests + diff score + merge/PR/discard): ~/.claude/skills/global/finishing-a-branch.md
- Web quality audit (Lighthouse-style 4-domain audit): ~/.claude/skills/global/web-quality-audit.md
- Web performance (budgets, images, fonts, caching, CRP): ~/.claude/skills/global/web-performance.md
- Core Web Vitals (LCP, INP, CLS — targeted fixes): ~/.claude/skills/global/core-web-vitals.md
- SEO (technical + on-page + structured data): ~/.claude/skills/global/seo.md
- Web best practices (CSP, SRI, Trusted Types, browser compat): ~/.claude/skills/global/web-best-practices.md

## General Rules
- Always check if a solution already exists in the codebase before creating new.
- Never use raw values — defer to tokens, constants, or config.
- Every component must meet WCAG 2.1 AA minimum.
- Never commit secrets, tokens, or credentials in any form.
- Atomic commits only. One concern per commit.
