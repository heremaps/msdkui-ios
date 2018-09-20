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

@testable import MSDKUI
import NMAKit

enum WaypointEntryFixture {
    static func berlin() -> WaypointEntry {
        return makeWaypoint(name: "Berlin", latitude: 52.530555, longitude: 13.379257)
    }

    static func frankfurt() -> WaypointEntry {
        return makeWaypoint(name: "Frankfurt", latitude: 50.110922, longitude: 8.682127)
    }

    static func berlinNaturekundemuseum() -> WaypointEntry {
        return makeWaypoint(name: "Naturekundemuseum, Berlin", latitude: 52.530555, longitude: 13.379257)
    }

    static func berlinReichstag() -> WaypointEntry {
        return makeWaypoint(name: "Reichstag, Berlin", latitude: 52.518620, longitude: 13.376187)
    }

    static func berlinBranderburgerTor() -> WaypointEntry {
        return makeWaypoint(name: "Branderburger Tor, Berlin", latitude: 52.516275, longitude: 13.377704)
    }

    static func berlinFernsehturm() -> WaypointEntry {
        return makeWaypoint(name: "Fernsehturm, Berlin", latitude: 52.520815, longitude: 13.4094195)
    }

    static func berlinAlexanderplatz() -> WaypointEntry {
        return makeWaypoint(name: "Alexanderplatz, Berlin", latitude: 52.521918, longitude: 13.413215)
    }

    static func berlinZoologischerGarten() -> WaypointEntry {
        return makeWaypoint(name: "Zoologischer Garten, Berlin", latitude: 52.507920, longitude: 13.337755)
    }

    static func empty() -> WaypointEntry {
        return WaypointEntry(NMAWaypoint(), name: "Without coordinates")
    }

    static func makeWaypoint(name: String, latitude: Double, longitude: Double) -> WaypointEntry {
        let coordinates = NMAGeoCoordinates(latitude: latitude, longitude: longitude)
        let waypoint = NMAWaypoint(geoCoordinates: coordinates)
        return WaypointEntry(waypoint, name: name)
    }
}
