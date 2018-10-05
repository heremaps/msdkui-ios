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

import Foundation
import NMAKit

/// This class provides all the resources for displaying a `NMAManeuver` object.
class ManeuverResources {

    /// Sets the threshold for switching to the next maneuver.
    private static let nextManeuverThreshold = 750

    /// Provides the strings for the maneuvers.
    private static let resourceMap: [AnyHashable: String] = [
        // Actions
        NMAManeuverAction.end: "msdkui_maneuver_arrive_at_02y".localized,
        NMAManeuverAction.enterHighway: "msdkui_maneuver_enter_highway".localized,
        NMAManeuverAction.enterHighwayFromLeft: "msdkui_maneuver_turn_keep_right".localized,
        NMAManeuverAction.enterHighwayFromRight: "msdkui_maneuver_turn_keep_left".localized,
        NMAManeuverAction.leaveHighway: "msdkui_maneuver_leave_highway".localized,
        NMAManeuverAction.uTurn: "msdkui_maneuver_uturn".localized,

        // Turns
        NMAManeuverTurn.heavyLeft: "msdkui_maneuver_turn_sharply_left".localized,
        NMAManeuverTurn.heavyRight: "msdkui_maneuver_turn_sharply_right".localized,
        NMAManeuverTurn.keepLeft: "msdkui_maneuver_turn_keep_left".localized,
        NMAManeuverTurn.keepMiddle: "msdkui_maneuver_turn_keep_middle".localized,
        NMAManeuverTurn.keepRight: "msdkui_maneuver_turn_keep_right".localized,
        NMAManeuverTurn.lightLeft: "msdkui_maneuver_turn_slightly_left".localized,
        NMAManeuverTurn.lightRight: "msdkui_maneuver_turn_slightly_right".localized,
        NMAManeuverTurn.quiteLeft: "msdkui_maneuver_turn_left".localized,
        NMAManeuverTurn.quiteRight: "msdkui_maneuver_turn_right".localized,
        NMAManeuverTurn.roundabout1: "msdkui_maneuver_turn_roundabout_exit_1".localized,
        NMAManeuverTurn.roundabout2: "msdkui_maneuver_turn_roundabout_exit_2".localized,
        NMAManeuverTurn.roundabout3: "msdkui_maneuver_turn_roundabout_exit_3".localized,
        NMAManeuverTurn.roundabout4: "msdkui_maneuver_turn_roundabout_exit_4".localized,
        NMAManeuverTurn.roundabout5: "msdkui_maneuver_turn_roundabout_exit_5".localized,
        NMAManeuverTurn.roundabout6: "msdkui_maneuver_turn_roundabout_exit_6".localized,
        NMAManeuverTurn.roundabout7: "msdkui_maneuver_turn_roundabout_exit_7".localized,
        NMAManeuverTurn.roundabout8: "msdkui_maneuver_turn_roundabout_exit_8".localized,
        NMAManeuverTurn.roundabout9: "msdkui_maneuver_turn_roundabout_exit_9".localized,
        NMAManeuverTurn.roundabout10: "msdkui_maneuver_turn_roundabout_exit_10".localized,
        NMAManeuverTurn.roundabout11: "msdkui_maneuver_turn_roundabout_exit_11".localized,
        NMAManeuverTurn.roundabout12: "msdkui_maneuver_turn_roundabout_exit_12".localized
    ]

    /// The maneuvers to be worked on.
    var maneuvers: [NMAManeuver] = []

    /// Creates a `ManeuverResources` object with the given maneuvers.
    ///
    /// - Parameter maneuvers: The maneuvers to be worked on.
    init(maneuvers: [NMAManeuver]) {
        self.maneuvers = maneuvers
    }

    /// Gets the resource icon name for the indexed maneuver.
    ///
    /// - Parameter index: The index of the maneuver asking its icon name.
    func getManeuverIconName(index: Int) -> String? {
        guard let maneuver = getManeuverAt(index: index) else {
            return nil
        }

        if maneuver.action == NMAManeuverAction.ferry && isRailFerryManeuver(maneuver: maneuver) {
            return "maneuver_icon_motorail"
        }

        return getManeuverIconName(icon: maneuver.icon)
    }

