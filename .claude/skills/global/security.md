# Security Skill

## Hard Rules — Never Violate

### Secrets
- No API keys, tokens, passwords, or credentials in code ever
- No secrets in comments, commit messages, or logs
- All secrets via environment variables — `.env` in `.gitignore` always
- `.env.example` with placeholder values is fine and encouraged

### Input Handling
- Never trust user input — validate and sanitize everything
- Never use `dangerouslySetInnerHTML` without explicit sanitization
- Parameterized queries only — never string-concatenated SQL/queries
- Validate on both client AND server — client validation is UX, not security

### Dependencies
- No installing packages without checking: downloads/week, last publish date, maintainer count
- Flag any package not updated in 12+ months
- No packages that request unnecessary permissions

### Authentication & Authorization
- Never store sensitive data in localStorage — use httpOnly cookies
- Never expose internal IDs or enumerable endpoints unnecessarily
- Check authorization on every protected route/action, not just on entry

### Output
- Escape all dynamic content rendered to DOM
- Content Security Policy headers on all projects
- Never log sensitive user data (emails, names, tokens) to console or external services

## Review Callout Format
`SECURITY [severity: low|medium|critical]: [location] — [issue] — [fix]`

## Critical = BLOCKED
Any critical security issue blocks the commit. No exceptions.
