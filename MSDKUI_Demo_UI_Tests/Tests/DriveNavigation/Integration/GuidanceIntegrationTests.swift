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

final class GuidanceIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .driveNavigation)

        // Position is needed to advance in tests
        Positioning.shared.start()

        // Dismiss permission alert
        DriveNavigationActions.dismissAlert()

        // Drive navigation and map view is shown
        // Destination marker appears on the map and location address is shown
        DriveNavigationActions.setDestination(with: .tap, destination: NMAGeoCoordinatesFixture.berlinSophienStrasse())
    }

    override func tearDown() {
        super.tearDown()

        // Done with positioning
        Positioning.shared.stop()

        // Returng to landing view
        DriveNavigationActions.returnToLandingPage()

        // Return screen orientation to portrait
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.portrait, errorOrNil: nil)
    }

    // MARK: - Tests

    /// MSDKUI-865: Route calculation.
    /// Check that route can be calculated.
    func testNavigateFromWaypointViewToRouteOverview() {

        // Show route overview
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()
        Utils.waitUntil(visible: DriveNavigationMatchers.driveNavMapView)

        // Return to waypoint view
        CoreActions.tap(element: CoreMatchers.backButton)
        Utils.waitUntil(visible: WaypointMatchers.waypointMapView)
    }

    /// MSDKUI-889: Start and stop guidance.
    /// Check that guidance can be started and stopped.
    func testStartStopNavigationIntegration() {

        // Show guidance
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // Start guidance
        CoreActions.tap(element: RouteOverviewMatchers.startNavigationButton)
        DriveNavigationActions.dismissAlert()
        Utils.waitUntil(visible: DriveNavigationMatchers.driveNavMapView)
    }

    /// MSDKUI-1268: Current speed in guidance.
    /// Check that current speed is visible.
    func testGuidanceDashboardSpeedView() {

        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // Start guidance
        CoreActions.tap(element: RouteOverviewMatchers.startNavigationButton)
        DriveNavigationActions.dismissAlert()
        Utils.waitUntil(visible: DriveNavigationMatchers.driveNavMapView)

        // Check if current speed is visible
        EarlGrey.selectElement(with: DriveNavigationMatchers.currentSpeed).atIndex(1).assert(grey_sufficientlyVisible())
    }

    /// MSDKUI-1289: Integration test for Guidance/Street label component.
    /// Check that street label component is visible.
    func testGuidanceStreetLabel() {
        DriveNavigationActions.performGuidanceTest(isLandscape: false) {
            checkStreetLabel()
        }
    }

    /// MSDKUI-1280: Guidance next-next maneuver view.
    /// Check that guidance next-next maneuver view is visible.
    func testNextNextManeuverView() {
        DriveNavigationActions.performGuidanceTest(isLandscape: false) {
            checkNextNextManeuverView()
        }
    }

    /// MSDKUI-1475: Integration test for ETA.
    /// Check if ETA is visible.
    func testGuidanceETA() {
        DriveNavigationActions.performGuidanceTest(isLandscape: false) {
            checkGuidanceETA()
        }
    }

    /// MSDKUI-1272: Integration test for speed limit.
    /// Check if speed limit is visible.
    func testGuidanceSpeedLimit() {
        DriveNavigationActions.performGuidanceTest(isLandscape: false) {
            checkGuidanceSpeedLimit()
        }
    }

    // MARK: - Private

    /// MSDKUI-1289: Integration test for Guidance/Street label component.
    /// Check that street label component is visible.
    private func checkStreetLabel() {
        // Wait for street label to be visible
        Utils.waitUntil(visible: DriveNavigationMatchers.currentStreetLabel)

        // Rotate to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Wait for street label to be visible
        Utils.waitUntil(visible: DriveNavigationMatchers.currentStreetLabel)
    }

    /// MSDKUI-1280: Guidance next-next maneuver view.
    /// Check that guidance next-next maneuver view is visible.
    private func checkNextNextManeuverView() {
        // Wait until next-next maneuver view is visible
        Utils.waitUntil(visible: DriveNavigationMatchers.nextManeuverView)

        // Rotate to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Wait until next-next maneuver view is visible
        Utils.waitUntil(visible: DriveNavigationMatchers.nextManeuverView)
    }

    /// MSDKUI-1475: Integration test for ETA.
    /// Check if ETA is visible.
    private func checkGuidanceETA() {
        // Wait for ETA to be visible
        Utils.waitUntil(visible: DriveNavigationMatchers.arrivalTime)

        // Rotate to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Wait for ETA to be visible
        Utils.waitUntil(visible: DriveNavigationMatchers.arrivalTime)
    }

    /// MSDKUI-1272: Integration test for speed limit.
    /// Check if speed limit is visible.
    private func checkGuidanceSpeedLimit() {
        // Wait until speed limit is visible
        Utils.waitUntil(visible: DriveNavigationMatchers.speedLimit)

        // Rotate to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Wait until speed limit is visible
        Utils.waitUntil(visible: DriveNavigationMatchers.speedLimit)
    }
}
