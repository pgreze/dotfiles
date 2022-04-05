###
### Java configuration
###

# https://github.com/AdoptOpenJDK/homebrew-openjdk
jdk() {
    local VERSION=$1
    if [ -z "$VERSION" ]; then
        printf "Usage: jdk (8,9,11,13...)\n\n"
        /usr/libexec/java_home -V
        echo "\nVersion: "
    else
        [ "$VERSION" = "8" ] && VERSION="1.8"
        export JAVA_HOME=$(/usr/libexec/java_home -v"$VERSION");
    fi
    java -version
}
