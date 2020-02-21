function os_based_prompt {
  case "$OSTYPE" in
    darwin*) echo "%(?:🍏 :🍎 )" ;;
    linux*)  echo "%(?:🐧 :🧨 )" ;;
    *)       echo "%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )" ;;
  esac
}

PROMPT="$(os_based_prompt)"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
