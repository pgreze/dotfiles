###
### Java configuration
###
### https://whichjdk.com/
### https://medium.com/@brunoborges/manage-multiple-jdks-on-mac-os-linux-and-windows-wsl2-3a73467b685c
### https://blogs.oregonstate.edu/cornercase/2022/04/21/the-apple-m1-and-java/
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

# See ./sdkman.sh

# https://www.jenv.be/
if [ -d "$HOME/.jenv/bin" ]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi
# jenv add ~/.sdkman/candidates/java/11.0.15-zulu/
# jenv versions
# jenv global 11.0.15-zulu
# jenv shell 11.0.15-tem
