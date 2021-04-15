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

enum RouteOverViewActions {

    /// This method checks that all the assests of route description item are displayed correctly.
    static func checkManeuverDescriptionItem() {
        EarlGrey.selectElement(with: RouteOverviewMatchers.routeDescriptionItem)
            .assert(grey_sufficientlyVisible())
            .perform(GREYActionBlock.action(withName: "Check maneuver description item assets") { element, errorOrNil -> Bool in
                guard
                    errorOrNil != nil,
                    let maneuverDescriptionItem = element as? RouteDescriptionItem,
                    let transportModeImage = maneuverDescriptionItem.transportModeImage,
                    let durationLabelText = maneuverDescriptionItem.durationLabel.text,
                    let delayLabelText = maneuverDescriptionItem.delayLabel.text,
                    let lenghtLabelText = maneuverDescriptionItem.lengthLabel.text,
                    let timeLabelText = maneuverDescriptionItem.timeLabel.text else {
                        return false
                }

                GREYAssertNotNil(transportModeImage, reason: "Transport mode image should be displayed")
                GREYAssertFalse(durationLabelText.isEmpty, reason: "Duration should be displayed")
                GREYAssertFalse(lenghtLabelText.isEmpty, reason: "Route length should be displayed")
                GREYAssertFalse(timeLabelText.isEmpty, reason: "Arrival time should be displayed")

                // If delay is greater or equal to 60 seconds, a traffic delay should be displayed
                if maneuverDescriptionItem.handler.delaySeconds >= 60 {
                    GREYAssertFalse(delayLabelText.isEmpty, reason: "Delay should be displayed")
                } else {
                    GREYAssertTrue(delayLabelText.isEmpty, reason: "Delay should not be displayed")
                }

                return true
            }
        )
    }

    /// Makes sures that the maneuver contains icon, instruction, address
    /// and distance data.
    static func checkManeuverTableView() {
        EarlGrey.selectElement(with: RouteOverviewMatchers.maneuverTableView)
            .perform(GREYActionBlock
                .action(withName: "checkManeuverTableView()") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let maneuverTableView = element as? ManeuverTableView else {
                            return false
                    }

                    // One-by-one check the maneuvers
                    for index in 0 ..< maneuverTableView.entryCount {
                        let indexPath = IndexPath(row: index, section: 0)
                        maneuverTableView.scrollToRow(at: indexPath, at: .bottom, animated: false) // Make sure it is visible
                        guard
                            let cell = maneuverTableView.cellForRow(at: indexPath),
                            let item = RouteOverViewActions.getManeuverItemView(inside: cell) else {
                                return false
                        }

                        print("maneuverTableView maneuver \(String(index)) accessibilityHint: \(String(describing: item.accessibilityHint))")

                        GREYAssertNotNil(item.iconImageView.image, reason: "No icon view!")
                        GREYAssertNotNil(item.instructionLabel.text, reason: "No instruction label text!")
                        GREYAssertFalse(item.instructionLabel.text?.isEmpty ?? true, reason: "Empty instruction label text!")
                        GREYAssertNotNil(item.addressLabel.text, reason: "No address label text!")
                        GREYAssertFalse(item.addressLabel.text?.isEmpty ?? true, reason: "Empty address label text!")

                        // The last item distance should not be visible
                        if index == maneuverTableView.entryCount - 1 {
                            GREYAssert(item.distanceLabel.isHidden == true, reason: "The last distance label text should be hidden!")
                        } else {
                            GREYAssertNotNil(item.distanceLabel.text, reason: "No distance label text!")
                            GREYAssertFalse(item.distanceLabel.text?.isEmpty ?? true, reason: "Empty distance label text!")
                        }
                    }
                    return true
                }
        )
    }

    /// After scrolling a maneuver table view, we need to make sure the visible rows are updated.
    /// This method makes sure that the maneuver table view has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func maneuverTableViewMustHaveNewVisibleRows(currentRows: String?) {
        RoutePlannerActions.tableViewMustHaveNewVisibleRows(.maneuver, visibleRows: currentRows)
    }

    /// Gets and returns the `ManeuverItemView` object out of the cell.
    ///
    /// - Parameter cell: The cell containing the `ManeuverItemView` object.
    /// - Returns: The `ManeuverItemView` found in the cell or `nil` when no `ManeuverItemView` was found.
    static func getManeuverItemView(inside cell: UITableViewCell) -> ManeuverItemView? {
        let views = cell.contentView.subviews.filter { $0 is ManeuverItemView }

        // There should be one and only one view in the views
        GREYAssertTrue(
            views.count == 1, reason: "Not the expected views count 1, but \(views.count)!")

        return views.first as? ManeuverItemView
    }

    /// Saves the maneuver table view visible rows to the `stringizedVisibleRows` property.
    static func saveManeuverTableViewVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteOverviewMatchers.maneuverTableView).perform(
            GREYActionBlock.action(withName: "saveManeuverTableViewVisibleRows") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let tableView = element as? ManeuverTableView,
                    let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
                        return false
                }

                RoutePlannerActions.stringizedVisibleRows = Utils.stringizeRows(visibleRowsIndexPaths)

                return true
            }
        )
    }

    /// Helper method to allow collecting maneuvers data from `ManeuverTableView`.
    ///
    /// - Parameter accessibilityIdentifier: Identifier of `ManeuverTableView`
    /// - Returns: Array of tuple containing address and icon accessibility identifier.
    static func collectManeuversData(from element: GREYMatcher) -> [(address: String, iconAccessibilityIdentifier: String)] {
        var data: [(String, String)] = []
        Utils.waitUntil(visible: element)

        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "Get description table view") { element, errorOrNil -> Bool in
                // Get description table view
                guard
                    errorOrNil != nil,
                    let descriptionTableView = element as? ManeuverTableView else {
                        return false
                }

                // Collect every address from table view
                for index in 0..<descriptionTableView.entryCount {
                    if let cell = descriptionTableView.cellForRow(at: IndexPath(row: index, section: 0))?.contentView.subviews.first as? ManeuverItemView {
                        // If available, add address and accessibility identifier to array
                        if let address = cell.addressLabel.text,
                            let imageAccessibilityId = cell.iconImageView.accessibilityIdentifier {
                            data.append((address, imageAccessibilityId))
                        }
                    }
                }

                // Addresses collected
                return true
            }
        )

        // Return collected data
        return data
    }
}
