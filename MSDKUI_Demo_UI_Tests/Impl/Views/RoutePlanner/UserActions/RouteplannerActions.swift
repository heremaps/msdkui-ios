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

enum RouteplannerActions {
    /// Used to save the `RouteDescriptionList` accessibility hints.
    static var routeListAccessibilityHints: [String] = []

    /// Used to save the `RouteDescriptionList` routes.
    static var routeListRoutes: [NMARoute] = []

    /// For keeping number of rows
    static var routeCount: Int = 0

    /// Gets the `RouteDescriptionItem` object out of the cell.
    ///
    /// - Parameter cell: The cell containing the `RouteDescriptionItem` object.
    static func getRouteDescriptionItem(inside cell: UITableViewCell) -> RouteDescriptionItem {
        let views = cell.contentView.subviews.filter { $0 is RouteDescriptionItem }

        // There should be one and only one view in the views
        GREYAssertTrue(
            views.count == 1,
            reason: "Not the expected views count 1, but \(views.count)!")

        return views[0] as! RouteDescriptionItem
    }

    /// Saves the route list routes to the `routeListRoutes` property.
    static func saveRouteListRoutesAndCount() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteplannerView.routeDescriptionList).perform(
            GREYActionBlock.action(withName: "saveRouteListRoutes()") { element, errorOrNil -> Bool in
                guard errorOrNil != nil else {
                    return false
                }

                let routeList = element as! RouteDescriptionList
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
        let routesCalculated = GREYCondition(name: "Wait for new routes") {
            // Make sure that the new routes are not nil and contain at least one route and different than the passed routes
            routeListRoutes.isEmpty == false && routeListRoutes != existingRoutes
        }.wait(withTimeout: Constans.longWait, pollInterval: Constans.mediumPollInterval)
        GREYAssertTrue(routesCalculated, reason: "Failed to calculate the new routes!")
    }

    /// Get route list routes
    static func getRouteListRoutes() -> [NMARoute] {
        let routesCalculated = GREYCondition(name: "Wait for new routes") {
            EarlGrey.selectElement(with: RouteplannerView.routeDescriptionList).perform(
                GREYActionBlock.action(withName: "waitUntilRoutesCalculated") { element, errorOrNil in
                    guard errorOrNil != nil else {
                        return false
                    }

                    let routeList = element as! RouteDescriptionList
                    routeListRoutes = routeList.routes

                    print("RouteList routes: \(routeListRoutes.count) route(s), \(String(describing: routeListRoutes))")

                    return true
                }
            )

            // Make sure that at least one roure is found
            return routeListRoutes.isEmpty == false
        }.wait(withTimeout: Constans.longWait, pollInterval: Constans.longPollInterval)
        GREYAssertTrue(
            routesCalculated, reason: "Failed to calculate the routes!")
        return routeListRoutes
    }

    /// Waits until the routes are calculated.
    static func waitUntilRoutesCalculated() {
        let routesCalculated = GREYCondition(name: "Wait for new routes") {
            EarlGrey.selectElement(with: RouteplannerView.routeDescriptionList).perform(
                GREYActionBlock.action(withName: "waitUntilRoutesCalculated") { element, errorOrNil in
                    guard errorOrNil != nil else {
                        return false
                    }

                    let routeList = element as! RouteDescriptionList
                    routeListRoutes = routeList.routes

                    print("RouteList routes: \(routeListRoutes.count) route(s), \(String(describing: routeListRoutes))")

                    return true
                }
            )

            // Make sure that at least one roure is found
            return routeListRoutes.isEmpty == false
        }.wait(withTimeout: Constans.longWait, pollInterval: Constans.longPollInterval)
        GREYAssertTrue(
            routesCalculated, reason: "Failed to calculate the routes!")
    }

    /// Makes sures that the routes contain transportation mode, duration, length
    /// and arrival data. It ignores the delay data as it is not clear what to
    /// expect.
    static func checkRouteListAccessibilityHints() {
        // The following strings are expected in an accessibilityHint:
        // "msdkui_duration_time" = "Duration: %@";
        // "msdkui_route_length" = "Distance: %@";
        // "msdkui_arrival_time" = "Arrival time: %@";
        // Let's delete the dynamic parts in order check the hints easier
        let duration = "msdkui_duration_time".localized.replacingOccurrences(of: "%@", with: "")
        let length = "msdkui_route_length".localized.replacingOccurrences(of: "%@", with: "")
        let arrival = "msdkui_arrival_time".localized.replacingOccurrences(of: "%@", with: "")

        for index in 0 ..< routeListAccessibilityHints.count {
            GREYAssertTrue(
                routeListAccessibilityHints[index].contains("msdkui_car".localized),
                reason: "No car transport mode!")
            GREYAssertTrue(
                routeListAccessibilityHints[index].contains(duration),
                reason: "No duration data!")
            GREYAssertTrue(
                routeListAccessibilityHints[index].contains(length),
                reason: "No length data!")
            GREYAssertTrue(
                routeListAccessibilityHints[index].contains(arrival),
                reason: "No arrival data!")
        }
    }

    /// Saves the route list accessibilityHints strings to the `routeListAccessibilityHints` property.
    static func saveRouteListAccessibilityHints() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteplannerView.routeDescriptionList).perform(
            GREYActionBlock.action(withName: "saveRouteListAccessibilityHints") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                // Make sure to empty the array
                routeListAccessibilityHints.removeAll()

                // One-by-one add the accessibility hints
                let routeList = element as! RouteDescriptionList
                for index in 0 ..< routeList.entryCount {
                    let indexPath = IndexPath(row: index, section: 0)
                    routeList.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false) // Make sure it is visible
                    let cell = routeList.tableView.cellForRow(at: indexPath)
                    let item = RouteplannerActions.getRouteDescriptionItem(inside: cell!)
                    let accessibilityHint = item.accessibilityHint

                    GREYAssertNotNil(accessibilityHint, reason: "No accessibility hint!")

                    print("RouteList route \(String(index)) accessibilityHint: \(accessibilityHint!)")

                    routeListAccessibilityHints.append(accessibilityHint!)
                }

                return true
            }
        )
    }

    /// Checks the targeted `RouteDescriptionItem` object.
    ///
    /// - Parameter index: The index of the targeted item.
    static func checkRouteDescriptionItem(index: Int) -> Bool {
        var matching: Bool = false
        // EarlGrey is not good at accessing UIStackView subviews directly: hence
        // we need to select the parent UIStackView object and then find our
        // RouteDescriptionItem subview
        EarlGrey.selectElement(with: RouteplannerView.routeStackView).perform(
            GREYActionBlock.action(withName: "checkRouteDescriptionItem") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let stackView = element as! UIStackView
                let routeDescriptionItem = stackView.arrangedSubviews[1] as! RouteDescriptionItem

                // Do the accessibility hints match?
                matching = routeDescriptionItem.accessibilityHint == self.routeListAccessibilityHints[index]
                return matching
            }
        )

        return matching
    }

    /// Compare the route preview RouteDescriptionItem data with the saved data
    static func compareRouteDescriptionData() {
        for index in 0 ..< routeListAccessibilityHints.count {
            CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: (index + 1)))

            // Wait for the segue effect
            Utils.waitFor(element: RouteplannerView.backButton)
            Utils.saveScreenshot()

            GREYAssertTrue(checkRouteDescriptionItem(index: index), reason: "Route description data is not matching!")
            CoreActions.tap(element: RouteplannerView.backButton)
        }
    }

    /// Selects route mode, changes route start and end waypoint and verifies change in routes list
    static func selectRouteModeUpdateWaypointsAndVerify(routeMode: GREYMatcher, firstWaypoint: WaypointEntry, secondWaypoint: WaypointEntry) {
        // Switch to route mode
        CoreActions.tap(element: routeMode)

        // New routes are calculated
        RouteplannerActions.waitUntilRoutesCalculated()
        var routes = RouteplannerActions.getRouteListRoutes()

        // Change the first waypoint value
        ActionbarActions.setWaypoint(at: 0, to: firstWaypoint)

        // Starting waypoint is updated. Updated route is automatically calculated.
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
        routes = RouteplannerActions.getRouteListRoutes()

        // Change the second waypoint value
        ActionbarActions.setWaypoint(at: 1, to: secondWaypoint)

        // Second waypoint is updated. Updated route is automatically calculated
        RouteplannerActions.waitUntilRoutesCalculated()
        RouteplannerActions.checkRoutesUpdated(existingRoutes: routes)
    }
}
