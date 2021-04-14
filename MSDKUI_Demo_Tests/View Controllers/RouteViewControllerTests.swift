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

final class RouteViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: RouteViewController?

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    /// Mock used to verify map route handler expectations.
    private var mockMapRoute = MockUtils.mockMapRoute()

    /// Mock used to verify for route expectations.
    private var mockRoute = MockUtils.mockRoute()

    /// The mock map route handler used to verify expectations.
    private var mockMapRouteHandler = MapRouteHandlerMock()

    /// The mock map viewport handler used to verify expectations.
    private var mockMapViewportHandler = MapViewportHandlerMock()

    /// Mock used to verify reverse geocoding.
    private var mockGeocoder = NMAGeocoderMock()

    override func setUp() {
        super.setUp()

        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as RouteViewController

        // Sets mock map route handler
        mockMapRouteHandler.stubMapRoute(toReturn: mockMapRoute)
        viewControllerUnderTest?.mapRouteHandler = mockMapRouteHandler

        // Sets mock map viewport handler
        viewControllerUnderTest?.mapViewportHandler = mockMapViewportHandler

        // Sets mock route
        viewControllerUnderTest?.route = mockRoute

        // Sets mock source and destination addresses
        viewControllerUnderTest?.sourceAddress = "Source"
        viewControllerUnderTest?.destinationAddress = "Destination"

        // Sets mock geocoder
        viewControllerUnderTest?.reverseGeocoder = mockGeocoder

        // In order to get the orientation changes, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()
    }

    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        // The default orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKeyPath: #keyPath(UIDevice.orientation))

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests if the view controller exists.
    func testExists() {
        XCTAssertNotNil(viewControllerUnderTest, "It exists")
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertLocalized(viewControllerUnderTest?.backButton.title, key: "msdkui_app_back", "It has the correct title")
        XCTAssertEqual(viewControllerUnderTest?.backButton.tintColor, .colorAccentLight, "It has the correct tint color")
    }

    /// Tests the title item.
    func testTitleItem() {
        XCTAssertLocalized(viewControllerUnderTest?.titleItem.title, key: "msdkui_app_route_preview_title", "It has the correct title")
    }

    /// Tests the maneuver table view.
    func testManeuverTableView() {
        XCTAssertEqual(viewControllerUnderTest?.maneuverTableView.tableFooterView?.bounds.height, 0, "It hides unused table view cells")
        XCTAssertEqual(viewControllerUnderTest?.maneuverTableView.route, mockRoute, "It has the correct route")
    }

    /// Tests the map view.
    func testMapView() throws {
        XCTAssertTrue(try require(viewControllerUnderTest?.mapView.isTrafficVisible), "It has traffic enabled")
    }

    /// Tests if the HUD is displayed when view is displayed.
    func testHUDWhenViewLoads() throws {
        XCTAssertFalse(try require(viewControllerUnderTest?.hudView.isHidden), "It shows the hud when the controller's view loads")
    }

    /// Tests if the map route is added to the map view.
    func testMapRouteAddedToMapView() {
        XCTAssertTrue(mockMapRouteHandler.didCallAddMapRouteToMapView, "It adds the map route to the map view")
        XCTAssert(mockMapRouteHandler.lastMapRoute === mockMapRoute, "It adds the correct map route to the map view")
        XCTAssert(mockMapRouteHandler.lastMapView === viewControllerUnderTest?.mapView, "It adds the map route to the correct map view")
    }

    /// Tests the preferred status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(viewControllerUnderTest?.preferredStatusBarStyle, .lightContent, "It returns the correct status bar style")
    }

    /// Tests the show button action.
    func testShowButtonAction() throws {
        let viewController = try require(viewControllerUnderTest)
        XCTAssertTrue(viewController.tableViewHeightConstraint.isActive, "Table View height constraint is active")
        XCTAssertTrue(viewController.mapView.isAccessibilityElement, "Map view is accessibility element")
        XCTAssertLocalized(
            viewController.showButton.title(for: .normal), key: "msdkui_app_guidance_button_showmaneuvers",
            "Button has correct title"
        )

        viewController.showButton.sendActions(for: .touchUpInside)

        XCTAssertFalse(viewController.tableViewHeightConstraint.isActive, "Table View height constraint is not active")
        XCTAssertFalse(viewController.mapView.isAccessibilityElement, "Map view is not accessibility element")
        XCTAssertLocalized(
            viewController.showButton.title(for: .normal), key: "msdkui_app_guidance_button_showmap",
            "Button has correct title"
        )

        viewController.showButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(viewController.tableViewHeightConstraint.isActive, "Table View height constraint is active")
        XCTAssertTrue(viewController.mapView.isAccessibilityElement, "Map view is accessibility element")
        XCTAssertLocalized(
            viewController.showButton.title(for: .normal), key: "msdkui_app_guidance_button_showmaneuvers",
            "Button has correct title"
        )
    }

    /// Tests accessibility.
    func testAccessibility() throws {
        XCTAssertEqual(
            viewControllerUnderTest?.backButton.accessibilityIdentifier, "RouteViewController.backButton",
            "It has the correct back button accessibility identifier"
        )

        XCTAssertTrue(
            try require(viewControllerUnderTest?.mapView.isAccessibilityElement),
            "It has map view accessibility enabled"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.mapView.accessibilityTraits, UIAccessibilityTraits.none,
            "It doesn't have map view accessibility traits"
        )

        XCTAssertLocalized(
            viewControllerUnderTest?.mapView.accessibilityLabel, key: "msdkui_app_map_view",
            "It has the correct map view accessibility label"
        )

        XCTAssertLocalized(
            viewControllerUnderTest?.mapView.accessibilityHint, key: "msdkui_app_hint_route_map_view",
            "It has the correct map view accessibility hint"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.mapView.accessibilityIdentifier, "RouteViewController.mapView",
            "It has the correct map view accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.hudView.accessibilityIdentifier, "RouteViewController.hudView",
            "It has the correct hud accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.showButton.accessibilityIdentifier, "RouteViewController.showButton",
            "It has correct show button accessibility identifier"
        )
    }

    /// Tests initial source and destination addresses.
    func testSourceDestinationAddresses() {
        XCTAssertEqual(viewControllerUnderTest?.sourceLabel.text, "Source", "It has correct source label")
        XCTAssertEqual(viewControllerUnderTest?.destinationLabel.text, "Destination", "It has correct destination label")
    }

    /// Tests source label for reverse geocoding with street and house number available.
    func testSourceReverseGeocoding() {
        viewControllerUnderTest?.sourceAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: "Street",
                    houseNumber: "123"
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.sourceLabel,
            extectedLabelText: "Street 123",
            expectedCoordinates: mockRoute.start?.originalPosition
        )
    }

    /// Tests source label for reverse geocoding without house number.
    func testSourceReverseGeocodingWithoutHouseNumber() {
        viewControllerUnderTest?.sourceAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: "Street",
                    houseNumber: nil
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.sourceLabel,
            extectedLabelText: "Street",
            expectedCoordinates: mockRoute.start?.originalPosition
        )
    }

    /// Tests source label for reverse geocoding without street and house number.
    func testSourceReverseGeocodingWithoutStreetAndHouseNumber() {
        viewControllerUnderTest?.sourceAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: nil,
                    houseNumber: nil
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.sourceLabel,
            extectedLabelText: "Formatted address",
            expectedCoordinates: mockRoute.start?.originalPosition
        )
    }

    /// Tests source label for reverse geocoding error.
    func testSourceReverseGeocodingError() {
        viewControllerUnderTest?.sourceAddress = nil

        reverseGeocodingTest(
            result: nil,
            error: NSError(domain: "", code: 0, userInfo: nil),
            labelToTest: viewControllerUnderTest?.sourceLabel,
            extectedLabelText: nil,
            expectedCoordinates: mockRoute.start?.originalPosition
        )
    }

    /// Tests destination label for reverse geocoding with street and house number available.
    func testDestinationReverseGeocoding() {
        viewControllerUnderTest?.destinationAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: "Street",
                    houseNumber: "123"
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.destinationLabel,
            extectedLabelText: "Street 123",
            expectedCoordinates: mockRoute.destination?.originalPosition
        )
    }

    /// Tests destination label for reverse geocoding without house number.
    func testDestinationReverseGeocodingWithoutHouseNumber() {
        viewControllerUnderTest?.destinationAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: "Street",
                    houseNumber: nil
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.destinationLabel,
            extectedLabelText: "Street",
            expectedCoordinates: mockRoute.destination?.originalPosition
        )
    }

    /// Tests destination label for reverse geocoding without street and house number.
    func testDestinationReverseGeocodingWithoutStreetAndHouseNumber() {
        viewControllerUnderTest?.destinationAddress = nil

        reverseGeocodingTest(
            result: [
                MockUtils.mockReverseGeocodeResult(
                    "Formatted address",
                    street: nil,
                    houseNumber: nil
                )
            ],
            error: nil,
            labelToTest: viewControllerUnderTest?.destinationLabel,
            extectedLabelText: "Formatted address",
            expectedCoordinates: mockRoute.destination?.originalPosition
        )
    }

    /// Tests source label for reverse geocoding error.
    func testDestinationReverseGeocodingError() {
        viewControllerUnderTest?.destinationAddress = nil

        reverseGeocodingTest(
            result: nil,
            error: NSError(domain: "", code: 0, userInfo: nil),
            labelToTest: viewControllerUnderTest?.destinationLabel,
            extectedLabelText: nil,
            expectedCoordinates: mockRoute.destination?.originalPosition
        )
    }

    /// Tests map with displayed route does update viewport when view is shown.
    func testMapWithDisplayedRouteViewportUpdatedsWhenViewIsShown() {
        // Triggers the view's life cycle methods
        viewControllerUnderTest?.viewDidLayoutSubviews()

        XCTAssertTrue(mockMapViewportHandler.didCallSetViewport, "It calls the map viewport handler to set map's viewport")
    }

    /// Tests map without displayed route does not update viewport when view is shown.
    func testMapWithoutDisplayedRouteViewportUpdatedsWhenViewIsShown() {
        // Resets the view controller under test
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as RouteViewController

        // Sets mock map route handler
        mockMapRouteHandler.stubMapRoute(toReturn: nil)
        viewControllerUnderTest?.mapRouteHandler = mockMapRouteHandler

        // Sets mock map viewport handler
        viewControllerUnderTest?.mapViewportHandler = mockMapViewportHandler

        // Triggers the view's life cycle methods
        viewControllerUnderTest?.loadViewIfNeeded()
        viewControllerUnderTest?.viewDidLayoutSubviews()

        XCTAssertFalse(mockMapViewportHandler.didCallSetViewport, "It doesn't call the map viewport handler to set map's viewport")
    }

    /// Tests map with displayed route does update viewport when orientation changes.
    func testMapWithDisplayedRouteViewportUpdatedsWhenOrientationChanges() {
        // Switch to landscape orientation from the default portrait orientation
        let predicate = NSPredicate(format: "didCallSetViewport == true")
        expectation(for: predicate, evaluatedWith: mockMapViewportHandler)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)
    }

    /// Tests map without displayed route doesn't update viewport when orientation changes.
    func testMapWithoutDisplayedRouteViewportUpdatedsWhenOrientationChanges() {
        // Resets the view controller under test
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as RouteViewController

        // In order to get the orientation changes, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Sets mock map route handler
        mockMapRouteHandler.stubMapRoute(toReturn: nil)
        viewControllerUnderTest?.mapRouteHandler = mockMapRouteHandler

        // Sets mock map viewport handler
        viewControllerUnderTest?.mapViewportHandler = mockMapViewportHandler

        // Triggers the view's life cycle methods
        viewControllerUnderTest?.loadViewIfNeeded()

        // Switch to landscape orientation from the default portrait orientation
        let predicate = NSPredicate(format: "orientation == \(UIInterfaceOrientation.landscapeRight.rawValue)")
        expectation(for: predicate, evaluatedWith: UIDevice.current)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)

        XCTAssertFalse(mockMapViewportHandler.didCallSetViewport, "It doesn't call the map viewport handler to set map's viewport")
    }

    // MARK: - Private

    private func reverseGeocodingTest(
        // swiftlint:disable:next discouraged_optional_collection
        result: [NMAReverseGeocodeResult]?,
        error: NSError?,
        labelToTest: UILabel?,
        extectedLabelText: String?,
        expectedCoordinates: NMAGeoCoordinates?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(mockGeocoder.didCallReverseGeocode, "Reverse geocoder called", file: file, line: line)
        // Check called coordinates with mocked
        XCTAssertEqual(mockGeocoder.lastCoordinates, expectedCoordinates, "Called with correct coordinates", file: file, line: line)

        // Check setting correct label text
        mockGeocoder.lastCompletionBlock?(NMARequest(), result, error)
        waitForLabelText(label: labelToTest, expectedText: extectedLabelText)
    }

    private func waitForHUDHidden() {
        let predicate = NSPredicate(format: "isHidden == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: viewControllerUnderTest?.hudView)
        wait(for: [expectation], timeout: 15)
    }

    private func waitForLabelText(label: UILabel?, expectedText: String?) {
        let predicate: NSPredicate
        if let expectedText = expectedText {
            predicate = NSPredicate(format: "text == %@", expectedText)
        } else {
            predicate = NSPredicate(format: "text == nil")
        }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: label)
        wait(for: [expectation], timeout: 15)
    }
}
