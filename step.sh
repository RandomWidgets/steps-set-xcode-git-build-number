#!/bin/bash

if [ -z "${plist_paths}" ] ; then
    IFS=$'\n'
    plist_array=($(grep -rl . -e CFBundleVersion --include \*.plist --exclude-dir={./Pods,*Tests}))
else
    IFS=',' read -r -a plist_array <<< "$plist_paths"
fi

if [ ${#plist_array[@]} -eq 0 ]; then
    echo " [!] Missing required input: plist_paths"
    exit 1
fi

if [ -z "${date_format}" ] ; then
    echo " [!] Missing required input: date_format"
    exit 1
fi

DATE=`date +$date_format`
COMMIT=`git rev-parse --short HEAD`
BRANCH=`git rev-parse --abbrev-ref HEAD`
BUILD_NUMBER_OUTPUT="$DATE.$COMMIT.$BRANCH"

for path in "${plist_array[@]}"
do
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER_OUTPUT}" "${path}"
    echo "Updated ${path}"
done

echo "Build number: $BUILD_NUMBER_OUTPUT"