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

enum RouteOverViewActions {

    /// Makes sures that the maneuver contains icon, instruction, address
    /// and distance data.
    static func checkManeuverList() {
        EarlGrey.selectElement(with: RouteOverviewMatchers.maneuverDescriptionList)
            .perform(GREYActionBlock
                .action(withName: "checkManeuverList()") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let maneuverList = element as? ManeuverDescriptionList else {
                            return false
                    }

                    // One-by-one check the maneuvers
                    for index in 0 ..< maneuverList.entryCount {
                        let indexPath = IndexPath(row: index, section: 0)
                        maneuverList.scrollToRow(at: indexPath, at: .bottom, animated: false) // Make sure it is visible
                        guard
                            let cell = maneuverList.cellForRow(at: indexPath),
                            let item = RouteOverViewActions.getManeuverDescriptionItem(inside: cell) else {
                                return false
                        }

                        print("ManeuverList maneuver \(String(index)) accessibilityHint: \(String(describing: item.accessibilityHint))")

                        GREYAssertNotNil(
                            item.iconImageView.image, reason: "No icon view!")
                        GREYAssertNotNil(
                            item.instructionLabel.text, reason: "No instruction label text!")
                        GREYAssertFalse(
                            item.instructionLabel.text?.isEmpty ?? true,
                            reason: "Empty instruction label text!")
                        GREYAssertNotNil(
                            item.addressLabel.text, reason: "No address label text!")
                        GREYAssertFalse(
                            item.addressLabel.text?.isEmpty ?? true, reason: "Empty address label text!")

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
                                item.distanceLabel.text?.isEmpty ?? true,
                                reason: "Empty distance label text!")
                        }
                    }
                    return true
                })
    }

    /// After scrolling a maneuver list, we need to make sure the visible rows are updated.
    /// This method makes sure that the maneuver list has new visible rows.
    ///
    /// - Parameter currentRows: The last known visible rows.
    /// - Important: If there is a timeout or no visible rows update, this method throws an
    ///              assertion failure.
    static func maneuverListMustHaveNewVisibleRows(currentRows: String?) {
        RoutePlannerActions.listMustHaveNewVisibleRows(.maneuver, visibleRows: currentRows)
    }

    /// Gets and returns the `ManeuverDescriptionItem` object out of the cell.
    ///
    /// - Parameter cell: The cell containing the `ManeuverDescriptionItem` object.
    /// - Returns: The `ManeuverDescriptionItem` found in the cell or `nil` when no `ManeuverDescriptionItem` was found.
    static func getManeuverDescriptionItem(inside cell: UITableViewCell) -> ManeuverDescriptionItem? {
        let views = cell.contentView.subviews.filter { $0 is ManeuverDescriptionItem }

        // There should be one and only one view in the views
        GREYAssertTrue(
            views.count == 1, reason: "Not the expected views count 1, but \(views.count)!")

        return views.first as? ManeuverDescriptionItem
    }

    /// Saves the maneuver list visible rows to the `stringizedVisibleRows` property.
    static func saveManeuverListVisibleRows() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteOverviewMatchers.maneuverDescriptionList).perform(
            GREYActionBlock.action(withName: "saveManeuverListVisibleRows") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let mapList = element as? ManeuverDescriptionList,
                    let visibleRowsIndexPaths = mapList.indexPathsForVisibleRows else {
                        return false
                }

                RoutePlannerActions.stringizedVisibleRows = Utils.stringizeRows(visibleRowsIndexPaths)

                return true
            }
        )
    }

    /// Helper method to allow collecting maneuvers data from `ManeuverDescriptionList`.
    ///
    /// - Parameter accessibilityIdentifier: Identifier of `ManeuverDescriptionList`
    /// - Returns: Array of tuple containing address and icon accessibility identifier.
    static func collectManeuversData(from element: GREYMatcher) -> [(address: String, iconAccessibilityIdentifier: String)] {
        var data: [(String, String)] = []
        Utils.waitUntil(visible: element)

        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "Get description list") { element, errorOrNil -> Bool in
                // Get description list
                guard
                    errorOrNil != nil,
                    let descriptionList = element as? ManeuverDescriptionList else {
                        return false
                }

                // Collect every address from list
                for index in 0..<descriptionList.entryCount {
                    if let cell = descriptionList.cellForRow(at: IndexPath(row: index, section: 0))?.contentView.subviews.first as? ManeuverDescriptionItem {
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
