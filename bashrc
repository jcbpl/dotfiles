# ~/.dotfiles/bashrc -- sourced from ~/.bashrc
#
# This file complements the system bashrc rather than replacing it.
# The installer appends a one-line source command to ~/.bashrc.

# If not running interactively, bail
[[ $- != *i* ]] && return

DOTFILES_BASHRC="${BASH_SOURCE[0]}"

# -- History -----------------------------------------------------------
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:cd:cd -:pwd:exit:clear"
shopt -s histappend

# -- Shell options -----------------------------------------------------
shopt -s globstar 2>/dev/null  # ** matches recursively
shopt -s cdspell        # Autocorrect minor cd typos
shopt -s dirspell 2>/dev/null  # Autocorrect directory name typos

# -- Editor ------------------------------------------------------------
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  export EDITOR="code --wait"
elif [[ "$(uname)" == "Darwin" ]]; then
  export EDITOR="subl -w"
else
  export EDITOR="vim"
fi
export VISUAL="$EDITOR"

# -- Prompt ------------------------------------------------------------
# Two-line prompt: path + git branch, arrow colored by last exit code
__prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo " ($branch)"
}

_set_prompt() {
  local last_exit=$?
  local reset='\[\033[0m\]'
  local blue='\[\033[0;34m\]'
  local cyan='\[\033[0;36m\]'
  local green='\[\033[0;32m\]'
  local red='\[\033[0;31m\]'

  local arrow_color="$green"
  (( last_exit != 0 )) && arrow_color="$red"

  # Set tab title to current directory while at the prompt
  printf '\033]0;%s\007' "${PWD##*/}"

  PS1="\n${blue}\w${cyan}\$(__prompt_git_branch)${reset}\n${arrow_color}❯${reset} "
}

# -- Tab title ---------------------------------------------------------
# Show the running command in the tab title while it executes
_set_running_title() {
  case "$BASH_COMMAND" in
    _set_prompt*|__prompt_git_branch*) return ;;
  esac
  printf '\033]0;%s\007' "${BASH_COMMAND}"
}
trap '_set_running_title' DEBUG

if [[ "$PROMPT_COMMAND" != *_set_prompt* ]]; then
  PROMPT_COMMAND="_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi

# -- WSL ---------------------------------------------------------------
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # Use Windows browser for URLs
  export BROWSER="wslview"
  # Clipboard helpers
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe -c Get-Clipboard'
fi

# -- Aliases -----------------------------------------------------------
# Colored ls on macOS (Linux systems handle this in /etc/bash.bashrc)
if [[ "$(uname)" == "Darwin" ]]; then
  alias ls='ls -GF'
fi
alias l='ls -lAh'
alias ll='ls -l'

# Git
alias gs='git status -sb'
alias gst='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -30'
alias gac='git add -A && git commit -m'

# Misc
# shellcheck disable=SC2139
alias reload="source $DOTFILES_BASHRC"
alias path='echo $PATH | tr : "\n"'
alias tmux='tmux -u'

# -- Functions ---------------------------------------------------------
mcd() { mkdir -p "$1" && cd "$1"; }

# -- PATH --------------------------------------------------------------
[[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && \
  export PATH="$HOME/.local/bin:$PATH"

# -- Completions -------------------------------------------------------
# macOS + Homebrew
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && \
    source "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

# Git alias completions (requires bash_completion above)
_complete_local_branches() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(git branch --format='%(refname:short)' 2>/dev/null)" -- "$cur"))
}
complete -F _complete_local_branches gb gco gd gds gl gla gp

# -- Tool integrations (only if present) -------------------------------
command -v mise &>/dev/null && eval "$(mise activate bash)"

# -- Local overrides ---------------------------------------------------
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
