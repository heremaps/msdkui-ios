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
import UIKit
import XCTest

class ViewControllerTests: XCTestCase {
    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: ViewController!

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromMainStoryboard() as ViewController

        // Load the view hierarchy
        viewControllerUnderTest.loadViewIfNeeded()
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest.mapView.isRenderAllowed = false

        super.tearDown()
    }

    /// Tests the multi-functional right button on the upper right corner: it functions
    /// as 'expand' and 'collapse' buttons.
    func testRightButton() {
        // Check the initial app title
        XCTAssertLocalized(viewControllerUnderTest.titleItem.title, key: "msdkui_app_rp_teaser_title",
                           "The app title should be the route planner card title!")

        // After the routes calculated: the right button functions as the 'expand' button
        calculateRoute()
        assertRightButtonHasExpandFunctionality()

        // After the waypoint list is expanded: the right button functions as the 'collapse' button
        viewControllerUnderTest?.rightButton.tap()
        assertRightButtonHasCollapseFunctionality()

        // After the waypoint list is collapsed: the right button functions as the 'expand' button
        viewControllerUnderTest?.rightButton.tap()
        assertRightButtonHasExpandFunctionality()
    }

    // MARK: Helper methods

    func calculateRoute() {
        viewControllerUnderTest.waypointList.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
        viewControllerUnderTest.waypointViewController(WaypointViewController(), entry: WaypointEntryFixture.berlinNaturekundemuseum())
        viewControllerUnderTest.waypointList.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
        viewControllerUnderTest.waypointViewController(WaypointViewController(), entry: WaypointEntryFixture.berlinReichstag())
        viewControllerUnderTest.calculateRoute()
    }

    func assertRightButtonHasExpandFunctionality() {
        XCTAssertFalse(viewControllerUnderTest.showMapView,
                       "ViewController should not show the map!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityLabel, key: "msdkui_app_expand",
                           "The right button should function as 'expand' button!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityHint, key: "msdkui_app_hint_expand",
                           "The right button should have the 'expand' accessibility hint!")

        XCTAssertFalse(viewControllerUnderTest.routesList.showTitle, "The route list should not show its title!")

        XCTAssertNotEqual(viewControllerUnderTest.titleItem.title, "msdkui_app_rp_teaser_title".localized,
                          "The app title should be updated!")
    }

    func assertRightButtonHasCollapseFunctionality() {
        XCTAssertFalse(viewControllerUnderTest.showMapView, "ViewController should not show the map!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityLabel, key: "msdkui_app_collapse",
                           "The right button should function as 'collapse' button!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityHint, key: "msdkui_app_hint_collapse",
                           "The right button should have the 'collapse' accessibilty hint!")

        XCTAssertFalse(viewControllerUnderTest.routesList.showTitle, "The route list should not show its title!")

        XCTAssertNotEqual(viewControllerUnderTest.titleItem.title, "msdkui_app_rp_teaser_title".localized,
                          "The app title should be updated!")
    }
}
