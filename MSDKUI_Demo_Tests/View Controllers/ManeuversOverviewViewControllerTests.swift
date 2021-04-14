//
// Copyright (C) 2017-2021 HERE Europe B.V.
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

final class ManeuversOverviewViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: ManeuversOverviewViewController?

    /// The test target address.
    private let toAddress = "Platz der Republik 1"

    override func setUp() {
        super.setUp()

        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as ManeuversOverviewViewController
        viewControllerUnderTest?.toAddress = toAddress

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()
    }

    // MARK: - Tests

    /// Tests the accessibility elements.
    func testAccessibility() {
        XCTAssertEqual(
            viewControllerUnderTest?.backButton.accessibilityIdentifier,
            "ManeuversOverviewViewController.backButton",
            "The backButton should have the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.routeDescriptionItem.accessibilityIdentifier,
            "ManeuversOverviewViewController.routeDescriptionItem",
            "The routeDescriptionItem should have the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.maneuverTableView.accessibilityIdentifier,
            "ManeuversOverviewViewController.maneuverTableView",
            "The maneuverTableView should have the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.showMapButton.accessibilityIdentifier,
            "ManeuversOverviewViewController.showMapButton",
            "The showMapButton should have the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.accessibilityIdentifier,
            "ManeuversOverviewViewController.startNavigationButton",
            "The startNavigationButton should have the correct accessibility identifier"
        )
    }

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(
            viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
            "It has the correct status bar style"
        )
    }

    /// Tests the back button exists, has the correct settings and has an action which works as expected.
    func testBackButton() throws {
        XCTAssertNotNil(viewControllerUnderTest?.backButton, "The back button should exist")

        XCTAssertLocalized(
            viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
            "The back button should have the correct title"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
            "The back button should have the correct tint color"
        )

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
        XCTAssertLocalized(
            viewControllerUnderTest?.toLabel.text,
            key: "msdkui_app_routeoverview_to",
            "The address line should start with \("msdkui_app_routeoverview_to".localized)"
        )
    }

    /// Tests that the address line contains the address.
    func testAddressLineContainsTheAddressSet() {
        XCTAssertEqual(
            viewControllerUnderTest?.addressLabel.text,
            toAddress,
            "The address line should contain '\(toAddress)'"
        )
    }

    /// Tests that the address line is visible in the portrait orientation when view is shown.
    func testAddressLineIsVisibleInPortraitOrientationWhenViewIsShown() throws {
        let viewController = try require(viewControllerUnderTest)
        let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController
        addTeardownBlock {
            UIApplication.shared.keyWindow?.rootViewController = originalRootViewController
        }

        // Expect hidden `destinationView`
        let hiddenDestinationViewExpectation = keyValueObservingExpectation(
            for: viewController.destinationView as Any,
            keyPath: #keyPath(UIView.isHidden),
            expectedValue: false
        )

        // In order to show `viewControllerUnderTest.view` set it as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        wait(for: [hiddenDestinationViewExpectation], timeout: 5)
    }

    /// Tests that the address line is visible in the portrait orientation when transitioned.
    func testAddressLineIsVisibleInPortraitOrientationWhenTransitioned() throws {
        let viewController = try require(viewControllerUnderTest)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Set trait collection to compact, to make sure that transition will happen on iOS 13 and newer
        navigationController.setOverrideTraitCollection(UITraitCollection(verticalSizeClass: .compact), forChild: viewController)

        // Expect hidden `destinationView`
        let hiddenDestinationViewExpectation = keyValueObservingExpectation(
            for: viewController.destinationView as Any,
            keyPath: #keyPath(UIView.isHidden),
            expectedValue: false
        )

        // Inject the regular trait collection for a transition
        navigationController.setOverrideTraitCollection(UITraitCollection(verticalSizeClass: .regular), forChild: viewController)

        wait(for: [hiddenDestinationViewExpectation], timeout: 5)
    }

    /// Tests that having no `toAddress` makes the address line hidden in the portrait orientation.
    func testAddressLineHiddenInPortraitOrientationWhenNoAddressSet() {
        viewControllerUnderTest?.toAddress = nil
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(
            viewControllerUnderTest?.destinationView.isHidden ?? false,
            "The address line should be hidden in portrait orientation"
        )
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
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        wait(for: [landscapeLeftExpectation], timeout: 5)

        let landscapeRightExpectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.destinationView)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        wait(for: [landscapeRightExpectation], timeout: 5)

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        // Restore the default orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
    }
}
