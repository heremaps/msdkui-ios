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

extension NMAMapView {
    // MARK: - Properties

    /// An `NMAMapMarker` of `positionIndicator.displayObject` or default transparent marker object
    /// with a size estimated as the same size of default `NMAKit`'s `positionIndicator.displayObject`.
    var currentPositionIndicatorMarker: NMAMapMarker {
        // Note: `positionIndicator.displayObject` returns `nil`,
        // but should return a `NMAMapMarker` or other supported objects
        return positionIndicator.displayObject as? NMAMapMarker ?? currentPositionIndicatorFallbackMarker
    }

    /// Default fallback position indicator marker with a size estimated as the same size
    /// of default `NMAKit`'s `positionIndicator.displayObject`.
    private static let positionIndicatorFallbackMarker: NMAMapMarker = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
        let image = renderer.image { context in
            UIColor.clear.setFill()
            context.fill(renderer.format.bounds)
        }

        return NMAMapMarker(geoCoordinates: NMAGeoCoordinates(), image: image)
    }()

    /// Default fallback position indicator marker with current position coordinates
    /// if available, else with last position coordinates.
    private var currentPositionIndicatorFallbackMarker: NMAMapMarker {
        let positionIndicatorFallbackMarker = NMAMapView.positionIndicatorFallbackMarker

        guard
            let coordinates = NMAPositioningManager.sharedInstance().currentPosition?.coordinates else {
            return positionIndicatorFallbackMarker
        }

        positionIndicatorFallbackMarker.coordinates = coordinates

        return positionIndicatorFallbackMarker
    }

    // MARK: - Public

    /// Provides custom scroll support by implementing the `UIAccessibilityAction` informal protocol's
    /// `accessibilityScroll(_:)` method.
    override open func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        guard
            let boundingBox = boundingBox,
            let latitude = boundingBox.center?.latitude,
            let longitude = boundingBox.center?.longitude else {
            return false
        }

        let ratio = 0.5
        var newCenter: NMAGeoCoordinates?
        var scrollDirection: String?

        switch direction {
        case .left:
            newCenter = NMAGeoCoordinates(latitude: latitude, longitude: longitude + boundingBox.width * ratio)
            scrollDirection = "msdkui_app_right".localized

        case .right:
            newCenter = NMAGeoCoordinates(latitude: latitude, longitude: longitude - boundingBox.width * ratio)
            scrollDirection = "msdkui_app_left".localized

        case .up:
            newCenter = NMAGeoCoordinates(latitude: latitude + boundingBox.height * ratio, longitude: longitude)
            scrollDirection = "msdkui_app_up".localized

        case .down:
            newCenter = NMAGeoCoordinates(latitude: latitude - boundingBox.height * ratio, longitude: longitude)
            scrollDirection = "msdkui_app_down".localized

        default:
            () // Unsupported option
        }

        // Scroll in the desired direction and make an announcement
        guard
            let scrollDirectionSet = scrollDirection,
            let newCenterSet = newCenter,
            case let width = Float(boundingBox.width),
            case let height = Float(boundingBox.height),
            let newBoundingBox = NMAGeoBoundingBox(center: newCenterSet, width: width, height: height) else {
            return false
        }

        set(boundingBox: newBoundingBox, animation: .linear)
        UIAccessibility.post(notification: .pageScrolled, argument: scrollDirectionSet)

        // Return true as the map is scrolled
        return true
    }

    /// Makes a marker with the specified image file & coordinates and adds it to the map view.
    ///
    /// - Parameters:
    ///   - imageFile: The image file for the marker.
    ///   - coordinates: The coordinates of the marker.
    /// - Returns: If successfull, the newly created marker or nil otherwise.
    /// - Important: The marker anchor offset is NMALayoutPositionBottomCenter.
    @discardableResult func addMarker(with imageFile: String, at coordinates: NMAGeoCoordinates) -> NMAMapMarker? {
        guard let image = UIImage(named: imageFile) else {
            return nil
        }

        let marker = NMAMapMarker(geoCoordinates: coordinates, image: image)
        marker.setAnchorOffset(.bottomCenter)
        add(mapObject: marker)

        return marker
    }
}
