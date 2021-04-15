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
import Foundation
import XCTest

final class WaypointListTests: XCTestCase {

    private let firstRow: Int = 0
    private let secondRow: Int = 1
    private let thirdRow: Int = 2

    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routePlanner)
    }

    override func tearDown() {
        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)

        super.tearDown()
    }

    // MARK: - Tests

    /// MSDKUI-147: Reorder waypoints.
    /// Check that waypoints can reordered.
    func testReorderWaypoint() {

        // Add the 3rd waypoint
        RoutePlannerActions.addWaypoint()

        // Set all the waypoints with known names
        // Waypoint 1, row 0: "Naturekundemuseum, Berlin"
        // Waypoint 2, row 1: "Reichstag, Berlin"
        // Waypoint 3, row 2: "Branderburger Tor, Berlin"
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag(),
                WaypointEntryFixture.berlinBranderburgerTor()
            ])

        // Check if labels from and to are hidden - waypoints are valid
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 2))
        RoutePlannerActions.waitUntilRoutesCalculated()

        var routes = RoutePlannerActions.getRouteListRoutes()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Drag 3rd waypoint onto 2nd waypoint
        RoutePlannerActions.dragAndCheckWaypointChange(
            fromRow: thirdRow,
            toRow: secondRow,
            expectedNames: [
                TestStrings.naturekundemuseumBerlin,
                TestStrings.branderburgerTorBerlin,
                TestStrings.reichstagBerlin
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RoutePlannerActions.getRouteListRoutes()

        // Check if waypoints have labels hidden
        // 3rd was moved to 2nd - so "To" label should be hidden
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 1))
        // 2nd was moved to 3rd - but since valid waypoint - "To" should be hidden
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 2))

        // Drag 1st waypoint onto 3rd waypoint
        RoutePlannerActions.dragAndCheckWaypointChange(
            fromRow: firstRow,
            toRow: thirdRow,
            expectedNames: [
                TestStrings.branderburgerTorBerlin,
                TestStrings.reichstagBerlin,
                TestStrings.naturekundemuseumBerlin
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RoutePlannerActions.getRouteListRoutes()

        // Check if waypoints have labels hidden
        // 1st was moved to 3rd - so "From" label should be gone, and since valid waypoint, "To" should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 2))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 2))
        // 3rd was moved to 2nd - so "To" label should be hidden
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 1))
        // 2nd was moved to 1st - since waypoint is valid, "From" should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))

        // Drag 1st waypoint onto 2nd waypoint
        RoutePlannerActions.dragAndCheckWaypointChange(
            fromRow: firstRow,
            toRow: secondRow,
            expectedNames: [
                TestStrings.reichstagBerlin,
                TestStrings.branderburgerTorBerlin,
                TestStrings.naturekundemuseumBerlin
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Check if waypoints have labels hidden
        // 1st was moved to 2nd - "From" label should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 1))
        // 2nd was moved to 1st - since waypoint is valid, "From" label should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
    }

    /// MSDKUI-148: Reverse Waypoints.
    /// Check that waypoints can be reversed.
    func testReverseWaypointItemsOrder() {

        // Add the 3rd and 4th waypoints
        RoutePlannerActions.addWaypoint()
        RoutePlannerActions.addWaypoint()

        // Set all the waypoints with known names
        // Waypoint 1, row 0: "Naturekundemuseum, Berlin"
        // Waypoint 2, row 1: "Reichstag, Berlin"
        // Waypoint 3, row 2: "Branderburger Tor, Berlin"
        // Waypoint 4, row 3: "Fernsehturm, Berlin"
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag(),
                WaypointEntryFixture.berlinBranderburgerTor(),
                WaypointEntryFixture.berlinFernsehturm()
            ])

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 3))
        RoutePlannerActions.waitUntilRoutesCalculated()

        var routes = RoutePlannerActions.getRouteListRoutes()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Reverse the waypoints
        RoutePlannerActions.reverseWaypoints()
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RoutePlannerActions.getRouteListRoutes()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 0),
            expectedName: TestStrings.fernsehturmBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 1),
            expectedName: TestStrings.branderburgerTorBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 2),
            expectedName: TestStrings.reichstagBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 3),
            expectedName: TestStrings.naturekundemuseumBerlin)

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 3))

        // Reverse the waypoints again: we should get the initial order
        RoutePlannerActions.reverseWaypoints()
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 0),
            expectedName: TestStrings.naturekundemuseumBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 1),
            expectedName: TestStrings.reichstagBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 2),
            expectedName: TestStrings.branderburgerTorBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 3),
            expectedName: TestStrings.fernsehturmBerlin)

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 3))
    }

    /// MSDKUI-146: Add and remove waypoints from existing route.
    /// Check that waypoints can be added and removed from a calculated route.
    func testAddRemoveWaypoints() {

        // Initiate the two wyapoints
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        // Check that waypoints do not have from and to labels
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 1))

        // Are the initial routes calculated?
        RoutePlannerActions.waitUntilRoutesCalculated()

        var routes = RoutePlannerActions.getRouteListRoutes()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Add the 3rd waypoint
        RoutePlannerActions.addWaypoint()

        // Set the newly added third waypoint to a known place
        RoutePlannerActions.setThirdWaypoint()

        // Is the routes are updated?
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RoutePlannerActions.getRouteListRoutes()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Check that waypoint 3 does not have to label displayed
        WaypointActions.checkWaypointToLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 2))

        // Remove the 3rd route
        RoutePlannerActions.removeWaypoint(
            element: RoutePlannerMatchers.waypointListCell(cellNr: 2))

        // Is the routes are updated?
        RoutePlannerActions.waitUntilRoutesCalculated()
        RoutePlannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)
    }

    /// MSDKUI-126: Add waypoints.
    /// Check that adding a waypoint works and correct address is displayed in Route Planner.
    func testSelectWaypointOnMap() {
        // Check "From" and "To" labels are displayed correctly
        WaypointActions.checkWaypointFromLabelDisplayed(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))
        WaypointActions.checkWaypointToLabelDisplayed(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 1))

        // Tap on "From" waypoint (first cell)
        CoreActions.tap(element: RoutePlannerMatchers.waypointListCell(cellNr: 0))

        // Wait until the view controller becomes ready
        Utils.waitUntil(hidden: "RouteViewController.hudView")

        // Tap somewhere on the map and save the waypoint name when it is reverse geocoded
        CoreActions.tap(element: WaypointMatchers.waypointMapView, point: Constants.aPointOnMapView)
        Utils.waitUntil(hidden: "WaypointViewController.hudView")
        RoutePlannerActions.saveSelectedWaypointName()

        GREYAssertNotNil(RoutePlannerActions.waypointName, reason: "There should be a waypoint name!")

        // Tap on OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)

        // Check if "From" label is gone
        WaypointActions.checkWaypointFromLabelHidden(forWaypoint: RoutePlannerMatchers.waypointListCell(cellNr: 0))

        // Check the waypoint name is transferred correctly to the waypoint list
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 0),
            expectedName: RoutePlannerActions.waypointName)
    }

    /// MSDKUI-138: Update waypoints.
    /// Check that updating waypoint results in route recalculation.
    func testUpdateWaypointAndVerifyRouteChanged() {

        // Set all the waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RoutePlannerActions.updateTransportModeWithWaypointsAndVerify(
            transportMode: RoutePlannerMatchers.transportModeCar,
            firstWaypoint: WaypointEntryFixture.berlinBranderburgerTor(),
            secondWaypoint: WaypointEntryFixture.berlinReichstag())

        // Switch to truck mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RoutePlannerActions.updateTransportModeWithWaypointsAndVerify(
            transportMode: RoutePlannerMatchers.transportModeTruck,
            firstWaypoint: WaypointEntryFixture.berlinAlexanderplatz(),
            secondWaypoint: WaypointEntryFixture.berlinZoologischerGarten())

        // Switch to walking mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RoutePlannerActions.updateTransportModeWithWaypointsAndVerify(
            transportMode: RoutePlannerMatchers.transportModePedestrian,
            firstWaypoint: WaypointEntryFixture.berlinBranderburgerTor(),
            secondWaypoint: WaypointEntryFixture.berlinAlexanderplatz())

        // switch to bike mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RoutePlannerActions.updateTransportModeWithWaypointsAndVerify(
            transportMode: RoutePlannerMatchers.transportModeBike,
            firstWaypoint: WaypointEntryFixture.berlinReichstag(),
            secondWaypoint: WaypointEntryFixture.berlinBranderburgerTor())

        // switch to scooter mode
        // Change the first waypoint value
        // Starting waypoint is updated. Updated route is automatically calculated.
        // Change the second waypoint value
        // Second waypoint is updated. Updated route is automatically calculated
        RoutePlannerActions.updateTransportModeWithWaypointsAndVerify(
            transportMode: RoutePlannerMatchers.transportModeScooter,
            firstWaypoint: WaypointEntryFixture.berlinNaturekundemuseum(),
            secondWaypoint: WaypointEntryFixture.berlinZoologischerGarten())
    }

    /// MSDKUI-145: Scroll waypoint list.
    /// Check that swiping the waypoint list results in scrolls.
    func testScrollWaypointList() {

        // Add the 3rd, 4th, 5th and 6th waypoints
        RoutePlannerActions.addWaypoint()
        RoutePlannerActions.addWaypoint()
        RoutePlannerActions.addWaypoint()
        RoutePlannerActions.addWaypoint()

        // Set all the waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinAlexanderplatz(),
                WaypointEntryFixture.berlinFernsehturm(),
                WaypointEntryFixture.berlinBranderburgerTor(),
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Expand waypoint list
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        // Save the initial visible rows
        RoutePlannerActions.saveWaypointListVisibleRows()
        let initialVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe up, i.e. scroll down
        CoreActions.swipeUpOn(element: RoutePlannerMatchers.waypointList)
        RoutePlannerActions.waypointListMustHaveNewVisibleRows(currentRows: initialVisibleRows)

        // Save the new visible rows
        let afterScrollDownVisibleRows = RoutePlannerActions.stringizedVisibleRows

        // Swipe down, i.e. scroll up
        CoreActions.swipeDownOn(element: RoutePlannerMatchers.waypointList)
        RoutePlannerActions.waypointListMustHaveNewVisibleRows(currentRows: afterScrollDownVisibleRows)
    }
}
