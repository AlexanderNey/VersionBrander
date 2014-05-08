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

#brands the build with information of the latest git commits, current branch, current user etc

PLISTBUDDY='/usr/libexec/PlistBuddy'

INFOPLIST_ABS_PATH=$1
GIT_TAG_PREFIX=$2

echo "Branding info.plist: ${INFOPLIST_ABS_PATH}"

# get git commit hash, branch, username and unstashed files
GIT_HASH=`cd "$PROJECT_DIR";git rev-parse HEAD`
GIT_BRANCH=`cd "$PROJECT_DIR";git rev-parse --abbrev-ref HEAD`
GIT_USER=`cd "$PROJECT_DIR";git config user.name`
BUILD_TIMESTAMP=$(date +%s)
BUILD_DATE=$(date -u +"%a %b %d %T GMT %Y")

#brand
$PLISTBUDDY -c "Add :BuildBrand dict " $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:BuildTimestamp integer '$BUILD_TIMESTAMP'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:BuildDate date '$BUILD_DATE'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitBranch string '$GIT_BRANCH'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitCommit string '$GIT_HASH'" $INFOPLIST_ABS_PATH
$PLISTBUDDY -c "Add :BuildBrand:GitUser string '$GIT_USER'" $INFOPLIST_ABS_PATH

if [ -n "$GIT_TAG_PREFIX" ]
then
	#get latest testflight* tag from git
	GIT_TAGS=(`git tag -l "$GIT_TAG_PREFIX"`)
	LENGTH=${#GIT_TAGS[@]}
	LAST_POSITION=$((LENGTH - 1))
	LATEST_GIT_TAG=${GIT_TAGS[$LAST_POSITION]}

	#get short git log	
	echo "adding log messages since tag: $LATEST_GIT_TAG"
	GIT_LOG=`git log --pretty='%ci %h %an %s %n' $LATEST_GIT_TAG..`

	#iterate trough logs and add to plist
	$PLISTBUDDY -c "Add :BuildBrand:GitLogSinceTag string '$LATEST_GIT_TAG'" $INFOPLIST_ABS_PATH
	$PLISTBUDDY -c 'Delete :BuildBrand:GitLog' $INFOPLIST_ABS_PATH
	$PLISTBUDDY -c 'Add :BuildBrand:GitLog array ' $INFOPLIST_ABS_PATH
	IFS='
	'
	for LOG in $GIT_LOG
	do
	   echo "Item: $LOG"
	   $PLISTBUDDY -c "Add :BuildBrand:GitLog: string '$LOG'" $INFOPLIST_ABS_PATH
	done
fi
