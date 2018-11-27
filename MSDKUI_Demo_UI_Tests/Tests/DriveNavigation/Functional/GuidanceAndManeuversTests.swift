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

final class GuidanceAndManeuversTests: XCTestCase {

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
        DriveNavigationActions.setDestination(with: .tap)
    }

    override func tearDown() {
        // Return screen orientation to portrait
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.portrait, errorOrNil: nil)

        // Done with positioning
        Positioning.shared.stop()

        super.tearDown()
    }

    // MARK: - Tests

    /// MSDKUI-574: Select a destination.
    /// Check that destination can be added by a long tap.
    func testSetDriveNavigationDestinationViaLongpress() {
        setDestination(with: .longPress)
    }

    /// MSDKUI-573: Select a destination.
    /// Check that destination can be added by a tap.
    func testSetDriveNavigationDestinationViaTap() {
        setDestination(with: .tap)
    }

    /// MSDKUI-896: Open drive navigation route overview.
    /// Check that route overview opens properly.
    func testGuidanceRouteOverview() {
        // Tap OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // verify elements on route overview
        DriveNavigationActions.checkRouteOverviewElementsAreVisible()

        // Leave Drive navigation
        CoreActions.tap(element: CoreMatchers.backButton)

        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)
    }

    /// MSDKUI-1191: Switch orientation during guidance.
    /// Check that orientation can be changed during guidance.
    func testManeuverViewBeforeAndAfterSwitchToLandscape() {
        // Tap OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // Start guidance
        CoreActions.tap(element: RouteOverviewMatchers.startNavigationButton)
        DriveNavigationActions.dismissAlert()

        // Check visibility of maneuver view
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverView).assert(grey_sufficientlyVisible())

        // Check visibility of text in maneuver view
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
            .atIndex(1)
            .assert(grey_sufficientlyVisible())

        // Switch to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Check visibility of maneuver view
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverView).assert(grey_sufficientlyVisible())

        // Check visibility of text in maneuver view
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
            .atIndex(0)
            .assert(grey_sufficientlyVisible())

        // Go back to landing page
        CoreActions.tap(element: DriveNavigationMatchers.stopNavigationButton)
    }

    /// MSDKUI-575: Maneuver view
    /// Check the next maneuver description during guidance.
    /// Portrait version of the test.
    func testManeuverViewInPortrait() {
        performManeuversTest(isLandscape: false)
    }

    /// MSDKUI-575: Maneuver view
    /// Check the next maneuver description during guidance.
    /// Landscape version of the test.
    func testManeuverViewInLandscape() {
        performManeuversTest(isLandscape: true)
    }

    /// MSDKUI-1481: Guidance dashboard
    /// Check dashboard and its settings during simulation.
    /// Portrait version of the test.
    func testGuidanceDashboardInPortrait() {
        performGuidanceTest(isLandscape: false) {
            checkDashboard()
        }
    }

    /// MSDKUI-1481: Guidance dashboard
    /// Check dashboard and its settings during simulation.
    /// Landscape version of the test.
    func testGuidanceDashboardInLandscape() {
        performGuidanceTest(isLandscape: true) {
            checkDashboard()
        }
    }

    /// MSDKUI-1534: Guidance speedview
    /// Check that speedview color is displayed correctly during normal driving and overspeeding.
    /// Portrait version of the test.
    func testGuidanceSpeedingInPortrait() {
        performGuidanceTest(isLandscape: false) {
            checkSpeeding()
        }
    }

    /// MSDKUI-1534: Guidance speedview
    /// Check that speedview color is displayed correctly during normal driving and overspeeding.
    /// Landscape version of the test.
    func testGuidanceSpeedingInLandscape() {
        performGuidanceTest(isLandscape: true) {
            checkSpeeding()
        }
    }

    /// MSDKUI-1477: ETA in Guidance
    /// Check the estimated arrival data until navigation ends.
    ///
    /// - Important: Due to GuidanceActions.adaptSimulationToEarlGrey(), the method should wait
    ///              for screen updates, see `Constants.updateIntervalForEarlGrey`. Plus, the TTA
    ///              is displayed in minutes initially for the short test route and in order to
    ///              see an update, we have to wait for one minute before comparing the ETA data.
    func testGuidanceEstimatedArrivalView() {
        performGuidanceTest(isLandscape: false) {
            // Get the initial ETA data
            var etaData = DriveNavigationActions.getEstimatedArrivalData()

            // Try to convert the ETA string to date
            guard let etaDate = DateFormatter.currentShortTimeFormatter.date(from: etaData.eta) else {
                GREYFail("No ETA date available")
                return
            }

            // The ETA data can differ at most three minutes during navigation, e.g.
            // if the ETA is "11:12 AM", then it can vary between "11:09 AM" and
            // "11:15 AM"
            let expectedEta: [String] = [DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(-180)),
                                         DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(-120)),
                                         DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(-60)),
                                         etaData.eta,
                                         DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(60)),
                                         DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(120)),
                                         DateFormatter.currentShortTimeFormatter.string(from: etaDate.addingTimeInterval(180))]

            // Wait one minute to make sure the ETA data is updated
            DriveNavigationActions.sleepMainThreadOneMinute()

            // Until arrival, check the ETA data regularly
            while !DriveNavigationActions.hasArrived() {
                let newEtaData = DriveNavigationActions.getEstimatedArrivalData()

                GREYAssertTrue(expectedEta.contains(newEtaData.eta), reason: "The ETA should stay the same")
                GREYAssertTrue(newEtaData.tta != etaData.tta, reason: "The TTA should be updated")
                GREYAssertTrue(newEtaData.distance != etaData.distance, reason: "The distance should be updated")

                // Refresh
                etaData = newEtaData

                // Wait one minute to make sure the ETA data is updated
                DriveNavigationActions.sleepMainThreadOneMinute()
            }

            // Wait until the view is updated
            DriveNavigationActions.sleepMainThreadUntilViewsUpdated()

            let finalEtaData = DriveNavigationActions.getEstimatedArrivalData()

            GREYAssertTrue(finalEtaData.eta == "--", reason: "The ETA should not be displayed after arrival")
            GREYAssertTrue(finalEtaData.tta == "--", reason: "The TTA should not be displayed after arrival")
            GREYAssertTrue(finalEtaData.distance == "--", reason: "The distance should not be displayed after arrival")
        }
    }

    // MARK: - Private

    /// Sets the destination with the specified gesture.
    ///
    /// - Parameter gesture: Gesture type like tap or long press.
    private func setDestination(with gesture: CoreActions.Gestures) {
        // Leave Drive navigation
        CoreActions.tap(element: CoreMatchers.exitButton)

        // Switch to landscape
        EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)

        // Drive navigation and map view is shown.
        CoreActions.tap(element: LandingMatchers.driveNavigation)
        DriveNavigationActions.dismissAlert()

        DriveNavigationActions.verifyWaypointMapViewWithNoDestinationIsVisible()

        // Destination marker appears on the map and location address is shown
        DriveNavigationActions.setDestination(with: gesture)

        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)
    }

    /// Method that implements MSDKUI-575 test.
    ///
    /// - Parameter isLandscape: if `true`, test will be performed in landscape, if `false` - in portrait.
    private func performManeuversTest(isLandscape: Bool) {
        // Tap OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // Check maneuvers
        CoreActions.tap(element: WaypointMatchers.showManeuversButton)

        var maneuversData = RouteOverViewActions.collectManeuversData(from:
            RouteOverviewMatchers.maneuverDescriptionList)
        GREYAssertFalse(maneuversData.isEmpty, reason: "Instructions must not be empty")

        // Remove first - it will not be displayed in view, since application displays "upcoming" maneuver
        maneuversData.removeFirst()

        // Set orientation here - to make sure that both orientations have the same route in test
        if isLandscape {
            EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)
        }

        // Start navigation simulation
        CoreActions.longPress(element: RouteOverviewMatchers.startNavigationButton, point: CGPoint(x: 10, y: 10))

        DriveNavigationActions.selecActionOnSimulationAlert(button: "OK")

        // Since we are launching simulation, we must change `updateInterval`, to allow application go into `idle` state
        // (default `updateInterval` is too often, so EarlGrey is not responding, waiting for `idle` state)
        DriveNavigationActions.adaptSimulationToEarlGrey()

        DriveNavigationActions.dismissAlert()

        // Check if correct maneuvers are displayed during simulation
        DriveNavigationActions.checkDisplayedManeuversDuringSimulation(maneuvers: maneuversData, isLandscape: isLandscape)

        // Wait until arrival
        DriveNavigationActions.waitForArrival()

        // Go back to landing page
        CoreActions.tap(element: DriveNavigationMatchers.stopNavigationButton)
    }

    /// Method that changes to specified orientation, launches guidance simulation, then runs specified
    /// tests and finally terminates the test.
    ///
    /// - Parameter isLandscape: if `true`, test will be performed in landscape and in portrait otherwise.
    private func performGuidanceTest(isLandscape: Bool, test: () -> Void) {
        // Tap OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        DriveNavigationActions.dismissAlert()

        // Set orientation here - to make sure that both orientations have the same route in test
        if isLandscape {
            EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)
        }

        // Start navigation simulation
        CoreActions.longPress(element: RouteOverviewMatchers.startNavigationButton, point: CGPoint(x: 10, y: 10))
        DriveNavigationActions.selecActionOnSimulationAlert(button: "OK")

        // Since we are launching simulation, we must change `updateInterval`, to allow application go into `idle` state
        // (default `updateInterval` is too often, so EarlGrey is not responding, waiting for `idle` state)
        DriveNavigationActions.adaptSimulationToEarlGrey()
        DriveNavigationActions.dismissAlert()

        // Carry out custom test actions
        test()

        // Go back to landing page
        CoreActions.tap(element: DriveNavigationMatchers.stopNavigationButton)
    }

    /// Checks for dashboard being displayed.
    ///
    /// - Note: Swipe gesture on dashboard is not supported on iOS App.
    private func checkDashboard() {
        // Check if arrival time is visible
        EarlGrey.selectElement(with: DriveNavigationMatchers.arrivalTime).assert(grey_sufficientlyVisible())

        // Expand dashboard
        CoreActions.tap(element: DriveNavigationMatchers.arrivalTime)

        // Check visibility of dashboard settings
        EarlGrey.selectElement(with: DriveNavigationMatchers.dashboardSettings).assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: DriveNavigationMatchers.dashboardAbout).assert(grey_sufficientlyVisible())

        // Collapse dashboard
        CoreActions.tap(element: DriveNavigationMatchers.arrivalTime)

        // Check visibilty of guidance speed limit
        EarlGrey.selectElement(with: DriveNavigationMatchers.speedLimit).assert(grey_sufficientlyVisible())

        // Check current speed
        EarlGrey.selectElement(with: DriveNavigationMatchers.currentSpeed).atIndex(1).assert(grey_sufficientlyVisible())
    }

    /// Method that implements MSDKUI-1534 test.
    private func checkSpeeding() {
        // Check that current speed is displayed in black so there is no overspeeding
        DriveNavigationActions.verifySpeeding(isSpeeding: false)

        // Increase current simulation speed so there is overspeeding
        DriveNavigationActions.increaseSimulationMovementSpeed()

        // Check that current speed is displayed in red so there is overspeeding
        DriveNavigationActions.verifySpeeding(isSpeeding: true)
    }
}
