#!/usr/bin/env bash
#
# setup.sh -- one-time setup
#
# What it does:
#   1. Authenticates with GitHub via gh (if not already logged in)
#   2. Sets git name/email from your GitHub profile
#   3. Runs install.sh to wire up dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()    { printf "\033[0;34m[info]\033[0m  %s\n" "$1"; }
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }
warn()    { printf "\033[0;33m[warn]\033[0m  %s\n" "$1"; }

# --- GitHub CLI ---
if ! command -v gh &>/dev/null; then
  warn "gh (GitHub CLI) not found -- skipping auth and identity setup"
  warn "install it from https://cli.github.com and re-run setup.sh"
  exit 0
fi

# --- GitHub auth ---
if gh auth status &>/dev/null; then
  success "already authenticated with GitHub"
else
  info "logging in to GitHub (this also configures git credentials)..."
  gh auth login
fi

# --- Git identity ---
if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
  success "git identity already set"
else
  info "fetching your identity from GitHub..."
  name=$(gh api user --jq '.name // empty' 2>/dev/null || true)
  email=$(gh api user --jq '.email // empty' 2>/dev/null || true)

  if [[ -z "$name" ]]; then
    read -rp "  Name (for git commits): " name
  else
    info "name from GitHub: $name"
  fi

  if [[ -z "$email" ]]; then
    read -rp "  Email (for git commits): " email
  else
    info "email from GitHub: $email"
  fi

  git config --global user.name "$name"
  git config --global user.email "$email"
  success "set git identity"
fi

echo ""
info "git identity:"
git config user.name && git config user.email

# --- Wire up dotfiles ---
echo ""
DOTFILES_QUIET=1 "$DOTFILES_DIR/install.sh"
