fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios screenshots
```
fastlane ios screenshots
```
Generate new localized screenshots
### ios frame
```
fastlane ios frame
```

### ios bump_version
```
fastlane ios bump_version
```
Bump version number (type: [patch | minor | major])

Example: `fastlane ios bump_version type:patch`
### ios bump_build_number
```
fastlane ios bump_build_number
```
Bump build number and create/push a new git tag
### ios release
```
fastlane ios release
```

### ios update_metadata
```
fastlane ios update_metadata
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
