#!/bin/sh
#
# Copyright (c) 2014 Alexander Ney
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

# Brands the build with information of the latest git commits, current branch, current user etc

echo_help_quit () { 
	  SCRIPTNAME=`basename $0`
	  echo ""
      echo "Versionbrander 1.0"
      echo "Author: Alexander Ney"
      echo "Git: https://github.com/AlexanderNey/VersionBrander"
      echo ""
      echo "Usage: $SCRIPTNAME < -t tagname >"
      echo ""
      exit
}

echo_readme_quit () { 
	  curl "https://raw.githubusercontent.com/AlexanderNey/VersionBrander/master/README.md"
      exit
}

GIT_TAG_PREFIX=
while getopts "t:h:d" opt; do
  case $opt in
  t)  #git tag for git log
      GIT_TAG_PREFIX=$OPTARG
      ;;
  h)  # help
      echo_help_quit
      ;;
  d)  #documentation - experimental
      echo_readme_quit
      ;;
  \?)
      echo_help_quit
      ;;
  esac
done


PLISTBUDDY='/usr/libexec/PlistBuddy'
INFOPLIST_ABS_PATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

# Check requirement parameters / files
if [ ! -x $PLISTBUDDY ]
then
	echo "plistbuddy not found or is not executable at: '$PLISTBUDDY'"
	exit 1
fi

if [ -z $TARGET_BUILD_DIR ]; then
    echo "Environment variable TARGET_BUILD_DIR must be defined"
    exit 1
fi 

if [ -z $INFOPLIST_PATH} ]; then
    echo "Environment variable INFOPLIST_PATH must be defined"
    exit 1
fi 

if [ ! -f $INFOPLIST_ABS_PATH ]; then
	echo "Could not find info.plist at '$INFOPLIST_ABS_PATH'"
fi


echo "Branding info.plist: $INFOPLIST_ABS_PATH"

# Get git commit hash, branch, username and unstashed files
GIT_HASH=`cd "$PROJECT_DIR";git rev-parse HEAD`
GIT_BRANCH=`cd "$PROJECT_DIR";git rev-parse --abbrev-ref HEAD`
GIT_USER=`cd "$PROJECT_DIR";git config user.name`
BUILD_TIMESTAMP=$(date +%s)
BUILD_DATE=$(date -u +"%a %b %d %T GMT %Y")
BUILD_NUMBER=`git rev-list --all |wc -l`

# Brand
$PLISTBUDDY -c "Add :BuildBrand dict " $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:BuildTimestamp integer '$BUILD_TIMESTAMP'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:BuildDate date '$BUILD_DATE'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitBranch string '$GIT_BRANCH'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitCommit string '$GIT_HASH'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitUser string '$GIT_USER'" $INFOPLIST_ABS_PATH

# Add Build Number
$PLISTBUDDY -c "Add :BuildBrand:Buildnumber string '$BUILD_NUMBER'" $INFOPLIST_ABS_PATH

if [ -n "$GIT_TAG_PREFIX" ]
then
	# Get latest testflight* tag from git
	GIT_TAGS=(`git tag -l "$GIT_TAG_PREFIX"`)
	LENGTH=${#GIT_TAGS[@]}
	LAST_POSITION=$((LENGTH - 1))
	LATEST_GIT_TAG=${GIT_TAGS[$LAST_POSITION]}

	# Get short git log	
	echo "adding log messages since tag: $LATEST_GIT_TAG"
	GIT_LOG=`git log --pretty='%ci %h %an %s %n' $LATEST_GIT_TAG..`

	# Iterate trough logs and add to plist
	$PLISTBUDDY -c "Add :BuildBrand:GitLogSinceTag string '$LATEST_GIT_TAG'" $INFOPLIST_ABS_PATH
	$PLISTBUDDY -c "Delete :BuildBrand:GitLog" $INFOPLIST_ABS_PATH
	$PLISTBUDDY -c "Add :BuildBrand:GitLog array " $INFOPLIST_ABS_PATH
	IFS='
	'
	for LOG in $GIT_LOG
	do
	   echo "Item: $LOG"
	   $PLISTBUDDY -c "Add :BuildBrand:GitLog: string '$LOG'" $INFOPLIST_ABS_PATH
	done
fi
