#!/usr/bin/env bash
#
# Tears down the old zsh/symlink-based dotfiles so you can switch to the
# new version. Run this from the dotfiles checkout directory.
#
# What it removes:
#   - Symlinks in $HOME that point into this repo (*.symlink convention)
#   - ~/.localrc mention (tells you to rename it)
#   - Sublime Text symlink
#
# What it does NOT touch:
#   - Homebrew packages
#   - macOS defaults (set-defaults.sh changes)
#   - ~/.gitconfig.local (may contain identity info you want to keep)

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd -P)"

info()  { printf "  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
ok()    { printf "  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
skip()  { printf "  [ \033[0;33m--\033[0m ] %s\n" "$1"; }

remove_symlink() {
  local target="$1"
  if [ -L "$target" ]; then
    local points_to
    points_to="$(readlink "$target")"
    if [[ "$points_to" == "$DOTFILES_ROOT"* ]]; then
      rm "$target"
      ok "removed $target -> $points_to"
    else
      skip "$target is a symlink but points outside this repo ($points_to)"
    fi
  elif [ -e "$target" ]; then
    skip "$target exists but is not a symlink, leaving it alone"
  fi
}

echo ""
info "Removing old dotfile symlinks from \$HOME"
echo ""

# These are the symlinks that script/bootstrap would have created.
# Pattern: find *.symlink files, map to ~/.basename-without-symlink
old_symlinks=(
  "$HOME/.gitconfig"        # git/gitconfig.symlink
  "$HOME/.gitconfig.local"  # git/gitconfig.local.symlink (generated from .example)
  "$HOME/.gitignore"        # git/gitignore.symlink
  "$HOME/.git_template"     # git/git_template.symlink
  "$HOME/.hyper.js"         # hyper/hyper.js.symlink
  "$HOME/.gemrc"            # ruby/gemrc.symlink
  "$HOME/.irbrc"            # ruby/irbrc.symlink
  "$HOME/.vimrc"            # vim/vimrc.symlink
  "$HOME/.zshrc"            # zsh/zshrc.symlink
)

for link in "${old_symlinks[@]}"; do
  remove_symlink "$link"
done

# Sublime Text symlink (sublime/install.sh linked the User dir).
# Replace the symlink with a real copy so Sublime keeps its preferences
# after the repo no longer has the sublime/User directory.
subl_user="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
if [ -L "$subl_user" ]; then
  points_to="$(readlink "$subl_user")"
  if [[ "$points_to" == "$DOTFILES_ROOT"* ]]; then
    # Copy the actual files, then swap the symlink for the real dir
    tmp_dir="$(mktemp -d)"
    cp -R "$subl_user"/ "$tmp_dir"/
    rm "$subl_user"
    mv "$tmp_dir" "$subl_user"
    ok "materialized Sublime Text User symlink into a real directory"
  fi
fi

echo ""
info "Checking for ~/.localrc"
if [ -f "$HOME/.localrc" ]; then
  echo "  The old setup sourced ~/.localrc for env overrides."
  echo "  The new setup uses ~/.bashrc.local instead."
  echo "  You may want to:  mv ~/.localrc ~/.bashrc.local"
else
  skip "no ~/.localrc found"
fi

echo ""
info "Done. You can now run ./setup.sh to install the new dotfiles."
echo ""
