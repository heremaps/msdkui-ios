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

final class MapViewportHandlerMock: NSObject {
    @objc private(set) dynamic var didCallSetViewport = false {
        willSet {
            willChangeValue(for: \.didCallSetViewport)
        }
        didSet {
            didChangeValue(for: \.didCallSetViewport)
        }
    }

    private(set) var didCallSetViewportCount = 0
    private(set) var lastMapView: NMAMapView?
    // swiftlint:disable discouraged_optional_collection
    private(set) var lastRoutes: [NMARoute?]?
    private(set) var lastMarkers: [NMAMapMarker?]?
    // swiftlint:enable discouraged_optional_collection
    private(set) var lastAnimation: NMAMapAnimation?
}

// MARK: - MapViewportHandling

extension MapViewportHandlerMock: MapViewportHandling {
    func setViewport(of mapView: NMAMapView, on routes: [NMARoute?], with markers: [NMAMapMarker?], animation: NMAMapAnimation) {
        didCallSetViewport = true
        didCallSetViewportCount += 1

        lastMapView = mapView
        lastRoutes = routes
        lastMarkers = markers
        lastAnimation = animation
    }
}
