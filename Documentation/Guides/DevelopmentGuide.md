# MSDKUI Development Guide

## Contents

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Contents](#contents)
- [Target Audience](#target-audience)
- [Development Environment](#development-environment)
	- [Getting the Code](#getting-the-code)
	- [Setting the HERE Maps SDK license](#setting-the-here-maps-sdk-license)
	- [Setting up the Environment](#setting-up-the-environment)
- [Building the MSKUI Framework](#building-the-mskui-framework)
- [Building the Demo App](#building-the-demo-app)
- [Running Tests](#running-tests)
- [Command Line](#command-line)
	- [MSDKUI API Documentation (tools:jazzy)](#msdkui-api-documentation-toolsjazzy)
	- [Test Coverage for the MSDKUI Framework (tools:xcov_msdkui)](#test-coverage-for-the-msdkui-framework-toolsxcovmsdkui)
	- [Test Coverage for the Demo Application (tools:xcov_demo_app)](#test-coverage-for-the-demo-application-toolsxcovdemoapp)
	- [Updating localized strings (izumi:all)](#updating-localized-strings-izumiall)
- [Troubleshooting](#troubleshooting)
	- [Bundler](#bundler)

<!-- /TOC -->

## Target Audience

The target audience of this guide is developers who want to contribute to the MSDKUI codebase, build the MSDKUI framework, or run the demo application on their local machines. For using the `MSDKUI.framework` on your own project, check the [QuickStart](QuickStart.md) guide.

## Development Environment

Prerequisites, as of July, 2018:

* Latest [Xcode](https://developer.apple.com/xcode/) (9.4.1), which requires macOS High Sierra
* Ruby 2.0 or higher
* [Bundler](https://bundler.io/) to ensure a consistent environment

There are many ways to install Ruby on macOS. Recent macOS versions already include Ruby 2.0 or higher, but other popular ways to install Ruby include [brew](https://brew.sh/), [rbenv](https://github.com/rbenv/rbenv), and [rvm](https://rvm.io/rvm/install). For this reason, installing Bundler might differ between environments, see [Troubleshooting](#troubleshooting) for more details.

### Getting the Code

```
$ git clone https://github.com/heremaps/msdkui-ios
$ cd msdkui-ios
```

### Setting the HERE Maps SDK license

Before building, testing, or running the MSDKUI demo application it's important to set the HERE Maps SDK credentials. If you don't know your credentials, please ask your HERE stakeholder or register on [developer.here.com](https://developer.here.com) and create new ones.

Create a file called `.env.rb` as shown below (or use your favorite text editor), replacing the fields with your credentials:

```bash
$ cat > .env.rb << EOF
ENV['MSDKUI_APP_ID_IOS'] = "replace with your app id"
ENV['MSDKUI_APP_TOKEN_IOS'] = "replace with your app code"
ENV['MSDKUI_APP_LICENSE_IOS'] = "replace with your license"
EOF
```

The file should have the following format when inspected:

```bash
$ cat .env.rb
ENV['MSDKUI_APP_ID_IOS'] = "your app id"
ENV['MSDKUI_APP_TOKEN_IOS'] = "your app code"
ENV['MSDKUI_APP_LICENSE_IOS'] = "your license"
```

### Setting up the Environment

```
$ bundle install
$ bundle exec pod install
```

The first command `bundle install` installs the gem dependencies needed to build the project. This includes [CocoaPods](https://rubygems.org/gems/cocoapods) for managing Pod dependencies, [xcov](https://rubygems.org/gems/xcov) for the code coverage report, and [jazzy](https://rubygems.org/gems/jazzy) to generate the MSDKUI framework API documentation. The `Gemfile` and `Gemfile.lock` files found in the repo specify the exact versions that Bundler should install to avoid dependency conflicts.

The latter, `bundle exec pod install`, installs the Pods (including the HERE Maps SDK) and creates the Xcode workspace.

Everything after this point is done from within Xcode. Launch it via command line (or by double clicking the workspace via Finder).

```
$ open -a xcode MSDKUI.xcworkspace
```

## Building the MSKUI Framework

The easiest way to build the MSDKUI Framework is using the command line:

```
$ bundle exec rake build:msdkui_framework
```

At the end it will drop the `MSDKUI.framework` at `output/framework/universal/`. The framework is a [fat binary](https://en.wikipedia.org/wiki/Fat_binary), built for device and simulator.

## Building the Demo App

1. Open the `MSDKUI.xcworkspace`
1. Select the `MSDKUI_Demo` scheme (if not selected by default)
1. Build it (Product > Build) or Command+B

## Running Tests

1. Open the `MSDKUI.xcworkspace`
1. Select the `MSDKUI_Demo` scheme (if not selected by default)
1. Test it (Product > Test or Command+U)
    1. The following test targets will be executed
        1. `MSDKUI_Test`: MSDKUI Framework Unit Tests
        1. `MSDKUI_Demo_Test`: Demo app Unit Tests
        1. `MSDKUI_Demo_UI_Test`: Demo app UI Tests

It's also possible to run these tests from the command line. See the [Command Line](#command-line) section below.

## Command Line

Several command line shortcuts are available, as Rake tasks, to build and test the MSDKUI framework and demo application.

```
$ bundle exec rake -T
rake build:clean             # Clean
rake build:msdkui_framework  # Build MSDKUI framework (fat binary)
rake build:simulator         # Build the demo app
rake test:all                # Run all tests (Demo app Unit and UI; MSDKUI Unit)
rake test:demo_app_ui        # Run Demo App UI Tests
rake test:demo_app_unit      # Run Demo App Unit Tests
rake test:msdkui_unit        # Run MSDKUI Framework Unit Tests
rake tools:cocoapods         # Run CocoaPods
rake tools:jazzy             # Build Jazzy API Documentation
rake tools:podspeclint       # Run Podspec lint
rake tools:swiftlint         # Run SwiftLint
rake tools:xcov_demo_app     # Run Test Coverage for the Demo App Unit Tests
rake tools:xcov_msdkui       # Run Test Coverage for the MSDKUI Framework Unit Tests
```

The iOS version used for testing is `11.4` (latest), and the Simulator used is `iPhone 8`. To run the tests using a different simulator or iOS version, specify the environment variables `DEFAULT_SIMULATOR_NAME` and `DEFAULT_IOS_VERSION`. For instance:

```
$ DEFAULT_SIMULATOR_NAME="iPhone 8 Plus" DEFAULT_IOS_VERSION="11.2" bundle exec rake test:msdkui_unit
```

Although most of the Rake tasks included are meant to be used by CI, some are relevant for developers. For instance, `tools:jazzy`, `tools:xcov_msdkui`, `tools:xcov_demo_app`, and the aforementioned `build:msdkui_framework`.

### MSDKUI API Documentation (tools:jazzy)

To generate the MSDKUI API documentation, run:

```
$ bundle exec rake tools:jazzy
```

It will place the documentation at `output/jazzy/`. Run `open output/jazzy/index.html` to open the documentation on the default browser.

### Test Coverage for the MSDKUI Framework (tools:xcov_msdkui)

To generate the test coverage for the MSDKUI framework, run:

```
$ bundle exec rake tools:xcov_msdkui
```

It will place the report at `output/xcov/msdkui/`. Run `open output/xcov/msdkui/index.html` to open the report on the default browser.

### Test Coverage for the Demo Application (tools:xcov_demo_app)

To generate the test coverage for the demo application, run:

```
$ bundle exec rake tools:xcov_demo_app
```

It will place the report at `output/xcov/demo_app/`. Run `open output/xcov/demo_app/index.html` to open the report on the default browser.

### Updating localized strings (izumi:all)

In order to update the localized strings, two env. variables are required: `MSDKUI_FRAMEWORK_IZUMI` and `MSDKUI_DEMO_APP_IZUMI`. They should hold the URLs to the .zip files containing the localized strings.

```
$ bundle exec rake izumi:all
```

The env. variables can be set via command line (preferable for CI)

```
$ MSDKUI_FRAMEWORK_IZUMI="https://.../release.zip" MSDKUI_DEMO_APP_IZUMI="https://.../release.zip" bundle exec rake izumi:all
```

Or via `.env.rb` (preferable for developer workstation)

```
ENV['MSDKUI_FRAMEWORK_IZUMI'] = "https://.../release.zip"
ENV['MSDKUI_DEMO_APP_IZUMI'] = "https://.../release.zip"
```

## Troubleshooting

### Bundler

The easiest way to install Bundler, as [described on Bundler's website](https://bundler.io/), is:

```
$ gem install bundler
```

This installs Bundler as a [gem](https://rubygems.org/gems/bundler) through [RubyGems](https://rubygems.org/). Basically, Bundler itself is a gem that can install other gems to ensure the required versions are compatible.

But depending on how Ruby is installed, `--user-install` might be necessary:

```
$ gem install bundler --user-install
```

Also, depending on how Ruby is installed, `--path vendor/bundle` might be necessary before running `bundle install`

```
$ bundle install --path vendor/bundle
```

This will install the required dependencies locally to `./vendor/bundle/ruby/your_ruby_version/gems/` - depending on how Ruby is installed, Bundler might try to install gems at system-level (aka globally) on directories the current user doesn't have write privileges.

Also, please make sure you have installed the Xcode command line tools: `xcode-select --install`. If you still experience problems, try instead:

```
$ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```
