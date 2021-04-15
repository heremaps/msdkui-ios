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

import Foundation
import NMAKit

/// This enum provides the helper methods for all the guidance-related activities.
enum GuidanceManeuverUtil {

    // MARK: - Properties

    /// Sets the threshold for switching to the next maneuver.
    private static let nextManeuverThreshold: Int = 750

    // MARK: - Public

    /// Returns the index of the maneuver among the maneuvers.
    ///
    /// - Parameter maneuver: The maneuver to be queried.
    /// - Parameter maneuvers: All the available maneuvers.
    /// - Returns: The index of the maneuver among the maneuvers.
    static func getIndex(of maneuver: NMAManeuver?, from maneuvers: [NMAManeuver]) -> Int? {
        var index: Int?

        for newIndex in 0 ..< maneuvers.count {
            if areManeuversEqual(maneuvers[newIndex], maneuver) {
                index = newIndex
                break
            }
        }

        return index
    }

    /// Checks if the specified maneuvers are equal or not.
    ///
    /// - Parameter left: The first maneuver.
    /// - Parameter right: The second maneuver.
    /// - Returns: True if the maneuvers are equal and false otherwise.
    /// - Important: If both of the maneuvers are nil, they are considered equal.
    static func areManeuversEqual(_ left: NMAManeuver?, _ right: NMAManeuver?) -> Bool {
        if let left = left, let right = right, let leftCoordinates = left.coordinates, let rightCoordinates = right.coordinates {
            return leftCoordinates.isEqual(rightCoordinates) && left.action == right.action
        } else {
            return left == nil && right == nil
        }
    }

    /// Returns the current street. In case the current street is not found, the current signpost is used.
    ///
    /// - Parameter maneuver: The maneuver to be queried.
    /// - Returns: The current street or nil.
    static func getCurrentStreet(from maneuver: NMAManeuver) -> String? {
        var currentStreet = combineStrings(maneuver: maneuver,
                                           name: maneuver.roadNames()?.first as String?,
                                           number: maneuver.roadNumber as String?)

        if !currentStreet.hasContent {
            currentStreet = maneuver.getStringFromSignpost()
        }

        return currentStreet
    }

    /// Returns the next street. Note that when the next street is not found, the specified route is queried to
    /// find it as a fallback.
    ///
    /// - Parameter maneuver: The maneuver to be queried.
    /// - Parameter route: The route to be queried as a fallback or nil when is not available.
    /// - Returns: The next street or nil.
    static func getNextStreet(from maneuver: NMAManeuver?, fallback route: NMARoute?) -> String? {
        var nextManeuver = GuidanceManeuverUtil.getNextManeuver(last: maneuver, fallback: route)
        var nextStreet: String?
        var distance = 0

        while distance < GuidanceManeuverUtil.nextManeuverThreshold && nextStreet == nil, let iterationNextManeuver = nextManeuver {
            distance += Int(clamping: iterationNextManeuver.distanceFromPreviousManeuver)
            nextStreet = GuidanceManeuverUtil.combineStrings(maneuver: iterationNextManeuver,
                                                             name: iterationNextManeuver.nextRoadNames()?.first as String?,
                                                             number: iterationNextManeuver.nextRoadNumber as String?)
            nextManeuver = GuidanceManeuverUtil.getNextManeuver(last: iterationNextManeuver, fallback: route)
        }

        return nextStreet
    }

    /// Creates a string like "number/name" out of the passed parameters.
    ///
    /// - Parameter maneuver: The maneuver.
    /// - Parameter name: The name of street.
    /// - Parameter number: The number within street.
    /// - Returns: The combined string.
    static func combineStrings(maneuver: NMAManeuver?, name: String?, number: String?) -> String? {
        var combinedString: String?

        // In case of leaving highway, prefer to show exit signpost text instead of road name
        if let maneuver = maneuver, maneuver.action == .leaveHighway {
            combinedString = maneuver.getStringFromSignpost() ?? name
        } else {
            // Proceed based on the string availability
            switch (name.hasContent, number.hasContent) {
            case (true, true):
                // Skips combining if the name contains the number already
                if let name = name, let number = number, name.range(of: number) == nil {
                    combinedString = String(format: "msdkui_maneuver_road_name_divider".localized, number, name)
                } else {
                    combinedString = name
                }

            case (true, false):
                combinedString = name

            case (false, true):
                combinedString = number

            case (false, false): // There is nothing!
                combinedString = nil
            }
        }

        return combinedString
    }

    // MARK: - Private

    /// Returns the next maneuver. Note that when the next maneuver is not found, the specified route is queried to
    /// find the next maneuver as a fallback.
    ///
    /// - Parameter maneuver: The last maneuver known.
    /// - Parameter route: The route to be queried as a fallback or nil if no route is available.
    /// - Returns: The next maneuver or nil.
    private static func getNextManeuver(last maneuver: NMAManeuver?, fallback route: NMARoute?) -> NMAManeuver? {
        // In case the next maneuver from the navigation manager is available and different,
        // return it, else try to find the next maneuver from the fallback route.
        if let nextManeuver = NMANavigationManager.sharedInstance().nextManeuver,
            GuidanceManeuverUtil.areManeuversEqual(maneuver, nextManeuver) == false {
            return nextManeuver
        } else if let route = route {
            return getFollowingManeuver(last: maneuver, from: route)
        } else {
            return nil
        }
    }

    /// Returns the following maneuver relative to the specified maneuver out of the specified route.
    ///
    /// - Parameter maneuver: The last maneuver known.
    /// - Parameter route: The route to be queried as a fallback.
    /// - Returns: The next maneuver or nil.
    private static func getFollowingManeuver(last maneuver: NMAManeuver?, from route: NMARoute) -> NMAManeuver? {
        if let lastManeuver = maneuver, let maneuvers = route.maneuvers {
            if let index = GuidanceManeuverUtil.getIndex(of: lastManeuver, from: maneuvers) {
                if index < maneuvers.count - 1 {
                    return maneuvers[index + 1]
                }
            }
        }

        return nil
    }
}
