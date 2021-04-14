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
@testable import MSDKUI
import XCTest

final class RoutePlannerIntegrationTests: XCTestCase {

    private let car = RoutePlannerMatchers.transportModeCar
    private let truck = RoutePlannerMatchers.transportModeTruck
    private let pedestrian = RoutePlannerMatchers.transportModePedestrian
    private let bicycle = RoutePlannerMatchers.transportModeBike
    private let scooter = RoutePlannerMatchers.transportModeScooter

    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routePlanner)
    }

    override func tearDown() {
        // Rotate device to portrait
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.portrait, errorOrNil: nil)

        // Set default routes to car
        CoreActions.tap(element: car)

        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)

        super.tearDown()
    }

    // MARK: - Tests

    /// MSDKUI-675: Open waypoints.
    /// Check that waypoint screen is openend.
    func testChoseWaypointItemAndVerifySelectionScreenOpens() {
        CoreActions.tap(element: RoutePlannerMatchers.waypointListCell(cellNr: 1))
        GREYAssertNotNil(Utils.viewContainingText(TestStrings.tapOrLongPressOnTheMap),
                         reason: "Waypoint selection did not open!")

        // Due to the UI reset function test has to exit the waypoint picker map
        CoreActions.tap(element: CoreMatchers.exitButton)
    }

    /// MSDKUI-675: Add waypoints.
    /// Check that a waypoint can be added.
    func testAddingAWaypointItemOpensTheMap() {
        CoreActions.tap(element: RoutePlannerMatchers.addButton)

        GREYAssertNotNil(Utils.viewContainingText(TestStrings.tapOrLongPressOnTheMap),
                         reason: "Waypoint selection did not open the map!")

        // Due to the UI reset function test has to exit the waypoint picker map
        CoreActions.tap(element: CoreMatchers.exitButton)
    }

    /// MSDKUI-675: Reverse waypoints.
    /// Check that waypoints can be reversed and route is calculated.
    func testReverseWaypointItems() {
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: car)

        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 0),
            expectedName: TestStrings.naturekundemuseumBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 1),
            expectedName: TestStrings.reichstagBerlin)

        CoreActions.tap(element: RoutePlannerMatchers.swapButton)

        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 0),
            expectedName: TestStrings.reichstagBerlin)
        WaypointActions.checkWaypointName(
            withId: RoutePlannerMatchers.waypointListCell(cellNr: 1),
            expectedName: TestStrings.naturekundemuseumBerlin)
    }

    /// MSDKUI-675: Expand and collapse Route Planner.
    /// Check that Route Planner can be expanded and collapsed.
    func testExpandCollapse() {
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: car)

        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).assert(grey_notVisible())

        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-882: Open travel time panel.
    /// Check if travel time panel opens.
    func testTravelTimePanel() {
        // Open travel time panel
        CoreActions.tap(element: RoutePlannerMatchers.travelTimePanel)

        // Wait for the picker view
        Utils.waitUntil(visible: RoutePlannerMatchers.travelTimePanelTitle)

        // Tap the "OK" button
        CoreActions.tap(element: RoutePlannerMatchers.travelTimePickerOk)

        // Time picker is not visible
        EarlGrey.selectElement(with: RoutePlannerMatchers.helperScrollView).assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-886: Calculate route for car.
    /// Check that there is at least one route shown for car mode.
    func testAnyRoutesBeingShownForCar() {
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: car)
        RoutePlannerActions.checkAnyRoutesAreShown()
    }

    /// MSDKUI-880: Test transport modes (car).
    /// Check that at car routes are different from scooter routes.
    func testTransportModeCar() {

        // Set default transport mode to scooter and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: scooter)

        // Switch to car and check if routes differ from previous mode
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [car],
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880: Test transport modes (truck).
    /// Check that truck routes are different from bicycle routes.
    func testTransportModeTruck() {

        // Set default transport mode to bicycle and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: bicycle)

        // Switch to truck and check if routes differ from previous mode
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [truck],
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880: Test transport modes (pedestrian).
    /// Check that pedestrian routes are different from truck routes.
    func testTransportModePedestrian() {

        // Set default transport mode to truck and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: truck)

        // Switch to pedestrian and check if routes differ from previous mode
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [pedestrian],
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880: Test transport modes (bicycle).
    /// Check that bicycle routes are different from car routes.
    func testTransportModeBicycle() {

        // Set default transport mode to truck and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: car)

        // Switch to bicycle and check if routes differ from previous mode
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [bicycle],
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-880: Test transport modes (scooter).
    /// Check that scooter routes are different from pedestrian routes.
    func testTransportModeScooter() {

        // Set default transport mode to pedestrian and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: pedestrian)

        // Switch to scooter and check if routes differ from previous mode
        RoutePlannerActions.switchToTransportModeAndVerifyRouteChange(
            transportModes: [scooter],
            routes: RoutePlannerActions.getRouteListRoutes())
    }

    /// MSDKUI-884: Open route preview.
    /// Check that route preview opens and route description is displayed.
    ///
    /// Portrait version of the test.
    func testRoutePreviewTestInPortrait() {
        performRoutePreviewTest(isLandscape: false)
    }

    /// MSDKUI-884: Open route preview.
    /// Check that route preview opens and route description is displayed.
    ///
    /// Landscape version of the test.
    func testRoutePreviewTestInLandscape() {
        performRoutePreviewTest(isLandscape: true)
    }

    /// MSDKUI-1473: Show maneuver table view.
    /// Check that switching between route overview and maneuver table view works
    /// Portrait version of the test.
    func testOpenManeuverTableViewInPortrait() {
        performOpenManeuverTableViewTest(isLandscape: false)
    }

    /// MSDKUI-1473: Show maneuver table view.
    /// Check that switching between route overview and maneuver table view works
    /// Landscape version of the test.
    func testOpenManeuverTableViewInLandscape() {
        performOpenManeuverTableViewTest(isLandscape: true)
    }

    // MARK: - Private

    /// Method that implements MSDKUI-884 test.
    ///
    /// - Parameter isLandscape: if `true`, test will be performed in landscape, if `false` - in portrait.
    private func performRoutePreviewTest(isLandscape: Bool) {
        if isLandscape {
            EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)
        }

        // Set the two waypoints with known names
        RoutePlannerActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinFernsehturm()
            ]
        )
        RoutePlannerActions.waitUntilRoutesCalculated()

        // Select the first route
        CoreActions.tap(element: RoutePlannerMatchers.routeDescriptionListCell(cellNr: 0))

        // Check that route description info is displayed correctly
        RouteOverViewActions.checkManeuverDescriptionItem()

        // Leave route preview
        EarlGrey.selectElement(with: RoutePlannerMatchers.backButton).perform(grey_tap())
    }

    /// Method that implements MSDKUI-1473 test.
    ///
    /// - Parameter isLandscape: if `true`, test will be performed in landscape, if `false` - in portrait.
    private func performOpenManeuverTableViewTest(isLandscape: Bool) {
        if isLandscape {
            EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)
        }

        // Select transport mode and calculate routes
        RoutePlannerActions.setTransportModeAndCalculateRoutes(transportMode: car)

        // Select the first route
        CoreActions.tap(element: RoutePlannerMatchers.routeDescriptionListCell(cellNr: 0))

        // Go to maneuver table view
        CoreActions.tap(element: RouteOverviewMatchers.maneuversShowMapButton)
        Utils.waitUntil(visible: RouteOverviewMatchers.maneuverTableView)

        // Go back to route planner
        CoreActions.tap(element: RoutePlannerMatchers.backButton)
    }
}
