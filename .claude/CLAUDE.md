# Global Claude Defaults

## Communication
- Be concise and direct. No fluff, no preamble.
- Show code first, explain after — only if explanation adds value.
- When there are tradeoffs, state them in one line each.
- Never apologize. Never over-explain. Just solve.

## Loaded Skills
The following skills apply to every session regardless of project.
Reference them before acting on any task of that type.

### Code Workflow
- Brainstorming [when: new feature, design question, "what should we build"]: ~/.claude/skills/global/brainstorming.md
- Writing plans [when: implementation task, multi-step feature, "how do we build this"]: ~/.claude/skills/global/writing-plans.md
- Test-driven development [when: any new feature or bug fix]: ~/.claude/skills/global/test-driven-development.md
- Systematic debugging [when: bug investigation, "why is X broken", unexpected behavior]: ~/.claude/skills/global/systematic-debugging.md
- Verification before completion [when: claiming any task is done]: ~/.claude/skills/global/verification-before-completion.md
- Finishing a branch [when: feature done, ready to merge/PR/discard]: ~/.claude/skills/global/finishing-a-branch.md

### Code Quality
- Code quality [when: naming, function length, complexity, refactoring]: ~/.claude/skills/global/code-quality.md
- Anti-patterns [when: code review, component structure, data fetching patterns]: ~/.claude/skills/global/anti-patterns.md
- Testing anti-patterns [when: writing tests, adding mocks, test utilities]: ~/.claude/skills/global/testing-anti-patterns.md
- Receiving code review [when: Amanda gets feedback on her code]: ~/.claude/skills/global/receiving-code-review.md

### Security
- Security [when: input handling, auth, deps, secrets, any data from users]: ~/.claude/skills/global/security.md
- Web best practices [when: CSP, SRI, Trusted Types, browser compat, deprecated APIs]: ~/.claude/skills/global/web-best-practices.md

### Web Quality
- Accessibility [when: any UI component, HTML, interactive element]: ~/.claude/skills/global/accessibility.md
- Web quality audit [when: full site audit, pre-launch review, "check everything"]: ~/.claude/skills/global/web-quality-audit.md
- Web performance [when: load time, images, fonts, caching, bundle size]: ~/.claude/skills/global/web-performance.md
- Core Web Vitals [when: LCP/INP/CLS, Lighthouse score, page speed]: ~/.claude/skills/global/core-web-vitals.md
- SEO [when: meta tags, sitemap, structured data, search visibility]: ~/.claude/skills/global/seo.md

### Writing & Communication
- Writing voice [when: any prose Amanda writes — bios, copy, case studies]: ~/.claude/skills/global/voice.md
- Portfolio writing [when: data journalism projects, portfolio case studies]: ~/.claude/skills/global/portfolio-writing.md
- PR template [when: creating a pull request]: ~/.claude/skills/global/pr-template.md
- Commit review [when: scoring a diff, reviewing changes before merge]: ~/.claude/skills/global/commit-review.md
- Decision log [when: documenting architecture or technical decisions]: ~/.claude/skills/global/decision-log-template.md
- README [when: writing a README for a personal project]: ~/.claude/skills/global/readme-personal.md

## General Rules
- Always check if a solution already exists in the codebase before creating new.
- Never use raw values — defer to tokens, constants, or config.
- Every component must meet WCAG 2.1 AA minimum.
- Never commit secrets, tokens, or credentials in any form.
- Atomic commits only. One concern per commit.
- Never commit or push without an explicit request. Show what you would commit and wait.
- Show the implementation plan and wait for approval before editing any files.
