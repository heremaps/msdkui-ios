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
import UIKit
import XCTest

final class LandingViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: LandingViewController!

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .main) as LandingViewController

        // Load the view hierarchy
        viewControllerUnderTest.loadViewIfNeeded()

        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest
    }

    override func tearDown() {
        // Restore
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests that LandingViewController.getAppVersionStrings(sender:) launches the expected view controller.
    func testHandleRoutePlannerTap() throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)

        // Sets the testing expectation
        let predicate = NSPredicate(format: "presentedViewController != nil")
        expectation(for: predicate, evaluatedWith: viewControllerUnderTest)

        // Triggers the action
        viewControllerUnderTest.handleRoutePlannerTap(sender: UITapGestureRecognizer())

        // Sets the timeout for the expectation
        waitForExpectations(timeout: 5)

        // Confirms if the view controller under tests presents the waypoint view controller
        XCTAssertNotNil(viewControllerUnderTest.presentedViewController as? ViewController, "It presents the view controller")
    }

    /// Tests that LandingViewController.handleDriveNavTap(sender:) launches the expected view controller.
    func testHandleDriveNavTap() throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)

        // Sets the testing expectation
        let predicate = NSPredicate(format: "presentedViewController != nil")
        expectation(for: predicate, evaluatedWith: viewControllerUnderTest)

        // Triggers the action
        viewControllerUnderTest.handleDriveNavTap(sender: UITapGestureRecognizer())

        // Sets the timeout for the expectation
        waitForExpectations(timeout: 5)

        // Confirms if the view controller under tests presents the waypoint view controller
        XCTAssertNotNil(viewControllerUnderTest.presentedViewController as? WaypointViewController, "It presents the waypoint view controller")
    }

    /// Tests route planner ImageView.
    func testRoutePlannerImageView() {
        XCTAssertNotNil(viewControllerUnderTest.routePlannerImageView.image, "Image should exist")
        XCTAssertNotNil(viewControllerUnderTest.routePlannerImageView.superview, "Image should be in view hierarchy")
        XCTAssertFalse(viewControllerUnderTest.routePlannerImageView.isHidden, "Image should not be hidden")
        // TODO: MSDKUI-2161
        // XCTAssertEqual(viewControllerUnderTest.routePlannerImageView.image, UIImage(named: "routeplanner_teaser"), "Should have correct image")
    }

    /// Tests drive navigation ImageView.
    func testDriveNavImageView() {
        XCTAssertNotNil(viewControllerUnderTest.driveNavImageView.image, "Image should exist")
        XCTAssertNotNil(viewControllerUnderTest.driveNavImageView.superview, "Image should be in view hierarchy")
        XCTAssertFalse(viewControllerUnderTest.driveNavImageView.isHidden, "Image should not be hidden")
        // TODO: MSDKUI-2161
        // XCTAssertEqual(viewControllerUnderTest.driveNavImageView.image, UIImage(named: "drivenav_teaser"), "Should have correct image")
    }

    /// Tests the behavior when the info button is tapped.
    func testWhenTheInfoButtonIsTapped() throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)

        // Sets the testing expectation
        let predicate = NSPredicate(format: "presentedViewController != nil")
        expectation(for: predicate, evaluatedWith: viewControllerUnderTest)

        // Taps the button
        viewControllerUnderTest.infoButton.tap()

        // Sets the timeout for the expectation
        waitForExpectations(timeout: 5)

        // Confirms if the view controller under tests presents the about view controller
        XCTAssertNotNil(viewControllerUnderTest.presentedViewController as? AboutViewController, "It presents the about view controller")
    }
}
