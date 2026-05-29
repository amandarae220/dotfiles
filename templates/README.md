# [Project Name]

> One-sentence value proposition — what does this do and why does it matter?

[![Deploy Status](https://img.shields.io/badge/deploy-live-brightgreen)](https://your-url.com)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

![Project Screenshot or Demo GIF](docs/preview.png)

---

## What it does

2–3 sentences. Lead with user value, not tech. Answer: what problem does this solve, for whom?

---

## Stack

| Layer | Tech |
|---|---|
| Framework | React / Next.js / Astro |
| Styling | Tailwind CSS / CSS Modules |
| State | Zustand / React Query |
| Testing | Vitest + Testing Library |
| Deploy | Vercel / Netlify / Cloudflare Pages |

---

## Getting started

```bash
# 1. Clone
git clone https://github.com/yourusername/project-name.git
cd project-name

# 2. Install
npm install

# 3. Environment
cp .env.example .env.local
# Fill in .env.local

# 4. Run
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

---

## Project structure

```
src/
├── app/           # Routes / pages
├── components/    # Shared UI components
├── features/      # Feature-scoped modules
├── hooks/         # Custom React hooks
├── lib/           # Third-party wrappers, utils
└── styles/        # Global styles, tokens
```

---

## Scripts

| Command | Description |
|---|---|
| `npm run dev` | Local dev server with HMR |
| `npm run build` | Production build |
| `npm run preview` | Preview production build locally |
| `npm run test` | Run unit + integration tests |
| `npm run test:e2e` | Run end-to-end tests |
| `npm run lint` | ESLint + type-check |
| `npm run format` | Prettier |

---

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | Yes | Base URL for API calls |
| `DATABASE_URL` | Yes | Postgres connection string |
| `NEXTAUTH_SECRET` | Yes | Auth session secret |

Copy `.env.example` and fill in values. Never commit `.env.local`.

---

## Accessibility

This project targets **WCAG 2.1 AA**. Automated audits run in CI via `axe-core`. Manual keyboard navigation and screen reader testing done before each release.

---

## Contributing

1. Fork and create a branch: `git checkout -b feat/your-feature`
2. Write code + tests
3. Run `npm run lint && npm run test` — must pass clean
4. Open a PR against `main` with a description of what and why

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

---

## License

[MIT](LICENSE) — © [Year] [Your Name]
