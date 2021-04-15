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
@testable import MSDKUI_Demo
import NMAKit
import XCTest

enum DriveNavigationActions {

    // MARK: - Types

    /// All the collected ETA data.
    struct ETAData {
        let eta: String
        let tta: String
        let distance: String
    }

    struct ETADataFormatted {
        let eta: Date
        let tta: Int
        let distance: Int
    }

    // MARK: - Properties

    /// Counter for verifying ETA check in MSDKUI-1477.
    static var etaCheckCounter = 0

    // MARK: - Public

    /// Returns from Drive navigation to landing page after test.
    static func returnToLandingPage() {
        var error: NSError?

        EarlGrey.selectElement(with: CoreMatchers.exitButton)
            .perform(grey_tap(), error: &error)

        EarlGrey.selectElement(with: DriveNavigationMatchers.stopNavigationButton)
            .perform(grey_tap(), error: &error)
    }

    /// Dismisses alert if displayed on top.
    static func dismissAlert() {
        let permissionAlertID = "LocationBasedViewController.AlertController.permissionsView"

        Utils.waitUntil(visible: grey_accessibilityID(permissionAlertID))
        EarlGrey.selectElement(with: grey_accessibilityID(permissionAlertID)).perform(
            GREYActionBlock.action(withName: "dismissAlert") { element, errorOrNil -> Bool in
                // Check error, make sure we have view here, and make sure this is alert controller view
                guard
                    errorOrNil != nil,
                    let alertView = element as? UIView,
                    let alert = alertView.viewController as? UIAlertController else {
                        return false
                }

                // Dismiss alert
                alert.dismiss(animated: true)

                // Wait until alert is not visible anymore
                Utils.waitUntil(hidden: permissionAlertID)

                return true
            }
        )
    }

    /// Taps the specified button after waiting for the specified alert visible.
    ///
    /// - Parameters:
    ///     - title: Text of the button that needs to be selected.
    static func selecActionOnSimulationAlert(button title: String) {
        let simulationAlert = grey_accessibilityID("GuidancePresentingViewController.AlertController.showSimulationView")

        Utils.waitUntil(visible: simulationAlert)
        EarlGrey.selectElement(with: simulationAlert).perform(
            GREYActionBlock.action(withName: "Select Alert Action \(title)") { _, errorOrNil -> Bool in
                guard errorOrNil != nil else {
                    return false
                }

                EarlGrey.selectElement(with: grey_text(title)).perform(grey_tap())

                return true
            }
        )
    }

