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

/// This struct holds all the data about a maneuver to be displayed on a `GuidanceManeuverPanel` object. Note
/// that it conforms to the `Equatable` and `CustomStringConvertible` protocols.
public struct GuidanceManeuverData {
    /// The maneuver icon of the next maneuver.
    var maneuverIcon: String?

    /// The distance to the next maneuver.
    var distance: String?

    /// The info1 string which is mostly the next maneuver street.
    var info1: String?

    /// The info2 string which is mostly the highway related information.
    var info2: String?

    /// The next road icon for this maneuver.
    var nextRoadIcon: UIImage?
}

// MARK: - Equatable

extension GuidanceManeuverData: Equatable {
    public static func == (lhs: GuidanceManeuverData, rhs: GuidanceManeuverData) -> Bool {
        return lhs.maneuverIcon == rhs.maneuverIcon &&
            lhs.distance == rhs.distance &&
            lhs.info1 == rhs.info1 &&
            lhs.info2 == rhs.info2 &&
            lhs.nextRoadIcon == rhs.nextRoadIcon
    }
}

// MARK: - CustomStringConvertible

extension GuidanceManeuverData: CustomStringConvertible {
    public var description: String {
        return "maneuverIcon: \(maneuverIcon ?? "nil"), distance: \(distance ?? "nil"), info1: \(info1 ?? "nil"), info2: \(info2 ?? "nil")"
    }
}
