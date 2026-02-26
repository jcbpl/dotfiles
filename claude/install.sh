#!/usr/bin/env bash
#
# claude/install.sh -- set up ~/.claude config
#
# Copies CLAUDE.md, settings.json, and skills into ~/.claude.
# Called from the top-level install.sh.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }

mkdir -p "$HOME/.claude"

# CLAUDE.md: overwrite from dotfiles
cp "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
success "copied CLAUDE.md"

# settings.json: overwrite from dotfiles
cp "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
success "copied settings.json"

# Skills: sync skill directories that contain a SKILL.md
SKILLS_SRC="$DOTFILES_DIR/claude/skills"
SKILLS_DST="$HOME/.claude/skills"
mkdir -p "$SKILLS_DST"
for skill_dir in "$SKILLS_SRC"/*/; do
  if [[ -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$SKILLS_DST/$skill_name"
    cp -R "$skill_dir"* "$SKILLS_DST/$skill_name/"
    success "copied skill $skill_name"
  fi
done
