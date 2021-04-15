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
import XCTest

final class ExtensionArrayTests: XCTestCase {
    /// Tests if there are no insets when map marker's icon doesn't have size.
    func testZeroSizeMapMarkersIconInsets() {
        NMALayoutPosition.allCases.forEach {
            XCTAssertEqual([NMAMapMarker(size: .zero, anchorOffset: $0)].iconsInsets, .zero)
        }
    }

    /// Tests insets of map marker's icon for different image's anchor offsets.
    func testMapMarkersIconInsets() {
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topLeft)].iconsInsets,
            UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topCenter)].iconsInsets,
            UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 1)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topRight)].iconsInsets,
            UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 0)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerLeft)].iconsInsets,
            UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 2)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .center)].iconsInsets,
            UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerRight)].iconsInsets,
            UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 0)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomLeft)].iconsInsets,
            UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 2)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomCenter)].iconsInsets,
            UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 1)
        )
        XCTAssertEqual(
            [NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomRight)].iconsInsets,
            UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0)
        )
    }

    /// Tests insets of multiple same map marker's icon for different image's anchor offsets.
    func testMultipleSameMapMarkersIconInsets() {
        var mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topLeft)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topCenter)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 1))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topRight)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 0))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerLeft)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 2))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .center)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerRight)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 0))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomLeft)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 2))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomCenter)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 1))
        mapMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomRight)
        XCTAssertEqual([mapMarker, mapMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0))
    }

    /// Tests insets of multiple different map marker's icon for different image's anchor offsets.
    func testMultipleDifferentMapMarkersIconInsets() {
        // Markers in relation to origin of UIKit's default coordinate system
        let bottomRightMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topLeft)
        let bottomLeftMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topRight)
        let topLeftMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomRight)
        let topRightMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomLeft)
        let centerMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .center)
        let centerRightMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerLeft)
        let centerLeftMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .centerRight)
        let bottomCenterMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .topCenter)
        let topCenterMarker = NMAMapMarker(size: CGSize(width: 2, height: 2), anchorOffset: .bottomCenter)

        // Asserts corner marker with each other
        XCTAssertEqual([bottomRightMarker, bottomLeftMarker].iconsInsets, UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2))
        XCTAssertEqual([bottomRightMarker, topLeftMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        XCTAssertEqual([bottomRightMarker, topRightMarker].iconsInsets, UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 2))
        XCTAssertEqual([bottomLeftMarker, topLeftMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 0))
        XCTAssertEqual([bottomLeftMarker, topRightMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        XCTAssertEqual([topLeftMarker, topRightMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2))

        // Asserts center with corner markers
        XCTAssertEqual([bottomRightMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 1, left: 1, bottom: 2, right: 2))
        XCTAssertEqual([bottomLeftMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 1))
        XCTAssertEqual([topLeftMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 1, right: 1))
        XCTAssertEqual([topRightMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 2))

        // Asserts center with paritialy center markers
        XCTAssertEqual([centerRightMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 2))
        XCTAssertEqual([centerLeftMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 1))
        XCTAssertEqual([bottomCenterMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 1, left: 1, bottom: 2, right: 1))
        XCTAssertEqual([topCenterMarker, centerMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 1))

        // Asserts paritialy center markers with each other
        XCTAssertEqual([centerRightMarker, centerLeftMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2))
        XCTAssertEqual([centerRightMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 1, left: 1, bottom: 2, right: 2))
        XCTAssertEqual([centerRightMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 2))
        XCTAssertEqual([centerLeftMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 1))
        XCTAssertEqual([centerLeftMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 1, right: 1))
        XCTAssertEqual([bottomCenterMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))

        // Asserts corner marker with paritialy center markers in the same relation to origin
        XCTAssertEqual([bottomRightMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 2))
        XCTAssertEqual([bottomRightMarker, centerRightMarker].iconsInsets, UIEdgeInsets(top: 1, left: 0, bottom: 2, right: 2))
        XCTAssertEqual([bottomLeftMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 1))
        XCTAssertEqual([bottomLeftMarker, centerLeftMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 0))
        XCTAssertEqual([topLeftMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 1))
        XCTAssertEqual([topLeftMarker, centerLeftMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 1, right: 0))
        XCTAssertEqual([topRightMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 2))
        XCTAssertEqual([topRightMarker, centerRightMarker].iconsInsets, UIEdgeInsets(top: 2, left: 0, bottom: 1, right: 2))

        // Asserts corner marker with paritialy center markers in opposite relation to origin
        XCTAssertEqual([bottomRightMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 2))
        XCTAssertEqual([bottomRightMarker, centerLeftMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 2))
        XCTAssertEqual([bottomLeftMarker, topCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 1))
        XCTAssertEqual([bottomLeftMarker, centerRightMarker].iconsInsets, UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 2))
        XCTAssertEqual([topLeftMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 1))
        XCTAssertEqual([topLeftMarker, centerRightMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 1, right: 2))
        XCTAssertEqual([topRightMarker, bottomCenterMarker].iconsInsets, UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 2))
        XCTAssertEqual([topRightMarker, centerLeftMarker].iconsInsets, UIEdgeInsets(top: 2, left: 2, bottom: 1, right: 2))
    }
}

// MARK: - Private

private extension NMAMapMarker {
    convenience init(size: CGSize, anchorOffset: NMALayoutPosition) {
        self.init(geoCoordinates: NMAGeoCoordinates(), image: UIImageFixture.image(with: size))
        setAnchorOffset(anchorOffset)
    }
}
