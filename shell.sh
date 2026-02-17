#!/usr/bin/env bash
#
# shell.sh -- set Homebrew bash as login shell (macOS only)
#
# Run after `brew bundle` and before setup.sh.
# Adds Homebrew's bash to /etc/shells and sets it as your login shell.
# Restart your terminal afterward.

set -euo pipefail

info()    { printf "\033[0;34m[info]\033[0m  %s\n" "$1"; }
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }
error()   { printf "\033[0;31m[err]\033[0m   %s\n" "$1"; }

if [[ "$(uname)" != "Darwin" ]]; then
  error "this script is for macOS only"
  exit 1
fi

# Ensure Homebrew is in PATH (it may not be yet if dotfiles aren't wired up)
if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    error "Homebrew is required. Install it from https://brew.sh"
    exit 1
  fi
fi

BREW_BASH="$(brew --prefix)/bin/bash"

if [[ ! -x "$BREW_BASH" ]]; then
  error "$BREW_BASH not found -- run 'brew bundle' first"
  exit 1
fi

success "bash: $($BREW_BASH --version | head -1)"

# Add to /etc/shells if needed
if grep -qF "$BREW_BASH" /etc/shells; then
  success "$BREW_BASH already in /etc/shells"
else
  info "adding $BREW_BASH to /etc/shells (requires sudo)..."
  echo "$BREW_BASH" | sudo tee -a /etc/shells >/dev/null
  success "added $BREW_BASH to /etc/shells"
fi

# Set login shell if needed
if [[ "$SHELL" == "$BREW_BASH" ]]; then
  success "login shell already set to $BREW_BASH"
else
  info "changing login shell to $BREW_BASH..."
  chsh -s "$BREW_BASH"
  success "login shell set -- restart your terminal"
fi

# Create ~/.bash_profile so login shells source ~/.bashrc
if grep -qF ".bashrc" "$HOME/.bash_profile" 2>/dev/null; then
  success "~/.bash_profile already sources ~/.bashrc"
else
  printf '# source ~/.bashrc for login shells\n[[ -f ~/.bashrc ]] && source ~/.bashrc\n' >> "$HOME/.bash_profile"
  success "created ~/.bash_profile -> sources ~/.bashrc"
fi
