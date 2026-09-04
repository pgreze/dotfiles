###
### Claude Code configuration
###

vsclaude() {
    local url="vscode://anthropic.claude-code/open"
    if [[ -n "$1" ]]; then
        url="${url}?prompt=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$*'))")"
    fi
    open "$url"
}

# https://github.com/alexrah/zsh-claudecode-plugin/blob/3ec180f945f1d86fc631c7acf833eb01875a08a9/claudecode.plugin.zsh
# Useful aliases for ClaudeCode
alias cl='claude'
alias clp='claude --print'
alias clc='claude --continue'
alias clr='claude --resume'
alias clu='claude update'
alias clm='claude mcp'
alias cla='claude agents --cwd .'
# Git-related aliases
alias clcommit='claude commit'
alias clpr='claude pr'
alias clreview='claude review'
# Development aliases
alias cltest='claude test'
alias cllint='claude lint'
alias cldocs='claude docs'
# Model-specific aliases
alias clhaiku='claude --model haiku'
alias clsonnet='claude --model sonnet'
alias clopus='claude --model opus'
