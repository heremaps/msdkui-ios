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

final class MapViewportHandlerTests: XCTestCase {
    /// The map viewpot handler instance under test.
    private var mapViewportHandlerUnderTest: MapViewportHandling = MapViewportHandler()

    /// The partial mock map view used to verify expectations.
    private var mapViewPartialMock: NMAMapViewPartialMock = NMAMapViewPartialMock()

    override func setUp() {
        super.setUp()

        // Sets map viewpot handler under test
        mapViewportHandlerUnderTest = MapViewportHandler()

        // Sets partial mock map view
        mapViewPartialMock = NMAMapViewPartialMock()
    }

    // MARK: - Routes

    /// Tests the set viewport method with no routes and no markers.
    func testSetViewportWithEmptyRoutesAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [], with: [], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with nil route and no markers.
    func testSetViewportWithNilRouteAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [nil], with: [], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with nil routes and no markers.
    func testSetViewportWithNilRoutesAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [nil, nil, nil], with: [], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with empty bounding box route and no markers.
    func testSetViewportWithEmptyBoundingBoxRouteAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [MockUtils.mockRoute(with: NMAGeoBoundingBox())], with: [], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with empty bounding box routes and no markers.
    func testSetViewportWithEmptyBoundingBoxRoutesAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(
            of: mapViewPartialMock, on: [
                MockUtils.mockRoute(with: NMAGeoBoundingBox()),
                MockUtils.mockRoute(with: NMAGeoBoundingBox()),
                MockUtils.mockRoute(with: NMAGeoBoundingBox())
            ],
            with: [], animation: .bow
        )

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with route containing a nonempty bounding box and no markers.
    func testSetViewportWithBoundingBoxRouteAndNoMarkers() throws {
        let expectedBoundingBox = try require(NMAGeoBoundingBox(center: NMAGeoCoordinates(latitude: 52.0, longitude: 13.0), width: 0.1, height: 0.1))

        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [MockUtils.mockRoute(with: expectedBoundingBox)], with: [], animation: .bow)

        XCTAssertTrue(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It does call map view's expected set method")
        XCTAssertEqual(mapViewPartialMock.lastScreenRect, .zero, "It uses a correct screen rectangle")
        XCTAssertEqual(mapViewPartialMock.lastAnimationType, .bow, "It uses a correct animation")

        let lastBoundingBox = try require(mapViewPartialMock.lastBoundingBox)
        XCTAssertEqual(lastBoundingBox.width, expectedBoundingBox.width, accuracy: 0.01, "Used bounding box has the same width")
        XCTAssertEqual(lastBoundingBox.height, expectedBoundingBox.height, accuracy: 0.01, "Used bounding box has the same height")
        XCTAssertEqual(
            lastBoundingBox.topLeft.latitude, expectedBoundingBox.topLeft.latitude, accuracy: 0.01,
            "Used bounding box has the same top-left latitude"
        )
        XCTAssertEqual(
            lastBoundingBox.topLeft.longitude, expectedBoundingBox.topLeft.longitude, accuracy: 0.01,
            "Used bounding box has the same top-left longitude"
        )
        XCTAssertEqual(
            lastBoundingBox.bottomRight.latitude, expectedBoundingBox.bottomRight.latitude, accuracy: 0.01,
            "Used bounding box has the same bottom-right latitude"
        )
        XCTAssertEqual(
            lastBoundingBox.bottomRight.longitude, expectedBoundingBox.bottomRight.longitude, accuracy: 0.01,
            "Used bounding box has the same bottom-right longitude"
        )
    }

