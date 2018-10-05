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

class DriveNavigationUITests: XCTestCase {

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
        // The map view rendering is problematic at the end of tests
        Utils.allowMapViewRendering(MapView.waypointMapView, false)

        // Return screen orientation to portrait
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.portrait, errorOrNil: nil)

        // Return back to the landing view
        CoreActions.tap(element: MapView.waypointMapViewExitButton)

        super.tearDown()
    }

    /// MSDKUI-574 Select Drive Navigation destination via longpress
    func testSelectDriveNavigationDestinationViaLongpress() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .longPress)

        // Leave Drive navigation
        CoreActions.tap(element: MapView.waypointMapViewExitButton)

        // Switch to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Drive navigation and map view is shown.
        CoreActions.tap(element: LandingView.driveNav)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")

        MapActions.verifyWaypointMapViewWithNoDestinationIsVisible()

        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .longPress)
    }

    /// MSDKUI-573 Select Drive Navigation destination via tap
    func testSelectDriveNavigationDestinationViaTap() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Leave Drive navigation
        CoreActions.tap(element: MapView.waypointMapViewExitButton)

        // Switch to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Drive navigation and map view is shown.
        CoreActions.tap(element: LandingView.driveNav)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")

        MapActions.verifyWaypointMapViewWithNoDestinationIsVisible()

        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)
    }

    /// MSDKUI-896 [iOS] Implementation - Guidance route overview
    func testGuidanceRouteOverview() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Tap OK button
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")

        // verify elements on route overview
        RouteOverviewActions.checkRouteOverviewElementsAreVisible()

        // Leave Drive navigation
        CoreActions.tap(element: RouteOverviewView.backButton)
    }

    /// MSDKUI-1191 [iOS] Implementation - Maneuver panel, switch orientation
    /// while navigation is ongoing
    func testManeuverPanelBeforeAndAfterSwitchToLandscape() {

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Tap OK button
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")

        // Start guidance
        CoreActions.tap(element: RouteOverviewView.startNavigationButton)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")

        // Check visibility of maneuver panel
        EarlGrey.selectElement(with: GuidanceView.maneuverPanel).assert(grey_sufficientlyVisible())

        // Check visibility of text in maneuver panel
        EarlGrey.selectElement(with: GuidanceView.maneuverPanelText)
            .atIndex(1)
            .assert(grey_sufficientlyVisible())

        // Switch to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Check visibility of maneuver panel
        EarlGrey.selectElement(with: GuidanceView.maneuverPanel).assert(grey_sufficientlyVisible())

        // Check visibility of text in maneuver panel
        EarlGrey.selectElement(with: GuidanceView.maneuverPanelText)
            .atIndex(0)
            .assert(grey_sufficientlyVisible())

        // Leave Drive navigation
        CoreActions.tap(element: GuidanceView.stopNavigationButton)

        // Go back to drive view
        CoreActions.reset(card: .driveNav)
        CoreActions.dismissAlert("LocationBasedViewController.AlertController.permissionsView")
    }
}
