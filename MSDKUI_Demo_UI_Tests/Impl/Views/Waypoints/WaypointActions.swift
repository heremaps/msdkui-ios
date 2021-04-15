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
import NMAKit

enum WaypointActions {

    /// Checks a waypoint name.
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    /// - Parameter expectedName: The expected name of the waypoint.
    static func checkWaypointName(withId matcher: GREYMatcher, expectedName: String?) {
        GREYAssertNotNil(expectedName, reason: "A comparison string is provided")

        EarlGrey.selectElement(with: matcher).perform(
            GREYActionBlock.action(withName: "checkWaypointName") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let cell = element as? UITableViewCell,
                    let item = RoutePlannerActions.getWaypointItem(inside: cell) else {
                        return false
                }

                // Does the waypoint name match the expected name?
                return item.entry.name == expectedName
            }
        )
    }

    /// Checks if "To" label is displayed
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    static func checkWaypointToLabelDisplayed(forWaypoint matcher: GREYMatcher) {
        checkWaypointLabel(forWaypoint: matcher, labelToTest: TestStrings.to, shouldBeDisplayed: true)
    }

    /// Checks if "From" label is displayed
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    static func checkWaypointFromLabelDisplayed(forWaypoint matcher: GREYMatcher) {
        checkWaypointLabel(forWaypoint: matcher, labelToTest: TestStrings.from, shouldBeDisplayed: true)
    }

    /// Checks if "To" label is hidden
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    static func checkWaypointToLabelHidden(forWaypoint matcher: GREYMatcher) {
        checkWaypointLabel(forWaypoint: matcher, labelToTest: TestStrings.to, shouldBeDisplayed: false)
    }

    /// Checks if "From" label is hidden
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    static func checkWaypointFromLabelHidden(forWaypoint matcher: GREYMatcher) {
        checkWaypointLabel(forWaypoint: matcher, labelToTest: TestStrings.from, shouldBeDisplayed: false)
    }

    /// Checks if specified label has correct visibility for waypoint
    ///
    /// - Parameter matcher: The GREYMatcher of the targeted element.
    /// - Parameter labelToTest: Label string that will be checked.
    /// - Parameter shouldBeDisaplyed: true if label should be visible, false otherwise.
    private static func checkWaypointLabel(forWaypoint matcher: GREYMatcher, labelToTest: String, shouldBeDisplayed: Bool) {
        EarlGrey.selectElement(with: matcher).perform(
            GREYActionBlock.action(withName: "checkWaypointLabel") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let cell = element as? UITableViewCell,
                    let item = RoutePlannerActions.getWaypointItem(inside: cell) else {
                        return false
                }

                // Label must not be nil
                GREYAssertNotNil(item.label.text, reason: "Waypoint label must not be nil!")

                let isDisplayed = item.label.text?.starts(with: labelToTest) ?? false
                return shouldBeDisplayed == isDisplayed
            }
        )
    }

    /// Sets current map view to new coordinates.
    ///
    /// - Parameter mapData: Latitude and longitude coordinates.
    static func switchMapViewTo(mapData: NMAGeoCoordinates) {
        EarlGrey.selectElement(with: WaypointMatchers.waypointMapView).perform(
            GREYActionBlock.action(withName: "Set map geo center to coordinates") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let mapView = element as? NMAMapView else {
                        return false
                }
                // Center current map view to specified coordinates
                mapView.set(geoCenter: mapData, animation: .none)
                return true
            }
        )
    }
}
