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

class RouteDescriptionListUITests: XCTestCase {
    /// Used to save the `TravelTimePanel` text.
    var travelTmePanelText: String?

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

    /// MSDKUI-145 Scroll waypoint list
    /// Tests that swiping the waypoint list results in scrolls.
    func testScrollWaypointList() {

        // Add the 3rd, 4th, 5th and 6th waypoints
        ActionbarActions.addWaypoint()
        ActionbarActions.addWaypoint()
        ActionbarActions.addWaypoint()
        ActionbarActions.addWaypoint()

        // Set all the waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz(),
                WaypointEntryFixture.berlinFernsehturm(),
                WaypointEntryFixture.berlinBranderburgerTor(),
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])
        RouteplannerActions.waitUntilRoutesCalculated()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Save the initial visible rows
        RoutingActions.saveWaypointListVisibleRows()
        let initialVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: ActionbarView.waypointList)
        RoutingActions.waypointListMustHaveNewVisibleRows(currentRows: initialVisibleRows)

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutingActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: ActionbarView.waypointList)
        RoutingActions.waypointListMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)
    }

    /// MSDKUI-138 Update a waypoint and verify route changed
    /// Tests that it should be possible to update a waypoint and calculate a new route.
    func testUpdateAWaypointAndVerifyRouteChanged() {

        // Set all the waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RouteplannerActions.waitUntilRoutesCalculated()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.selectRouteModeUpdateWaypointsAndVerify(
            routeMode: ActionbarView.transportModeCar,
            firstWaypoint: WaypointEntryFixture.berlinBranderburgerTor(),
            secondWaypoint: WaypointEntryFixture.berlinReichstag())

        // Switch to truck mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.selectRouteModeUpdateWaypointsAndVerify(
            routeMode: ActionbarView.transportModeTruck,
            firstWaypoint: WaypointEntryFixture.berlinAlexanderplatz(),
            secondWaypoint: WaypointEntryFixture.berlinZoologischerGarten())

        // Switch to walking mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.selectRouteModeUpdateWaypointsAndVerify(
            routeMode: ActionbarView.transportModePedestrian,
            firstWaypoint: WaypointEntryFixture.berlinBranderburgerTor(),
            secondWaypoint: WaypointEntryFixture.berlinAlexanderplatz())

        // switch to bike mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.selectRouteModeUpdateWaypointsAndVerify(
            routeMode: ActionbarView.transportModeBike,
            firstWaypoint: WaypointEntryFixture.berlinReichstag(),
            secondWaypoint: WaypointEntryFixture.berlinBranderburgerTor())

        // switch to scooter mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.selectRouteModeUpdateWaypointsAndVerify(
            routeMode: ActionbarView.transportModeScooter,
            firstWaypoint: WaypointEntryFixture.berlinNaturekundemuseum(),
            secondWaypoint: WaypointEntryFixture.berlinZoologischerGarten())
    }

    /// MSDKUI-133 Create a route with two waypoints
    func testCreateARouteWithTwoWaypoints() {

        // Set all the waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RouteplannerActions.waitUntilRoutesCalculated()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Expecting the route planner to be expanded

        // Location address is filled for first waypoint
        EarlGrey.selectElement(with: viewContainingText(
            text: WaypointEntryFixture.berlinZoologischerGarten().name))
            .assert(grey_sufficientlyVisible())

        // Location address is filled for second waypoint
        EarlGrey.selectElement(with: viewContainingText(
            text: WaypointEntryFixture.berlinAlexanderplatz().name))
            .assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-317 Clear waypoints (back button)
    /// There is no clear understanding how the test case should work.
    /// It is automated based on iOS app actual behaviour.
    func testClearWaypoints() {

        // Set all the waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RouteplannerActions.waitUntilRoutesCalculated()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Waypoints selected
        EarlGrey.selectElement(with: viewContainingText(
            text: WaypointEntryFixture.berlinZoologischerGarten().name))
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: viewContainingText(
            text: WaypointEntryFixture.berlinAlexanderplatz().name))
            .assert(grey_sufficientlyVisible())

        // Tap Exit button
        CoreActions.tap(element: ActionbarView.exitButton)

        // User is on the landing page
        Utils.waitUntil(visible: "LandingViewController.routePanner")

        // Tap Route planner
        CoreActions.tap(element: LandingView.routingPlanner)

        // User is on the route planner view
        Utils.waitUntil(visible: "ViewController.mapView")

        // Waypoints are cleared
        EarlGrey.selectElement(with: viewContainingText(text: TestStrings.from))
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: viewContainingText(text: TestStrings.to))
            .assert(grey_sufficientlyVisible())
    }
}