    /// Checks that basic elements are visible in route overview view
    static func checkRouteOverviewElementsAreVisible() {
        EarlGrey.selectElement(with: CoreMatchers.backButton).assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: RouteOverviewMatchers.startNavigationButton)
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: DriveNavigationMatchers.driveNavMapView).assert(grey_sufficientlyVisible())
    }

    /// Verifies that waypoint map view is visible
    static func verifyWaypointMapViewWithNoDestinationIsVisible() {
        EarlGrey.selectElement(with: WaypointMatchers.waypointMapView)
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.tapTheMapToSetYourDestination))
            .assert(grey_sufficientlyVisible())
    }

    /// Taps on the map view at the specified point and sets the destination.
    ///
    /// - Parameters:
    ///   - gesture: Gesture type like tap or long press.
    ///   - screenPoint: Point on the map view to tap.
    static func setDestination(with gesture: CoreActions.Gestures, destination: NMAGeoCoordinates) {
        let screenPoint = CoreActions.centerOfElementBounds(element: WaypointMatchers.waypointMapView)

        // Drive navigation and map view is shown.
        verifyWaypointMapViewWithNoDestinationIsVisible()

        // Move current viewport to a designated location
        WaypointActions.switchMapViewTo(mapData: destination)

        // Tap or longtap to the center of current map view
        switch gesture {
        case .tap:
            CoreActions.tap(element: WaypointMatchers.waypointMapView, point: screenPoint)

        case .longPress:
            CoreActions.longPress(element: WaypointMatchers.waypointMapView, point: screenPoint)
        }

        // Destination marker appears on the map and location address is shown
        // Negative assertion is done, to avoid location changes
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.tapOrLongPressOnTheMap))
            .assert(grey_notVisible())
    }

    /// Checks if correct maneuvers are displayed during simulation.
    ///
    /// - Parameters:
    ///     - maneuvers: Maneuvers that should be displayed (e.g. from `collectManeuversData`).
    ///     - isLandscape: if `true`, test will be performed in landscape, if `false` - in portrait.
    static func checkDisplayedManeuversDuringSimulation(maneuvers: [(address: String, iconAccessibilityIdentifier: String)],
                                                        isLandscape: Bool) {
        // For every instruction
        for step in 0..<maneuvers.count {
            // Check every step from maneuvers data.
            // 1. Wait for correct address to be displayed
            // 2. When displayed, check if displayed icon is correct

            // Check if address is correct
            let addressCondition = GREYCondition(name: "Wait for correct address") {
                var address = ""
                // Get view address label
                EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
                    .atIndex(0)
                    .perform(
                        GREYActionBlock.action(withName: "Get description list") { element, errorOrNil -> Bool in
                            guard
                                errorOrNil != nil,
                                let label = element as? UILabel,
                                let labelText = label.text else {
                                    return false
                            }

                            // Get address text
                            address = labelText
                            return true
                        }
                )

                // Check is displayed address is the same as in maneuvers list
                return maneuvers[step].address == address
            }

            // Wait until correct address will be visible
            addressCondition.wait(withTimeout: 200, pollInterval: 1)

            // When address is correct, check if correct icon is present
            // Since we are using 2 sets of views - one for portrait, one for landscape,
            // both icons are in hierarchy, but different index is visible
            let iconElementIndex: UInt = isLandscape ? 1 : 0
            EarlGrey.selectElement(with: grey_accessibilityID(maneuvers[step].iconAccessibilityIdentifier))
                .atIndex(iconElementIndex)
                .assert(grey_notNil())
        }
    }

    /// Waits until simulation ends with arrival to destination.
    ///
    /// - Important: Arrival trigger is that the address color changes to .colorAccentLight
    ///              when destination is reached.
    static func waitForArrival() {
        let timeOut: Double = 240
        let condition = GREYCondition(name: "Wait for destination") {
            // Is the destination reached?
            getEstimatedArrivalLabelTextColor() == .colorAccentLight
        }.wait(withTimeout: timeOut, pollInterval: 1)

        GREYAssertTrue(condition, reason: "Destination was not reached after \(timeOut) seconds")
    }

    /// Returns a Boolean flag depending on destination is reached or not.
    ///
    /// - Returns: True if the destination reached and false otherwise.
    /// - Important: Arrival trigger is that the address color changes to .colorAccentLight
    ///              when destination is reached.
    static func hasArrived() -> Bool {
        var labelColor: UIColor?

        _ = GREYCondition(name: "Wait for label text color retrieval") {
            labelColor = getEstimatedArrivalLabelTextColor()

            // Make sure that a color is retrieved
            return labelColor != nil
        }.wait(withTimeout: Constants.shortWait, pollInterval: Constants.mediumPollInterval)

        // Is the destination reached?
        return labelColor == .colorAccentLight
    }

    /// This method checks if correct color is displayed on speedView.
    /// Red is expected for overspeeding and black for regular drive.
    ///
    /// - Parameters:
    ///     - isSpeeding: A Boolean value to assume whether overspeeding is taking place or not.
    static func verifySpeeding(isSpeeding: Bool) {
        var labelColor: UIColor?
        var viewBackgroundColor: UIColor?

        let timeOut = Constants.longWait
        let condition = GREYCondition(name: "Speed view must have correct color") {
            (labelColor, viewBackgroundColor) = getCurrentSpeedViewColor()

            switch isSpeeding {
            case true:
                return labelColor == .colorNegative || viewBackgroundColor == .colorNegative

            case false:
                return labelColor == .colorForeground || viewBackgroundColor == .colorBackgroundBrand
            }
        }.wait(withTimeout: timeOut, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Correct color was not displayed after waiting for \(timeOut) seconds")
    }

    /// Helper method to adapt positioning data source update interval to EarlGrey framework.
    static func adaptSimulationToEarlGrey() {
        // Since updateInterval is too often, EarlGrey is not responding, assuming that application is not
        // in "idle state". We must change update interval in order to be able to work with application
        // during simulation.

        // Disable synchronization to avoid waiting for "application idle state"
        GREYConfiguration.sharedInstance().setValue(false, forConfigKey: kGREYConfigKeySynchronizationEnabled)

        // Wait until simulation data source is set in application
        let condition = GREYCondition(name: "Data source set") {

            // Check if data source is set and is our "simulation data source"
            return NMAPositioningManager.sharedInstance().dataSource is NMARoutePositionSource
        }
        let result = condition.wait(withTimeout: 5, pollInterval: 1)

        // Make sure we have correct data source
        GREYAssertTrue(result, reason: "Data source not set")

        // Configure data source with new update interval and speed - this will allow EarlGrey to proceed
        NMAPositioningManager.sharedInstance().stopPositioning()
        if let dataSource = NMAPositioningManager.sharedInstance().dataSource as? NMARoutePositionSource {
            dataSource.updateInterval = Constants.normalUpdateIntervalForEarlGrey
            dataSource.movementSpeed = Constants.normalSimulationSpeed
            NMAPositioningManager.sharedInstance().dataSource = dataSource
        }

        // Start positioning again
        NMAPositioningManager.sharedInstance().startPositioning()

        // Enable synchronization in order to work with application as usual
        GREYConfiguration.sharedInstance().setValue(true, forConfigKey: kGREYConfigKeySynchronizationEnabled)
    }

    /// Method for changing update interval and simulation speed.
    ///
    /// - Parameters:
    ///     - updateInterval: A Double value for positioning update interval.
    ///     - movementSpeed: A Float value for setting simulation speed.
    static func setSimulationSpeed(updateInterval: Double, movementSpeed: Float) {
        NMAPositioningManager.sharedInstance().stopPositioning()
        if let dataSource = NMAPositioningManager.sharedInstance().dataSource as? NMARoutePositionSource {
            dataSource.updateInterval = updateInterval
            dataSource.movementSpeed = movementSpeed
            NMAPositioningManager.sharedInstance().dataSource = dataSource
        }

        // Start positioning again
        NMAPositioningManager.sharedInstance().startPositioning()
    }

    /// This method retrieves the estimated arrival data from dashboard.
    ///
    /// - Returns:
    ///     - etaData: Estimated arrival data in a string format.
    ///     - etaDataFormatted: Estimated arrival data in specified formats.
    static func getEstimatedArrivalData() -> (ETAData: ETAData, ETADataFormatted: ETADataFormatted?) {

        var etaData = ETAData(eta: "", tta: "", distance: "")
        var etaDataFormatted = ETADataFormatted(eta: Date(), tta: Int(), distance: Int())

        _ = GREYCondition(name: "Wait for ETA data") {
            EarlGrey.selectElement(with: DriveNavigationMatchers.arrivalTime).perform(
                GREYActionBlock.action(withName: "eta") { element, errorOrNil in
                    guard
                        errorOrNil != nil,
                        let arrivalView = element as? GuidanceEstimatedArrivalView,
                        let eta = arrivalView.estimatedTimeOfArrivalLabel?.text,
                        let tta = arrivalView.durationLabel?.text,
                        let distance = arrivalView.distanceLabel?.text else {
                            return false
                    }

                    etaData = ETAData(eta: eta, tta: tta, distance: distance)
                    return true
                }
            )

            // Convert ETA data into measurable form until destination is reached
            if hasArrived() == false {
                guard
                    let etaDate = DateFormatter.currentShortTimeFormatter.date(from: etaData.eta),
                    let ttaInt = Int(etaData.tta.trimmingCharacters(in: .whitespaces)
                        .components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .joined()),
                    let distanceInt = Int(etaData.distance.trimmingCharacters(in: .whitespaces)
                        .components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .joined()) else {
                            return false
                }
                etaDataFormatted = ETADataFormatted(eta: etaDate, tta: ttaInt, distance: distanceInt)
                return true
            }

            return etaData.eta.isEmpty == false && etaData.tta.isEmpty == false && etaData.distance.isEmpty == false
        }.wait(withTimeout: Constants.shortWait, pollInterval: Constants.longPollInterval)

        GREYAssertTrue(etaData.eta.isEmpty == false && etaData.tta.isEmpty == false && etaData.distance.isEmpty == false,
                       reason: "the data is not retrieved")

        return (etaData, etaDataFormatted)
    }

    /// This method checks ETA data continously within fixed conditions
    /// - Parameter conditionBlock: if true function will stop calling itself.
    /// - Note: Checks are being done on a background thread.
    static func checkETADataDuringSimulation(conditionBlock: @escaping () -> Bool) {
        DispatchQueue.global(qos: .background).async {

            // Save first ETA data
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                guard let firstETAData = getEstimatedArrivalData().ETADataFormatted else {
                    GREYFail("ETA data could not be converted")
                    return
                }

                // Save second ETA data and compare it to the first
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    guard let secondETAData = getEstimatedArrivalData().ETADataFormatted else {
                        GREYFail("ETA data could not be converted")
                        return
                    }

                    // Start checking ETA data when distance is below 1 km/mi
                    if firstETAData.distance != 1 && firstETAData.distance != 2 {
                        let comparisonETA = firstETAData.eta.compare(secondETAData.eta)

                        // Increase counter by 1 with every iteration
                        etaCheckCounter += 1

                        GREYAssertTrue(comparisonETA == ComparisonResult.orderedSame ||
                            comparisonETA == ComparisonResult.orderedDescending,
                                       reason: "ETA should be the same or decrease over time")
                        GREYAssertTrue(firstETAData.tta >= secondETAData.tta,
                                       reason: "TTA should be same and decrease over time")
                        GREYAssertTrue(firstETAData.distance > secondETAData.distance,
                                       reason: "Distance must decrease over time")
                    }

                    // Stop recursion when condition is true
                    if !conditionBlock() {
                        self.checkETADataDuringSimulation(conditionBlock: conditionBlock)
                    }
                }
            }
        }
    }

    /// Method that changes to specified orientation, launches guidance simulation, then runs specified
    /// tests and finally terminates the test.
    ///
    /// - Parameter isLandscape: if `true`, test will be performed in landscape and in portrait otherwise.
    static func performGuidanceTest(isLandscape: Bool, test: () -> Void) {
        // Tap OK button
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
        dismissAlert()

        // Set orientation here - to make sure that both orientations have the same route in test
        if isLandscape {
            EarlGrey.rotateDeviceTo(orientation: UIDeviceOrientation.landscapeLeft, errorOrNil: nil)
        }

        // Start navigation simulation
        CoreActions.longPress(element: RouteOverviewMatchers.startNavigationButton, point: CGPoint(x: 10, y: 10))
        selecActionOnSimulationAlert(button: "OK")

        // Since we are launching simulation, we must change `updateInterval`, to allow application go into `idle` state
        // (default `updateInterval` is too often, so EarlGrey is not responding, waiting for `idle` state)

        adaptSimulationToEarlGrey()
        dismissAlert()

        // Disable synchronization to avoid waiting for "application idle state"
        GREYConfiguration.sharedInstance().setValue(false, forConfigKey: kGREYConfigKeySynchronizationEnabled)

        // We can increase simulation speed when EG sync is disabled
        setSimulationSpeed(updateInterval: Constants.fastUpdateIntervalForEarlGrey, movementSpeed: Constants.fastSimulationSpeed)

        // Carry out custom test actions
        test()

        // Go back to landing page
        CoreActions.tap(element: DriveNavigationMatchers.stopNavigationButton)
        GREYConfiguration.sharedInstance().setValue(true, forConfigKey: kGREYConfigKeySynchronizationEnabled)
    }

    /// Checks if the view is complete, that is it has content for all of it's properties.
    ///
    /// - Parameter guidanceNextManeuverView: the view to check for cmpleteness.
    /// - Returns: true if the view has content in all of it's properties, false otherwise.
    static func isViewComplete(_ guidanceNextManeuverView: GuidanceNextManeuverView) -> Bool {
        guidanceNextManeuverView.maneuverImageView.image != nil &&
            guidanceNextManeuverView.distanceLabel.text != nil &&
            guidanceNextManeuverView.separatorLabel.text != nil &&
            guidanceNextManeuverView.streetNameLabel.text != nil
    }

    // MARK: - Private

    /// This method retrieves the estimated arrival label text color.
    ///
    /// - Returns: Estimated arrival label text color.
    private static func getEstimatedArrivalLabelTextColor() -> UIColor? {
        var labelColor: UIColor?
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
            .atIndex(0)
            .perform(
                GREYActionBlock.action(withName: "Get label text color") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let label = element as? UILabel else {
                            return false
                    }

                    labelColor = label.textColor
                    return true
                }
        )

        return labelColor
    }

    /// This method retrieves current speed view colors for label and background.
    ///
    /// - Returns: Speed view label and background color.
    private static func getCurrentSpeedViewColor() -> (UIColor?, UIColor?) {
        var labelColor: UIColor?
        var viewBackgroundColor: UIColor?

        EarlGrey.selectElement(with: DriveNavigationMatchers.currentSpeed)
            .atIndex(1)
            .perform(
                GREYActionBlock.action(withName: "Get label text color") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let speedView = element as? GuidanceSpeedView else {
                            return false
                    }

                    labelColor = speedView.speedValueLabel.textColor
                    viewBackgroundColor = speedView.backgroundColor
                    return true
                }
        )

        return (labelColor, viewBackgroundColor)
    }

    /// Method that is getting `GuidanceStreetLabel` object.
    /// - Returns: current streel label object or nil if cannot be find.
    static func getCurrentStreetLabel() -> GuidanceStreetLabel? {
        var currentStreetLabel: GuidanceStreetLabel?
        EarlGrey.selectElement(with: DriveNavigationMatchers.currentStreetLabel).perform(
            GREYActionBlock.action(withName: "Get street label") { element, errorOrNil -> Bool in
                guard errorOrNil != nil, let streetLabel = element as? GuidanceStreetLabel else {
                    return false
                }

                currentStreetLabel = streetLabel
                return true
            }
        )

        return currentStreetLabel
    }

    /// Method that is checking text change for current street label.
    /// - Parameter minNumberOfStreets: minimum number of different street names that is needed to pass.
    /// - Note: Only valid street names are counted, text set when `isLookingForLocation` is not counted.
    static func streetLabelTextChangeTest(minNumberOfStreets: Int) {
        // Get current street label
        guard let currentStreetLabel = DriveNavigationActions.getCurrentStreetLabel() else {
            GREYFail("Cannot get current street label")
            return
        }

        // Set of currently collected street names
        var collectedStreetNames = Set<String>()

        // Using KVO observe text changes in current street label
        let observation = currentStreetLabel.observe(\.text, options: [.new]) { _, change in
            // Check if values are correct
            guard let newValue = change.newValue, let streetName = newValue else {
                return
            }
            // Add new street name (ignore isLookingForPosition text)
            if !currentStreetLabel.isLookingForPosition {
                collectedStreetNames.insert(streetName)
            }
        }

        // Condition to wait until minimum number of different street names is collected
        let collectedStreetNamesCondition = GREYCondition(name: "Collected street names") {
            collectedStreetNames.count >= minNumberOfStreets
        }

        // Wait until minimum number of street names is collected
        collectedStreetNamesCondition.wait(withTimeout: 120, pollInterval: 1)

        // Invalidate KVO observation
        observation.invalidate()
    }
}
