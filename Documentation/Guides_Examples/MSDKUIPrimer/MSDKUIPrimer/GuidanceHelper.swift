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
class GuidanceHelper {

    static let sharedInstance = GuidanceHelper()

    private init() {
        // no public constructor, this is a Singleton
    }

    func startGuidanceSimulation(route: NMARoute, mapView: NMAMapView) {
        // Configure the map
        let mapRoute = NMAMapRoute(route)
        mapView.add(mapObject: mapRoute!)
        mapView.set(boundingBox: route.boundingBox!, animation: .linear)
        mapView.landmarksVisible = true
        mapView.positionIndicator.isVisible = true

        // Place the indicator at the bottom map area
        mapView.transformCenter = CGPoint(x: 0.5, y: 0.85)
        mapView.mapCenterFixedOnRotateZoom = true

        // Configure the navigation manager
        NMANavigationManager.sharedInstance().map = mapView
        NMANavigationManager.sharedInstance().mapTrackingTilt = .tilt3D
        NMANavigationManager.sharedInstance().voicePackageMeasurementSystem = .metric
        NMANavigationManager.sharedInstance().mapTrackingEnabled = true
        NMANavigationManager.sharedInstance().realisticViewMode = .day

        // Prepare simulated guidance
        NMAPositioningManager.sharedInstance().stopPositioning()
        let routeSource = NMARoutePositionSource(route: route)
        routeSource.movementSpeed = 50.0 // 50m/s
        NMAPositioningManager.sharedInstance().dataSource = routeSource
        NMAPositioningManager.sharedInstance().startPositioning()

        // Start guidance
        NMANavigationManager.sharedInstance().startTurnByTurnNavigation(route)
    }

    func stopGuidance() {
        NMANavigationManager.sharedInstance().stop()
        NMAPositioningManager.sharedInstance().stopPositioning()
        NMAPositioningManager.sharedInstance().dataSource = nil
        NMAPositioningManager.sharedInstance().startPositioning()
    }
}
