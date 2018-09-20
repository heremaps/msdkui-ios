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

class ManeuversOverviewViewControllerTests: XCTestCase {
    /// The view controller to be tested.
    var viewControllerUnderTest: ManeuversOverviewViewController?

    /// The test target address.
    let toAddress = "Platz der Republik 1"

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as ManeuversOverviewViewController
        viewControllerUnderTest?.toAddress = toAddress

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()
    }

    /// Tests the accessibility elements.
    func testAccessibility() {
        XCTAssertEqual(viewControllerUnderTest?.backButton.accessibilityIdentifier,
                       "ManeuversOverviewViewController.backButton",
                       "The backButton should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.routeDescriptionItem.accessibilityIdentifier,
                       "ManeuversOverviewViewController.routeDescriptionItem",
                       "The routeDescriptionItem should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.maneuverList.accessibilityIdentifier,
                       "ManeuversOverviewViewController.maneuverList",
                       "The maneuverList should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.showMapButton.accessibilityIdentifier,
                       "ManeuversOverviewViewController.showMapButton",
                       "The showMapButton should have the correct accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.startNavigationButton.accessibilityIdentifier,
                       "ManeuversOverviewViewController.startNavigationButton",
                       "The startNavigationButton should have the correct accessibility identifier")
    }

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
                       "It has the correct status bar style")
    }

    /// Tests the back button exists, has the correct settings and has an action which works as expected.
    func testBackButton() throws {
        XCTAssertNotNil(viewControllerUnderTest?.backButton, "The back button should exist")

        XCTAssertLocalized(viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
                           "The back button should have the correct title")

        XCTAssertEqual(viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
                       "The back button should have the correct tint color")

        XCTAssertNotNil(viewControllerUnderTest?.backButton.action, "The back button should have an action")

        // In order to perform the back action, present the `viewControllerUnderTest`
        UIApplication.shared.keyWindow?.rootViewController?.present(try require(viewControllerUnderTest), animated: false)

        // viewControllerUnderTest should be in "being presented" state
        XCTAssertTrue(viewControllerUnderTest?.isBeingPresented ?? false, "It displays the correct view controller")

        // Set the predicate expectation: back button action should lead to dismissal of `viewControllerUnderTest`
        let predicate = NSPredicate(format: "isBeingPresented == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest)

        // Tap the back button
        viewControllerUnderTest?.backButton.tap()

        // Wait for dismissal
        wait(for: [expectation], timeout: 5)
    }

    /// Tests that the address line starts with "To".
    func testAddressLineStartsWithTo() {
        XCTAssertLocalized(viewControllerUnderTest?.toLabel.text,
                           key: "msdkui_app_routeoverview_to",
                           "The address line should start with \("msdkui_app_routeoverview_to".localized)")
    }

    /// Tests that the address line contains the address.
    func testAddressLineContainsTheAddressSet () {
        XCTAssertEqual(viewControllerUnderTest?.addressLabel.text,
                       toAddress,
                       "The address line should contain '\(toAddress)'")
    }

    /// Tests that the address line is visible in the portrait orientation.
    func testAddressLineIsVisibleInPortraitOrientation() {
        XCTAssertFalse(viewControllerUnderTest?.destinationView.isHidden ?? true,
                       "The address line should be hidden in portrait orientation")
    }

    /// Tests that having no `toAddress` makes the address line hidden in the portrait orientation.
    func testAddressLineHiddenInPortraitOrientationWhenNoAddressSet() {
        viewControllerUnderTest?.toAddress = nil
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(viewControllerUnderTest?.destinationView.isHidden ?? false,
                      "The address line should be hidden in portrait orientation")
    }

    /// Tests that the address line is hidden in the landscape orientations.
    func testAddressLineIsHiddenInLandscapeOrientations() {
        // The real `rootViewController` is replaced with `viewControllerUnderTest`
        let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

        // In order to get the orientation changes, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Set the predicate expectation: landscape orientations should lead to hiding the address line
        let predicate = NSPredicate(format: "isHidden == true")

        let landscapeLeftExpectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.destinationView)
        XCUIDevice.shared.orientation = .landscapeLeft
        wait(for: [landscapeLeftExpectation], timeout: 5)

        let landscapeRightExpectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.destinationView)
        XCUIDevice.shared.orientation = .landscapeRight
        wait(for: [landscapeRightExpectation], timeout: 5)

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        // Restore the default orientation
        XCUIDevice.shared.orientation = .portrait
    }
}
