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

@testable import MSDKUI
@testable import MSDKUI_Demo
import UIKit
import XCTest

final class ViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: ViewController!

    /// The mock core router used to verify expectations.
    private var mockCoreRouter = NMACoreRouterMock()

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as ViewController

        // Set the core router
        viewControllerUnderTest?.router = mockCoreRouter

        // Load the view hierarchy
        viewControllerUnderTest.loadViewIfNeeded()

        // Set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest
    }

    override func tearDown() {
        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests the multi-functional right button on the upper right corner: it functions
    /// as 'expand' and 'collapse' buttons.
    func testRightButton() {
        // Check the initial app title
        XCTAssertLocalized(
            viewControllerUnderTest.titleItem.title, key: "msdkui_app_rp_teaser_title",
            "The app title should be the route planner card title!"
        )

        // Triggers the core router completion handler with route results
        calculateRoute()

        // Triggers the core router completion handler with route results
        let mockRoutes = MockUtils.mockRoutes()
        let mockRouteResult = MockUtils.mockRouteResult(with: mockRoutes)
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        // After the routes calculated: the right button functions as the 'expand' button
        assertRightButtonHasExpandFunctionality()

        // After the waypoint list is expanded: the right button functions as the 'collapse' button
        viewControllerUnderTest?.rightButton.tap()
        assertRightButtonHasCollapseFunctionality()

        // After the waypoint list is collapsed: the right button functions as the 'expand' button
        viewControllerUnderTest?.rightButton.tap()
        assertRightButtonHasExpandFunctionality()
    }

    /// Tests the behavior when the core router returns valid result (with routes).
    func testWhenCoreRouterReturnsValidRoutes() throws {
        // Triggers the core router
        calculateRoute()

        // Triggers the core router completion handler with route results
        let mockRoutes = MockUtils.mockRoutes()
        let mockRouteResult = MockUtils.mockRouteResult(with: mockRoutes)
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        XCTAssertEqual(viewControllerUnderTest.routesList.routes, mockRoutes, "It updates the routes list with the correct routes")
        XCTAssertFalse(try require(viewControllerUnderTest.showHelperScrollView), "It hides the helper scroll view")
        XCTAssertTrue(try require(viewControllerUnderTest.hudView.isHidden), "It hides the HUD")
    }

    /// Tests the behavior when the core router returns empty results.
    func testWhenCoreRouterReturnsEmptyResults() throws {
        // Triggers the core router
        calculateRoute()

        // Triggers the core router completion handler without route results
        let mockRouteResult = MockUtils.mockRouteResult(with: [])
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        XCTAssertTrue(viewControllerUnderTest.routesList.routes.isEmpty, "It updates the route list with an empty array")
        XCTAssertFalse(try require(viewControllerUnderTest.showHelperScrollView), "It hides the helper scroll view")
        XCTAssertTrue(try require(viewControllerUnderTest.hudView.isHidden), "It hides the HUD")
    }

    /// Tests the behavior when the core router doesn't return results (nil).
    func testWhenCoreRouterReturnsNilForResult() throws {
        // Triggers the core router
        calculateRoute()

        // Triggers the core router completion handler with nil
        mockCoreRouter.lastCompletion?(nil, .none)

        XCTAssertTrue(viewControllerUnderTest.routesList.routes.isEmpty, "It updates the route list with an empty array")
        XCTAssertFalse(try require(viewControllerUnderTest.showHelperScrollView), "It hides the helper scroll view")
        XCTAssertTrue(try require(viewControllerUnderTest.hudView.isHidden), "It hides the HUD")
    }

    /// Tests the behavior when the core router returns error.
    func testWhenCoreRouterReturnsError() throws {
        // Triggers the core router
        calculateRoute()

        // Triggers the core router completion handler with nil
        mockCoreRouter.lastCompletion?(nil, .networkCommunication)

        XCTAssertTrue(viewControllerUnderTest.routesList.routes.isEmpty, "It updates the route list with an empty array")
        XCTAssertFalse(try require(viewControllerUnderTest.showHelperScrollView), "It hides the helper scroll view")
        XCTAssertTrue(try require(viewControllerUnderTest.hudView.isHidden), "It hides the HUD")
    }

    // MARK: - Private

    private func calculateRoute(file: StaticString = #file, line: UInt = #line) {
        viewControllerUnderTest.waypointList.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        viewControllerUnderTest.waypointViewController(WaypointViewController(), entry: WaypointEntryFixture.berlinNaturekundemuseum())
        viewControllerUnderTest.waypointList.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .top)
        viewControllerUnderTest.waypointViewController(WaypointViewController(), entry: WaypointEntryFixture.berlinReichstag())

        viewControllerUnderTest.calculateRoute()

        // Checks if core router is called (with correct parameters)
        XCTAssertTrue(mockCoreRouter.didCallCalculateRouteWithStopsRoutingMode, "It attempts to calculate route", file: file, line: line)
        XCTAssertEqual(mockCoreRouter.lastStops?.count, 2, "It passes two waypoints to the core router", file: file, line: line)
        XCTAssertEqual(
            mockCoreRouter.lastRoutingMode, viewControllerUnderTest.routingMode,
            "It passes the correct routing mode to the core router", file: file, line: line
        )
    }

    private func assertRightButtonHasExpandFunctionality(file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(
            viewControllerUnderTest.showHelperScrollView,
            "ViewController hides the helper scroll view", file: file, line: line
        )

        XCTAssertLocalized(
            viewControllerUnderTest.rightButton.accessibilityLabel, key: "msdkui_app_expand",
            "The right button function as 'expand' button", file: file, line: line
        )

        XCTAssertLocalized(
            viewControllerUnderTest.rightButton.accessibilityHint, key: "msdkui_app_hint_expand",
            "The right button has the 'expand' accessibility hint", file: file, line: line
        )

        XCTAssertFalse(viewControllerUnderTest.routesList.showTitle, "The route list hides its title!", file: file, line: line)

        XCTAssertNotEqual(
            viewControllerUnderTest.titleItem.title, localizedString(fromKey: "msdkui_app_rp_teaser_title"),
            "The app title is updated", file: file, line: line
        )
    }

    private func assertRightButtonHasCollapseFunctionality(file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(viewControllerUnderTest.showHelperScrollView, "ViewController hides the helper scroll view", file: file, line: line)

        XCTAssertLocalized(
            viewControllerUnderTest.rightButton.accessibilityLabel, key: "msdkui_app_collapse",
            "The right button functions as 'collapse' button", file: file, line: line
        )

        XCTAssertLocalized(
            viewControllerUnderTest.rightButton.accessibilityHint, key: "msdkui_app_hint_collapse",
            "The right button has the 'collapse' accessibilty hint", file: file, line: line
        )

        XCTAssertFalse(viewControllerUnderTest.routesList.showTitle, "The route list hides its title", file: file, line: line)

        XCTAssertNotEqual(
            viewControllerUnderTest.titleItem.title, localizedString(fromKey: "msdkui_app_rp_teaser_title"),
            "The app title is updated", file: file, line: line
        )
    }

    private func localizedString(fromKey key: String, bundle: Bundle? = .main) -> String {
        // Since ".localized" is defined in both MSDKUI and MSDKUI_Demo, we cannot use it
        // This helper method will get localized string with specified key from specified bundle
        guard let bundle = bundle else {
            XCTFail("Invalid bundle")
            return ""
        }

        return NSLocalizedString(key, bundle: bundle, value: "", comment: "") // swiftlint:disable:this localized_string
    }
}
