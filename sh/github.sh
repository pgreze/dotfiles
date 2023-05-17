test-gh-token() {
    printf "Enter your Github token: "
    read -s TOKEN
    curl -H "Authorization: token $TOKEN" https://api.github.com/user
}
