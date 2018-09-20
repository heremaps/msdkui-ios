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

class ActionbarUITests: XCTestCase {
    /// Used to save the `TravelTimePanel` text.
    var travelTmePanelText: String?

    let firstRow: Int = 0
    let secondRow: Int = 1
    let thirdRow: Int = 2

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

    /// MSDKUI-147 Reorder waypoints
    /// This test is designed to test the `WaypointList`'s reorder capability.
    func testReorderWaypoint() {

        // Add the 3rd waypoint
        ActionbarActions.addWaypoint()

        // Set all the waypoints with known names
        // Waypoint 1, row 0: "Naturekundemuseum, Berlin"
        // Waypoint 2, row 1: "Reichstag, Berlin"
        // Waypoint 3, row 2: "Branderburger Tor, Berlin"
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag(),
                WaypointEntryFixture.berlinBranderburgerTor()
            ])

        // Check if labels from and to are hidden - waypoints are valid
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 3))
        RouteplannerActions.waitUntilRoutesCalculated()

        var routes = RouteplannerActions.getRouteListRoutes()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Drag 3rd waypoint onto 2nd waypoint
        ActionbarActions.dragAndCheckWaypointChange(
            fromRow: thirdRow,
            toRow: secondRow,
            expectedNames: [
                TestStrings.naturekundemuseumBerlin,
                TestStrings.branderburgerTorBerlin,
                TestStrings.reichstagBerlin
            ])
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RouteplannerActions.getRouteListRoutes()

        // Check if waypoints have labels hidden
        // 3rd was moved to 2nd - so "To" label should be hidden
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 2))
        // 2nd was moved to 3rd - but since valid waypoint - "To" should be hidden
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 3))

        // Drag 1st waypoint onto 3rd waypoint
        ActionbarActions.dragAndCheckWaypointChange(
            fromRow: firstRow,
            toRow: thirdRow,
            expectedNames: [
                TestStrings.branderburgerTorBerlin,
                TestStrings.reichstagBerlin,
                TestStrings.naturekundemuseumBerlin
            ])
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RouteplannerActions.getRouteListRoutes()

        // Check if waypoints have labels hidden
        // 1st was moved to 3rd - so "From" label should be gone, and since valid waypoint, "To" should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 3))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 3))
        // 3rd was moved to 2nd - so "To" label should be hidden
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 2))
        // 2nd was moved to 1st - since waypoint is valid, "From" should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))

        // Drag 1st waypoint onto 2nd waypoint
        ActionbarActions.dragAndCheckWaypointChange(
            fromRow: firstRow,
            toRow: secondRow,
            expectedNames: [
                TestStrings.reichstagBerlin,
                TestStrings.branderburgerTorBerlin,
                TestStrings.naturekundemuseumBerlin
            ])
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Check if waypoints have labels hidden
        // 1st was moved to 2nd - "From" label should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 2))
        // 2nd was moved to 1st - since waypoint is valid, "From" label should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
    }

    /// MSDKUI-148 Reverse waypoint items order
    /// This test is designed to test the `WaypointList`'s reversal capability.
    func testReverseWaypointItemsOrder() {

        // Add the 3rd and 4th waypoints
        ActionbarActions.addWaypoint()
        ActionbarActions.addWaypoint()

        // Set all the waypoints with known names
        // Waypoint 1, row 0: "Naturekundemuseum, Berlin"
        // Waypoint 2, row 1: "Reichstag, Berlin"
        // Waypoint 3, row 2: "Branderburger Tor, Berlin"
        // Waypoint 4, row 3: "Fernsehturm, Berlin"
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag(),
                WaypointEntryFixture.berlinBranderburgerTor(),
                WaypointEntryFixture.berlinFernsehturm()
            ])

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 4))
        RouteplannerActions.waitUntilRoutesCalculated()

        var routes = RouteplannerActions.getRouteListRoutes()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Reverse the waypoints
        ActionbarActions.reverseWaypoints()
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RouteplannerActions.getRouteListRoutes()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 1),
            expectedName: TestStrings.fernsehturmBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 2),
            expectedName: TestStrings.branderburgerTorBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 3),
            expectedName: TestStrings.reichstagBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 4),
            expectedName: TestStrings.naturekundemuseumBerlin)

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 4))

        // Reverse the waypoints again: we should get the initial order
        ActionbarActions.reverseWaypoints()
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 1),
            expectedName: TestStrings.naturekundemuseumBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 2),
            expectedName: TestStrings.reichstagBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 3),
            expectedName: TestStrings.branderburgerTorBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 4),
            expectedName: TestStrings.fernsehturmBerlin)

        // Since all waypoints are valid, "From" and "To" labels should be hidden
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 4))
    }

    /// MSDKUI-149 Set departure time
    /// This test is designed to test the `TravelTimePanel` & `TravelTimePicker`'s time handling.
    func testSetDepartureTime() {

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Launch the time picker
        CoreActions.tap(element: ActionbarView.travelTimePanel)

        // Save the initial date & routes
        ActionbarActions.saveTravelTmePanelText()
        let travelTmePanelText = ActionbarActions.travelTmePanelText
        RouteplannerActions.saveRouteListRoutesAndCount()
        let initialTravelTmePanelText = travelTmePanelText
        let initialRouteListRoutes = RouteplannerActions.routeListRoutes

        // Update the date
        let newDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        ActionbarActions.setPickerDate(newDate!)

        // Save the updated date
        ActionbarActions.saveTravelTmePanelText()
        let updatedTravelTmePanelText = ActionbarActions.travelTmePanelText
        RouteplannerActions.saveRouteListRoutesAndCount()
        let updatedRouteListRoutes = RouteplannerActions.routeListRoutes

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

    /// MSDKUI-137 Select different transportation modes
    /// This test is designed to test the `TransportModePanel`.
    func testSelectDifferentTransportationModes() {

        // Is the default transport mode OK?
        ActionbarActions.saveTransportMode()
        GREYAssertTrue(
            ActionbarActions.transportMode == .car,
            reason: "The default transport mode should be car!")

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        let transportModes = [ActionbarView.transportModeTruck,
                              ActionbarView.transportModePedestrian,
                              ActionbarView.transportModeBike,
                              ActionbarView.transportModeScooter,
                              ActionbarView.transportModeCar]

        // Iterate through given transport modes and check if new routes differ from previous
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: transportModes,
            routes: RouteplannerActions.getRouteListRoutes())
    }

    /// MSDKUI-146 Add/Remove waypoints
    /// This method is designed to test the `RouteDescriptionList` scroll.
    func testAddRemoveWaypoints() {

        // Initiate the two wyapoints
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ])

        // Check that waypoints do not have from and to labels
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 2))

        // Are the initial routes calculated?
        RouteplannerActions.waitUntilRoutesCalculated()

        var routes = RouteplannerActions.getRouteListRoutes()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Add the 3rd waypoint
        ActionbarActions.addWaypoint()

        // Set the newly added third waypoint to a known place
        ActionbarActions.setThirdWaypoint()

        // Is the routes are updated?
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RouteplannerActions.getRouteListRoutes()

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        // Check that waypoint 3 does not have to label displayed
        ActionbarMatchers.checkWaypointToLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 3))

        // Remove the 3rd route
        ActionbarActions.removeWaypoint(
            element: ActionbarView.waypointListCell(cellNr: 3))

        // Is the routes are updated?
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")
    }

    /// MSDKUI-126 Select a waypoint on the map
    func testSelectWaypointOnMap() {
        // Check "From" and "To" labels are displayed correctly
        ActionbarMatchers.checkWaypointFromLabelDisplayed(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))
        ActionbarMatchers.checkWaypointToLabelDisplayed(forWaypoint: ActionbarView.waypointListCell(cellNr: 2))

        // Tap on "From" waypoint (first cell)
        CoreActions.tap(element: ActionbarView.waypointListCell(cellNr: 1))

        // Wait until the view controller becomes ready
        Utils.waitUntil(hidden: "RouteViewController.hudView")

        // Tap somewhere on the map and save the waypoint name when it is reverse geocoded
        CoreActions.tap(element: MapView.waypointMapView, point: Constans.aPointOnMapView)
        Utils.waitUntil(hidden: "WaypointViewController.hudView")
        RoutingActions.saveSelectedWaypointName()

        GREYAssertNotNil(RoutingActions.waypointName, reason: "There should be a waypoint name!")

        // Tap on OK button
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)

        // Check if "From" label is gone
        ActionbarMatchers.checkWaypointFromLabelHidden(forWaypoint: ActionbarView.waypointListCell(cellNr: 1))

        // Check the waypoint name is transferred correctly to the waypoint list
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: 1),
            expectedName: RoutingActions.waypointName!)
    }
}
