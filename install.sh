#!/usr/bin/env bash
#
# install.sh -- set up dotfiles
#
# Wires dotfiles into your shell and git config. No symlinks -- just
# appends/includes into existing system files. Idempotent.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
info()    { printf "\033[0;34m[info]\033[0m  %s\n" "$1"; }
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }

# --- Git config (include, not symlink) ---
# We add an [include] to ~/.gitconfig rather than replacing it.
# This lets gh and other tools write to ~/.gitconfig without polluting the repo.
if git config --global --get-all include.path | grep -qF "$DOTFILES_DIR/gitconfig"; then
  success "~/.gitconfig already includes dotfiles"
else
  git config --global --add include.path "$DOTFILES_DIR/gitconfig"
  success "added include to ~/.gitconfig -> $DOTFILES_DIR/gitconfig"
fi

# --- Global gitignore ---
if [[ "$(git config --global core.excludesfile)" == "$DOTFILES_DIR/gitignore" ]]; then
  success "core.excludesfile already set"
else
  git config --global core.excludesfile "$DOTFILES_DIR/gitignore"
  success "set core.excludesfile -> $DOTFILES_DIR/gitignore"
fi

# --- Tmux config ---
SOURCE_CMD="source-file $DOTFILES_DIR/tmux.conf"
if grep -qF "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf" 2>/dev/null; then
  success "~/.tmux.conf already sources dotfiles"
else
  printf '# dotfiles\n%s\n' "$SOURCE_CMD" >> "$HOME/.tmux.conf"
  success "added source-file to ~/.tmux.conf"
fi

# --- Bashrc source line ---
SOURCE_LINE="[[ -f $DOTFILES_DIR/bashrc ]] && source $DOTFILES_DIR/bashrc"
if grep -qF "$DOTFILES_DIR/bashrc" "$HOME/.bashrc" 2>/dev/null; then
  success "~/.bashrc already sources dotfiles"
else
  printf '\n# dotfiles\n%s\n' "$SOURCE_LINE" >> "$HOME/.bashrc"
  success "appended source line to ~/.bashrc"
fi

# --- Claude config ---
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_START="# <<~DOTFILES $DOTFILES_DIR/CLAUDE.md"
CLAUDE_END="# DOTFILES"
mkdir -p "$HOME/.claude"
if grep -qF "$CLAUDE_START" "$CLAUDE_MD" 2>/dev/null; then
  # Replace existing section between start and end markers
  sed -i '' "\|$CLAUDE_START|,\|$CLAUDE_END|d" "$CLAUDE_MD"
fi
printf '\n%s\n' "$CLAUDE_START" >> "$CLAUDE_MD"
cat "$DOTFILES_DIR/CLAUDE.md" >> "$CLAUDE_MD"
printf '%s\n' "$CLAUDE_END" >> "$CLAUDE_MD"
success "updated ~/.claude/CLAUDE.md from $DOTFILES_DIR/CLAUDE.md"

if [[ -z "${DOTFILES_QUIET:-}" ]]; then
  echo ""
  info "Done! Restart your shell or run: source ~/.bashrc"
fi
