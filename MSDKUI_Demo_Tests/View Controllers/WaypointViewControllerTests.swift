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

@testable import MSDKUI_Demo
import NMAKit
import UIKit
import XCTest

class WaypointViewControllerTests: XCTestCase {
    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: WaypointViewController?

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as WaypointViewController
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mocked positioning manager
        viewControllerUnderTest?.positioningManager = MockUtils.mockPositioningManager()

        // Load the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // Set mock notification
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter

        // Set test subtitle
        viewControllerUnderTest?.controllerInfoString = "Test"
        viewControllerUnderTest?.updateLocationState()
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    /// Tests the WaypointViewController.makeEntry(from:) method.
    func testReverseGeoCoding() {
        let coordinates = [
            NMAGeoCoordinates(latitude: 53.348820, longitude: 12.760032),
            NMAGeoCoordinates(latitude: 47.486887, longitude: -26.964165),
            NMAGeoCoordinates(latitude: 53.369070, longitude: 14.675490),
            NMAGeoCoordinates(latitude: 52.530800, longitude: 13.384898),
            NMAGeoCoordinates(latitude: 61.365777, longitude: 10.461852),
            NMAGeoCoordinates(latitude: 75.571278, longitude: -36.557888)
        ]
        let expectations = [
            "17248 Rechlin, Germany",
            "47.48689, -26.96417",
            "ulica Dąbska 70, 70-789 Szczecin, Poland",
            "Invalidenstraße 116, 10115 Berlin, Germany",
            "Baullstulvegen 137, 2635 Tretten, Norway",
            "Greenland"
        ]
        let predicate = NSPredicate(format: "isHidden == true")

        // One-by-one check each coordinates
        for index in 0 ..< coordinates.count {
            // Set the predicate expectation: reverse geocoding HUD should be hidden
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.hudView)
            viewControllerUnderTest?.makeEntry(from: coordinates[index])

            // Wait for the reverse geocoding HUD to hide
            wait(for: [expectation], timeout: 15)

            XCTAssertEqual(viewControllerUnderTest?.waypointLabel.text, expectations[index], "Wrong reverse geocoding!")
        }
    }

    /// Tests WaypointViewController.mapView(_, didReceiveTapAt:) method.
    func testMapViewDidReceiveTapAt() throws {
        // Set the predicate expectation: the OK button should be enabled
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.okButton)

        let mapView = try require(viewControllerUnderTest?.mapView)
        viewControllerUnderTest?.mapView(mapView, didReceiveTapAt: CGPoint(x: 50, y: 50))

        // Wait for the OK button enabled
        wait(for: [expectation], timeout: 15)

        XCTAssertTrue(viewControllerUnderTest?.okButton.isEnabled ?? false, "OK button is not enabled!")
    }

    /// Tests that a long press selects a point.
    func testLongPressOnMapViewWithValidPoint() throws {
        // Set the predicate expectation: reverse geocoding HUD should be hidden
        let predicate = NSPredicate(format: "isHidden == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.hudView)

        // Trigger the long press
        let coordinate = NMAGeoCoordinates(latitude: 52.530800, longitude: 13.384898)
        let pointOnMap = viewControllerUnderTest?.mapView.point(from: coordinate) ?? .zero

        let mapView = try require(viewControllerUnderTest?.mapView)
        viewControllerUnderTest?.mapView(mapView, didReceiveLongPressAt: pointOnMap)

        // Wait for the reverse geocoding HUD to hide
        wait(for: [expectation], timeout: 15)

        // Check if the waypoint item was correctly added
        XCTAssertTrue(try require(viewControllerUnderTest?.waypointLabel.text?.contains("10115 Berlin, Germany")), "No WaypointItem!")
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
