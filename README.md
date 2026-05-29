# dotfiles

Personal development environment and AI workflow configuration.

## What's in here

| Path | Purpose |
|------|---------|
| `.claude/CLAUDE.md` | Global Claude Code defaults — auto-loaded every session |
| `.claude/skills/global/` | Reusable skills: commit review, a11y, security, code quality, anti-patterns |
| `git/` | Git config and commit message template |
| `shell/` | Zsh aliases and config |
| `vscode/` | Editor settings |
| `templates/` | Starter files for new projects (README, React component) |

## Setup

```bash
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Safe to re-run — skips anything already linked.

## Adding a new skill

1. Create `~/.claude/skills/global/your-skill.md`
2. Reference it in `.claude/CLAUDE.md` under "Loaded Skills"
3. Commit it here

## Project-specific skills

Each project repo has its own `.claude/` folder with skills scoped to that codebase.
Global skills always apply. Project skills extend them.

## Updating

```bash
cd ~/dotfiles
git pull
```

Symlinks mean changes take effect immediately — no re-running install.
