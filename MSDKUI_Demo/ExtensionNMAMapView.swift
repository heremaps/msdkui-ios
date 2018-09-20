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

import NMAKit

extension NMAMapView {
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
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, scrollDirectionSet)

        // Return true as the map is scrolled
        return true
    }

    /// Makes a marker with the specified image file & coordinates and adds it to the map view.
    ///
    /// - Parameter imageFile: The image file for the marker.
    /// - Parameter coordinates: The coordinates of the marker.
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

    /// Unfortunately, a marker knows its anchor coordinates, but not its bounding box:
    /// so we need to calculate an approximate bounding box. Note that to simplify things,
    /// two assumptions are made:
    /// 1 - The achor offset is NMALayoutPositionBottomCenter.
    /// 2 - The marker size is approximately 40x50dp.
    ///
    /// - Returns: If successfull, the calculated bounding box or nil otherwise.
    func markerBoundingBox(at coordinates: NMAGeoCoordinates?) -> NMAGeoBoundingBox? {
        guard
            let coordinates = coordinates,
            case let markerPoint = point(from: coordinates),
            case let topLeftPoint = CGPoint(x: markerPoint.x - 50.0, y: markerPoint.y - 75.0),
            case let bottomRightPoint = CGPoint(x: markerPoint.x + 50.0, y: markerPoint.y + 25.0),
            let topLeftCoordinates = geoCoordinates(from: topLeftPoint),
            let bottomRightCoordinates = geoCoordinates(from: bottomRightPoint) else {
                return nil
        }

        return NMAGeoBoundingBox(topLeft: topLeftCoordinates, bottomRight: bottomRightCoordinates)
    }
}
