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

/// This protocol is introduced to make testing `NMAMapRoute` handling methods easier.
protocol MapRouteHandling: AnyObject {
    /// Makes a map route ot of the given route.
    ///
    /// - Parameter route: The route to be used.
    /// - Returns: An `NMAMapRoute` object or nil.
    func makeMapRoute(with route: NMARoute) -> NMAMapRoute?

    /// Adds the given map route to the given map view.
    ///
    /// - Parameters:
    ///   - mapRoute: The map route to be added.
    ///   - mapView: The target map view.
    func add(_ mapRoute: NMAMapRoute, to mapView: NMAMapView)

    /// Removes the given map route from the given map view.
    ///
    /// - Parameters:
    ///   - mapRoute: The map route to be removed.
    ///   - mapView: The target map view.
    func remove(_ mapRoute: NMAMapRoute, from mapView: NMAMapView)
}

class MapRouteHandler: MapRouteHandling {
    func makeMapRoute(with route: NMARoute) -> NMAMapRoute? {
        NMAMapRoute(route)
    }

    func add(_ mapRoute: NMAMapRoute, to mapView: NMAMapView) {
        mapView.add(mapObject: mapRoute)
    }

    func remove(_ mapRoute: NMAMapRoute, from mapView: NMAMapView) {
        mapView.remove(mapObject: mapRoute)
    }
}
