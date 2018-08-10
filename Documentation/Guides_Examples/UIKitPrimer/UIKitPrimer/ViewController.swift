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

import UIKit
import NMAKit
import MSDKUI

/// Shows example usage of WaypointList and TransportModePanel. A Map is added to show how the calulcated
/// route is affected by interacting with these components.
class ViewController: UIViewController, WaypointListDelegate {

    @IBOutlet weak var waypointList: WaypointList!
    @IBOutlet weak var transportModePanel: TransportModePanel!
    @IBOutlet weak var mapView: NMAMapView!

    var routingMode = NMARoutingMode()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("MSDK UI Kit version: \(Version.getString())")

        navigationController?.navigationBar.topItem?.title = "UI Kit Primer"

        let startWaypoint = WaypointEntry(NMAWaypoint(
            geoCoordinates: NMAGeoCoordinates(latitude: 52.53852, longitude: 13.42506)))
        let stopoverWaypoint1 = WaypointEntry(NMAWaypoint(
            geoCoordinates: NMAGeoCoordinates(latitude: 52.33852, longitude: 13.22506)))
        let stopoverWaypoint2 = WaypointEntry(NMAWaypoint(
            geoCoordinates: NMAGeoCoordinates(latitude: 52.43852, longitude: 13.12506)))
        let destinationWaypoint = WaypointEntry(NMAWaypoint(
            geoCoordinates: NMAGeoCoordinates(latitude: 52.37085, longitude: 13.27242)))

        waypointList.waypointEntries = [startWaypoint, stopoverWaypoint1, stopoverWaypoint2, destinationWaypoint]
        waypointList.listDelegate = self

        // Use styles to provide visual feedback when a waypoint is selected
        Styles.shared.waypointListFlashColor = .lightGray
        Styles.shared.waypointListFlashDurationSeconds = 0.1

        transportModePanel.onModeChanged = onTransportModeChanged
        transportModePanel.transportModes = [.bike, .pedestrian, .truck, .car]
        transportModePanel.transportMode = .car

        routingMode.resultLimit = 5
        calculateRoutes()
    }

    // MARK: WaypointListDelegate

    func entrySelected(_ list: MSDKUI.WaypointList, index: Int, entry: MSDKUI.WaypointEntry) {
        print("entrySelected")
        // zoom from route overview to waypoint
        mapView.zoomLevel = 14
        mapView.set(geoCenter: entry.waypoint.originalPosition, animation: NMAMapAnimation.bow)
    }

    func entryRemoved(_ list: MSDKUI.WaypointList, index: Int, entry: MSDKUI.WaypointEntry) {
        print("entryRemoved")
        calculateRoutes()
    }

    func entryDragged(_ list: MSDKUI.WaypointList, from: Int, to: Int) {
        print("entryDragged")
        calculateRoutes()
    }

    // MARK: TransportModePanel callback

    func onTransportModeChanged(_ mode: NMATransportMode) {
        print("onModeChanged called: new mode: \(mode.rawValue)")
        routingMode.transportMode = mode
        calculateRoutes()
    }

    // MARK: Route calculation

    func calculateRoutes() {
        let myWaypoints = waypointList.waypoints
        RouteHelper.sharedInstance.onRoutesCalculated = onRoutesCalculated
        RouteHelper.sharedInstance.calculateRoute(waypoints: myWaypoints, routingMode: routingMode)
    }

    func onRoutesCalculated(routes: [NMARoute]?) {
        // for demo purposes, only show first route
        RouteHelper.sharedInstance.showRoute(mapView: mapView, route: routes?[0])
    }
}
