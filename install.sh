#!/bin/bash

# dotfiles install script
# Usage: ./install.sh
# Safe to re-run — skips if symlink already exists

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 Dotfiles dir: $DOTFILES_DIR"
echo ""

# Helper
link() {
  local src="$1"
  local dest="$2"
  if [ -L "$dest" ]; then
    echo "⏭  Already linked: $dest"
  elif [ -e "$dest" ]; then
    echo "⚠️  Exists (not a symlink): $dest — skipping. Back it up and re-run."
  else
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "✅ Linked: $dest → $src"
  fi
}

echo "🤖 Claude skills..."
link "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/.claude/skills" "$HOME/.claude/skills"

echo ""
echo "🔧 Git config..."
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/commit-template.txt" "$HOME/.git-commit-template.txt"

echo ""
echo "🐚 Shell..."
if [ -f "$HOME/.zshrc" ]; then
  # Append source line if not already there
  if ! grep -q "dotfiles/shell/.zshrc" "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "# dotfiles" >> "$HOME/.zshrc"
    echo "source $DOTFILES_DIR/shell/.zshrc" >> "$HOME/.zshrc"
    echo "✅ Sourced shell config in ~/.zshrc"
  else
    echo "⏭  Shell config already sourced"
  fi
fi

echo ""
echo "💻 VS Code..."
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
link "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_SETTINGS"

echo ""
echo "✅ Done. Open a new terminal to pick up shell changes."
