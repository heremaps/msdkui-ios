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
import UIKit
import XCTest

final class WaypointViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: WaypointViewController?

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The mock reverse geocoder.
    private var mockReverseGeocoder = NMAGeocoderMock()

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as WaypointViewController

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mocked positioning manager
        viewControllerUnderTest?.positioningManager = MockUtils.mockPositioningManager()

        // Load the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // Set mock notification center
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter

        // Set mock reverse geocoder
        viewControllerUnderTest?.reverseGeocoder = mockReverseGeocoder

        // Set test subtitle
        viewControllerUnderTest?.controllerInfoString = "Test"
        viewControllerUnderTest?.updateLocationState()
    }

    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests the WaypointViewController.makeEntry(from:) method.
    func testReverseGeocoding() {
        // Set "no-position" manager to avoid waypointLabel updates
        viewControllerUnderTest?.positioningManager = MockUtils.mockPositioningManagerWithoutPosition()

        // Call test method with correct coordinates
        let testCoordinates = NMAGeoCoordinates(latitude: 52.530800, longitude: 13.384898, altitude: 0)
        viewControllerUnderTest?.makeEntry(from: testCoordinates)

        // Check if called
        XCTAssertTrue(mockReverseGeocoder.didCallReverseGeocode, "Reverse geocoder called")

        // Check coordinates
        XCTAssertEqual(mockReverseGeocoder.lastCoordinates, testCoordinates, "Called with correct coordinates")

        // Check if correct label text is set
        let result = MockUtils.mockReverseGeocodeResult("Formatted Address", street: "Street", houseNumber: "123")
        mockReverseGeocoder.lastCompletionBlock?(NMARequest(), [result], nil)

        XCTAssertEqual(viewControllerUnderTest?.waypointLabel.text, "Formatted Address", "Correct address displayed")
    }

    /// Tests WaypointViewController.mapView(_, didReceiveTapAt:) method.
    func testMapViewDidReceiveTapAt() throws {
        // Set the predicate expectation: the OK button should be enabled
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.okButton)

        let mapView = try require(viewControllerUnderTest?.mapView)
        viewControllerUnderTest?.mapView(mapView, didReceiveTapAt: CGPoint(x: 50, y: 50))

        // Post reverse geocoder response
        let result = MockUtils.mockReverseGeocodeResult("Formatted Address", street: "Street", houseNumber: "123")
        mockReverseGeocoder.lastCompletionBlock?(NMARequest(), [result], nil)

        // Wait for the OK button enabled
        wait(for: [expectation], timeout: 15)

        XCTAssertTrue(viewControllerUnderTest?.okButton.isEnabled ?? false, "OK button is not enabled!")
    }

    /// Tests that a long press selects a point.
    func testLongPressOnMapViewWithValidPoint() throws {
        // Set "no-position" manager to avoid waypointLabel updates
        viewControllerUnderTest?.positioningManager = MockUtils.mockPositioningManagerWithoutPosition()

        // Trigger the long press
        let coordinate = NMAGeoCoordinates(latitude: 52.530800, longitude: 13.384898)
        let pointOnMap = viewControllerUnderTest?.mapView.point(from: coordinate) ?? .zero

        let mapView = try require(viewControllerUnderTest?.mapView)
        viewControllerUnderTest?.mapView(mapView, didReceiveLongPressAt: pointOnMap)

        // Check if called
        XCTAssertTrue(mockReverseGeocoder.didCallReverseGeocode, "Reverse geocoder called")

        // Check if correct label text is set
        let result = MockUtils.mockReverseGeocodeResult("Formatted Address", street: "Street", houseNumber: "123")
        mockReverseGeocoder.lastCompletionBlock?(NMARequest(), [result], nil)

        XCTAssertEqual(viewControllerUnderTest?.waypointLabel.text, "Formatted Address", "Correct address displayed")
    }

    /// Tests update position notification and info update.
    func testDidUpdatePosition() throws {
        // Set provider to return empty position
        viewControllerUnderTest?.positioningManager = MockUtils.mockPositioningManagerWithoutPosition()
        viewControllerUnderTest?.updateLocationState()

        // Send notification
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Wait for UI update and check if waypoint indicator is visible and animating
        let viewController = try require(viewControllerUnderTest)
        XCTAssertNil(viewController.positioningManager.currentPosition, "Current position should be nil!")

        // Check state
        XCTAssertEqual(viewController.locationState, .searching, "Location state not correct!")

        // Check waypoint indicator
        XCTAssertFalse(viewController.waypointIndicator.isHidden, "Waypoint indicator should be visible!")
        XCTAssertTrue(viewController.waypointIndicator.isAnimating, "Waypoint indicator should animate!")

        // Check if general text was replaced
        XCTAssertNotEqual(viewControllerUnderTest?.waypointLabel.text, viewControllerUnderTest?.controllerInfoString, "Wrong message!")
    }
}
