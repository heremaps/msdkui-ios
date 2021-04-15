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

final class ExtensionNMAMapViewTests: XCTestCase {
    /// The object under test.
    private var mapViewUnderTest: NMAMapViewPartialMock?

    override func setUp() {
        super.setUp()

        mapViewUnderTest = NMAMapViewPartialMock(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    }

    // MARK: - Tests

    /// Tests the add marker method when the image isn't available.
    func testAddMarkerWithInvalidImage() {
        let marker = mapViewUnderTest?.addMarker(with: "", at: NMAGeoCoordinates(latitude: 40, longitude: 2))

        XCTAssertNil(marker, "It doesn't return a marker")
    }

    /// Tests the add marker method when a valid image name is passed.
    func testAddMarkerWithValidImage() {
        let marker = mapViewUnderTest?.addMarker(with: "Route.end", at: NMAGeoCoordinates(latitude: 40, longitude: 2))

        XCTAssertNotNil(marker, "It returns a marker")

        XCTAssertEqual(marker?.coordinates.latitude, 40.0, "It returns a marker with the correct latitude")
        XCTAssertEqual(marker?.coordinates.longitude, 2.0, "It returns a marker with the correct longitude")

        XCTAssertEqual(mapViewUnderTest?.didCallAddMapObject, true, "It adds the marker to the map")
        XCTAssertTrue(mapViewUnderTest?.lastMapObject === marker, "It adds the correct marker to the map")
    }

    /// Tests the accessibility scroll when user scrolls up.
    func testAccessibilityScrollUp() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.up))

        // Tests if map view did scroll
        XCTAssertTrue(didScroll, "It scrolls the map view")

        // Tests the new bouding box
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.latitude), 0.5, accuracy: 0.1, "It scrolls the map view")
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.longitude), 0.0, accuracy: 0.1, "It keeps the same longitude")

        // Tests if the animated with the correct animation type
        XCTAssertEqual(mapViewUnderTest?.lastAnimationType, .linear, "It scrolls with the correct animation")
    }

    /// Tests the accessibility scroll when user scrolls down.
    func testAccessibilityScrollDown() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.down))

        XCTAssertTrue(didScroll, "It scrolls the map view")

        // New bounding box
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.latitude), -0.5, accuracy: 0.1, "It scrolls the map view")
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.longitude), 0.0, accuracy: 0.1, "It keeps the same longitude")

        // Animation to new bounding box
        XCTAssertEqual(mapViewUnderTest?.lastAnimationType, .linear, "It scrolls with the correct animation")
    }

    /// Tests the accessibility scroll when user scrolls left.
    func testAccessibilityScrollLeft() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.left))

        // Tests if map view did scroll
        XCTAssertTrue(didScroll, "It scrolls the map view")

        // Tests the new bouding box
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.latitude), 0.0, accuracy: 0.1, "It keeps the same latitude")
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.longitude), 0.5, accuracy: 0.1, "It scrolls the map view")

        // Tests if the animated with the correct animation type
        XCTAssertEqual(mapViewUnderTest?.lastAnimationType, .linear, "It scrolls with the correct animation")
    }

    /// Tests the accessibility scroll when user scrolls right.
    func testAccessibilityScrollRight() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.right))

        // Tests if map view did scroll
        XCTAssertTrue(didScroll, "It scrolls the map view")

        // Tests the new bouding box
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.latitude), 0.0, accuracy: 0.1, "It keeps the same latitude")
        XCTAssertEqual(try require(mapViewUnderTest?.lastBoundingBox?.center?.longitude), -0.5, accuracy: 0.1, "It scrolls the map view")

        // Tests if the animated with the correct animation type
        XCTAssertEqual(mapViewUnderTest?.lastAnimationType, .linear, "It scrolls with the correct animation")
    }

    /// Tests the accessibility scroll when user scrolls to the next view.
    func testAccessibilityScrollNext() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.next))

        // Tests if map view did not scroll: not supported
        XCTAssertFalse(didScroll, "It doesn't scroll the map view")
    }

    /// Tests the accessibility scroll when user scrolls to the previous view.
    func testAccessibilityScrollPrevious() throws {
        try setUpDefaultMapBoundingBox()

        // Triggers the method with desired direction
        let didScroll = try require(mapViewUnderTest?.accessibilityScroll(.previous))

        // Tests if map view did not scroll: not supported
        XCTAssertFalse(didScroll, "It doesn't scroll the map view")
    }

    /// Tests `currentPositionIndicatorMarker` when there is no `positionIndicator.displayObject`.
    func testCurrentPositionIndicatorMarkerWhenNoDisplayObject() {
        mapViewUnderTest?.positionIndicator.set(displayObject: nil, toLayer: .foreground)

        XCTAssertNotNil(mapViewUnderTest?.currentPositionIndicatorMarker, "It is an object")
    }

    /// Tests `currentPositionIndicatorMarker` when the `positionIndicator.displayObject` is not a marker.
    func testCurrentPositionIndicatorMarkerWhenDisplayObjectIsNotAMarker() {
        let displayObject = NMAMapObject()

        mapViewUnderTest?.positionIndicator.set(displayObject: displayObject, toLayer: .foreground)

        XCTAssertTrue(mapViewUnderTest?.currentPositionIndicatorMarker !== displayObject, "It is a different object")
    }

    /// Tests `currentPositionIndicatorMarker` when the `positionIndicator.displayObject` is a marker.
    func testCurrentPositionIndicatorMarkerWhenMarkerDisplayed() {
        let positionMarker = NMAMapMarker(geoCoordinates: NMAGeoCoordinates())

        mapViewUnderTest?.positionIndicator.set(displayObject: positionMarker, toLayer: .foreground)

        XCTAssertTrue(mapViewUnderTest?.currentPositionIndicatorMarker === positionMarker, "It is the same object")
    }

    // MARK: - Private

    private func setUpDefaultMapBoundingBox() throws {
        let boundingBox = try require(NMAGeoBoundingBox(center: NMAGeoCoordinates(latitude: 0, longitude: 0), width: 1, height: 1))
        mapViewUnderTest?.set(boundingBox: boundingBox, animation: .none)
    }
}
