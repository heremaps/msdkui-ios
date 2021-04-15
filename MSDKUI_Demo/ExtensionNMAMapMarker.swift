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

/// Extension for `NMAMapMarker`.
extension NMAMapMarker {
    // MARK: - Properties

    /// A rectangle that aligns an anchor offset point with the origin of UIKit's default coordinate system, that is positive values increase from the origin to the right on x-axis and down on y-axis.
    /// This property is meant to be used only in context of `NMAMapMarker`.
    private var anchorFrame: CGRect {
        NMAMapMarker.calculateAnchorFrame(for: icon?.size ?? .zero, with: anchorOffset)
    }

    // MARK: - Public

    /// Calculates icon insets - insets that should be used to encompass all icons at the boarder of a rectangle.
    ///
    /// - Parameter mapMarkers: array of `NMAMapMarker` of which size and position of icon is taken.
    /// - Returns: insets that should be used to encompass all icons at the boarder of a rectangle.
    static func calculateIconsInsets(from mapMarkers: [NMAMapMarker]) -> UIEdgeInsets {
        let anchorFramesUnion = mapMarkers.lazy.map { $0.anchorFrame }
            .reduce(mapMarkers.first?.anchorFrame ?? .zero) { $0.union($1) }
        return calculateInsets(from: anchorFramesUnion)
    }

    // MARK: - Private

    /// Calculates insets of a frame in UIKit's default coordinate system, that is positive values increase from the origin to the right on x-axis and down on y-axis. Insets components are distances of anchor frames's outermost bounds from the coordinate system's origin.
    /// This function is meant to be used only in context of `NMAMapMarker`.
    ///
    /// - Parameter anchorFrame: a frame offset by an anchor point.
    /// - Returns: insets used to encompass all icons at the boarder of a rectangle.
    private static func calculateInsets(from anchorFrame: CGRect) -> UIEdgeInsets {
        var topInset = min(anchorFrame.minY, anchorFrame.maxY)
        topInset = topInset < 0 ? abs(topInset) : 0

        var leftInset = min(anchorFrame.minX, anchorFrame.maxX)
        leftInset = leftInset < 0 ? abs(leftInset) : 0

        var bottomInset = max(anchorFrame.minY, anchorFrame.maxY)
        bottomInset = bottomInset > 0 ? bottomInset : 0

        var rightInset = max(anchorFrame.minX, anchorFrame.maxX)
        rightInset = rightInset > 0 ? rightInset : 0

        return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }

    /// Calculates an anchor frame - a rectangle that aligns an anchor offset point with the origin of UIKit's default coordinate system, that is positive values increase from the origin to the right on x-axis and down on y-axis.
    /// This function is meant to be used only in context of `NMAMapMarker`.
    ///
    /// - Parameters:
    ///   - iconSize: size of the icon from `NMAMapMarker`.
    ///   - anchorOffset: anchor offset point of `NMAMapMarker`'s icon.
    /// - Returns: a frame in UIKit's default coordinate system.
    private static func calculateAnchorFrame(for iconSize: CGSize, with anchorOffset: CGPoint) -> CGRect {
        let iconFrame = CGRect(origin: .zero, size: iconSize)
        let anchorCenter = CGPoint(x: iconFrame.midX, y: iconFrame.midY)

        return iconFrame.offsetBy(dx: -anchorCenter.x + anchorOffset.x, dy: -anchorCenter.y + anchorOffset.y)
    }
}
