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

import UIKit
import NMAKit
import MSDKUI

/// Shows a programmatically added WaypointList where each waypoint has a custom name. Usually
/// this can be used to show reverse geocoded addresses. Here we show the traditional
/// "Hello World" message instead.
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let waypointList = WaypointList(frame: view.bounds)
        view.addSubview(waypointList)

        let waypoint = NMAWaypoint(geoCoordinates: NMAGeoCoordinates(latitude: 52, longitude: 13))
        let startWaypointEntry = WaypointEntry(waypoint)
        let stopoverWaypointEntry = WaypointEntry(waypoint)
        let destinationWaypointEntry = WaypointEntry(waypoint)

        startWaypointEntry.name = "Hello HERE"
        stopoverWaypointEntry.name = "Mobile SDK"
        destinationWaypointEntry.name = "UI Kit!"

        waypointList.waypointEntries = [startWaypointEntry,
                                        stopoverWaypointEntry,
                                        destinationWaypointEntry]

        waypointList.itemTextColor = UIColor(red: 1.0, green: 0.77, blue: 0.11, alpha: 1.0)
    }
}