    /// Gets the maneuver instruction for the indexed maneuver.
    ///
    /// - Parameter index: The index of the maneuver asking its instruction.
    func getManeuverInstruction(index: Int) -> String {
        guard let maneuver = getManeuverAt(index: index) else {
            return ""
        }
        guard let instruction = getInstruction(maneuver: maneuver), !instruction.isEmpty else {
            return String(format: "msdkui_maneuver_head_to".localized,
                          getLocalizedOrientation(angleInDegrees: maneuver.mapOrientation))
        }
        return instruction
    }

    /// Gets the distance of given maneuver from the previous NMAManeuver.
    ///
    /// - Parameter index: index of maneuver to find out distance from its previous maneuver.
    func getDistance(index: Int) -> Int {
        guard let nextManeuver = getManeuverAt(index: index + 1) else {
            return 0
        }
        return Int(nextManeuver.distanceFromPreviousManeuver)
    }

    /// Gets the road name for the indexed maneuver.
    ///
    /// - Parameter index: index of maneuver to find out roadname for.
    func getRoadToDisplay(index: Int) -> String? {
        guard let maneuver = getManeuverAt(index: index) else {
            return nil
        }

        let exitDir = getExitDirections(maneuver: maneuver)
        if let exitDir = exitDir {
            return String(format: "msdkui_maneuver_exit_directions_towards".localized, getRoadName(index: index), exitDir)
        }
        return getRoadName(index: index)
    }

    /// Gets the exit direction for for the given maneuver.
    ///
    /// - Parameter maneuver: The maneuver to find out roadname for.
    func getExitDirections(maneuver: NMAManeuver) -> String? {
        let signpost = maneuver.signpost
        guard let post = signpost else {
            return nil
        }

        var exitDirectionsText: String?
        for localizedLabel in post.exitDirections {
            if let text = localizedLabel.text, !text.isEmpty {
                exitDirectionsText = exitDirectionsText == nil ? text : String(format: "msdkui_maneuver_road_name_divider".localized, exitDirectionsText!, text)
            }
        }

        return exitDirectionsText
    }

    /// Gets the resource icon name for the given NMAManeuverIcon.
    ///
    /// - Parameter icon: The icon asking its icon name.
    private func getManeuverIconName(icon: NMAManeuverIcon) -> String? {
        if icon == .passStation {
            return nil
        }

        return "maneuver_icon_\(icon.rawValue)"
    }

    /// Gets if given NMAManeuver has NMARoadElementAttribute.railFerry attribute.
    private func isRailFerryManeuver(maneuver: NMAManeuver) -> Bool {
        if let routeElement = maneuver.routeElements.first, let roadElement = routeElement.roadElement {
            return roadElement.attributes & NMARoadElementAttribute.railFerry.rawValue > 0
        }

        return false
    }

    /// Gets instruction for the given maneuver from the resource map.
    ///
    /// - Parameter maneuver: The maneuver asking its instruction.
    private func getInstruction(maneuver: NMAManeuver) -> String? {
        switch maneuver.action {
        case .changeHighway:
            return getHighwayInstructions(turn: maneuver.turn)
        case .continueHighway:
            return getHighwayInstructions(turn: maneuver.turn)
        case .ferry:
            return isRailFerryManeuver(maneuver: maneuver) ?
                "msdkui_maneuver_enter_car_shuttle_train".localized : "msdkui_maneuver_enter_ferry".localized
        case .junction:
            return ManeuverResources.resourceMap[maneuver.turn]
        case .roundabout:
            return ManeuverResources.resourceMap[maneuver.turn]
        default:
            return ManeuverResources.resourceMap[maneuver.action]
        }
    }

