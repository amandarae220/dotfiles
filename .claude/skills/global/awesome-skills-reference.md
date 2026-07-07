# Awesome Agent Skills — Reference Index

Skills from [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) worth adding per-project.

**Already imported globally** (don't add again):
- `addyosmani/web-quality-skills` → `web-quality-audit.md`, `web-performance.md`, `core-web-vitals.md`, `seo.md`, `web-best-practices.md`

**Skipped (require binary infrastructure, not portable):**
- `garrytan/gstack` — requires `~/.claude/skills/gstack/bin/` install

---

## Add per-project: Netlify projects

Install from `officialskills.sh` or directly from source repos:

- **Netlify config audit** — reviews `netlify.toml` for correctness, build settings, redirects, headers
- **Netlify functions** — edge functions, Netlify Functions patterns
- **Netlify deploy previews** — PR preview workflow

Source: `netlify-labs` org on GitHub or officialskills.sh registry

## Add per-project: Vercel projects

- **Vercel config** — `vercel.json` review, Edge Config, rewrites, ISR patterns
- **Next.js deployment** — build optimization for Vercel, Image Optimization API, serverless functions
- **Edge middleware** — Vercel Edge Middleware patterns

Source: `vercel-labs` org on GitHub

## Add per-project: React / TypeScript

- **React patterns** — hooks, composition, context vs state management tradeoffs
- **TypeScript strict mode** — strict null checks, exact types, discriminated unions
- **Storybook** — component documentation, visual testing
- **Testing Library** — React Testing Library best practices

## Add per-project: APIs / backend

- **REST API design** — resource naming, status codes, pagination, versioning
- **GraphQL** — schema design, N+1 prevention, fragments
- **OpenAPI spec** — writing specs, codegen

## Add per-project: Data / content

- **CMS patterns** — headless CMS integration (Contentful, Sanity, Prismic)
- **MDX authoring** — content pipeline patterns
- **Data visualization** — D3, observable framework, accessible charts

---

## How to install a specific skill

```bash
# View available skills
curl https://officialskills.sh

# Fetch a specific skill
curl https://officialskills.sh/<org>/<skill-name>

# Or pull directly from GitHub
gh api repos/<org>/<repo>/contents/<path>/SKILL.md --jq '.content' | base64 -d > ~/.claude/skills/project/<skill-name>.md
```

Add to project `.claude/CLAUDE.md`:
```markdown
## Project Skills
- Skill name: .claude/skills/<skill-name>.md
```

---

## What to look for when evaluating new skills

Before importing, check:
- **Portable** — no external binaries, no infrastructure dependencies
- **Standalone** — can run without a specific SDK or service installed
- **Actionable** — provides concrete rules, not just philosophy
- **Not redundant** — doesn't duplicate existing global skills
