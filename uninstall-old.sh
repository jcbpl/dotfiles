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
  return 0
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

# Sublime Text: copy preferences from the repo to replace the symlink
# so they survive switching to main (which removes sublime/User).
subl_repo="$DOTFILES_ROOT/sublime/User"
for subl_user in \
  "$HOME/Library/Application Support/Sublime Text/Packages/User" \
  "$HOME/Library/Application Support/Sublime Text 3/Packages/User"; do
  if [ -d "$subl_repo" ] && [ -L "$subl_user" ]; then
    rm "$subl_user"
    cp -R "$subl_repo" "$subl_user"
    ok "copied Sublime preferences to $subl_user"
  fi
done

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
