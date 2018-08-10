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
import Foundation
@testable import MSDKUI
import NMAKit
import XCTest

class RoutePlannerIntegrationTests: XCTestCase {
    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routingPlanner)
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // Rotate device to portrait
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.portrait, errorOrNil: nil)

        // The map view rendering is problematic at the end of tests
        Utils.allowMapViewRendering(MapView.mapView, false)

        // Return back to the landing view
        CoreActions.tap(element: ActionbarView.exitButton)

        super.tearDown()
    }

    let waypointCellNr1 = 1
    let waypointCellNr2 = 2

    // MSDKUI-675 choose waypoint item and verify selection screeen opens
    // Taps to add value to existing waypoint
    func testChoseWaypointItemAndVerifySelectionScreenOpens() {
        Utils.initTest(name: #function)

        CoreActions.tap(element: ActionbarView.waypointListCell(cellNr: waypointCellNr1))
        GREYAssertNotNil(viewContainingText(text: TestStrings.tapOrLongPressOnTheMap),
                         reason: "Waypoint selection did not open!")

        // Due to the UI reset function test has to exit the waypoint picker map
        CoreActions.tap(element: MapView.waypointMapViewExitButton)
    }

    // MSDKUI-675 Adding a waypoint item opens the map
    // Taps to add new waypoint
    func testAddingAWaypointItemOpensTheMap() {
        Utils.initTest(name: #function)

        CoreActions.tap(element: ActionbarView.addButton)

        GREYAssertNotNil(viewContainingText(text: TestStrings.tapOrLongPressOnTheMap),
                         reason: "Waypoint selection did not open the map!")

        // Due to the UI reset function test has to exit the waypoint picker map
        CoreActions.tap(element: MapView.waypointMapViewExitButton)
    }

    // MSDKUI-675 reverse waypoint items
    func testReverseWaypointItems() {
        Utils.initTest(name: #function)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        CoreActions.tap(element: ActionbarView.viewContollerRight)

        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: waypointCellNr1),
            expectedName: TestStrings.naturekundemuseumBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: waypointCellNr2),
            expectedName: TestStrings.reichstagBerlin)

        CoreActions.tap(element: ActionbarView.swapButton)

        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: waypointCellNr1),
            expectedName: TestStrings.reichstagBerlin)
        ActionbarMatchers.checkWaypointName(
            withId: ActionbarView.waypointListCell(cellNr: waypointCellNr2),
            expectedName: TestStrings.naturekundemuseumBerlin)
    }

    // MSDKUI-675 expand/collapse
    // Tests expansion and collapsing of actionbar
    func testExpandCollapse() {
        Utils.initTest(name: #function)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        EarlGrey.selectElement(with: ActionbarView.waypointList).assert(grey_notVisible())

        CoreActions.tap(element: ActionbarView.viewContollerRight)

        EarlGrey.selectElement(with: ActionbarView.waypointList).assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-882 [iOS] Implementation - Integration tests for Route Planner/Travel time panel
    func testTravelTimePanel() {
        // Open travel time panel
        CoreActions.tap(element: ActionbarView.travelTimePanel)

        // Wait for the picker view
        Utils.waitFor(element: ActionbarView.travelTimePanelTitle)
        Utils.saveScreenshot()

        // Tap the "OK" button
        CoreActions.tap(element: ActionbarView.travelTimePickerOk)

        // Time picker is not visible
        EarlGrey.selectElement(with: MapView.mapView).assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-880 [iOS] Implementation - Integration tests for Route Planner/Transport Mode
    /// Tests that at car routes are different from scooter routes
    func testTransportModeCar() {
        Utils.initTest(name: #function)

        // Set default routes to scooter
        CoreActions.tap(element: ActionbarView.transportModeScooter)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        RouteplannerActions.waitUntilRoutesCalculated()
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [ActionbarView.transportModeCar],
            routes: RouteplannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880 [iOS] Implementation - Integration tests for Route Planner/Transport Mode
    /// Tests that truck routes are different from bike routes
    func testTransportModeTruck() {
        Utils.initTest(name: #function)

        // Set default routes to bicycle
        CoreActions.tap(element: ActionbarView.transportModeBike)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        RouteplannerActions.waitUntilRoutesCalculated()
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [ActionbarView.transportModeTruck],
            routes: RouteplannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880 [iOS] Implementation - Integration tests for Route Planner/Transport Mode
    /// Tests that pedestrian routes are different from truck routes
    func testTransportModePedestrian() {
        Utils.initTest(name: #function)

        // Set default routes to truck
        CoreActions.tap(element: ActionbarView.transportModeTruck)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        RouteplannerActions.waitUntilRoutesCalculated()
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [ActionbarView.transportModePedestrian],
            routes: RouteplannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880 [iOS] Implementation - Integration tests for Route Planner/Transport Mode
    /// Tests that bicycle routes are different from car routes
    func testTransportModeBicycle() {
        Utils.initTest(name: #function)

        // Set default routes to car
        CoreActions.tap(element: ActionbarView.transportModeCar)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        RouteplannerActions.waitUntilRoutesCalculated()
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [ActionbarView.transportModeBike],
            routes: RouteplannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880 [iOS] Implementation - Integration tests for Route Planner/Transport Mode
    /// Tests that scooter routes are different from pedestrian routes
    func testTransportModeScooter() {
        Utils.initTest(name: #function)

        // Set default routes to pedestrian
        CoreActions.tap(element: ActionbarView.transportModePedestrian)

        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinNaturekundemuseum(),
                WaypointEntryFixture.berlinReichstag()
            ]
        )

        RouteplannerActions.waitUntilRoutesCalculated()
        ActionbarActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [ActionbarView.transportModeScooter],
            routes: RouteplannerActions.getRouteListRoutes())
    }
}
