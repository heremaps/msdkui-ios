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

import EarlGrey
@testable import MSDKUI
import NMAKit
import XCTest

class RouteViewControllerUITests: XCTestCase {
    /// Used to save the `entryCount` property of the route or maneuver lists.
    var entryCount = 0

    /// Used to save the `NMAMapView` boundingBox property.
    var boundingBox: NMAGeoBoundingBox?

    /// Stringized visible rows like "0, 1, 2, ..." .
    var stringizedVisibleRows: String = ""

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routingPlanner)
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        Utils.allowMapViewRendering(MapView.mapView, false)

        // Return back to the landing view
        CoreActions.tap(element: ActionbarView.exitButton)

        super.tearDown()
    }

    /// MSDKUI-152 Maneuver description
    /// This test is designed to test the `ManeuverDescriptionList` data per row.
    func testManeuverDescription() {
        Utils.initTest(name: #function)

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinReichstag()
        ])
        RouteplannerActions.waitUntilRoutesCalculated()
        Utils.saveWaypointsScreenshot()

        // Check the ManeuverDescriptionItem objects one-by-one for each route
        RoutingActions.checkManueverDescriptionItemEachRouteOnebyOne()
    }

    /// MSDKUI-153 Browse maneuver list
    /// Tests that tapping the maneuvers list affects the map view.
    func testTapManeuverList() {
        Utils.initTest(name: #function)

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinZoologischerGarten()
        ])
        RouteplannerActions.waitUntilRoutesCalculated()
        Utils.saveWaypointsScreenshot()

        // Select the second route
        CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: 2))

        // Wait for the segue effect
        EarlGrey.selectElement(with: RouteplannerView.routeOverviewMapView).assert(grey_sufficientlyVisible())
        Utils.saveScreenshot()

        // Save the initial bounding box
        MapActions.saveMapViewBoundingBox()
        let initialBoundingBox = MapActions.boundingBox

        // Tap the first maneuver
        CoreActions.tap(element: RoutingView.maneuverDescriptionListCell(cellNr: 1))
        MapActions.mustHaveNewBoundingBox(existingBoundingBox: initialBoundingBox)
        Utils.saveScreenshot()

        MapActions.saveMapViewBoundingBox()
        let firstManeuverBoundingBox = MapActions.boundingBox

        // Tap a random maneuver
        RoutingActions.tapRandomManeuver()
        MapActions.mustHaveNewBoundingBox(existingBoundingBox: firstManeuverBoundingBox)
        Utils.saveScreenshot()

        // Return back
        CoreActions.tap(element: RouteplannerView.backButton)
    }

    /// MSDKUI-153 Browse maneuver list
    /// Tests that swiping the maneuvers list results in scrolls.
    func testScrollManeuverList() {
        Utils.initTest(name: #function)

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinReichstag()
        ])
        RouteplannerActions.waitUntilRoutesCalculated()
        Utils.saveWaypointsScreenshot()

        // Select the second route
        CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: 2))

        // Wait for the segue effect
        Utils.waitFor(element: MapView.mapView)
        Utils.saveScreenshot()

        // Save the initial visible rows
        RoutingActions.saveManeuverListVisibleRows()
        let initialVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: RoutingView.manouverDesctiptionList)
        RoutingActions.maneuverListMustHaveNewVisibleRows(currentRows: initialVisibleRows)
        Utils.saveScreenshot()

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: RoutingView.manouverDesctiptionList)
        RoutingActions.maneuverListMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)
        Utils.saveScreenshot()

        // Return back
        CoreActions.tap(element: RouteplannerView.backButton)
    }

    /// MSDKUI-140 - Scroll route list state (multiple routes count)
    /// Tests that swiping the route list results in scrolls.
    func testScrollRouteList() {
        Utils.initTest(name: #function)

        // We want to have as many routes as possible
        CoreActions.tap(element: ActionbarView.transportModeBike)

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinZoologischerGarten()
        ])
        RouteplannerActions.waitUntilRoutesCalculated()
        Utils.saveWaypointsScreenshot()

        // Save the initial visible rows
        RoutingActions.saveRouteListVisibleRows()
        let initialVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: RouteplannerView.routeDescriptionList)
        RoutingActions.routeListMustHaveNewVisibleRows(currentRows: initialVisibleRows)
        Utils.saveScreenshot()

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: RouteplannerView.routeDescriptionList)
        RoutingActions.routeListMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)
        Utils.saveScreenshot()
    }
}
