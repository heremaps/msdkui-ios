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

final class RouteOverviewViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: RouteOverviewViewController?

    /// The mock map route handler used to verify expectations.
    private var mockMapRouteHandler = MapRouteHandlerMock()

    /// The mock map viewport handler used to verify expectations.
    private var mockMapViewportHandler = MapViewportHandlerMock()

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The mock core router used to verify expectations.
    private var mockCoreRouter = NMACoreRouterMock()

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    /// The test target address.
    private let toAddress = "Platz der Republik 1"

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as RouteOverviewViewController

        viewControllerUnderTest?.toAddress = toAddress

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mock notification center
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter

        // Set mock map route handler
        mockMapRouteHandler.stubMapRoute(toReturn: MockUtils.mockMapRoute())
        viewControllerUnderTest?.mapRouteHandler = mockMapRouteHandler

        // Set mock map viewport handler
        viewControllerUnderTest?.mapViewportHandler = mockMapViewportHandler

        // Set the core router mock
        viewControllerUnderTest?.router = mockCoreRouter

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

    /// Tests the accessibility elements.
    func testAccessibility() {
        XCTAssertEqual(
            viewControllerUnderTest?.backButton.accessibilityIdentifier, "RouteOverviewViewController.backButton",
            "The backButton has the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.mapView.accessibilityIdentifier, "RouteOverviewViewController.mapView",
            "The mapView has the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.containerView.accessibilityIdentifier, "RouteOverviewViewController.containerView",
            "The containerView has the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.showManeuversButton.accessibilityIdentifier, "RouteOverviewViewController.showManeuversButton",
            "The showManeuversButton has the correct accessibility identifier"
        )
        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.accessibilityIdentifier, "RouteOverviewViewController.startNavigationButton",
            "The startNavigationButton has the correct accessibility identifier"
        )
    }

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(
            viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
            "It has the correct status bar style"
        )
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertNotNil(
            viewControllerUnderTest?.backButton,
            "The back button exists"
        )

        XCTAssertNotEqual(
            viewControllerUnderTest?.backButton.title, "msdkui_app_back",
            "The back button title is localized"
        )

        XCTAssertLocalized(
            viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
            "The back button has the correct title"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
            "The back button has the correct tint color"
        )
    }

    /// Tests the navigation button.
    func testNavigationButtonState() {
        XCTAssertNotNil(
            viewControllerUnderTest?.startNavigationButton,
            "The start navigation button exists"
        )

        XCTAssertNotEqual(
            viewControllerUnderTest?.startNavigationButton.currentTitle, "msdkui_app_guidance_button_start",
            "The start navigation button title is localized"
        )

        XCTAssertLocalized(
            viewControllerUnderTest?.startNavigationButton.currentTitle, key: "msdkui_app_guidance_button_start",
            "The start navigation button has the correct title"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.backgroundColor, .colorAccent,
            "The start navigation button has the correct background color"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.layer.cornerRadius, 2,
            "The start navigation button has the correct corner radius"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.currentTitleColor, .colorForegroundLight,
            "The start navigation button has the correct title color"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.titleLabel?.font, UIFont.preferredFont(forTextStyle: .callout),
            "The start navigation button has the correct font"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.titleLabel?.lineBreakMode, .byTruncatingTail,
            "The start navigation button has the correct line break mode"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.startNavigationButton.titleEdgeInsets, UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
            "The start navigation button has the correct edge insets for title"
        )
    }

    /// Tests that the address line starts with "To".
    func testAddressLineStartsWithTo() {
        XCTAssertLocalized(viewControllerUnderTest?.toLabel.text, key: "msdkui_app_routeoverview_to", "It has the correct address line")
    }

    /// Tests that the address line contains the address.
    func testAddressLineContainsTheAddressSet() {
        XCTAssertEqual(
            viewControllerUnderTest?.addressLabel.text, toAddress,
            "The address line contains '\(toAddress)'"
        )
    }

    /// Tests that the address line is visible in the portrait orientation.
    func testAddressLineIsVisibleInPortraitOrientation() {
        XCTAssertFalse(
            try require(viewControllerUnderTest?.destinationView.isHidden),
            "The address line is hidden in portrait orientation"
        )
    }

    /// Tests if the hud is displayed when the view loads and coordinates are set.
    func testHUDWhenViewLoadsAndCoordinatesAreSet() throws {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(try require(viewControllerUnderTest?.containerView.isHidden), "It hides the container")
        XCTAssertTrue(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It animates the spinner view")
        XCTAssertTrue(try require(viewControllerUnderTest?.panelView.isHidden), "It hides the panel view")
        XCTAssertFalse(try require(viewControllerUnderTest?.noRouteLabel.isHidden), "It shows the 'no route' label")
    }

    /// Tests if the hud is displayed when the view loads and coordinates are not set.
    func testHUDWhenViewLoadsAndCoordinatesAreNotSet() throws {
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertFalse(try require(viewControllerUnderTest?.containerView.isHidden), "It shows the container")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner view")
        XCTAssertTrue(try require(viewControllerUnderTest?.panelView.isHidden), "It hides the panel view")
        XCTAssertFalse(try require(viewControllerUnderTest?.noRouteLabel.isHidden), "It shows the 'no route' label")
    }

    /// Tests that the address line is hidden in the landscape orientations.
    func testAddressLineIsHiddenInLandscapeOrientations() throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)
        let predicate = NSPredicate(format: "isHidden == true")

        expectation(for: predicate, evaluatedWith: viewControllerUnderTest.destinationView)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)

        expectation(for: predicate, evaluatedWith: viewControllerUnderTest.destinationView)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)
    }

    /// Tests that having no `toAddress` makes the address line hidden in the portrait orientation.
    func testAddressLineHiddenInPortraitOrientationWhenNoAddressSet() throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)
        let predicate = NSPredicate(format: "isHidden == true")

        // Switch to landscape orientation from the default portrait orientation
        expectation(for: predicate, evaluatedWith: viewControllerUnderTest.destinationView)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)

        // Clear the `toAddress`
        viewControllerUnderTest.toAddress = nil

        // Switch to portrait orientation
        expectation(for: predicate, evaluatedWith: viewControllerUnderTest.destinationView)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)
    }

    /// Tests map with displayed route does force update viewport when orientation changes.
    func testMapWithDisplayedRouteViewportUpdatedsWhenOrientationChanges() throws {
        // Draws the route
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler with route results
        let mockRoute = MockUtils.mockRoute()
        let mockRouteResult = MockUtils.mockRouteResult(with: [mockRoute])
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        // Reset mock map viewport handler
        mockMapViewportHandler = MapViewportHandlerMock()
        viewControllerUnderTest?.mapViewportHandler = mockMapViewportHandler

        // Switch to landscape orientation from the default portrait orientation
        let predicate = NSPredicate(format: "didCallSetViewport == true")
        expectation(for: predicate, evaluatedWith: mockMapViewportHandler)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)
    }

    /// Tests map without displayed route doesn't force update viewport when orientation changes.
    func testMapWithoutDisplayedRouteViewportUpdatedsWhenOrientationChanges() {
        // Switch to landscape orientation from the default portrait orientation
        let predicate = NSPredicate(format: "orientation == \(UIInterfaceOrientation.landscapeRight.rawValue)")
        expectation(for: predicate, evaluatedWith: UIDevice.current)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
        waitForExpectations(timeout: 5)

        XCTAssertFalse(mockMapViewportHandler.didCallSetViewport, "It doesn't call the map viewport handler to set map's viewport")
    }

    /// Tests route description item.
    func testRouteDescriptionItemWhenViewLoads() {
        // Triggers the map view delegate method
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertEqual(
            viewControllerUnderTest?.routeDescriptionItem.trafficEnabled, viewControllerUnderTest?.mapView.isTrafficVisible,
            "It respects map view's traffic visibility"
        )
    }

    // MARK: - Route calculation

    /// Tests if the route gets calculated when the view loads.
    func testRouteCalculationWhenViewLoads() {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the map view delegate method
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(mockCoreRouter.didCallCalculateRouteWithStopsRoutingMode, "It calls core router to calculate a route")
        XCTAssertEqual(mockCoreRouter.lastStops?.count, 2, "It passes two waypoints to the core router")
        XCTAssertEqual(mockCoreRouter.lastRoutingMode?.transportMode, .car, "It passes a car as transport mode")
        XCTAssertEqual(mockCoreRouter.lastRoutingMode?.resultLimit, 1, "It requests a single route result")
    }

    /// Tests when route calculation finishes and returns a valid route.
    func testWhenRouteCalculationReturnsValidRoute() {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler with route results
        let mockRoute = MockUtils.mockRoute()
        let mockRouteResult = MockUtils.mockRouteResult(with: [mockRoute])
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        XCTAssertEqual(viewControllerUnderTest?.route, mockRoute, "It updates the route information with the correct route")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner animation")
        XCTAssertFalse(try require(viewControllerUnderTest?.containerView.isHidden), "It shows the container view")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner view")
    }

    /// Tests when route calculation finishes but returns an error.
    func testWhenRouteCalculationReturnsError() {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // let mapView = try require(viewControllerUnderTest?.mapView)

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler with error
        mockCoreRouter.lastCompletion?(nil, .invalidParameters)

        XCTAssertNil(viewControllerUnderTest?.route, "It doesn't update the route information")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner animation")
        XCTAssertFalse(try require(viewControllerUnderTest?.containerView.isHidden), "It shows the container view")
    }

    /// Tests when route calculation finishes and returns a route with restrictions (aka "relaxed truck options").
    func testWhenRouteCalculationReturnsRouteWithRestrictions() {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler with route results
        let mockRoute = MockUtils.mockRoute()
        let mockRouteResult = MockUtils.mockRouteResult(with: [mockRoute])
        mockCoreRouter.lastCompletion?(mockRouteResult, .violatesOptions)

        XCTAssertEqual(viewControllerUnderTest?.route, mockRoute, "It updates the route information with the correct route")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner animation")
        XCTAssertFalse(try require(viewControllerUnderTest?.containerView.isHidden), "It shows the container view")
        XCTAssertFalse(try require(viewControllerUnderTest?.activityIndicator.isAnimating), "It stops the spinner view")
    }

    // MARK: - NMAMapViewDelegate

    /// Tests when the core router returns a route.
    func testWhenCoreRouterReturnsRoute() throws {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler with route results
        let mockRoute = MockUtils.mockRoute()
        let mockRouteResult = MockUtils.mockRouteResult(with: [mockRoute])
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        XCTAssertTrue(mockMapRouteHandler.didCallAddMapRouteToMapView, "It calls the map route handler to add a marker to the map")
        XCTAssertTrue(mockMapViewportHandler.didCallSetViewport, "It calls the map viewport handler to set map's viewport")
        XCTAssertEqual(mockMapRouteHandler.lastRoute, mockRoute, "It adds the correct route to the map")
        XCTAssertFalse(try require(viewControllerUnderTest?.panelView.isHidden), "It shows the panel view")
        XCTAssertTrue(try require(viewControllerUnderTest?.noRouteLabel.isHidden), "It hides the 'no route' label")
    }

    /// Tests when the core router doesn't return route.
    func testWhenCoreRouterDoesntReturnRoute() throws {
        viewControllerUnderTest?.fromCoordinates = NMAGeoCoordinatesFixture.berlinCenter()
        viewControllerUnderTest?.toCoordinates = NMAGeoCoordinatesFixture.berlinReichstag()

        // Triggers the view did load method (to trigger core router request)
        viewControllerUnderTest?.viewDidLoad()

        // Triggers the core router completion handler without routes
        let mockRouteResult = MockUtils.mockRouteResult(with: [])
        mockCoreRouter.lastCompletion?(mockRouteResult, .none)

        XCTAssertFalse(mockMapRouteHandler.didCallAddMapRouteToMapView, "It doesn't call the map route handler to add a marker to the map")
        XCTAssertFalse(mockMapViewportHandler.didCallSetViewport, "It doesn't call the map viewport handler to set map's viewport")
        XCTAssertTrue(try require(viewControllerUnderTest?.panelView.isHidden), "It hides the panel view")
        XCTAssertFalse(try require(viewControllerUnderTest?.noRouteLabel.isHidden), "It shows the 'no route' label")
    }
}
