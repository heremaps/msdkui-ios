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

class DriveNavigationIntegrationUITests: XCTestCase {

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .driveNav)

        // Position is needed to advance in tests
        Positioning.shared.start()

        // Dismiss permission alert
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()

        // Stop positioning
        Positioning.shared.stop()
    }

    // MSDKUI-865 Integration tests for route calculation in Guidance
    func testNavigateFromWaypointViewToRouteOverview() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Show route overview
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
        Utils.waitUntil(visible: "RouteOverviewViewController.mapView")

        // Return to waypoint view
        CoreActions.tap(element: RouteOverviewView.backButton)
        Utils.waitUntil(visible: "WaypointViewController.mapView")

        // Exit waypoint view
        CoreActions.tap(element: MapView.waypointMapViewExitButton)
    }

    /// MSDKUI-889 Integration tests for start/stop navigation
    func testStartStopNavigationIntegration() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Show guidance
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
        CoreActions.tap(element: RouteOverviewView.startNavigationButton)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
        Utils.waitUntil(visible: "GuidanceViewController.mapView")

        // Stop guidance
        CoreActions.tap(element: GuidanceView.stopNavigationButton)
        Utils.waitUntil(visible: "LandingViewController.driveNavView")
    }

    /// MSDKUI-1268 Integration test for Guidance current speed
    func testGuidanceDashboardSpeedView() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Show guidance
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
        CoreActions.tap(element: RouteOverviewView.startNavigationButton)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
        Utils.waitUntil(visible: "GuidanceViewController.mapView")

        // Check if current speed is visible
        EarlGrey.selectElement(with: GuidanceView.currentSpeed).atIndex(1).assert(grey_sufficientlyVisible())

        // Stop guidance
        CoreActions.tap(element: GuidanceView.stopNavigationButton)
        Utils.waitUntil(visible: "LandingViewController.driveNavView")
    }
}