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

enum RoutingActions {
    /// For taking action based on the list type.
    private enum Lists {
        case waypoint
        case route
        case maneuver
    }

    /// For saving stringized visible rows.
    static var stringizedVisibleRows: String?

    /// For saving waypoint name.
    static var waypointName: String?

    /// Check the ManeuverDescriptionItem objects one-by-one for each route
    static func checkManueverDescriptionItemEachRouteOnebyOne() {
        RouteplannerActions.saveRouteListRoutesAndCount()
        for index in 0 ..< RouteplannerActions.routeCount {
            CoreActions.tap(element: RouteplannerView.routeDescriptionListCell(cellNr: index))

            // Wait until the view controller becomes ready
            Utils.waitUntil(hidden: "RouteViewController.hudView")

            checkManeuverList()
            CoreActions.tap(element: RouteplannerView.backButton)
        }
    }

    /// Makes sures that the maneuver contains icon, instruction, address
    /// and distance data.
    static func checkManeuverList() {
        EarlGrey.selectElement(with: RoutingView.manouverDesctiptionList)
            .perform(GREYActionBlock
                .action(withName: "checkManeuverList()") { element, errorOrNil -> Bool in
                    guard errorOrNil != nil else {
                        return false
                    }

                    // One-by-one check the maneuvers
                    let maneuverList = element as! ManeuverDescriptionList
                    for index in 0 ..< maneuverList.entryCount {
                        let indexPath = IndexPath(row: index, section: 0)
                        maneuverList.scrollToRow(at: indexPath, at: .bottom, animated: false) // Make sure it is visible
                        let cell = maneuverList.cellForRow(at: indexPath)
                        let item = RoutingActions.getManeuverDescriptionItem(inside: cell!)

                        print("ManeuverList maneuver \(String(index)) accessibilityHint: \(item.accessibilityHint!)")

                        GREYAssertNotNil(
                            item.iconImageView.image, reason: "No icon view!")
                        GREYAssertNotNil(
                            item.instructionLabel.text, reason: "No instruction label text!")
                        GREYAssertFalse(
                            item.instructionLabel.text!.isEmpty,
                            reason: "Empty instruction label text!")
                        GREYAssertNotNil(
                            item.addressLabel.text, reason: "No address label text!")
                        GREYAssertFalse(
                            item.addressLabel.text!.isEmpty, reason: "Empty address label text!")

                        // The last item distance should not be visible
                        if index == maneuverList.entryCount - 1 {
                            GREYAssertTrue(
                                item.visibleSections == [.icon, .instructions, .address],
                                reason: "The last distance label text should be hidden!")
                            GREYAssert(
                                item.distanceLabel.isHidden == true,
                                reason: "The last distance label text should be hidden!")
                        } else {
                            GREYAssertNotNil(
                                item.distanceLabel.text,
                                reason: "No distance label text!")
                            GREYAssertFalse(
                                item.distanceLabel.text!.isEmpty,
                                reason: "Empty distance label text!")
                        }
                    }
                    return true
                })
    }

    /// Taps a random maneuver execept the first one which is tapped previously and the last one, i.e.
    /// arrival one, which does not generate a map update.
    static func tapRandomManeuver() {
        let element = grey_accessibilityID("MSDKUI.ManeuverDescriptionList")

        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "tapRandomManeuver") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let maneuverList = element as! ManeuverDescriptionList
                let index = self.randomManeuver(max: maneuverList.entryCount)

                // Scroll to random maneuver
                let indexPath = IndexPath(row: index, section: 0)
                maneuverList.scrollToRow(at: indexPath, at: .none, animated: true)

                // Tap it
                CoreActions.tap(element: RoutingView.routeDescriptionPanel, point: CGPoint(x: 0.5, y: 1.2))

