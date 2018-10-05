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
import XCTest

class RoutePreviewIntegrationTests: XCTestCase {
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

    /// MSDKUI-884 [iOS] Implementation - Integration tests for Route planner/Route preview
    /// Test that route preview opens and route description is displayed in Portrait Mode
    func testRoutePreviewInPortraitMode() {

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinFernsehturm()
            ]
        )
        RouteplannerActions.waitUntilRoutesCalculated()

        // Select the first route
        CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: 0))

        // Check if route description panel is visible
        EarlGrey.selectElement(with: RoutingView.routeDescriptionPanel).assert(grey_sufficientlyVisible())

        // Leave route preview
        EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
    }

    /// MSDKUI-884 [iOS] Implementation - Integration tests for Route planner/Route preview
    /// Test that route preview opens and route description is not displayed in landscape
    func testRoutePreviewLandscapeMode() {

        // Rotate device to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Set the two waypoints with known names
        ActionbarActions.setWaypoints(
            waypoints: [
                WaypointEntryFixture.berlinZoologischerGarten(),
                WaypointEntryFixture.berlinFernsehturm()
            ]
        )
        RouteplannerActions.waitUntilRoutesCalculated()

        // Select the first route
        CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: 0))

        // Check if route description panel is invisible
        EarlGrey.selectElement(with: RoutingView.routeDescriptionPanel).assert(grey_notVisible())

        // Leave route preview
        EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
    }
}
