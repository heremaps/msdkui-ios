//
// Copyright (C) 2017-2018 HERE Europe B.V.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

@testable import MSDKUI_Demo
import NMAKit
import UIKit
import XCTest

class RouteOverviewViewControllerTests: XCTestCase {
    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: RouteOverviewViewController?

    /// The real rootViewController is replaced with `viewControllerUnderTest` to get the
    /// orientation change notifications.
    let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The test target address.
    let toAddress = "Platz der Republik 1"

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromMainStoryboard() as RouteOverviewViewController
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinNaturekundemuseum()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()
        viewControllerUnderTest?.toAddress = toAddress

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mock notification
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // In order to get the orientation changes, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        // The default orientation
        XCUIDevice.shared.orientation = .portrait

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    /// Tests the accessibility elements.
    func testAccessibility() {
        XCTAssertEqual(viewControllerUnderTest?.backButton.accessibilityIdentifier, "RouteOverviewViewController.back",
                       "The backButton should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.mapView.accessibilityIdentifier, "RouteOverviewViewController.mapView",
                       "The mapView should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.containerView.accessibilityIdentifier, "RouteOverviewViewController.containerView",
                       "The containerView should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.accessibilityIdentifier, "RouteOverviewViewController.startNavigationButton",
                       "The start navigation button should have the correct accessibility identifier")
    }

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
                       "It has the correct status bar style")
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertNotNil(viewControllerUnderTest?.backButton,
                        "The back button should exist")

        XCTAssertNotEqual(viewControllerUnderTest?.backButton.title, "msdkui_app_back",
                          "The back button title should be localized")

        XCTAssertLocalized(viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
                           "The back button should have the correct title")

        XCTAssertEqual(viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
                       "The back button should have the correct tint color")
    }

    /// Tests the start navigation button.
    func testStartNavigationButtonState() {
        XCTAssertNotNil(viewControllerUnderTest?.startNavigationButton,
                        "The start navigation button should exist")

        XCTAssertNotEqual(viewControllerUnderTest?.startNavigationButton.currentTitle, "msdkui_app_guidance_button_start",
                          "The start navigation button title should be localized")

        XCTAssertLocalized(viewControllerUnderTest?.startNavigationButton.currentTitle, key: "msdkui_app_guidance_button_start",
                           "The start navigation button should have the correct title")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.backgroundColor, .colorAccent,
                       "The start navigation button should have the correct background color")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.layer.cornerRadius, 2,
                       "The start navigation button should have the correct corner radius")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.currentTitleColor, .colorForegroundLight,
                       "The start navigation button should have the correct title color")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.titleLabel?.font, UIFont.preferredFont(forTextStyle: .callout),
                       "The start navigation button should have the correct font")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.titleLabel?.lineBreakMode, .byTruncatingTail,
                       "The start navigation button should have the correct line break mode")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.titleEdgeInsets, UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
                       "The start navigation button should have the correct edge insets for title")
    }

    /// Tests the start navigation button tap.
    func testStartNavigationTapped() {
        XCTAssertNil(viewControllerUnderTest?.presentedViewController, "It doesn't present any view controller")
        viewControllerUnderTest?.startNavigationButton?.sendActions(for: .touchUpInside)
        XCTAssertNotNil(viewControllerUnderTest?.presentedViewController as? GuidanceViewController, "It presents a guidance view controller")
    }

    /// Tests that the address line starts with "To".
    func testAddressLineStartsWithTo() {
        XCTAssertLocalized(viewControllerUnderTest?.toLabel.text, key: "msdkui_app_routeoverview_to",
                           "The address line should start with \("msdkui_app_routeoverview_to".localized)")
    }

    /// Tests that the address line contains the address.
    func testAddressLineContainsTheToAddressSet () {
        XCTAssertEqual(viewControllerUnderTest?.addressLabel.text, toAddress,
                       "The address line should contain '\(toAddress)'")
    }

    /// Tests that the address line is visible in the portrait orientation.
    func testAddressLineIsVisibleInPortraitOrientation() {
        XCTAssertFalse(viewControllerUnderTest?.destinationView.isHidden ?? true,
                       "The address line should be hidden in portrait orientation")
    }

    /// Tests that the address line is hidden in the landscape orientations.
    func testAddressLineIsHiddenInLandscapeOrientations() {
        waitForRoute()

        XCUIDevice.shared.orientation = .landscapeLeft
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        XCTAssertTrue(viewControllerUnderTest?.destinationView.isHidden ?? false, "The address line should be hidden in landscape orientation")

        XCUIDevice.shared.orientation = .landscapeRight
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        XCTAssertTrue(viewControllerUnderTest?.destinationView.isHidden ?? false, "The address line should be hidden in landscape orientation")
    }

    /// Tests that having no `toAddress` makes the address line hidden in the portrait orientation.
    func testAddressLineHiddenInPortraitOrientationWhenNoToAddressSet() {
        viewControllerUnderTest?.toAddress = nil
        viewControllerUnderTest?.viewDidLoad()
        waitForRoute()
        XCTAssertTrue(viewControllerUnderTest?.destinationView.isHidden ?? false,
                      "The address line should be hidden in portrait orientation")
    }

    /// Tests that when the route calculation is succeeded, the `routeDescriptionItem` becomes visible.
    func testRouteDescriptionItemIsVisibleWhenRouteCalculated() {
        waitForRoute()
        XCTAssertFalse(viewControllerUnderTest?.routeDescriptionItem.isHidden ?? true,
                       "The `routeDescriptionItem` should be visible when there is a route found")
    }

    /// Tests that when the route calculation is failed, the `noRouteLabel` becomes visible.
    func testNoRouteLabelIsVisibleWhenNoRouteFound() {
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinates(latitude: 1, longitude: 1)
        waitForRoute()
        XCTAssertFalse(viewControllerUnderTest?.noRouteLabel.isHidden ?? true,
                       "The no route found label should be visible when there is no route found")
    }

    /// Tests that having no `fromCoordinates` makes the `noRouteLabel` visible.
    func testNoRouteFoundWhenFromCoordinatesNotSet() {
        viewControllerUnderTest?.fromCoordinates = nil
        viewControllerUnderTest?.viewDidLoad()
        waitForRoute()
        XCTAssertFalse(viewControllerUnderTest?.noRouteLabel.isHidden ?? true,
                       "The no route found label should be visible when there is no `fromCoordinates` set")
    }

    /// Tests that having no `toCoordinates` makes the `noRouteLabel` visible.
    func testNoRouteFoundWhenToCoordinatesNotSet() {
        viewControllerUnderTest?.toCoordinates = nil
        viewControllerUnderTest?.viewDidLoad()
        waitForRoute()
        XCTAssertFalse(viewControllerUnderTest?.noRouteLabel.isHidden ?? true,
                       "The no route found label should be visible when there is no `toCoordinates` set")
    }

    /// Tests the behavior when the start simulation button is long pressed.
    func testStartSimulationOnLongPress() throws {
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Triggers the long press action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        XCTAssertLocalized(alertController.title, key: "msdkui_app_guidance_start_simulation",
                           "It presents an alert with the correct title.")

        XCTAssertEqual(alertController.actions.count, 2,
                       "It presents an alert with the correct number of actions.")

        XCTAssertLocalized(alertController.actions[0].title, key: "msdkui_app_cancel",
                           "It presents an alert with a cancel button.")

        XCTAssertEqual(alertController.actions[0].style, .cancel,
                       "It presents an alert with the cancel style for the cancel button.")

        XCTAssertLocalized(alertController.actions[1].title, key: "msdkui_app_ok",
                           "It presents an alert with an ok button.")

        XCTAssertEqual(alertController.actions[1].style, .default,
                       "It presents an alert with the default style for the ok button.")
    }

    /// Tests the behavior when the cancel button is tapped after the start simulation button is long pressed.
    func testStartSimulationOnLongPressCancelButtonTapped() throws {
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Triggers the long press action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Taps the Cancel button
        alertController.tapButton(at: 0)

        let shouldStartSimulation = try require(viewControllerUnderTest?.shouldStartSimulation)
        XCTAssertFalse(shouldStartSimulation, "It disables simulation.")
    }

    /// Tests the behavior when the ok button is tapped after the start simulation button is long pressed.
    func testStartSimulationOnLongPressOKButtonTapped() throws {
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Triggers the long press action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Taps the OK button
        alertController.tapButton(at: 1)

        let shouldStartSimulation = try require(viewControllerUnderTest?.shouldStartSimulation)
        XCTAssertTrue(shouldStartSimulation, "It enables simulation.")
    }

    // MARK: private

    /// Waits until the route calculation attempt is completed.
    private func waitForRoute() {
        // Wait at most some seconds while polling
        for _ in 0 ..< 450 {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))

            // Is the containerView visible?
            if viewControllerUnderTest?.containerView.isHidden == false {
                break
            }
        }
    }
}
