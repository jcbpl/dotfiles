#!/usr/bin/env bash
#
# agents/install.sh -- set up Codex and Claude agent config
#
# Copies shared guidance into Codex and Claude config directories and
# installs Claude-specific settings. Called from the top-level install.sh.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME"
cp "$DOTFILES_DIR/agents/AGENTS.md" "$CODEX_HOME/AGENTS.md"
success "copied AGENTS.md"

mkdir -p "$HOME/.claude"
cp "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
success "copied CLAUDE.md"

cp "$DOTFILES_DIR/agents/claude/settings.json" "$HOME/.claude/settings.json"
success "copied Claude settings"

SKILLS_DST="$HOME/.claude/skills"
mkdir -p "$SKILLS_DST"
for skill_name in commit pr; do
  if [[ -d "$SKILLS_DST/$skill_name" ]]; then
    rm -rf "$SKILLS_DST/$skill_name"
    success "removed skill $skill_name"
  fi
done