                return true
            }
        )
    }

    /// Returns a random maneuver index based on the following rules:
    /// 1 - Ignore the first maneuver as it was tapped already.
    /// 2 - Ignore the last maneuver, i.e. arrival maneuver, as it doesn't generate any map updates.
    ///
    /// - Parameter entryCount: The upper bound of the random number.
    /// - Returns: The randomly selected number in the [1..max-2] range.
    /// - Important: The maneuver indexes start from zero.
    static func randomManeuver(max entryCount: Int) -> Int {
        let max = UInt32(entryCount - 3)
        let index = Int(arc4random_uniform(max))

        print("Random number: \(index) / max number: \(max)")

        return index + 1
    }

    /// Saves the route list visible rows to the `stringizedVisibleRows` property.
    static func saveRouteListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteplannerView.routeDescriptionList).perform(
            GREYActionBlock.action(withName: "saveRouteListVisibleRows") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let routeList = element as! RouteDescriptionList
                stringizedVisibleRows = Utils.stringizeRows(routeList.tableView.indexPathsForVisibleRows!)

                return true
            }
        )
    }

    /// Saves the route list visible rows to the `stringizedVisibleRows` property.
    static func saveWaypointListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: ActionbarView.waypointList).perform(
            GREYActionBlock.action(withName: "saveWaypointListVisibleRows") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let waypointList = element as! WaypointList
                stringizedVisibleRows = Utils.stringizeRows(waypointList.indexPathsForVisibleRows!)

                return true
            }
        )
    }

    /// Saves the maneuver list visible rows to the `stringizedVisibleRows` property.
    static func saveManeuverListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RoutingView.manouverDesctiptionList).perform(
            GREYActionBlock.action(withName: "saveManeuverListVisibleRows") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let mapList = element as! ManeuverDescriptionList
                stringizedVisibleRows = Utils.stringizeRows(mapList.indexPathsForVisibleRows!)

                return true
            }
        )
    }

    /// After scrolling a waypoint list, we need to make sure the visible rows are updated.
    /// This method makes sure that the waypoint list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func waypointListMustHaveNewVisibleRows(currentRows: String?) {
        listMustHaveNewVisibleRows(.waypoint, visibleRows: currentRows)
    }

    /// After scrolling a route list, we need to make sure the visible rows are updated.
    /// This method makes sure that the route list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func routeListMustHaveNewVisibleRows(currentRows: String?) {
        listMustHaveNewVisibleRows(.route, visibleRows: currentRows)
    }

    /// After scrolling a maneuver list, we need to make sure the visible rows are updated.
    /// This method makes sure that the maneuver list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func maneuverListMustHaveNewVisibleRows(currentRows: String?) {
        listMustHaveNewVisibleRows(.maneuver, visibleRows: currentRows)
    }

    /// Saves the newly selected waypoint name on the waypoint view controller.
    static func saveSelectedWaypointName() {
        EarlGrey.selectElement(with: MapView.waypoint).perform(
            GREYActionBlock.action(withName: "Save the waypoint name") { element, errorOrNil in
                guard errorOrNil != nil, let label = element as? UILabel else {
                    return false
                }

                waypointName = label.text

                print("Waypoint name: \(waypointName ?? "nil")")

                return true
            }
        )
    }

    /// Gets and returns the `ManeuverDescriptionItem` object out of the cell.
    ///
    /// - Parameter cell: The cell containing the `ManeuverDescriptionItem` object.
    static func getManeuverDescriptionItem(inside cell: UITableViewCell) -> ManeuverDescriptionItem {
        let views = cell.contentView.subviews.filter { $0 is ManeuverDescriptionItem }

        // There should be one and only one view in the views
        GREYAssertTrue(
            views.count == 1, reason: "Not the expected views count 1, but \(views.count)!")

        return views[0] as! ManeuverDescriptionItem
    }

    // MARK: Private methods

    /// This method makes sure that the passed list has new visible rows relative to the passed ones.
    ///
    /// - Parameter list: The list to check the visible rows.
    /// - Parameter visibleRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    private static func listMustHaveNewVisibleRows(_ list: Lists, visibleRows: String?) {
        let newVisibleRows = GREYCondition(name: "Wait for new visible rows") {
            // Save the visible rows depending on the list
            switch list {
            case .waypoint:
                RoutingActions.saveWaypointListVisibleRows()

            case .route:
                RoutingActions.saveRouteListVisibleRows()

            case .maneuver:
                RoutingActions.saveManeuverListVisibleRows()
            }

            return visibleRows != RoutingActions.stringizedVisibleRows
        }.wait(withTimeout: Constans.mediumWait, pollInterval: Constans.mediumPollInterval)

        GREYAssertTrue(newVisibleRows, reason: "Failed to update the visible rows!")
    }
}
