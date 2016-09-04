autoload colors && colors

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_branch_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo "%{$fg_bold[green]%}($(git_branch))%{$reset_color%}"
    else
      echo "%{$fg_bold[yellow]%}($(git_branch))%{$reset_color%}"
    fi
  fi
}

directory_name() {
  echo "%{$fg_bold[blue]%}%1~%{$reset_color%}"
}

export PROMPT=$'$(directory_name)$(git_branch_dirty)%# '
set_prompt () {
  export RPROMPT="%{$fg_bold[blue]%}%{$reset_color%}"
}

precmd() {
  set_prompt
}
