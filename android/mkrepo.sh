#!/bin/bash

REPO=`which repo`

if test "x$REPO" = "x"; then
    mkdir -pv $HOME/bin

    # get the repo script
    curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
    chmod a+x $HOME/bin/repo

    REPO="$HOME/bin/repo"
fi

manifest=$1
lwd=`pwd`
echo "local working directory is $lwd"
defaultname="default.xml"

mkdir .local
cd .local
git init --quiet
if test "x$manifest" = "x" ; then
cat <<EOF >$defaultname
<?xml version="1.0" encoding="UTF-8"?>
<manifest>

  <remote  name="aosp"
      fetch="https://android.googlesource.com/" />

  <remote name="github"
      fetch="https://github.com" />

  <remote name="googlesource"
      fetch="https://gerrit.googlesource.com/" />

  <default revision="refs/heads/master"
           remote="aosp"
           sync-j="4" />

  <!-- project path="external/jack" name="platform/external/jack" / -->
  <!-- project path="external/tools" name="zachriggle/tools" revision="refs/heads/master" remote="github"/ -->
  <project path="gitiles" name="gitiles" revision="refs/heads/master" remote="googlesource"/>
  <project path="buck" name="facebook/buck" revision="refs/heads/master" remote="github"/>

</manifest>
EOF

    echo "since you did not provide a manifest file, one has been provided "
    echo "for you"
else
    cp $manifest $defaultname
fi

git add $defaultname
git commit -m "add $defaultname"
cd $lwd
$REPO init -u file://$lwd/.local -b master
