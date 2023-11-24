###
### Python configuration
###

# Export python startup script
export PYTHONSTARTUP=~/.pythonrc

alias cleanpyc="find . -name '*.pyc' -delete"

# pipx
case $SHELL in
  */zsh)  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh ;;
  */bash) [ -f ~/.fzf.bash ] && source ~/.fzf.bash ;;
esac
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
