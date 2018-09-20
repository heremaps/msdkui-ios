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

import EarlGrey
import Foundation
@testable import MSDKUI
import NMAKit

enum MapActions {
    /// Used to save the `NMAMapView` boundingBox property.
    static var boundingBox: NMAGeoBoundingBox?

    /// Saves the bounding box of the map view to the `boundingBox` property.
    static func saveMapViewBoundingBox() {
        // EarlGrey doesn't support inout variables!
        EarlGrey.selectElement(with: RouteplannerView.routeOverviewMapView).perform(
            GREYActionBlock.action(withName: "saveMapViewBoundingBox") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let mapView = element as! NMAMapView
                self.boundingBox = mapView.boundingBox

                // Dump the center
                if let center = self.boundingBox?.center {
                    let boundingBoxCenter = String(format: "%.5f", center.latitude) +
                        ", " +
                        String(format: "%.9f", center.longitude)

                    print("MapView boundingBox center: \(boundingBoxCenter)")
                } else {
                    print("MapView boundingBox center not known!")
                }

                return true
            }
        )
    }

    /// After some kind of actions, we want to make sure the map is updated, i.e. has a new bounding box.
    /// This method makes sure that the map view has a new bounding box relative to the passed one.
    ///
    /// - Parameter existingBoundingBox: The last known map bounding box.
    /// - Important: If there is a timeout or no bounding box update, this method throws an
    ///              assertion failure.
    static func mustHaveNewBoundingBox(existingBoundingBox: NMAGeoBoundingBox?) {
        let newBoundingBox = GREYCondition(name: "Wait for a new bounding box") {
            MapActions.saveMapViewBoundingBox()

            // Do we know the bounding box centers?
            guard let existingBoundingBoxCenter = existingBoundingBox?.center,
                let newBoundingBoxCenter = MapActions.boundingBox?.center else {
                    return false
            }

            // Make sure they are different
            return existingBoundingBoxCenter.latitude != newBoundingBoxCenter.latitude &&
                existingBoundingBoxCenter.longitude != newBoundingBoxCenter.longitude
        }.wait(withTimeout: Constans.mediumWait, pollInterval: Constans.mediumPollInterval)
        GREYAssertTrue(newBoundingBox, reason: "Failed to update the bounding box!")
    }

    /// Taps on the map and verifies destination selection based on map desination label
    ///
    /// - Parameter tapType: "long" or "short" making the map tap long or short
    /// - Parameter screenPoint: Point on the map to tap
    static func mustHaveDestinationSelected(with gesture: CoreActions.Gestures, screenPoint: CGPoint = CGPoint(x: 110.0, y: 110.0)) {
        // Drive navigation and map view is shown.
        verifyWaypointMapViewWithNoDestinationIsVisible()

        // Longtap anywhere on the map
        // Tap anywhere on the map
        switch gesture {
        case .tap:
            CoreActions.tap(element: MapView.waypointMapView, point: screenPoint)
        case .longPress:
            CoreActions.longPress(element: MapView.waypointMapView, point: screenPoint)
        }

        // Destination marker appears on the map and location address is shown
        // Negative assertion is done, to avoid location changes
        EarlGrey.selectElement(with: viewContainingText(text: TestStrings.tapOrLongPressOnTheMap))
            .assert(grey_notVisible())
    }

    /// Verifies that waypoint map view is visible
    static func verifyWaypointMapViewWithNoDestinationIsVisible() {
        EarlGrey.selectElement(with: MapView.waypointMapView)
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: viewContainingText(text: TestStrings.tapTheMapToSetYourDestination))
            .assert(grey_sufficientlyVisible())
    }
}
