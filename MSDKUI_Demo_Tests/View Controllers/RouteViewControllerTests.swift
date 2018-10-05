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

class RouteViewControllerTests: XCTestCase {

    /// The view controller to be tested. Note that it is re-created before each test.
    private var viewControllerUnderTest: RouteViewController?

    /// Mock used to verify map route handler expectations.
    private var mockMapRoute = MockUtils.mockMapRoute()

    /// Mock used to verify for route expectations.
    private var mockRoute = MockUtils.mockRoute()

    /// The mock map route handler used to verify expectations.
    private var mockMapRouteHandler = MapRouteHandlerMock()

    override func setUp() {
        super.setUp()

        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as RouteViewController

        // Sets mock map route handler
        mockMapRouteHandler.stubMapRoute(toReturn: mockMapRoute)
        viewControllerUnderTest?.mapRouteHandler = mockMapRouteHandler

        // Sets mock route
        viewControllerUnderTest?.route = mockRoute

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()
    }

    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        super.tearDown()
    }

    /// Tests if the view controller exists.
    func testExists() {
        XCTAssertNotNil(viewControllerUnderTest, "It exists")
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertLocalized(viewControllerUnderTest?.backButton.title, key: "msdkui_app_back", "It has the correct title")
        XCTAssertEqual(viewControllerUnderTest?.backButton.tintColor, .colorAccentLight, "It has the correct tint color")
    }

    /// Tests the title item.
    func testTitleItem() {
        XCTAssertLocalized(viewControllerUnderTest?.titleItem.title, key: "msdkui_app_route_preview_title", "It has the correct title")
    }

    /// Tests the maneuver list.
    func testManeuverList() {
        XCTAssertEqual(viewControllerUnderTest?.maneuverList.tableFooterView?.bounds.height, 0, "It hides unused table view cells")
        XCTAssertEqual(viewControllerUnderTest?.maneuverList.route, mockRoute, "It has the correct route")
        XCTAssert(viewControllerUnderTest?.maneuverList.listDelegate === viewControllerUnderTest, "It has the correct list delegate")
    }

    /// Tests the map view.
    func testMapView() throws {
        XCTAssertTrue(try require(viewControllerUnderTest?.mapView.isTrafficVisible), "It has traffic enabled")
    }

    /// Tests if the HUD is displayed when view is displayed.
    func testHUDWhenViewLoads() throws {
        XCTAssertFalse(try require(viewControllerUnderTest?.hudView.isHidden), "It shows the hud when the controller's view loads")
    }

    /// Tests if the map route is added to the map view.
    func testMapRouteAddedToMapView() {
        XCTAssertTrue(mockMapRouteHandler.didCallAddMapRouteToMapView, "It adds the map route to the map view")
        XCTAssert(mockMapRouteHandler.lastMapRoute === mockMapRoute, "It adds the correct map route to the map view")
        XCTAssert(mockMapRouteHandler.lastMapView === viewControllerUnderTest?.mapView, "It adds the map route to the correct map view")
    }

    /// Tests the preferred status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(viewControllerUnderTest?.preferredStatusBarStyle, .lightContent, "It returns the correct status bar style")
    }

    /// Tests accessibility.
    func testAccessibility() throws {
        XCTAssertEqual(viewControllerUnderTest?.backButton.accessibilityIdentifier, "RouteViewController.backButton",
                       "It has the correct back button accessibility identifier")

        XCTAssertTrue(try require(viewControllerUnderTest?.mapView.isAccessibilityElement),
                      "It has map view accessibility enabled")

        XCTAssertEqual(viewControllerUnderTest?.mapView.accessibilityTraits, UIAccessibilityTraits.none,
                       "It doesn't have map view accessibility traits")

        XCTAssertLocalized(viewControllerUnderTest?.mapView.accessibilityLabel, key: "msdkui_app_map_view",
                           "It has the correct map view accessibility label")

        XCTAssertLocalized(viewControllerUnderTest?.mapView.accessibilityHint, key: "msdkui_app_hint_route_map_view",
                           "It has the correct map view accessibility hint")

        XCTAssertEqual(viewControllerUnderTest?.mapView.accessibilityIdentifier, "RouteViewController.mapView",
                       "It has the correct map view accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.hudView.accessibilityIdentifier, "RouteViewController.hudView",
                       "It has the correct hud accessibility identifier")

        XCTAssertEqual(viewControllerUnderTest?.routeStackView.accessibilityIdentifier, "RouteViewController.routeStackView",
                       "It has the correct route stack view accessibility identifier")
    }
}
