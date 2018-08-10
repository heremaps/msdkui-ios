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

@testable import MSDKUI
@testable import MSDKUI_Demo
import NMAKit
import UIKit
import XCTest

class GuidanceViewControllerTests: XCTestCase {
    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: GuidanceViewController?

    /// The real `rootViewController` is replaced with `viewControllerUnderTest` to get the
    /// orientation change notifications.
    let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromMainStoryboard() as GuidanceViewController

        // In order to get the orientation changes, set the `viewControllerUnderTest` as the `rootViewController`
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mock notification
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter

        // Load the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // As the route is not set, the presenter object is not created!
        // Create it with the mock route manually
        viewControllerUnderTest?.presenter = GuidanceManeuverPanelPresenter(route: MockUtils.mockRoute())
        viewControllerUnderTest?.presenter?.delegate = viewControllerUnderTest
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest?.mapView.isRenderAllowed = false

        // Done
        viewControllerUnderTest?.stopSimulation()

        // The default orientation
        XCUIDevice.shared.orientation = .portrait

        // Restore
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    /// Tests the status bar visibility under all the supported orientations.
    func testStatusBar() {
        XCUIDevice.shared.orientation = .portrait
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertFalse(viewControllerUnderTest?.prefersStatusBarHidden ?? true, "Status bar is hidden!")

        XCUIDevice.shared.orientation = .landscapeLeft
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertFalse(viewControllerUnderTest?.prefersStatusBarHidden ?? true, "Status bar is hidden!")

        XCUIDevice.shared.orientation = .landscapeRight
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertFalse(viewControllerUnderTest?.prefersStatusBarHidden ?? true, "Status bar is hidden!")
    }

    /// Checks the GuidanceViewController.preferredStatusBarStyle variable.
    func testStatusBarStyle() {
        XCTAssertEqual(viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
                       "Not the expected statusbar style!")
    }

    /// Tests the stop navigation button.
    func testStopNavigationButton() throws {
        XCTAssertNotNil(viewControllerUnderTest?.stopNavigationButton,
                        "The stop navigation button should exist")

        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.accessibilityIdentifier, "GuidanceViewController.stopNavigationButton",
                       "The stop navigation button should have the correct accessibility identifier")

        XCTAssertLocalized(viewControllerUnderTest?.stopNavigationButton.accessibilityLabel, key: "msdkui_app_stop_navigation",
                           "The stop navigation button should have the correct accessibility label")

        XCTAssertNil(viewControllerUnderTest?.stopNavigationButton.currentTitle,
                     "The stop navigation button should not have any title")

        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.backgroundColor, .colorSignificantLight,
                       "The stop navigation button should have the correct background color")

        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.layer.cornerRadius, 2,
                       "The stop navigation button should have the correct corner radius")

        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.tintColor, .colorSignificant,
                       "The stop navigation button should have the correct tint color")

        XCTAssertNotNil(viewControllerUnderTest?.stopNavigationButton.currentImage,
                        "The stop navigation button's image should exist")

        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.imageView?.frame.size, CGSize(width: 24, height: 24),
                       "The stop navigation button's image should have the correct size")

        let expectedImage = try require(UIImage(named: "Clear", in: Bundle(for: GuidanceViewController.self), compatibleWith: nil))
        XCTAssertEqual(viewControllerUnderTest?.stopNavigationButton.currentImage, expectedImage,
                       "The stop navigation button should have correct image")
    }

    /// Tests the stop navigation button tap.
    func testStopNavigationButtonTapped() throws {
        // Create navigation stack
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.instantiateFromMainStoryboard() as LandingViewController
        UIApplication.shared.keyWindow?.rootViewController?.present(try require(viewControllerUnderTest), animated: false)
        XCTAssertEqual(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController, viewControllerUnderTest,
                       "View controller under test should be presented")

        viewControllerUnderTest?.startGuidance()
        XCTAssertNotEqual(NMANavigationManager.sharedInstance().navigationState, .running,
                          "Navigation manager should be started")

        viewControllerUnderTest?.stopNavigationButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(NMANavigationManager.sharedInstance().navigationState, .idle,
                       "Navigation manager should be stopped")
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController is LandingViewController, "Should be a LandingViewController")
    }

    /// Tests the GuidanceManeuverPanelPresenterDelegate callbacks.
    func testCallbacks() throws {
        let presenter = try require(viewControllerUnderTest?.presenter)
        let data = GuidanceManeuverData()

        viewControllerUnderTest?.guidanceManeuverPanelPresenter(presenter, didUpdateData: data)

        // Is the data passed?
        XCTAssertNotNil(viewControllerUnderTest?.panel.data, "Maneuver panel has no data!")
        XCTAssertEqual(viewControllerUnderTest?.panel.data, data, "Maneuver panel hasn't the data!")

        viewControllerUnderTest?.guidanceManeuverPanelPresenterDidReachDestination(presenter)

        // Are the Info2 labels highlighted?
        viewControllerUnderTest?.panel.info2Labels.forEach {
            XCTAssertEqual($0.textColor, Styles.shared.guidanceManeuverArrivalTextColor,
                           "Maneuver panel info2 labels not highlighted!")
        }
    }

    /// Tests failed rerouting for empty and nil routes.
    func testFailedRerouting() throws {
        try failedRerouting(with: MockUtils.mockRouteResult(with: []))
        try failedRerouting(with: MockUtils.mockRouteResult(with: nil))
    }

    /// Tests failed rerouting.
    private func failedRerouting(with failingRouteResult: NMARouteResult) throws {
        let viewControllerUnderTest = try require(self.viewControllerUnderTest)
        let routeBefore = viewControllerUnderTest.route
        let mapRouteBefore = viewControllerUnderTest.mapRoute

        viewControllerUnderTest.navigationManager(NMANavigationManager.sharedInstance(), didUpdateRoute: failingRouteResult)

        XCTAssertEqual(viewControllerUnderTest.route, routeBefore, "Failed rerouting should not change the route")
        XCTAssertEqual(viewControllerUnderTest.mapRoute, mapRouteBefore, "Failed rerouting should not change the map route")
    }
}
