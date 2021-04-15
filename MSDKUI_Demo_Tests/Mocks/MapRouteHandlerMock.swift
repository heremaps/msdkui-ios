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

@testable import MSDKUI_Demo
import NMAKit

final class MapRouteHandlerMock {
    private(set) var didCallMakeMapRoute = false
    private(set) var didCallAddMapRouteToMapView = false
    private(set) var didCallAddMapRouteToMapViewCount = 0
    private(set) var didCallRemoveMapRouteToMapView = false

    private(set) var lastRoute: NMARoute?
    private(set) var lastMapRoute: NMAMapRoute?
    private(set) var lastMapView: NMAMapView?

    // Properties used for stubbing the mock object
    private(set) var stubbedMapRoute: NMAMapRoute?
}

// MARK: - MapRouteHandling

extension MapRouteHandlerMock: MapRouteHandling {
    func makeMapRoute(with route: NMARoute) -> NMAMapRoute? {
        didCallMakeMapRoute = true
        lastRoute = route
        return stubbedMapRoute
    }

    func add(_ mapRoute: NMAMapRoute, to mapView: NMAMapView) {
        didCallAddMapRouteToMapView = true
        didCallAddMapRouteToMapViewCount += 1
        lastMapRoute = mapRoute
        lastMapView = mapView
    }

    func remove(_ mapRoute: NMAMapRoute, from mapView: NMAMapView) {
        didCallRemoveMapRouteToMapView = true
        lastMapRoute = mapRoute
        lastMapView = mapView
    }
}

// MARK: - Stub

extension MapRouteHandlerMock {
    func stubMapRoute(toReturn value: NMAMapRoute?) {
        stubbedMapRoute = value
    }
}