    /// Tests the set viewport method with routes containing nonempty bounding boxes and no markers.
    func testSetViewportWithBoundingBoxRoutesAndNoMarkers() {
        mapViewportHandlerUnderTest.setViewport(
            of: mapViewPartialMock,
            on: [
                MockUtils.mockRoute(with: NMAGeoBoundingBox(
                    center: NMAGeoCoordinates(latitude: 53.0, longitude: 14.0),
                    width: 0.1, height: 0.1
                )),
                MockUtils.mockRoute(with: NMAGeoBoundingBox(
                    center: NMAGeoCoordinates(latitude: 52.0, longitude: 13.0),
                    width: 0.1, height: 0.1
                ))
            ],
            with: [], animation: .rocket
        )

        XCTAssertTrue(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It does call map view's expected set method")
        XCTAssertNotNil(mapViewPartialMock.lastBoundingBox, "It uses a bounding box")
        XCTAssertEqual(mapViewPartialMock.lastScreenRect, .zero, "It uses a correct screen rectangle")
        XCTAssertEqual(mapViewPartialMock.lastAnimationType, .rocket, "It uses a correct animation")
    }

    // MARK: - Markers

    /// Tests the set viewport method with no routes and nil marker.
    func testSetViewportWithEmptyRoutesAndNilMarker() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [], with: [nil], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with no routes and nil markers.
    func testSetViewportWithEmptyRoutesAndNilMarkers() {
        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [], with: [nil, nil, nil], animation: .bow)

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with no routes and a marker.
    func testSetViewportWithEmptyRoutesAndAMarker() {
        mapViewportHandlerUnderTest.setViewport(
            of: mapViewPartialMock, on: [],
            with: [NMAMapMarker(geoCoordinates: NMAGeoCoordinates(latitude: 52.0, longitude: 13.0))], animation: .bow
        )

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with no routes and same markers.
    func testSetViewportWithEmptyRoutesAndSameMarkers() {
        let geoCoordinates = NMAGeoCoordinates(latitude: 52.0, longitude: 13.0)

        mapViewportHandlerUnderTest.setViewport(
            of: mapViewPartialMock, on: [],
            with: [NMAMapMarker(geoCoordinates: geoCoordinates), NMAMapMarker(geoCoordinates: geoCoordinates)],
            animation: .bow
        )

        XCTAssertFalse(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It doesn't call map view's expected set method")
    }

    /// Tests the set viewport method with no routes and different markers.
    func testSetViewportWithEmptyRoutesAndDifferentMarkers() throws {
        let expectedTopRight = NMAGeoCoordinates(latitude: 53.0, longitude: 14.0)
        let expectedBottomLeft = NMAGeoCoordinates(latitude: 52.0, longitude: 13.0)

        mapViewportHandlerUnderTest.setViewport(
            of: mapViewPartialMock, on: [],
            with: [NMAMapMarker(geoCoordinates: expectedTopRight), NMAMapMarker(geoCoordinates: expectedBottomLeft)],
            animation: .linear
        )

        XCTAssertTrue(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It does call map view's expected set method")
        XCTAssertEqual(mapViewPartialMock.lastScreenRect, .zero, "It uses a correct screen rectangle")
        XCTAssertEqual(mapViewPartialMock.lastAnimationType, .linear, "It uses a correct animation")

        let lastBoundingBox = try require(mapViewPartialMock.lastBoundingBox)
        XCTAssertEqual(lastBoundingBox.topRight.latitude, expectedTopRight.latitude, accuracy: 0.01, "Used bounding box has the same top-right latitude")
        XCTAssertEqual(lastBoundingBox.topRight.longitude, expectedTopRight.longitude, accuracy: 0.01, "Used bounding box has the same top-right longitude")
        XCTAssertEqual(lastBoundingBox.bottomLeft.latitude, expectedBottomLeft.latitude, accuracy: 0.01, "Used bounding box has the same bottom-left latitude")
        XCTAssertEqual(
            lastBoundingBox.bottomLeft.longitude, expectedBottomLeft.longitude, accuracy: 0.01,
            "Used bounding box has the same bottom-left longitude"
        )
    }

    /// Tests the set viewport method with no routes and different visible markers.
    func testSetViewportWithEmptyRoutesAndDifferentVisibleMarkers() throws {
        // Markers with icon in origin, bounds in screen frame
        let topRightMarker = NMAMapMarker(geoCoordinates: NMAGeoCoordinates(latitude: 53.0, longitude: 14.0), imageSize: CGSize(width: 1, height: 1))
        topRightMarker.setAnchorOffset(.topLeft)
        let bottomLeftMarker = NMAMapMarker(geoCoordinates: NMAGeoCoordinates(latitude: 52.0, longitude: 13.0), imageSize: CGSize(width: 1, height: 1))
        bottomLeftMarker.setAnchorOffset(.topLeft)

        // Bounds that can be inset by markers' icon sizes
        mapViewPartialMock.bounds = CGRect(origin: .zero, size: CGSize(width: 2, height: 2))

        mapViewportHandlerUnderTest.setViewport(of: mapViewPartialMock, on: [], with: [topRightMarker, bottomLeftMarker], animation: .none)

        XCTAssertTrue(mapViewPartialMock.didCallSetBoundingBoxInsideWithAnimation, "It does call map view's expected set method")
        XCTAssertEqual(mapViewPartialMock.lastAnimationType, .some(.none), "It uses a correct animation")
        XCTAssertEqual(mapViewPartialMock.lastScreenRect, CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), "It uses a correct screen rectangle")

        let lastBoundingBox = try require(mapViewPartialMock.lastBoundingBox)
        XCTAssertEqual(
            lastBoundingBox.topRight.latitude, topRightMarker.coordinates.latitude, accuracy: 0.01,
            "Used bounding box has the same top-right latitude"
        )
        XCTAssertEqual(
            lastBoundingBox.topRight.longitude, topRightMarker.coordinates.longitude, accuracy: 0.01,
            "Used bounding box has the same top-right longitude"
        )
        XCTAssertEqual(
            lastBoundingBox.bottomLeft.latitude, bottomLeftMarker.coordinates.latitude, accuracy: 0.01,
            "Used bounding box has the same bottom-left latitude"
        )
        XCTAssertEqual(
            lastBoundingBox.bottomLeft.longitude, bottomLeftMarker.coordinates.longitude, accuracy: 0.01,
            "Used bounding box has the same bottom-left longitude"
        )
    }
}

// MARK: - Private

private extension NMAMapMarker {
    convenience init(geoCoordinates: NMAGeoCoordinates, imageSize: CGSize) {
        self.init(geoCoordinates: geoCoordinates, image: UIImageFixture.image(with: imageSize))
    }
}
