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

enum RoutePlannerActions {

    // MARK: - Types

    /// For taking action based on the list type.
    enum Lists {
        case waypoint
        case route
        case maneuver
    }

    // MARK: - Properties

    /// For saving the time panel text value.
    static var travelTmePanelText: String?

    /// For saving the transport mode value.
    static var transportMode: NMATransportMode?

    /// Used to save the `RouteDescriptionList` accessibility hints.
    static var routeListAccessibilityHints: [String] = []

    /// Used to save the `RouteDescriptionList` routes.
    static var routeListRoutes: [NMARoute] = []

    /// For saving number of rows.
    static var routeCount: Int = 0

    /// Used to save the `NMAMapView` boundingBox property.
    static var boundingBox: NMAGeoBoundingBox?

    /// For saving stringized visible rows.
    static var stringizedVisibleRows: String?

    /// For saving current waypoint name.
    static var waypointName: String?

    private static let point = 24

    // MARK: - Public

    /// Reverses the order of the `ViewController`'s `WaypointList`.
    static func reverseWaypoints() {
        CoreActions.tap(element: RoutePlannerMatchers.swapButton)
    }

    /// Used for resetting the `ViewController`.
    static func reset() {
        EarlGrey.selectElement(with: RoutePlannerMatchers.transportModePanel).perform(
            GREYActionBlock.action(withName: "prepare for routing tests") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let transportModePanel = element as? TransportModePanel else {
                        return false
                }

                transportModePanel.transportMode = .car

                // Make sure to use a car by default
                let viewController = transportModePanel.superview?.viewController as? ViewController

                GREYAssertNotNil(viewController, reason: "No ViewController!")

                // Disable traffic support to simplify the tests: having the traffic
                // data makes it difficult to set the expectations
                viewController?.trafficEnabled = false

                // It is easier to test when have more routes
                viewController?.routingMode.resultLimit = 7

                // Make sure to use a car by default
                viewController?.routingMode.transportMode = .car
                return true
            }
        )
    }

    /// Saves the time panel text to the `travelTmePanelText` property.
    static func saveTravelTmePanelText() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.travelTimePanelTime).perform(
            GREYActionBlock.action(withName: "saveTravelTmePanelText") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let timeLabel = element as? UILabel else {
                        return false
                }

                travelTmePanelText = timeLabel.text

                print("TravelTmePanel text: \(String(describing: travelTmePanelText))")

                return true
            }
        )
    }

    /// Sets the `TravelTimePicker` picker view date.
    ///
    /// - Parameter date: The date to be set to the picker view.
    static func setPickerDate(_ date: Date?) {
        // EarlGrey does apply some gestures before completing the action. Unfortunately, it triggers
        // the cancel handler as the gestures hit the transparent view above the picker view. So, we
        // have to tap the "OK" button after we set the new date!
        EarlGrey.selectElement(with: RoutePlannerMatchers.travelTimePickerDatePicker).perform(
            GREYActionBlock.action(withName: "setPickerDate") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let datePicker = element as? UIDatePicker,
                    let date = date else {
                        return false
                }

                datePicker.date = date

                // Tap the "OK" button
                CoreActions.tap(element: RoutePlannerMatchers.travelTimePickerOk)

                return true
            }
        )
    }

    /// Saves the current tranport mode to the `transportMode` property.
    static func saveTransportMode() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.transportModePanel).perform(
            GREYActionBlock.action(withName: "saveTransportMode") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let panel = element as? TransportModePanel else {
                        return false
                }

                transportMode = panel.transportMode

                print("TransportModePanel mode: \(String(describing: transportMode))")

                return true
            }
        )
    }

    /// Sets the third waypoint to a known place.
    static func setThirdWaypoint() {
        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).perform(
            GREYActionBlock.action(withName: "setThirdWaypoint") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let waypointList = element as? WaypointList else {
                        return false
                }

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
        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).perform(
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
    /// - Parameter waypoints: Array of waypoints to be set in the same order as in the array.
    /// - Important: It updates the available wayponts in the `WaypointList`. So, the number of waypoints
    ///              determines the waypoints set.
    static func setWaypoints(waypoints: [WaypointEntry]) {
        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).perform(
            GREYActionBlock.action(withName: "setWaypoints") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let waypointList = element as? WaypointList else {
                        return false
                }

                // We want to initiate the route calculation only once! So, set the waypoints from the
                // bottom to top: only when we set the topmost one, we should be able to calculate the
                // routes

                // Firstly, set the waypoints coming on top of the default ones in a bottom to top fashion
                for (index, waypoint) in zip(waypoints.indices.reversed(), waypoints.reversed()) {
                    waypointList.updateEntry(waypoint, at: index)
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
        CoreActions.tap(element: RoutePlannerMatchers.addButton)

        // Wait until the reverse geocoding is completed
        CoreActions.tap(element: WaypointMatchers.waypointMapView)
        let condition = GREYCondition(name: "Wait for reverse geocoding") {
            let errorOrNil = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
            errorOrNil.initialize(to: nil)

            EarlGrey.selectElement(with: WaypointMatchers.waypointViewControllerOk)
                .assert(grey_enabled(), error: errorOrNil)
            return errorOrNil.pointee == nil
        }.wait(withTimeout: Constants.longWait, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Reverse geocoding was not successful after \(Constants.longWait) seconds")
        CoreActions.tap(element: WaypointMatchers.waypointViewControllerOk)
    }

    /// Drags a waypoint from the specified initial row to the specified final row.
    ///
    /// - Parameter fromRow: The initial row.
    /// - Parameter toRow: The final row.
    static func dragWaypoint(fromRow: Int, toRow: Int) {
        print("Dragging row \(fromRow) onto row \(toRow)...")
        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).perform(
            GREYActionBlock.action(withName: "dragWaypoint") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let waypointList = element as? WaypointList else {
                        return false
                }

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
    /// - Returns: The `WaypointItem` found in the cell or `nil` when no `WaypointItem` was found.
    static func getWaypointItem(inside cell: UITableViewCell) -> WaypointItem? {
        let views = cell.contentView.subviews.filter { $0 is WaypointItem }

        // There should be one and only one view in the views
        GREYAssertTrue(views.count == 1, reason: "Not the expected views count 1, but \(views.count)!")

        return views.first as? WaypointItem
    }

    /// Drags waypoint from one row to anouther and checks that waypoint names are as expected
    ///
    /// - Parameter fromRow: from what row to drag
    /// - Parameter toRow: to what row to drag
    /// - Parameter expectedNames: expected names array, must be in the same order as expected
    static func dragAndCheckWaypointChange(fromRow: Int, toRow: Int, expectedNames: [String]) {
        RoutePlannerActions.dragWaypoint(fromRow: fromRow, toRow: toRow)

        // Expand WaypointList
        CoreActions.tap(element: RoutePlannerMatchers.viewContollerRight)

        for (cellNr, expectedName) in expectedNames.enumerated() {
            WaypointActions.checkWaypointName(
                withId: RoutePlannerMatchers.waypointListCell(cellNr: cellNr),
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
            waitUntilRoutesCalculated()
            checkRoutesUpdated(existingRoutes: routes)
        }
    }

    /// Switches to specified transport mode and calculates a route with fixed waypoints
    ///
    /// - Parameter transportMode: Transport mode that will be used to calculate routes
    static func setTransportModeAndCalculateRoutes(transportMode: GREYMatcher) {
        if !transportMode.matches(RoutePlannerMatchers.transportModeCar) {
            CoreActions.tap(element: transportMode)
        }

        let fixedWaypoints = [WaypointEntryFixture.berlinNaturekundemuseum(),
                              WaypointEntryFixture.berlinReichstag()]
        RoutePlannerActions.setWaypoints(waypoints: fixedWaypoints)
        waitUntilRoutesCalculated()
    }

    /// Gets the `RouteDescriptionItem` object out of the cell.
    ///
    /// - Parameter cell: The cell containing the `RouteDescriptionItem` object.
    /// - Returns: The `RouteDescriptionItem` found in the cell or `nil` when no `RouteDescriptionItem` was found.
    static func getRouteDescriptionItem(inside cell: UITableViewCell) -> RouteDescriptionItem? {
        let views = cell.contentView.subviews.filter { $0 is RouteDescriptionItem }

        // There should be one and only one view in the views
        GREYAssertTrue(
            views.count == 1,
            reason: "Not the expected views count 1, but \(views.count)!")

        return views.first as? RouteDescriptionItem
    }

    /// Saves the route list routes to the `routeListRoutes` property.
    static func saveRouteListRoutesAndCount() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.routeDescriptionList).perform(
            GREYActionBlock.action(withName: "saveRouteListRoutes()") { element, errorOrNil -> Bool in
                guard
                    errorOrNil != nil,
                    let routeList = element as? RouteDescriptionList else {
                        return false
                }

                routeListRoutes = routeList.routes
                routeCount = routeList.entryCount

                print("RouteList routes: \(routeCount) route(s), \(routeListRoutes)")

                return true
            }
        )
    }

    /// Waits until the routes are calculated and then compares them with the passed routes.
    ///
    /// - Parameter existingRoutes: The array of the existing routes.
    static func checkRoutesUpdated(existingRoutes: [NMARoute]) {
        let condition = GREYCondition(name: "Wait for new routes") {
            // Make sure that the new routes are not nil and contain at least one route and different than the passed routes
            routeListRoutes.isEmpty == false && routeListRoutes != existingRoutes
        }.wait(withTimeout: Constants.longWait, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Routes did not differ from previous after \(Constants.longWait) seconds")
    }

    /// Get route list routes.
    ///
    /// - Returns: The array of routes the route list has.
    static func getRouteListRoutes() -> [NMARoute] {
        let condition = GREYCondition(name: "Wait for new routes") {
            EarlGrey.selectElement(with: RoutePlannerMatchers.routeDescriptionList).perform(
                GREYActionBlock.action(withName: "waitUntilRoutesCalculated") { element, errorOrNil in
                    guard
                        errorOrNil != nil,
                        let routeList = element as? RouteDescriptionList else {
                            return false
                    }

                    routeListRoutes = routeList.routes

                    print("RouteList routes: \(routeListRoutes.count) route(s), \(String(describing: routeListRoutes))")

                    return true
                }
            )

            // Make sure that at least one roure is found
            return routeListRoutes.isEmpty == false
        }.wait(withTimeout: Constants.longWait, pollInterval: Constants.longPollInterval)

        GREYAssertTrue(condition, reason: "Route list was not obtained after \(Constants.longWait) seconds")
        return routeListRoutes
    }

    /// Waits until the routes are calculated.
    static func waitUntilRoutesCalculated() {
        let condition = GREYCondition(name: "Wait for new routes") {
            EarlGrey.selectElement(with: RoutePlannerMatchers.routeDescriptionList).perform(
                GREYActionBlock.action(withName: "waitUntilRoutesCalculated") { element, errorOrNil in
                    guard
                        errorOrNil != nil,
                        let routeList = element as? RouteDescriptionList else {
                            return false
                    }

                    routeListRoutes = routeList.routes

                    print("RouteList routes: \(routeListRoutes.count) route(s), \(String(describing: routeListRoutes))")

                    return true
                }
            )

            // Make sure that at least one roure is found
            return routeListRoutes.isEmpty == false
        }.wait(withTimeout: Constants.longWait, pollInterval: Constants.longPollInterval)

        GREYAssertTrue(condition, reason: "Routes were not calculated after \(Constants.longWait) seconds")
    }

    /// Checks the targeted `RouteDescriptionItem` object.
    ///
    /// - Parameter index: The index of the targeted item.
    static func checkRouteDescriptionItem(index: Int) -> Bool {
        var matching: Bool = false
        // EarlGrey is not good at accessing UIStackView subviews directly: hence
        // we need to select the parent UIStackView object and then find our
        // RouteDescriptionItem subview
        EarlGrey.selectElement(with: RoutePlannerMatchers.routeStackView).perform(
            GREYActionBlock.action(withName: "checkRouteDescriptionItem") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let stackView = element as? UIStackView,
                    let routeDescriptionItem = stackView.arrangedSubviews.dropFirst().first as? RouteDescriptionItem else {
                        return false
                }

                // Do the accessibility hints match?
                matching = routeDescriptionItem.accessibilityHint == self.routeListAccessibilityHints[index]
                return matching
            }
        )

        return matching
    }

    /// Compare the route preview RouteDescriptionItem data with the saved data.
    static func compareRouteDescriptionData() {
        for index in 0 ..< routeListAccessibilityHints.count {
            CoreActions.tap(element: RoutePlannerMatchers.routeDescriptionListCell(cellNr: index))

            // Wait until the view controller becomes ready
            Utils.waitUntil(hidden: "RouteViewController.hudView")

            GREYAssertTrue(checkRouteDescriptionItem(index: index), reason: "Route description data is not matching!")
            CoreActions.tap(element: RoutePlannerMatchers.backButton)
        }
    }

    /// Updates transport mode, changes route start and end waypoint and verifies change in routes list.
    ///
    /// - Parameters:
    ///   - transportMode: The new transport mode in use.
    ///   - firstWaypoint: The first waypoint.
    ///   - secondWaypoint: The second waypoint.
    static func updateTransportModeWithWaypointsAndVerify(transportMode: GREYMatcher,
                                                          firstWaypoint: WaypointEntry,
                                                          secondWaypoint: WaypointEntry) {
        // Switch to route mode
        CoreActions.tap(element: transportMode)

        // New routes are calculated
        waitUntilRoutesCalculated()

        var routes = getRouteListRoutes()

        // Change the first waypoint value
        RoutePlannerActions.setWaypoint(at: 0, to: firstWaypoint)

        // Starting waypoint is updated. Updated route is automatically calculated.
        waitUntilRoutesCalculated()
        checkRoutesUpdated(existingRoutes: routes)
        routes = getRouteListRoutes()

        // Change the second waypoint value
        RoutePlannerActions.setWaypoint(at: 1, to: secondWaypoint)

        // Second waypoint is updated. Updated route is automatically calculated
        waitUntilRoutesCalculated()
        checkRoutesUpdated(existingRoutes: routes)
    }

    /// Checks that at least one route is being shown
    static func checkAnyRoutesAreShown() {
        GREYAssertFalse(getRouteListRoutes().isEmpty,
                        reason: "No route was found for this transport mode")
    }

    /// After scrolling a waypoint list, we need to make sure the visible rows are updated.
    /// This method makes sure that the waypoint list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func waypointListMustHaveNewVisibleRows(currentRows: String?) {
        tableViewMustHaveNewVisibleRows(.waypoint, visibleRows: currentRows)
    }

    /// After scrolling a route list, we need to make sure the visible rows are updated.
    /// This method makes sure that the route list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func routeListMustHaveNewVisibleRows(currentRows: String?) {
        tableViewMustHaveNewVisibleRows(.route, visibleRows: currentRows)
    }

    /// This method makes sure that the passed table view has new visible rows relative to the passed ones.
    ///
    /// - Parameter tableView: The table view to check the visible rows.
    /// - Parameter visibleRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func tableViewMustHaveNewVisibleRows(_ tableView: Lists, visibleRows: String?) {
        let condition = GREYCondition(name: "Wait for new visible rows") {
            // Save the visible rows depending on the list
            switch tableView {
            case .waypoint:
                saveWaypointListVisibleRows()

            case .route:
                saveRouteListVisibleRows()

            case .maneuver:
                RouteOverViewActions.saveManeuverTableViewVisibleRows()
            }

            return visibleRows != stringizedVisibleRows
        }.wait(withTimeout: Constants.mediumWait, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Visible rows did not differ from previous after \(Constants.mediumWait) seconds")
    }

    /// Saves the route list visible rows to the `stringizedVisibleRows` property.
    static func saveRouteListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.routeDescriptionList).perform(
            GREYActionBlock.action(withName: "saveRouteListVisibleRows") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let routeList = element as? RouteDescriptionList,
                    let visibleRowsIndexPaths = routeList.tableView.indexPathsForVisibleRows else {
                        return false
                }

                stringizedVisibleRows = Utils.stringizeRows(visibleRowsIndexPaths)

                return true
            }
        )
    }

    /// Saves the route list visible rows to the `stringizedVisibleRows` property.
    static func saveWaypointListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.waypointList).perform(
            GREYActionBlock.action(withName: "saveWaypointListVisibleRows") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let waypointList = element as? WaypointList,
                    let visibleRowsIndexPaths = waypointList.indexPathsForVisibleRows else {
                        return false
                }

                stringizedVisibleRows = Utils.stringizeRows(visibleRowsIndexPaths)

                return true
            }
        )
    }

    /// Saves the newly selected waypoint name on the waypoint view controller.
    static func saveSelectedWaypointName() {
        EarlGrey.selectElement(with: WaypointMatchers.waypoint).perform(
            GREYActionBlock.action(withName: "Save the waypoint name") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let label = element as? UILabel else {
                        return false
                }

                waypointName = label.text

                print("Waypoint name: \(waypointName ?? "nil")")

                return true
            }
        )
    }

    /// Check one-by-one all the `ManeuverItemView` objects of each route.
    static func checkManeuversOfEachRoute() {
        RoutePlannerActions.saveRouteListRoutesAndCount()

        for index in 0 ..< RoutePlannerActions.routeCount {
            CoreActions.tap(element: RoutePlannerMatchers.routeDescriptionListCell(cellNr: index))

            // Wait until the view controller becomes ready
            Utils.waitUntil(hidden: "RouteViewController.hudView")

            // Show maneuvers
            CoreActions.tap(element: WaypointMatchers.showManeuversButton)

            RouteOverViewActions.checkManeuverTableView()
            RouteOverViewActions.checkManeuverDescriptionItem()
            CoreActions.tap(element: RoutePlannerMatchers.backButton)
        }
    }

    /// Saves the bounding box of the map view to the `boundingBox` property.
    static func saveMapViewBoundingBox() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutePlannerMatchers.routeOverviewMapView).perform(
            GREYActionBlock.action(withName: "saveMapViewBoundingBox") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let mapView = element as? NMAMapView else {
                        return false
                }

                self.boundingBox = mapView.boundingBox

                // Dump the center
                if let center = self.boundingBox?.center {
                    let boundingBoxCenter = String(format: "%.5f", center.latitude) +
                        ", " +
                        String(format: "%.9f", center.longitude)

                    print("MapView boundingBox center: \(boundingBoxCenter)")
                } else {
                    print("MapView boundingBox center not known!")
                }

                return true
            }
        )
    }

    /// After some kind of actions, we want to make sure the map is updated, i.e. has a new bounding box.
    /// This method makes sure that the map view has a new bounding box relative to the passed one.
    ///
    /// - Parameter existingBoundingBox: The last known map bounding box.
    /// - Important: If there is a timeout or no bounding box update, this method throws an
    ///              assertion failure.
    static func mustHaveNewBoundingBox(existingBoundingBox: NMAGeoBoundingBox?) {
        let condition = GREYCondition(name: "Wait for a new bounding box") {
            RoutePlannerActions.saveMapViewBoundingBox()

            // Do we know the bounding box centers?
            guard let existingBoundingBoxCenter = existingBoundingBox?.center,
                let newBoundingBoxCenter = RoutePlannerActions.boundingBox?.center else {
                    return false
            }

            // Make sure they are different
            return existingBoundingBoxCenter.latitude != newBoundingBoxCenter.latitude &&
                existingBoundingBoxCenter.longitude != newBoundingBoxCenter.longitude
        }.wait(withTimeout: Constants.mediumWait, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Bouding box was not updated after \(Constants.mediumWait) seconds")
    }
}
