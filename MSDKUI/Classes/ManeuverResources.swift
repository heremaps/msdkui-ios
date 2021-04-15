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

/// This class provides all the resources for displaying a `NMAManeuver` object.
class ManeuverResources {

    // MARK: - Properties

    /// Sets the threshold for switching to the next maneuver.
    private static let nextManeuverThreshold = 750

    /// The maneuvers to be worked on.
    private var maneuvers: [NMAManeuver] = []

    // MARK: - Public

    /// Creates a `ManeuverResources` object with the given maneuvers.
    ///
    /// - Parameter maneuvers: The maneuvers to be worked on.
    init(maneuvers: [NMAManeuver]) {
        self.maneuvers = maneuvers
    }

    /// Gets the resource icon name for an indexed maneuver.
    ///
    /// - Parameter index: The index of a maneuver asking its icon name.
    /// - Returns: The icon name assigned to the maneuver.
    func getIconFileName(for index: Int) -> String? {
        guard let maneuver = getManeuver(at: index) else {
            return nil
        }

        return maneuver.getIconFileName()
    }

    /// Gets the maneuver instruction for an indexed maneuver.
    ///
    /// - Parameter index: The index of a maneuver asking its instruction.
    /// - Returns: The maneuver instruction.
    func getInstruction(for index: Int) -> String? {
        guard let maneuver = getManeuver(at: index) else {
            return nil
        }

        let instructionString = maneuver.instructionString

        if instructionString.hasContent {
            return instructionString
        } else {
            return String(format: "msdkui_maneuver_head_to".localized, maneuver.orientationString)
        }
    }

    /// Gets the distance of a given maneuver from the previous maneuver.
    ///
    /// - Parameter index: The index of a maneuver asking its distance from the previous maneuver.
    /// - Returns: The maneuver's `NMAManeuver.distanceFromPreviousManeuver` property.
    /// - Important: When the indexed maneuver is not found, returns zero.
    func getDistance(for index: Int) -> Int {
        guard let nextManeuver = getManeuver(at: index + 1) else {
            return 0
        }

        return Int(nextManeuver.distanceFromPreviousManeuver)
    }

    /// Gets the road name for the indexed maneuver.
    ///
    /// - Parameter index: The index of maneuver asking its road name.
    /// - Returns: The maneuver road name.
    /// - Important: When the indexed maneuver is not found, returns nil.
    func getRoadName(for index: Int) -> String? {
        guard let maneuver = getManeuver(at: index) else {
            return nil
        }

        let roadName = getRoadName(maneuver: maneuver, index: index)

        if let exitDir = getExitDirection(maneuver: maneuver), let roadName = roadName {
            return String(format: "msdkui_maneuver_exit_directions_towards".localized, roadName, exitDir)
        }

        return roadName
    }

    // MARK: - Private

    /// Gets the maneuver corresponding to the given index.
    ///
    /// - Parameter index: The index of maneuver.
    /// - Returns: The indexed maneuver.
    private func getManeuver(at index: Int) -> NMAManeuver? {
        guard maneuvers.indices.contains(index) else {
            return nil
        }

        return maneuvers[index]
    }

    /// Gets the exit direction for the given maneuver. Note that all the available exit direction
    /// data is combined.
    ///
    /// - Parameter maneuver: The maneuver asking for its exit direction.
    /// - Returns: A string combining all the exit direction data or nil.
    /// - Important: The exit data direction data are combined with the "msdkui_maneuver_road_name_divider".localized string.
    private func getExitDirection(maneuver: NMAManeuver) -> String? {
        guard let signpost = maneuver.signpost else {
            return nil
        }

        var exitDirection: String?

        for signpostExitDirection in signpost.exitDirections {
            if let signpostExitDirectionText = signpostExitDirection.text, !signpostExitDirectionText.isEmpty {
                if let currentExitDirection = exitDirection {
                    exitDirection = String(format: "msdkui_maneuver_road_name_divider".localized, currentExitDirection, signpostExitDirectionText)
                } else {
                    exitDirection = signpostExitDirectionText
                }
            }
        }

        return exitDirection
    }

    /// Gets the road name for the indexed maneuver.
    ///
    /// - Parameter index: The index of a maneuver.
    /// - Returns: The road name for the indexed maneuver.
    private func getRoadName(maneuver: NMAManeuver, index: Int) -> String? {
        var roadName = maneuver.roadNames()?.first as String?
        var roadNumber = maneuver.roadNumber as String?

        if maneuver.isChangingRoad || index == 0 {
            roadName = maneuver.nextRoadNames()?.first as String?
            roadNumber = maneuver.nextRoadNumber as String?
        }

        let data = GuidanceManeuverUtil.combineStrings(maneuver: maneuver,
                                                       name: roadName,
                                                       number: roadNumber)

        if data.hasContent {
            return data
        } else {
            return getNextManeuverStreet(index: index)
        }
    }

    /// Gets the next maneuver street name for an indexed maneuver.
    ///
    /// - Parameter index: The index of a maneuver.
    /// - Returns: The next maneuver street name.
    private func getNextManeuverStreet(index: Int) -> String? {
        var distance: Int = 0
        var newIndex = index + 1
        var nextManeuverStreetValue: String?
        var afterNextManeuver = getManeuver(at: newIndex)

        while distance < ManeuverResources.nextManeuverThreshold && afterNextManeuver != nil && nextManeuverStreetValue == nil {
            if let distanceFromPreviousManeuver = afterNextManeuver?.distanceFromPreviousManeuver {
                distance += Int(clamping: distanceFromPreviousManeuver)
            }

            nextManeuverStreetValue = GuidanceManeuverUtil.combineStrings(maneuver: afterNextManeuver,
                                                                          name: afterNextManeuver?.nextRoadNames()?.first as String?,
                                                                          number: afterNextManeuver?.nextRoadNumber as String?)
            newIndex += 1
            afterNextManeuver = getManeuver(at: newIndex)
        }

        return nextManeuverStreetValue
    }
}
