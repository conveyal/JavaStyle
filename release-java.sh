#!/bin/bash

# Warn user if not on master branch
branch=$(git rev-parse --abbrev-ref HEAD)
# Get version from pom.xml
echo Checking version number in pom.xml
version=$(mvn help:evaluate -Dexpression=project.version|grep -Ev '(^\[|Download\w+:)')
# Check for push to repository
echo "Version number found in pom is $version. Continue with release? (Y/n)"
read cont
if [ "$cont" =  "Y" ]; then
    continue
else
    echo Exiting.
    exit 0
fi
master="master"
if [ "$branch" = "$master" ]; then
    echo On branch master...
else
    echo "WARNING: Not currently on master branch (current branch is $branch). Continue anyway? (Y/n)"
    read cont
    if [ "$cont" =  "Y" ]; then
        continue
    else
        echo Exiting.
        exit 0
    fi
fi
# Parse version number parts
major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)
micro=$(echo $version | cut -d. -f3)
new_minor=$((minor + 1))
new_version=$major.$new_minor.$micro
echo Preparing release v$version
git add pom.xml
git commit -m "Prepare $version release"
if [ $? -eq 0 ]; then
    echo Commit successful!
else
    echo WARNING: Commit failed... Did you forget to update pom.xml with v$version?
    exit 0
fi
# Tag release with version number
git tag -a v$version -m "Release $version"
if [ $? -eq 0 ]; then
    echo Creating tag v$version was successful!
else
    echo WARNING: Creating tag v$version failed! Exiting.
    exit 0
fi
echo "#####################################"
echo New tag created:
echo "#####################################"
# Print tag info
git cat-file tag v$version
# Check for push to repository
echo "Would you like to push to remote? (Y/n/reset)"
read cont
if [ "$cont" =  "Y" ]; then
    continue
elif [ "$cont" = "reset" ]; then
    git reset --soft HEAD~1
    git tag -d v$version
    echo Reset commit and deleted tag v$version
    exit 0
else
    echo Exiting.
    exit 0
fi

git push origin v$version
# Print instructions on updating pom to snapshot with new version number
echo "#####################################"
echo "Please update version in POM to next snapshot, e.g., $new_version-SNAPSHOT. Then run the following command:"
echo "#####################################"
echo ""
echo git add pom.xml
echo git commit -m \"Prepare next development iteration $new_version-SNAPSHOT\"
echo git push
