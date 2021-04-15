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


/// Convenience class that does not contain any MSDK UI Kit related code.
class RouteHelper {

    static let sharedInstance = RouteHelper()

    private var corerouter: NMACoreRouter!
    private var currentMapRoute: NMAMapRoute?
    var lastCalculatedRoutes: [NMARoute]?
    var selectedRoute: NMARoute?

    // Called when route calculation is done
    var onRoutesCalculated: (([NMARoute]?) -> Void)?

    private init() {
        corerouter = NMACoreRouter()
    }

    func calculateRoute(waypoints: [NMAWaypoint], routingMode: NMARoutingMode) {
        corerouter.calculateRoute(withStops: waypoints, routingMode: routingMode) { routeResult, error in
            if error != NMARoutingError.none {
                print("Routing Error: \(error.rawValue)")
            }

            self.lastCalculatedRoutes = routeResult?.routes
            self.onRoutesCalculated?(self.lastCalculatedRoutes)

            let length = self.lastCalculatedRoutes?.count
            print("Calculated \(String(describing: length)) routes.")
        }
    }

    func showRoute(mapView: NMAMapView, route: NMARoute?) {
        guard let route = route else {
            print("Route is nil, nothing to show.")
            return
        }

        // remove old route, if any
        if let currentMapRoute = currentMapRoute {
            mapView.remove(mapObject: currentMapRoute)
        }

        currentMapRoute = NMAMapRoute(route)

        // zoom map to show entire route
        if let currentMapRoute = currentMapRoute, let boundingBox = route.boundingBox {
            mapView.add(mapObject: currentMapRoute)
            mapView.set(boundingBox: boundingBox, animation: NMAMapAnimation.bow)
        }
    }
}
