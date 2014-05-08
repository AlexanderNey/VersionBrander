VersionBrander
==============

Brand your info.plist with information about your current git repository

**Usage**

1. Add the versionbrander.sh to your project directory

2. Add a Buildpahse script to your target:

	```
	INFOPLIST_ABS_PATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
	
	sh "$PROJECT_DIR/versionbrander.sh" $INFOPLIST_ABS_PATH
	```
	
	To include a git log since the latest tag starting with "release":
	
	```
	sh "$PROJECT_DIR/versionbrander.sh" $INFOPLIST_ABS_PATH 'release*'
	```

This will brand the info.plist file of your build with following values:


**Branding Values**

| Key     | Type      | Description   |
|------|:-------:| :------|
|BuildBrand.BuildTimestamp| Number| Unix timestamp of the build|
|BuildBrand.GitBranch| Number | Current Git branch|
|BuildBrand.GitCommit| String| Latest commit hash|
|BuildBrand.GitUser| String| Current Git user|

If you added the Tag prefix:

| Key     | Type      | Description   |
|-----|:------:| :-----|
|BuildBrand.GitLogSinceTag|String|The latest tag from where the log starts|
|BuildBrand.GitLog|Array|Git log|
