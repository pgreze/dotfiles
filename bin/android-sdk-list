#!/usr/bin/env sh

# Created because
# $ $ANDROID_HOME/tools/bin/sdkmanager --list
# is SUPER SLOW and only working with Java8...
# Error: java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema

echo "Android SDK located in: $ANDROID_HOME"

echo ">> platform-tools/ version"
grep Pkg.Revision $ANDROID_HOME/platform-tools/source.properties

printf "\n>> build-tools/* versions\n"
ls $ANDROID_HOME/build-tools/

printf "\n>> platforms/* versions\n"
for platform_version in $(ls $ANDROID_HOME/platforms/); do
    source_pros="$ANDROID_HOME/platforms/$platform_version/source.properties"
    [ -f $source_pros ] && echo "$platform_version $(grep Pkg.Revision $source_pros)"
done
