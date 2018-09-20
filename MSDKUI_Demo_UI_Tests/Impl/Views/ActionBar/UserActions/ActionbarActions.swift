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
@testable import MSDKUI_Demo
import NMAKit
import XCTest

enum ActionbarActions {
    private static let point = 24

    /// Reverses the order of the `ViewController`'s `WaypointList`.
    static func reverseWaypoints() {
        CoreActions.tap(element: ActionbarView.swapButton)
    }

    /// for keeping time panel text value
    static var travelTmePanelText: String?

    /// for keeping transport mode value
    static var transportMode: NMATransportMode?

    /// Used for resetting the `ViewController`.
    static func reset() {
        EarlGrey.selectElement(with: ActionbarView.transportModePanel).perform(
            GREYActionBlock.action(withName: "prepare for routing tests") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let transportModePanel = element as! TransportModePanel
                transportModePanel.transportMode = .car

                // Make sure to use a car by default
                let view = transportModePanel.superview!
                let viewController = view.viewController as? ViewController

                GREYAssertNotNil(viewController, reason: "No ViewController!")

                // Disable traffic support to simplify the tests: having the traffic
                // data makes it difficult to set the expectations
                viewController!.trafficEnabled = false

                // It is easier to test when have more routes
                viewController!.routingMode.resultLimit = 7

                // Make sure to use a car by default
                viewController!.routingMode.transportMode = .car
                return true
            }
        )
    }

    /// Saves the time panel text to the `travelTmePanelText` property.
    static func saveTravelTmePanelText() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: ActionbarView.travelTimePanelTime).perform(
            GREYActionBlock.action(withName: "saveTravelTmePanelText") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let timeLabel = element as! UILabel
                travelTmePanelText = timeLabel.text

                print("TravelTmePanel text: \(travelTmePanelText!)")

                return true
            }
        )
    }

    /// Sets the `TravelTimePicker` picker view date.
    ///
    /// - Parameter date: The date to be set to the picker view.
    static func setPickerDate(_ date: Date) {
        // EarlGrey does apply some gestures before completing the action. Unfortunately, it triggers
        // the cancel handler as the gestures hit the transparent view above the picker view. So, we
        // have to tap the "OK" button after we set the new date!
        EarlGrey.selectElement(with: ActionbarView.travelTimePickerDatePicker).perform(
            GREYActionBlock.action(withName: "setPickerDate") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let datePicker = element as! UIDatePicker
                datePicker.date = date

                // Tap the "OK" button
                CoreActions.tap(element: ActionbarView.travelTimePickerOk)

                return true
            }
        )
    }

    /// Saves the current tranport mode to the `transportMode` property.
    static func saveTransportMode() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: ActionbarView.transportModePanel).perform(
            GREYActionBlock.action(withName: "saveTransportMode") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let panel = element as! TransportModePanel
                transportMode = panel.transportMode

                print("TransportModePanel mode: \(transportMode!)")

                return true
            }
        )
    }

    /// Sets the third waypoint to a known place.
    static func setThirdWaypoint() {
        EarlGrey.selectElement(with: ActionbarView.waypointList).perform(
            GREYActionBlock.action(withName: "setThirdWaypoint") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let waypointList = element as! WaypointList
                waypointList.updateEntry(WaypointEntryFixture.berlinBranderburgerTor(), at: 2)

                return true
            }
        )
    }

    /// Sets the waypoint at row to a selected place.
    ///
    /// - Parameter at: The row of the waypoint to be changed.
    /// - Parameter to: The value of the waypoint to be changed.
    static func setWaypoint(at: Int, to: WaypointEntry) {
        EarlGrey.selectElement(with: ActionbarView.waypointList).perform(
            GREYActionBlock.action(withName: "setThirdWaypoint") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let waypointList = element as? WaypointList else {
                        return false
                }

                waypointList.updateEntry(to, at: at)

                return true
            }
        )
    }

    /// Sets the waypoints and indirectly generates the routes.
    ///
    /// - Important: It updates the available wayponts in the `WaypointList`. So, the number of waypoints
    ///              determines the waypoints set.
    ///
    /// - Parameter waypoints: Array of waypoints to be set in the same order as in the array.
    static func setWaypoints(waypoints: [WaypointEntry]) {
        EarlGrey.selectElement(with: ActionbarView.waypointList).perform(
            GREYActionBlock.action(withName: "setWaypoints") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let waypointList = element as! WaypointList

                // We want to initiate the route calculation only once! So, set the waypoints from the
                // bottom to top: only when we set the topmost one, we should be able to calculate the
                // routes

                // Firstly, set the waypoints coming on top of the default ones in a bottom to top fashion
                for waypoint in waypoints.reversed() {
                    waypointList.updateEntry(waypoint, at: waypoints.index(of: waypoint)!)
                }

                return true
            }
        )
    }

    /// Removes the specified waypoint.
    ///
    /// - Parameter element: The GREYMatcher of the targeted element.
    /// - Important: After selecting the specified waypoint, a point known to be on the remove
    ///              button is tapped.
    static func removeWaypoint(element: GREYMatcher) {
        EarlGrey.selectElement(with: element)
            .perform(grey_tapAtPoint(CGPoint(x: point, y: point)))
    }

    /// Adds a new waypoint.
    ///
    /// - Important: The tapped point is not set. This method simply adds a new `WaypointItem`. This is
    ///              to simplify the route setup: no map view update is necessary: update the added
    ///              waypoint afterwards.
    static func addWaypoint() {
        CoreActions.tap(element: ActionbarView.addButton)

        // Wait until the reverse geocoding is completed
        CoreActions.tap(element: MapView.waypointMapView)

        let reverseGeocoded = GREYCondition(name: "Wait for reverse geocoding") {
            let errorOrNil = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
            errorOrNil.initialize(to: nil)

            EarlGrey
                .selectElement(with: ActionbarView.waypointViewControllerOk)
                .assert(grey_enabled(), error: errorOrNil)

            return errorOrNil.pointee == nil
        }.wait(withTimeout: Constans.longWait, pollInterval: Constans.mediumPollInterval)
        GREYAssertTrue(reverseGeocoded, reason: "Failed to reverse geocode!")

        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
    }

    /// Drags a waypoint from the specified initial row to the specified final row.
    ///
    /// - Parameter fromRow: The initial row.
    /// - Parameter toRow: The final row.
    static func dragWaypoint(fromRow: Int, toRow: Int) {
        print("Dragging row \(fromRow) onto row \(toRow)...")
        EarlGrey.selectElement(with: ActionbarView.waypointList).perform(
            GREYActionBlock.action(withName: "dragWaypoint") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let waypointList = element as! WaypointList
                let indexPathFrom = IndexPath(row: fromRow, section: 0)
                let indexPathTo = IndexPath(row: toRow, section: 0)
                waypointList.beginUpdates()
                waypointList.tableView(waypointList, moveRowAt: indexPathFrom, to: indexPathTo)
                waypointList.endUpdates()

                return true
            }
        )
    }

    /// Gets the `WaypointItem` object out of the cell and returns it
    ///
    /// - Parameter cell: The cell containing the `WaypointItem` object.
    /// - Returns: The `WaypointItem` found in the cell.
    static func getWaypointItem(inside cell: UITableViewCell) -> WaypointItem {
        let views = cell.contentView.subviews.filter { $0 is WaypointItem }

        // There should be one and only one view in the views
        GREYAssertTrue(views.count == 1, reason: "No WaypointItem!")

        return views[0] as! WaypointItem
    }

    /// Drags waypoint from one row to anouther and checks that waypoint names are as expected
    ///
    /// - Parameter fromRow: from what row to drag
    /// - Parameter toRow: to what row to drag
    /// - Parameter expectedNames: expected names array, must be in the same order as expected
    static func dragAndCheckWaypointChange(fromRow: Int, toRow: Int, expectedNames: [String]) {
        ActionbarActions.dragWaypoint(fromRow: fromRow, toRow: toRow)

        // Expand WaypointList
        CoreActions.tapElement("ViewController.right")

        for expectedName in expectedNames {
            ActionbarMatchers.checkWaypointName(
                withId: ActionbarView.waypointListCell(cellNr: (expectedNames.index(of: expectedName)! + 1)),
                expectedName: expectedName)
        }
    }

    /// Switches to specified transport mode(s) and checks if new routes differ from previous
    ///
    /// - Parameter transportModes: An array of transport modes that route displaying will be checked on.
    /// - Parameter routes: Array of calculated routes, which new routes will be checked against.
    static func switchToTransportModeAndVerifyRouteChange(transportModes: [GREYMatcher], routes: [NMARoute]) {
        for transportMode in transportModes {
            CoreActions.tap(element: transportMode)
            RouteplannerActions.waitUntilRoutesCalculated()
            RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        }
    }

    /// Switches to specified transport mode and calculates a route with fixed waypoints
    ///
    /// - Parameter transportMode: Transport mode that will be used to calculate routes
    static func setTransportModeAndCalculateRoutes(transportMode: GREYMatcher) {
        if !transportMode.matches(ActionbarView.transportModeCar) {
            CoreActions.tap(element: transportMode)
        }

        let fixedWaypoints = [WaypointEntryFixture.berlinNaturekundemuseum(),
                              WaypointEntryFixture.berlinReichstag()]
        ActionbarActions.setWaypoints(waypoints: fixedWaypoints)
        RouteplannerActions.waitUntilRoutesCalculated()
    }
}
