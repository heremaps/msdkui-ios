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

import EarlGrey
import NMAKit
import XCTest

final class RoutesAndManeuversTests: XCTestCase {

    /// Used to save the `entryCount` property of the route or maneuver lists.
    private var entryCount = 0

    /// Used to save the `NMAMapView` boundingBox property.
    private var boundingBox: NMAGeoBoundingBox?

    /// Stringized visible rows like "0, 1, 2, ..." .
    private var stringizedVisibleRows: String = ""

    /// Used to save the `TravelTimePanel` text.
    private var travelTmePanelText: String?

    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routePlanner)
    }

    override func tearDown() {
        // Rotate device to portrait
        EarlGrey.rotateDeviceTo(orientation: .portrait, errorOrNil: nil)

        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)

        super.tearDown()
    }

    // MARK: - Tests

    /// MSDKUI-133: Create a route.
    /// Check that waypoints are correctly displayed.
    func testCreateRoutesWithTwoWaypoints() {

        // Set all the waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Location address is filled for first waypoint
        EarlGrey.selectElement(with: Utils.viewContainingText(WaypointEntryFixture.berlinZoologischerGarten().name))
            .assert(grey_sufficientlyVisible())

        // Location address is filled for second waypoint
        EarlGrey.selectElement(with: Utils.viewContainingText(WaypointEntryFixture.berlinAlexanderplatz().name))
            .assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-149: Change departure time.
    /// Check that changing time picker times also changes departure times.
    func testSetDepartureTime() {

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Launch the time picker
        CoreActions.tap(element: RoutePlannerMatchers.travelTimePanel)

        // Save the initial date & routes
        RoutePlannerActions.saveTravelTmePanelText()
        let travelTmePanelText = RoutePlannerActions.travelTmePanelText
        RoutePlannerActions.saveRouteListRoutesAndCount()
        let initialTravelTmePanelText = travelTmePanelText
        let initialRouteListRoutes = RoutePlannerActions.routeListRoutes

        // Update the date
        let newDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        RoutePlannerActions.setPickerDate(newDate)

        // Save the updated date
        RoutePlannerActions.saveTravelTmePanelText()
        let updatedTravelTmePanelText = RoutePlannerActions.travelTmePanelText
        RoutePlannerActions.saveRouteListRoutesAndCount()
        let updatedRouteListRoutes = RoutePlannerActions.routeListRoutes

        // Assert that they are not equal
        GREYAssertTrue(
            initialTravelTmePanelText != updatedTravelTmePanelText,
            reason: "No TravelTimePanel update!"
        )
        GREYAssertTrue(
            initialRouteListRoutes != updatedRouteListRoutes,
            reason: "No RouteDescriptionList update!"
        )
    }

    /// MSDKUI-137: Calculate route for different transport modes.
    /// Check that different transport modes show correct routes for each.
    func testSelectDifferentTransportModes() {

        // Is the default transport mode OK?
        RoutePlannerActions.saveTransportMode()
        GREYAssertTrue(
            RoutePlannerActions.transportMode == .car,
            reason: "The default transport mode should be car!")

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        let transportModes = [RoutePlannerMatchers.transportModeTruck,
                              RoutePlannerMatchers.transportModePedestrian,
                              RoutePlannerMatchers.transportModeBike,
                              RoutePlannerMatchers.transportModeScooter,
                              RoutePlannerMatchers.transportModeCar]

        // Iterate through given transport modes and check if new routes differ from previous
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: transportModes,
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-152: Maneuver description list components.
    /// Check maneuver description list by verifying its components.
    func testManeuverDescription() {

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinReichstag()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Check the ManeuverItemView objects one-by-one for each route
        RoutePlannerActions.checkManeuversOfEachRoute()
    }

    /// MSDKUI-153: Scroll maneuver table view.
    /// Check that swiping the maneuvers list results in scrolls.
    func testScrollManeuverTableView() {

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinZoologischerGarten(),
            WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Select the first route
        CoreActions.tap(element: RoutePlannerMatchers.routeDescriptionListCell(cellNr: 0))

        // Wait until the view controller becomes ready
        Utils.waitUntil(hidden: "RouteViewController.hudView")

        // Show maneuvers
        CoreActions.tap(element: WaypointMatchers.showManeuversButton)

        // Save the initial visible rows
        RouteOverViewActions.saveManeuverTableViewVisibleRows()
        let initialVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: RouteOverviewMatchers.maneuverTableView)
        RouteOverViewActions.maneuverTableViewMustHaveNewVisibleRows(currentRows: initialVisibleRows)

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: RouteOverviewMatchers.maneuverTableView)
        RouteOverViewActions.maneuverTableViewMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)

        // Return back
        CoreActions.tap(element: RoutePlannerMatchers.backButton)
    }

    /// MSDKUI-140: Scroll route list.
    /// Check that swiping the route list results in scrolls.
    /// - Note: In case of X-series iPhones, route list scroll is being checked in landcape because
    ///   in portrait all the routes fit on the screen.
    func testScrollRouteList() {

        // If X-series device is used, switch to landscape mode to test scroll
        // Those screen heights start at 812 points
        if UIScreen.main.bounds.height > 811 {
            // Rotate device to landscape
            EarlGrey.rotateDeviceTo(orientation: .landscapeLeft, errorOrNil: nil)
        }

        // We want to have as many routes as possible
        CoreActions.tap(element: RoutePlannerMatchers.transportModeBike)

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(waypoints: [
            WaypointEntryFixture.berlinNaturekundemuseum(),
            WaypointEntryFixture.berlinZoologischerGarten()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Save the initial visible rows
        RoutePlannerActions.saveRouteListVisibleRows()
        let initialVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: RoutePlannerMatchers.routeDescriptionList)
        RoutePlannerActions.routeListMustHaveNewVisibleRows(currentRows: initialVisibleRows)

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: RoutePlannerMatchers.routeDescriptionList)
        RoutePlannerActions.routeListMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)
    }

    /// MSDKUI-317: Clear route.
    /// Check that route can be cleared by exit button.
    func testClearRoute() {

        // Set all the waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Waypoints selected
        EarlGrey.selectElement(with: Utils.viewContainingText(WaypointEntryFixture.berlinZoologischerGarten().name))
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: Utils.viewContainingText(WaypointEntryFixture.berlinAlexanderplatz().name))
            .assert(grey_sufficientlyVisible())

        // Tap Exit button
        CoreActions.tap(element: CoreMatchers.exitButton)

        // User is on the landing page
        Utils.waitUntil(visible: LandingMatchers.routePlanner)

        // Tap Route planner
        CoreActions.tap(element: LandingMatchers.routePlanner)

        // User is on the route planner view
        Utils.waitUntil(visible: RoutePlannerMatchers.helperScrollView)

        // Waypoints are cleared
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.from))
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.to))
            .assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-1628: Tunnel route option applied.
    /// Check that route is recalculated after enabling tunnels.
    func testTunnelOptionApplied() {
        // Make sure default transport mode car is selected
        RoutePlannerActions.saveTransportMode()
        GREYAssertTrue(
            RoutePlannerActions.transportMode == .car,
            reason: "The default transport mode should be car!"
        )

        // Set all the waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinHauptbahnhof(),
                WaypointEntryFixture.berlinPotsdamerPlatz()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Get data for first initially calculated route
        guard let initialRoute = RoutePlannerActions.routeListRoutes.first else {
            GREYFail("No route is found")
            return
        }

        // Go to route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)
        EarlGrey.selectElement(with: RoutePlannerOptionMatchers.optionRouteOptions)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        // Tap avoid tunnels switch
        EarlGrey.selectElement(with: RoutePlannerOptionMatchers.optionSwitchAvoidTunnels)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        // Back to route planner
        EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
        EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Get data for first updated route
        guard let updatedRoute = RoutePlannerActions.routeListRoutes.first else {
            GREYFail("No route is found")
            return
        }

        // Check if length and duration is different for initial and updated route
        GREYAssertNotEqualObjects(initialRoute.length, updatedRoute.length, reason: "Lengths should be different")
        GREYAssertNotEqualObjects(initialRoute.ttaExcludingTraffic(forSubleg: UInt(NMARouteSublegWhole))?.duration,
                                  updatedRoute.ttaExcludingTraffic(forSubleg: UInt(NMARouteSublegWhole))?.duration,
                                  reason: "Durations should be different")
    }
}
