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

import NMAKit

/// Extension for `NMAManeuver`.
public extension NMAManeuver {

    /// Gets the current street. In case the current street is not found, the current signpost is used.
    ///
    /// - Returns: The current street name or nil when it is not available.
    @objc func getCurrentStreet() -> String? {
        GuidanceManeuverUtil.getCurrentStreet(from: self)
    }

    /// Gets the next street name. In case the next street is not found, the next maneuvers
    /// coming after are checked and when the next street is still not found, as a fallback,
    /// the maneuvers in the route are checked.
    ///
    /// - Parameter route: The route whose maneuvers will be checked as a fallback or nil when is not available.
    /// - Returns: The next street name or nil when it is not available.
    @objc func getNextStreet(fallback route: NMARoute?) -> String? {
        var nextStreet = GuidanceManeuverUtil.combineStrings(maneuver: self,
                                                             name: nextRoadNames()?.first as String?,
                                                             number: nextRoadNumber as String?)

        if nextStreet.hasContent == false {
            nextStreet = GuidanceManeuverUtil.getNextStreet(from: self, fallback: route)
        }

        if nextStreet.hasContent == false {
            nextStreet = GuidanceManeuverUtil.combineStrings(maneuver: self,
                                                             name: roadNames()?.first as String?,
                                                             number: roadNumber as String?)
        }

        if nextStreet.hasContent == false {
            if let signpost = signpost, signpost.exitText.hasContent == true {
                nextStreet = signpost.exitText
            }
        }

        return nextStreet
    }

    /// Gets the signpost exit number.
    ///
    /// - Returns: The exit number string from the signpost or nil when it is not available.
    @objc func getSignpostExitNumber() -> String? {
        if let signpost = signpost, signpost.exitNumber.hasContent, let signpostExitNumber = signpost.exitNumber {
            return String(format: "msdkui_maneuver_exit".localized, signpostExitNumber)
        }

        return nil
    }

    /// Returns a string from the maneuver's signpost.
    ///
    /// - Returns: The string from the maneuver signpost or nil when it is not available.
    @objc func getStringFromSignpost() -> String? {
        if let signpost = signpost {
            if signpost.exitDirections.isEmpty == false && signpost.exitDirections[0].text.hasContent == true {
                return signpost.exitDirections[0].text
            }

            // Try the signpost exit text.
            if signpost.exitText.hasContent == true {
                return signpost.exitText
            }
        }

        return nil
    }

    /// Gets the internal resource icon file name.
    ///
    /// - Returns: The icon name.
    @objc func getIconFileName() -> String? {
        if action == .ferry && isRailFerryManeuver {
            return "maneuver_icon_motorail"
        }

        if icon == .passStation {
            return nil
        }

        return "maneuver_icon_\(icon.rawValue)"
    }
}

extension NMAManeuver {

    /// The localized orientation string.
    /// - Note: If unable to assign the angle to a string, returns an empty string.
    var orientationString: String {
        // Convert `mapOrientation` to an index.
        let index = Int(((mapOrientation + 45 / 2) % 360) / 45)

        if NMAManeuver.localizedOrientations.indices.contains(index) {
            return NMAManeuver.localizedOrientations[index]
        } else {
            return ""
        }
    }

    /// Gets instruction for the given maneuver from the resource map.
    var instructionString: String? {
        switch action {
        case .changeHighway, .continueHighway:
            return highwayInstructionString

        case .ferry:
            return isRailFerryManeuver ?
                "msdkui_maneuver_enter_car_shuttle_train".localized : "msdkui_maneuver_enter_ferry".localized

        case .junction:
            return NMAManeuver.localizedInstructions[turn]

        case .roundabout:
            return NMAManeuver.localizedInstructions[turn]

        default:
            return NMAManeuver.localizedInstructions[action]
        }
    }

    /// A Boolean value that determines whether the maneuver indicates a junction or a roundabout.
    var isChangingRoad: Bool {
        action == NMAManeuverAction.junction || action == NMAManeuverAction.roundabout
    }
}

private extension NMAManeuver {

    /// Provides the localized intsruction strings.
    static let localizedInstructions: [AnyHashable: String] = [
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

    /// All the localized orientation strings.
    static let localizedOrientations = [
        "msdkui_maneuver_orientation_north".localized,
        "msdkui_maneuver_orientation_north_east".localized,
        "msdkui_maneuver_orientation_east".localized,
        "msdkui_maneuver_orientation_south_east".localized,
        "msdkui_maneuver_orientation_south".localized,
        "msdkui_maneuver_orientation_south_west".localized,
        "msdkui_maneuver_orientation_west".localized,
        "msdkui_maneuver_orientation_north_west".localized
    ]

    /// The maneuver's highway instruction.
    var highwayInstructionString: String {
        if turn == .keepLeft || turn == .keepMiddle || turn == .keepRight {
            return NMAManeuver.localizedInstructions[turn] ?? ""
        }

        return "msdkui_maneuver_continue".localized
    }

    /// A Boolean value that determines whether the maneuver has `NMARoadElementAttribute.railFerry`
    /// attribute.
    var isRailFerryManeuver: Bool {
        if let routeElement = routeElements.first, let roadElement = routeElement.roadElement {
            return roadElement.attributes & NMARoadElementAttribute.railFerry.rawValue > 0
        }

        return false
    }
}
