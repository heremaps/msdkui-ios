# HERE Mobile SDK UI Kit (MSDKUI) Contribution Guide

This guide is for developers who want to contribute to the MSDKUI codebase, build the MSDKUI framework, or run the Demo application on their local machines. For using the `MSDKUI.framework` on your own project, or running the accompanying example apps, please check the [QuickStart](QuickStart.md) guide.

## Contents

- [HERE Mobile SDK UI Kit (MSDKUI) Contribution Guide](#here-mobile-sdk-ui-kit-msdkui-contribution-guide)
  - [Contents](#contents)
  - [Development environment](#development-environment)
    - [Getting the code](#getting-the-code)
    - [Setting the HERE Mobile SDK credentials](#setting-the-here-mobile-sdk-credentials)
    - [Setting up the environment](#setting-up-the-environment)
  - [Building the MSDKUI Framework](#building-the-msdkui-framework)
  - [Building the Demo app](#building-the-demo-app)
  - [Building the Dev app](#building-the-dev-app)
  - [Commit / pull request policy](#commit--pull-request-policy)
  - [Writing Git commit messages](#writing-git-commit-messages)
    - [A normal ticket](#a-normal-ticket)
    - [Solving multiple tickets](#solving-multiple-tickets)
  - [Submitting a pull request](#submitting-a-pull-request)
  - [Writing unit tests](#writing-unit-tests)
    - [Localized Strings](#localized-strings)
    - [Nonlocalizable Strings](#nonlocalizable-strings)
    - [IBActions](#ibactions)
    - [UIAlertController](#uialertcontroller)
      - [Testing UIAlertController presentation](#testing-uialertcontroller-presentation)
      - [Testing UIAlertController actions (when buttons are tapped)](#testing-uialertcontroller-actions-when-buttons-are-tapped)
    - [UIBarButtonItem](#uibarbuttonitem)
    - [Test cases MARK directives](#test-cases-mark-directives)
  - [Running tests](#running-tests)
  - [Writing code](#writing-code)
    - [Accessibility Identifiers](#accessibility-identifiers)
    - [MARK directives](#mark-directives)
  - [Command line](#command-line)
    - [MSDKUI API Reference (tools:jazzy)](#msdkui-api-reference-toolsjazzy)
    - [Test Coverage for the MSDKUI Framework (tools:xcov_msdkui)](#test-coverage-for-the-msdkui-framework-toolsxcov_msdkui)
    - [Test Coverage for the Demo Application (tools:xcov_demo_app)](#test-coverage-for-the-demo-application-toolsxcov_demo_app)
    - [Updating localized strings (strings:all)](#updating-localized-strings-stringsall)
  - [Troubleshooting](#troubleshooting)
    - [Installing rbenv, ruby, and bundler](#installing-rbenv-ruby-and-bundler)
    - [Bundler](#bundler)

## Development environment

Prerequisites, as of August, 2019:

- Latest [Xcode](https://developer.apple.com/xcode/) (12.4), which requires macOS Catalina (or higher)
- [Brew](https://brew.sh/)
- Xcode command line tools, which can be installed by running the command `xcode-select --install`
- Ruby 2.0 or higher
- [Bundler](https://bundler.io/) to ensure a consistent environment

There are many ways to install Ruby on macOS. Recent macOS versions already include Ruby 2.0 or higher, but other popular ways to install Ruby include [brew](https://brew.sh/), [rbenv](https://github.com/rbenv/rbenv), and [rvm](https://rvm.io/rvm/install). For this reason, installing Bundler might differ between environments, see [Troubleshooting](#troubleshooting) for more details.

### Getting the code

```bash
git clone https://github.com/heremaps/msdkui-ios
cd msdkui-ios
```

### Setting the HERE Mobile SDK credentials

Before building, testing, or running the MSDKUI Demo application it's important to set the HERE Mobile SDK credentials. If you don't know your credentials, please ask your HERE stakeholder or register on [developer.here.com](https://developer.here.com) and create new ones.

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

### Setting up the environment

```bash
bundle install
bundle exec pod install
```

The first command `bundle install` installs the gem dependencies needed to build the project. This includes [CocoaPods](https://rubygems.org/gems/cocoapods) for managing Pod dependencies, [xcov](https://rubygems.org/gems/xcov) for the code coverage report, and [jazzy](https://rubygems.org/gems/jazzy) to generate the MSDKUI framework API Reference. The `Gemfile` and `Gemfile.lock` files found in the repo specify the exact versions that Bundler should install to avoid dependency conflicts.

The latter, `bundle exec pod install`, installs the Pods (including the HERE Mobile SDK) and creates the Xcode workspace.

Everything after this point is done from within Xcode. Launch it via command line (or by double clicking the workspace via Finder).

```bash
open -a xcode MSDKUI.xcworkspace
```

## Building the MSDKUI Framework

The easiest way to build the MSDKUI Framework is using the command line:

```bash
bundle exec rake build:msdkui_framework
```

At the end it will drop the `MSDKUI.framework` at `output/framework/universal/`. The framework is a [fat binary](https://en.wikipedia.org/wiki/Fat_binary), built for device and simulator.

>**Note:** Depending on your network and machine, building the framework may take longer for the first time. If the rake task complains about missing simulators, please try to install them from within Xcode. To do this, open *Xcode -> Preferences -> Components*.

## Building the Demo app

1. Open the `MSDKUI.xcworkspace`
1. Select the `MSDKUI_Demo` scheme (if not selected by default)
1. Build it (Product > Build) or Command+B

>**Note:** If you run the demo app in a simulator, please make sure to delete the build phase "Adapt to Build Platform" in Xcode. Otherwise, you won't be able to mock locations for the iOS simulator of your choice.

## Building the Dev app

This project includes a Dev application, which is designed to display MSDKUI components in their raw form. While the `Demo App` offers a polished experience of the MSDKUI components, it doesn't show the different combinations these components allow developers to set.

1. Open the `MSDKUI.xcworkspace`
1. Select the `MSDKUI_Dev` scheme
1. Build it (Product > Build) or Command+B

## Commit / pull request policy

Please follow our commit policy. Once you have pushed your changes, you should be able to see your work on GitHub. Each pull request will be reviewed and merged if there are no objections. Before sending a pull request, please make sure to:

- Write well-formatted [commit messages](#writing-git-commit-messages).
- [Explain what the pull request addresses](#submitting-a-pull-request) (especially if your pull request bundles several commits).
- Add [unit tests](#running-tests) for newly added features or - if suitable - for bug fixes.
- Add new UI components to the `MSDKUI_Dev` application.
- Keep the unit test coverage for the MSDKUI framework and Demo app above 80% (reported via Codecov via comment on Pull Requests).
- If your change involves a new UI behavior, please consider to help us write a [UI test](#running-tests) (not mandatory, but more than welcome).

## Writing Git commit messages

We follow the format described below to ensure all the commit messages are aligned and in a consistent format.

### A normal ticket

```plaintext
TICKET-ID: Capitalized short - 72 characters or less - title

Extended description. Please wrap it to 72 characters. Don't forget
the blank line separating the title from the description, otherwise
Git will treat the entire thing as title.

Use blank lines for additional paragraphs.

- Lists/bullet points are okay.
- Typically a hyphen or asterisk is used for the bullet and don't forget
  to indent additional lines, like this one.
```

>**Note:**

- Keep the title short. It should explain what the commit is about.
- Don't end the commit title with a period.
- Use imperative mood (*Fix* instead of *Fixes*, *Add* instead of *Adds*, etc..).
- For HERE internal tracking, TICKET-ID follows the pattern: `PROJECT-XYZ`.
- For GitHub Issues, TICKET-ID format is `#XYZ` (e.g. `#123`).

### Solving multiple tickets

```plaintext
TICKET-IDX, TICKET-IDY, TICKET-IDZ: Capitalized short - 72 characters or less - title

Contains:

TICKET-IDX: Ticket X Title
TICKET-IDY: Ticket Y Title
TICKET-IDZ: Ticket Z Title

Extended description (as for a normal ticket, see above).
```

## Submitting a pull request

- Pull Requests may contain multiple commits.
- Pull Requests should not include "Merge" commits.
  - Rebase your work to keep the Pull Request commits on top.
- Give the Pull Request a short title which explains what the Pull Request is about.
- Give the Pull Request a description with details on what the Pull Request is about.
- Once the Pull Request is merged into master, delete the remote feature branch.

## Writing unit tests

These are general rules to follow when writing unit tests.

### Localized Strings

Use `XCTAssertLocalized` to verify strings.

```swift
func testLocalizedStrings() {
    // Tests a localized label
    XCTAssertLocalized(viewControllerUnderTest.someLabel?.text,
                       key: "some_localized_key")

    // Tests a localized label that uses a string formatter
    XCTAssertLocalized(viewControllerUnderTest.someLabel?.text,
                       formatKey: "some_localized_format_key",
                       arguments: "one", "two", "three")
}
```

`XCTAssertLocalized` also takes a `bundle` parameter which allows to specify where the string is defined. If not specified, it uses the main bundle (as above).

### Nonlocalizable Strings

Use `XCTAssertNonlocalizable` to verify strings which are nonlocalizable, in other words, strings that are not translated by the translation team.

```swift
func testNonelocalizableStrings() {
    // Tests a nonlocalizable label
    XCTAssertNonlocalizable(viewControllerUnderTest.someLabel?.text,
                            key: "some_nonlocalizable_key")
}
```

### IBActions

Avoid testing `IBActions` directly. Instead, send an action to the button connected to the `IBAction`. This will automatically check if the `IBAction` is connected to the `IBOutlet`.

```swift
func testButtonTapped() {
    // Send a .touchUpInside action (tap) to the button
    viewControllerUnderTest.someButton?.sendAction(.touchUpInside)

    // Tests the behavior expected when the button is tapped
    XCTAssertTrue(...)
    XCTAssertFalse(...)
}
```

### UIAlertController

#### Testing UIAlertController presentation

The snipped below shows how to test the presented `UIAlertController`. It tests the controller title, number of actions, buttons texts and styles.

```swift
func testAlerControllerPresentation() throws {
    // Triggers the action that will display the alert
    viewControllerUnderTest.someButton?.sendAction(.touchUpInside)

    // Retrieves the presented alert view
    let alertController = try require(viewControllerUnderTest.presentedViewController as? UIAlertController)

    // Tests the alert title
    XCTAssertLocalized(alertController.title, key: "some_localized_key")

    // Tests the number of actions on the alert
    XCTAssertEqual(alertController.actions.count, 2)

    // Tests the first button title
    XCTAssertLocalized(alertController.actions[0].title, key: "some_localized_key")

    // Tests the first button style
    XCTAssertEqual(alertController.actions[0].style, .cancel)

    // Tests the second button title
    XCTAssertLocalized(alertController.actions[1].title, key: "some_localized_key")

    // Tests the second button title
    XCTAssertEqual(alertController.actions[1].style, .default)
}
```

#### Testing UIAlertController actions (when buttons are tapped)

The snipped below shows how to test an `UIAlertController` action. It triggers the action and checks the expected result when the button is tapped.

```swift
func testAlertControllerButtonAction() throws {
    // Triggers the action that will display the alert
    viewControllerUnderTest.someButton?.sendAction(.touchUpInside)

    // Retrieves the presented alert view
    let alertController = try require(viewControllerUnderTest.presentedViewController as? UIAlertController)

    // Taps the first button
    alertController.tapButton(at: 0)

    // Tests the behavior expected when the button is tapped
    XCTAssertTrue(...)
    XCTAssertFalse(...)
}
```

### UIBarButtonItem

Avoid testing `IBActions` directly. Instead, "tap" on the bar button item connected to the `IBAction`.

```swift
func testBarButtonItemTapped() {
    // Taps the bar buttom item
    viewControllerUnderTest.someBarButtonItem?.tap()

    // Tests the behavior expected when the button is tapped
    XCTAssertTrue(...)
    XCTAssertFalse(...)
}
```

### Test cases MARK directives

`XCTestCase` classes should have their test methods grouped as much as possible:

```swift
class ViewControllerTests: XCTestCase {
    // ... code ...

    // In tests ignore the properties along with XCTestCase.setUp() and
    // XCTestCase.tearDown() methods

    // MARK: - Addition

    /// Tests add method.
    func testAdd() { // ... code ... }
    func testAddWhenSomething() { // ... code ... }

    // MARK: - Removal

    /// Tests remove method.
    func testRemove() { // ... code ... }
    func testRemoveWhenSomething() { // ... code ... }

    // ... code ...
}
```

In case grouping is not possible, a generic "Tests" `MARK` directive should be used:

```swift
class ViewControllerTests: XCTestCase {
    // ... code ...

    // MARK: - Tests

    // ... code ...

    // MARK: - Private

    // ... code ...
}
```

`MARK` protocol conformance and stub extensions of mocks:

```swift
final class FooMock {
    // ... code ...
}

// MARK: - ProtocolA

extension FooMock: ProtocolA {
    // ... code ...
}

// MARK: - Stubs

extension FooMock {
    // ... code ...
}
```

## Running tests

1. Open the `MSDKUI.xcworkspace`
1. Select the `MSDKUI_Demo` scheme (if not selected by default)
1. Test it (Product > Test or Command+U)
    1. The following test targets will be executed
        1. `MSDKUI_Test`: MSDKUI Framework Unit Tests
        1. `MSDKUI_Demo_Test`: Demo app Unit Tests
        1. `MSDKUI_Demo_UI_Test`: Demo app UI Tests

It's also possible to run these tests from the command line. See the [Command Line](#command-line) section below.

## Writing code

These are general rules to follow when writing code.

### Accessibility Identifiers

Prefer to use a pattern for accessibility identifiers of `ViewController.xType`, where `x` is the name of accessibility element and `Type` is a general type of that element.

- Specific types like `UIButton`, `UITabBarButton`, `IconButton` use a general `Button` as a `Type`. The same rules apply for other types. For example `UILabel` and `FancyLabel` would just use `Label` as a `Type`.

```swift
/// ViewController class from demo app.
final class GuidanceDashboardViewController: UIViewController {
    @IBOutlet private(set) weak var stopNavigationButton: UIButton!

    private func setAccessibility() {
        stopNavigationButton.accessibilityIdentifier = "GuidanceDashboardViewController.stopNavigationButton"
    }
}
```

- Demo app components do not use any prefix. The MSDKUI components use their bundle name as a prefix, e.g., `MSDKUI.ManeuverDescriptionList`

- List items' identifier should be constructed by adding postfix numbering in form of `_%d`

```swift
/// Function of class ManeuverDescriptionList from MSDKUI.
private func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
    cell.accessibilityIdentifier = "MSDKUI.ManeuverDescriptionList.cell_\(row)"
}
```

```swift
/// Function of class MultipleChoiceOptionItem from MSDKUI.
private func setAccessibility(_ index: Int) {
    optionLabels[index].accessibilityIdentifier = "MSDKUI.MultipleChoiceOptionItem.optionLabel_\(index)"
}
```

- Enum based types' identifier should be constructed by using enum case name in place of `x` from `ViewController.xType`

```swift
/// Function of class TransportModePanel from MSDKUI.
private func setAccessibility(_ button: UIButton, _ mode: NMATransportMode) {
    switch mode {
    case .car:
        button.accessibilityIdentifier = "MSDKUI.TransportModePanel.carButton"
    }
}
```

- Alerts' view identifier should be in form of `ViewController.AlertController.xType`

```swift
let alert = UIAlertController(...)
alert.view.accessibilityIdentifier = "LocationBasedViewController.AlertController.permissionsView"
```

### MARK directives

Add `MARK` directives based on access modifier and section type. A general order and naming convention is defined below:

```swift
class ViewController: UIViewController {

    // MARK: - Types

    /// All types in order of: `open`, `public`, `internal`, `fileprivate`, `private`.
    /// Inner types follow the same `MARK` order and naming.

    // MARK: - Properties

    /// All properties in order of: `@IBOutlet`, `@IBInspectable`, `open`, `public`, `internal`, `fileprivate`, `private`.

    // MARK: - Life cycle

    /// Life cycle methods of `UIKit` such as `viewDidLoad()`, `prepare(for:sender:)`, `didMoveToSuperview()`
    /// and `init` and `deinit` for such objects. In other objects without `UIKit` lifecycle methods
    /// `init` and `deinit` are treated as normal methods and should be marked as such.

    // MARK: - Public

    /// All methods in order of: `open`, `public`, `internal`.

    // MARK: - Private

    /// All methods in order of: `fileprivate`, `private`, `@IBAction`.
}
```

Do not use `MARK` directives for protocol extensions of a type, which already conforms to that protocol:

```swift
class FooBar {
    func foo() { // ... code ... }
    func bar() { // ... code ... }
}

protocol ProtocolFoo {
    func foo()
}

protocol ProtocolBar {
    func bar()
}

extension FooBar: ProtocolFoo, ProtocolBar {}
```

Add a `MARK` directive for protocol conformance:

```swift
// MARK: - ProtocolA

extension Foo: ProtocolA {
    // ... code ...
}
```

When extensions are well focused, a `MARK` directive could group them

```swift
// MARK: - Dashboard Constants

public extension CGFloat {
    static let dashboardCollapsedAlpha = CGFloat(0.0)
    static let dashboardCollapsedHeight = CGFloat(84)
    static let dashboardOpenAlpha = CGFloat(0.5)
    static let dashboardOpenHeight = CGFloat(197)
}
```

Add a `MARK` directive for generic extension with names of the type constraints:

```swift
// MARK: - Foo

extension ProtocolA where Self: Foo {
    // ... code ...
}
```

Apply `MARK` directives only when they make sense. For example, if a `struct` has only properties, one doesn't need to group them as `Properties`. Please try to avoid excessive use of the `MARK` directives.

## Command line

Several command line shortcuts are available, as Rake tasks, to build and test the MSDKUI framework and Demo application.

```bash
$ bundle exec rake -T
rake build:clean             # Clean
rake build:msdkui_framework  # Build MSDKUI framework (fat binary)
rake build:simulator         # Build the Demo app
rake test:all                # Run all tests (Demo app Unit and UI; MSDKUI Unit)
rake test:demo_app_ui        # Run Demo App UI Tests
rake test:demo_app_unit      # Run Demo App Unit Tests
rake test:msdkui_unit        # Run MSDKUI Framework Unit Tests
rake tools:cocoapods         # Run CocoaPods
rake tools:jazzy             # Build Jazzy API Reference
rake tools:podspeclint       # Run Podspec lint
rake tools:swiftlint         # Run SwiftLint
rake tools:xcov_demo_app     # Run Test Coverage for the Demo App Unit Tests
rake tools:xcov_msdkui       # Run Test Coverage for the MSDKUI Framework Unit Tests
```

The iOS version used for testing is `14.4` (latest), and the Simulator used is `iPhone 8`. To run the tests using a different simulator or iOS version, specify the environment variables `DEFAULT_SIMULATOR_NAME` and `DEFAULT_IOS_VERSION`. For instance:

```bash
DEFAULT_SIMULATOR_NAME="iPhone 8 Plus" DEFAULT_IOS_VERSION="14.4.2" bundle exec rake test:msdkui_unit
```

Although most of the Rake tasks included are meant to be used by CI, some are relevant for developers. For instance, `tools:jazzy`, `tools:xcov_msdkui`, `tools:xcov_demo_app`, and the aforementioned `build:msdkui_framework`.

### MSDKUI API Reference (tools:jazzy)

To generate the MSDKUI API Reference, run:

```bash
bundle exec rake tools:jazzy
```

It will place the API Reference at `output/jazzy/`. Run `open output/jazzy/index.html` to open the API Reference on the default browser.

### Test Coverage for the MSDKUI Framework (tools:xcov_msdkui)

To generate the test coverage for the MSDKUI framework, run:

```bash
bundle exec rake tools:xcov_msdkui
```

It will place the report at `output/xcov/msdkui/`. Run `open output/xcov/msdkui/index.html` to open the report on the default browser.

### Test Coverage for the Demo Application (tools:xcov_demo_app)

To generate the test coverage for the Demo application, run:

```bash
bundle exec rake tools:xcov_demo_app
```

It will place the report at `output/xcov/demo_app/`. Run `open output/xcov/demo_app/index.html` to open the report on the default browser.

### Updating localized strings (strings:all)

>**Note:** This section is only relevant if you are an internal at HERE.

In order to update the localized strings, two env. variables are required: `MSDKUI_FRAMEWORK_STRINGS_URL` and `MSDKUI_DEMO_APP_STRINGS_URL`. They should hold the URLs to the .zip files containing the localized strings.

```bash
bundle exec rake strings:all
```

The env. variables can be set via command line (preferable for CI)

```bash
MSDKUI_FRAMEWORK_STRINGS_URL="https://.../release.zip" MSDKUI_DEMO_APP_STRINGS_URL="https://.../release.zip" bundle exec rake strings:all
```

Or via `.env.rb` (preferable for developer workstation)

```rb
ENV['MSDKUI_FRAMEWORK_STRINGS_URL'] = "https://.../release.zip"
ENV['MSDKUI_DEMO_APP_STRINGS_URL'] = "https://.../release.zip"
```

## Troubleshooting

### Installing rbenv, ruby, and bundler

We highly recommend `rbenv` to install `ruby` and `gem`s, and `brew` to install `rbenv`. To create a ruby environment from scratch, follow the following instructions:

```bash
# Install rbenv (ruby manager)
$ brew install rbenv

# Install ruby-build (to install and build native extension)
$ brew install ruby-build

# Add rbenv (and gems) to PATH
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile

# Initialize rbenv
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# Install the Ruby version
$ rbenv install 2.5.1

# Set the ruby version
$ rbenv global 2.5.1

# Install bundler
gem install bundler -v '1.16.6'
```

The instructions on how to install `rbenv` and `ruby-build` using `brew` can also be found at [rbenv's GitHub page](https://github.com/rbenv/rbenv).

### Bundler

The easiest way to install Bundler, as [described on Bundler's website](https://bundler.io/), is:

```bash
gem install bundler
```

This installs Bundler as a [gem](https://rubygems.org/gems/bundler) through [RubyGems](https://rubygems.org/). Basically, Bundler itself is a gem that can install other gems to ensure the required versions are compatible.

But depending on how Ruby is installed, `--user-install` might be necessary:

```bash
gem install bundler --user-install
```

Also, depending on how Ruby is installed, `--path vendor/bundle` might be necessary before running `bundle install`

```bash
bundle install --path vendor/bundle
```

This will install the required dependencies locally to `./vendor` - depending on how Ruby is installed, Bundler might try to install gems at system-level (aka globally) on directories the current user doesn't have write privileges.
