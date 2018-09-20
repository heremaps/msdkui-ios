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

/// Wrapper class for a `NMAWaypoint` object and an optional name. When the name is not specified,
/// the `NMAWaypoint` object's coordinates are used to name the entry. Specifying a name can be
/// useful to show, for example, POI names with addresses or hints like "Select Location" or "Home".
open class WaypointEntry: NSObject {
    /// The `NMAWaypoint` object for this entry.
    public var waypoint: NMAWaypoint

    /// The display name of the entry.
    public var name: String

    /// Sets whether the entry is draggable or not.
    public var draggable: Bool = true

    /// Sets whether the entry is removable or not.
    public var removable: Bool = true

    /// A string representation of the entry which is useful for debugging.
    override open var description: String {
        return "<MSDKUI.WaypointEntry: \(Unmanaged.passUnretained(self).toOpaque())" +
            "; name:\"\(name)\"" +
            "; draggable:\(draggable)" +
            "; removable: \(removable)" +
            "; latitude: \(String(format: "%.5f", waypoint.originalPosition.latitude))" +
        "; longitude: \(String(format: "%.5f", waypoint.originalPosition.longitude))>"
    }

    /// Creates a `WaypointEntry` object with a `NMAWaypoint` object and a name.
    ///
    /// - Parameter waypoint: The `NMAWaypoint` object.
    /// - Parameter name: The name for this `NMAWaypoint` object.
    public init(_ waypoint: NMAWaypoint, name: String) {
        self.waypoint = waypoint
        self.name = name
    }

    /// Creates a `WaypointEntry` object with a `NMAWaypoint` object.
    ///
    /// - Parameter waypoint: The `NMAWaypoint` object.
    /// - Important: The name associated with the waypoint is a string representation of its coordinates.
    /// - Important: The latitude and longitude values are rounded to five decimal digits.
    public convenience init(_ waypoint: NMAWaypoint) {
        let waypointLabel = String(format: "%.5f", waypoint.originalPosition.latitude) +
            ", " +
            String(format: "%.5f", waypoint.originalPosition.longitude)

        self.init(waypoint, name: waypointLabel)
    }

    /// Determines if this entry holds a valid `NMAWaypoint` or not. It is valid when its latitude is in the
    /// [-90, 0), (0, +90] range and its longitude is in the [-180, 0), (0, +180] range.
    /// Note that, the default values of the `NMAWaypoint`, latitude = 0 and longitude = 0, are considered as invalid.
    ///
    /// - Returns: True, if the `NMAWaypoint` contains a valid coordinate, false otherwise.
    public func isValid() -> Bool {
        return waypoint.originalPosition.latitude != 0 && waypoint.originalPosition.latitude >= -90 && waypoint.originalPosition.latitude <= 90.0 &&
            waypoint.originalPosition.longitude != 0 && waypoint.originalPosition.longitude >= -180 && waypoint.originalPosition.longitude <= 180
    }
}
