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
