###
### https://github.com/adrienverge/yamllint
###

if command -v yamllint > /dev/null; then
    _yamllint="$(command -v yamllint)"
    alias yamllint="$_yamllint -c $HOME/.yamllint.yml"
elif [[ "$(uname)" == 'Darwin' ]]; then
    echo "TODO: brew install yamllint"
    echo "TODO: pip install --user yamllint"
fi