    /// Gets the highway instructions for the given NMAManeuverTurn.
    ///
    /// - Parameter turn: The turn asking its instruction.
    private func getHighwayInstructions(turn: NMAManeuverTurn) -> String? {
        if turn == .keepLeft || turn == .keepMiddle || turn == .keepRight {
            return ManeuverResources.resourceMap[turn]
        }
        return "msdkui_maneuver_continue".localized
    }

    /// Gets the localized orientation.
    ///
    /// - Parameter angleInDegrees: The orientation angle.
    /// - Important: If unable to assign the angle to a string, returns an empty string.
    private func getLocalizedOrientation(angleInDegrees: UInt) -> String {
        let ids = [
            "msdkui_maneuver_orientation_north",
            "msdkui_maneuver_orientation_north_east",
            "msdkui_maneuver_orientation_east",
            "msdkui_maneuver_orientation_south_east",
            "msdkui_maneuver_orientation_south",
            "msdkui_maneuver_orientation_south_west",
            "msdkui_maneuver_orientation_west",
            "msdkui_maneuver_orientation_north_west"
        ]
        let index = Int(((angleInDegrees + 45 / 2) % 360) / 45)
        if ids.indices.contains(index) {
            return ids[index].localized
        } else {
            return ""
        }
    }

    /// Gets the road name for the indexed maneuver.
    ///
    /// - Parameter index: index of maneuver to find out it's roadname.
    private func getRoadName(index: Int) -> String {
        guard let currentManeuver = getManeuverAt(index: index) else {
            return ""
        }
        var roadName: String? = currentManeuver.roadName as String?
        var roadNumber: String? = currentManeuver.roadNumber as String?
        if isManeuverChangingRoad(maneuver: currentManeuver) || index == 0 {
            roadName = currentManeuver.nextRoadName as String?
            roadNumber = currentManeuver.nextRoadNumber as String?
        }
        var formattedRoad = format(roadName: roadName, roadNumber: roadNumber)
        // use the solution from Guidance for slip roads
        if formattedRoad.isEmpty, let nextStreet = determineNextManeuverStreet(index: index) {
            formattedRoad = nextStreet
        }
        return formattedRoad
    }

    /// Gets the next maneuver street name for the indexed maneuver.
    ///
    /// - Parameter index: index of maneuver to find out next maneuver street name.
    private func determineNextManeuverStreet(index: Int) -> String? {
        var distance: Int = 0
        var newIndex = index + 1
        var nextManeuverStreetValue: String?
        var afterNextManeuver = getManeuverAt(index: newIndex)
        while distance < ManeuverResources.nextManeuverThreshold &&
            afterNextManeuver != nil && nextManeuverStreetValue == nil {
                distance += Int((afterNextManeuver?.distanceFromPreviousManeuver)!)
                nextManeuverStreetValue = format(roadName: afterNextManeuver?.nextRoadName as String?, roadNumber: afterNextManeuver?.nextRoadNumber as String?)
                newIndex += 1
                afterNextManeuver = getManeuverAt(index: newIndex)
        }

        return nextManeuverStreetValue
    }

    /// Gets the maneuver for the indexed maneuver.r.
    ///
    /// - Parameter index: index of maneuver.
    private func getManeuverAt(index: Int) -> NMAManeuver? {
        guard maneuvers.indices.contains(index) else {
            return nil
        }

        return maneuvers[index]
    }

    /// Formats road and number in the "number / name" pattern.
    private func format(roadName: String?, roadNumber: String?) -> String {
        if let number = roadNumber, !number.isEmpty, let name = roadName, !name.isEmpty {
            return String(format: "msdkui_maneuver_road_name_divider".localized, number, name)
        } else if let number = roadNumber, !number.isEmpty {
            return number
        } else if let name = roadName, !name.isEmpty {
            return name
        } else {
            return ""
        }
    }

    /// Gets if given maneuver is for changing the road.
    ///
    /// - Parameter maneuver: The maneuver to find out it is for changing road or not.
    private func isManeuverChangingRoad(maneuver: NMAManeuver) -> Bool {
        return maneuver.action == NMAManeuverAction.junction || maneuver.action == NMAManeuverAction.roundabout
    }
}
