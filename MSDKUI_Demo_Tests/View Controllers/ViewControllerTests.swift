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

@testable import MSDKUI
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
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as ViewController
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

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

    /// Tests accessibility strings.
    func testRouteDescriptionAccessibility() throws {
        // Make sure we will have at least one route calculated
        let predicate = NSPredicate(format: "entryCount > 0")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.routesList)

        // Calculate example route
        calculateRoute()

        // Wait for calculated routes
        wait(for: [expectation], timeout: 15)

        // Get strings that we expect to find in accessibility hint
        let car = localizedString(fromKey: "msdkui_car", bundle: .MSDKUI)
        // Remove formatters from parameterized strings
        let duration = localizedString(fromKey: "msdkui_duration_time", bundle: .MSDKUI).replacingOccurrences(of: "%@", with: "")
        let length = localizedString(fromKey: "msdkui_route_length", bundle: .MSDKUI).replacingOccurrences(of: "%@", with: "")
        let arrival = localizedString(fromKey: "msdkui_arrival_time", bundle: .MSDKUI).replacingOccurrences(of: "%@", with: "")

        // Get number for routes calculated
        let entryCount = try require(viewControllerUnderTest?.routesList.entryCount)
        XCTAssertGreaterThan(entryCount, 0, "There must be at least 1 route for test!")

        // Check every route
        for index in 0..<entryCount {
            let cell = try require(viewControllerUnderTest?.routesList.tableView.cellForRow(at: IndexPath(row: index, section: 0)))

            // Check cell accessibility label
            let accessibilityLabel = try require(cell.accessibilityLabel)
            XCTAssertLocalized(accessibilityLabel,
                               formatKey: "msdkui_route_in_list",
                               arguments: index + 1, entryCount,
                               bundle: .MSDKUI,
                               message: "Failed instruction is not correct")

            // Check cell accessibility hint
            let accessibilityHint = try require(cell.accessibilityHint)

            XCTAssertTrue(accessibilityHint.contains(car), "Accessibility hint should contain car!")
            XCTAssertTrue(accessibilityHint.contains(duration), "Accessibility hint should contain duration!")
            XCTAssertTrue(accessibilityHint.contains(length), "Accessibility hint should contain length!")
            XCTAssertTrue(accessibilityHint.contains(arrival), "Accessibility hint should contain arrival!")
        }
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

        XCTAssertNotEqual(viewControllerUnderTest.titleItem.title, localizedString(fromKey: "msdkui_app_rp_teaser_title"),
                          "The app title should be updated!")
    }

    func assertRightButtonHasCollapseFunctionality() {
        XCTAssertFalse(viewControllerUnderTest.showMapView, "ViewController should not show the map!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityLabel, key: "msdkui_app_collapse",
                           "The right button should function as 'collapse' button!")

        XCTAssertLocalized(viewControllerUnderTest.rightButton.accessibilityHint, key: "msdkui_app_hint_collapse",
                           "The right button should have the 'collapse' accessibilty hint!")

        XCTAssertFalse(viewControllerUnderTest.routesList.showTitle, "The route list should not show its title!")

        XCTAssertNotEqual(viewControllerUnderTest.titleItem.title, localizedString(fromKey: "msdkui_app_rp_teaser_title"),
                          "The app title should be updated!")
    }

    // MARK: - Private

    private func localizedString(fromKey key: String, bundle: Bundle? = .main) -> String {
        // Since ".localized" is defined in both MSDKUI and MSDKUI_Demo, we cannot use it
        // This helper method will get localized string with specified key from specified bundle
        guard let bundle = bundle else {
            XCTFail("Invalid bundle")
            return ""
        }

        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "") //swiftlint:disable:this localized_string
    }
}
