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
import UIKit

/// This protocol exposes handling methods of a `NMAMapView` viewport.
protocol MapViewportHandling {
    /// Sets the viewport of a map view to encompass all visual elements passed as arguments.
    ///
    /// - Parameters:
    ///   - mapView: map view that will have it's viewport set.
    ///   - routes: routes to be displeyed fully.
    ///   - markers: markers to be displayed fully.
    ///   - animation: animation used for transitioning to target viewport.
    func setViewport(of mapView: NMAMapView, on routes: [NMARoute?], with markers: [NMAMapMarker?], animation: NMAMapAnimation)
}

/// Map viewport handler class with default behavior.
class MapViewportHandler: MapViewportHandling {
    /// Sets the viewport of a map view to encompass all visual elements passed as arguments.
    ///
    /// - Parameters:
    ///   - mapView: map view that will have it's viewport set.
    ///   - routes: routes to be displeyed fully.
    ///   - markers: markers to be displayed fully.
    ///   - animation: animation used for transitioning to target viewport.
    func setViewport(of mapView: NMAMapView, on routes: [NMARoute?], with markers: [NMAMapMarker?], animation: NMAMapAnimation) {
        // Gather bounding boxes
        var boundingBoxes = routes.compactMap { $0?.boundingBox }
        let markers = markers.compactMap { $0 }

        if
            let markersCoordinatesBoundingBox = NMAGeoBoundingBox(coordinates: markers.map { $0.coordinates }),
            !markersCoordinatesBoundingBox.isEmpty() {
            boundingBoxes.append(markersCoordinatesBoundingBox)
        }

        // Guard against empty bounding box
        guard
            let intersectionBoundingBox = NMAGeoBoundingBox(boundingBoxes: boundingBoxes),
            !intersectionBoundingBox.isEmpty() else {
            return
        }

        // Calculate map insets
        let boundsInsetByAnchorFrames = mapView.bounds.inset(by: markers.iconsInsets)

        // Set inset bounding box
        mapView.set(boundingBox: intersectionBoundingBox, inside: boundsInsetByAnchorFrames, animation: animation)
    }
}
