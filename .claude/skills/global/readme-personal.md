# README Template — Personal Projects

Use this template when writing a README for a personal project. Fill in the placeholders; remove any section that doesn't apply.

Tone: direct, first-person, no corporate fluff. Write like you're explaining it to a curious developer friend.

---

## Template

```markdown
# {{PROJECT_NAME}}

{{One or two sentences: what it is and why you built it. Lead with the interesting part.}}

Live: {{URL or "not deployed"}}

---

## Overview

{{2–4 sentences expanding on the project. What problem does it solve or what does it demonstrate? Who is it for (even if just yourself)?}}

---

## Tech Stack

| Technology | Why I chose it |
|------------|---------------|
| {{Tech 1}} | {{Reason — be specific, not just "it's popular"}} |
| {{Tech 2}} | {{Reason}} |
| {{Tech 3}} | {{Reason}} |

---

## Getting Started

**Prerequisites:** {{Node version, package manager, or other requirements}}

```bash
# Clone the repo
git clone {{REPO_URL}}
cd {{PROJECT_DIR}}

# Install dependencies
{{npm install / yarn / pnpm install}}

# Start local dev server
{{npm start / ng serve / etc.}}
```

The app runs at `http://localhost:{{PORT}}` by default.

---

## Deployment

Deployed via {{platform — e.g. Vercel, Netlify, GitHub Pages}}. Pushes to `main` trigger automatic builds. No additional configuration needed for standard deployments.

---

## Latest Updates

_Most recent changes — update this section when shipping meaningful features or fixes._

- **{{Date or version}}** — {{What changed and why it matters}}
- **{{Date or version}}** — {{What changed}}
```

---

## Notes for Claude

- Fill placeholders from the repo's actual code and context — don't invent details.
- The "Why I chose it" column should reflect the actual architectural decisions, not generic praise.
- "Latest Updates" should list the 3–5 most meaningful recent changes, newest first. Pull from recent git commits if needed.
- Keep the whole README under ~60 lines of content. If it's getting long, cut — don't expand.
- Never add a Contributing or License section unless the user asks.
