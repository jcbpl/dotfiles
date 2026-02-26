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

# --- Claude Code ---
"$DOTFILES_DIR/claude/install.sh"

if [[ -z "${DOTFILES_QUIET:-}" ]]; then
  echo ""
  info "Done! Restart your shell or run: source ~/.bashrc"
fi
