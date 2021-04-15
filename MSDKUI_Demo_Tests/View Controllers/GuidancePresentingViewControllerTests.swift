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

final class GuidancePresentingViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: RouteOverviewViewController?

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as RouteOverviewViewController

        // Load the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // In order to perform the segues, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest
    }

    override func tearDown() {
        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests the behavior when the start simulation button is long pressed.
    func testStartSimulationAlert() throws {
        // Trigger the action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        XCTAssertLocalized(
            alertController.title, key: "msdkui_app_guidance_start_simulation",
            "It presents an alert with the correct title."
        )

        XCTAssertEqual(
            alertController.actions.count, 2,
            "It presents an alert with the correct number of actions."
        )

        XCTAssertLocalized(
            alertController.actions[0].title, key: "msdkui_app_cancel",
            "It presents an alert with a cancel button."
        )

        XCTAssertEqual(
            alertController.actions[0].style, .cancel,
            "It presents an alert with the cancel style for the cancel button."
        )

        XCTAssertLocalized(
            alertController.actions[1].title, key: "msdkui_app_ok",
            "It presents an alert with an ok button."
        )

        XCTAssertEqual(
            alertController.actions[1].style, .default,
            "It presents an alert with the default style for the ok button."
        )
    }

    /// Tests the behavior when the cancel button is tapped after the start simulation button is long pressed.
    func testStartSimulationAlertCancelButtonTapped() throws {
        // Trigger the action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Tap the cancel button
        alertController.tapButton(at: 0)

        let shouldStartSimulation = try require(viewControllerUnderTest?.shouldStartSimulation)
        XCTAssertFalse(shouldStartSimulation, "It disables simulation.")
    }

    /// Tests the behavior when the ok button is tapped after the start simulation button is long pressed.
    func testStartSimulationAlertOKButtonTapped() throws {
        // Trigger the action
        viewControllerUnderTest?.showSimulationAlert()

        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Taps the OK button
        alertController.tapButton(at: 1)

        let shouldStartSimulation = try require(viewControllerUnderTest?.shouldStartSimulation)
        XCTAssertTrue(shouldStartSimulation, "It enables simulation.")
    }

    /// Tests the start navigation button tap.
    func testStartNavigationTapped() {
        XCTAssertNil(viewControllerUnderTest?.presentedViewController, "It doesn't present any view controller")
        viewControllerUnderTest?.startNavigationButton?.sendActions(for: .touchUpInside)
        XCTAssertNotNil(viewControllerUnderTest?.presentedViewController as? GuidanceViewController, "It presents a guidance view controller")
    }
}
