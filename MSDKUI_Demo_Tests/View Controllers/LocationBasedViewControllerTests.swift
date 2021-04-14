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

final class LocationBasedViewControllerTests: XCTestCase {
    /// The view controller under test which conforms to the `LocationBasedViewController` protocol.
    private var viewControllerUnderTest: WaypointViewController?

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The mock URL opener used to verify expectations.
    private var mockURLOpener = URLOpenerMock()

    /// The real `rootViewController` is replaced with `viewControllerUnderTest`.
    private let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as WaypointViewController
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        // Set mocked location authorization provider
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .authorizedAlways }

        // Set mocked URL opener
        viewControllerUnderTest?.urlOpener = mockURLOpener

        // Set mock notification center
        viewControllerUnderTest?.notificationCenter = mockNotificationCenter
    }

    override func tearDown() {
        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // MARK: - Tests

    /// Tests displaying alert when authorization is not granted.
    func testCheckLocationAuthorizationStatus() throws {
        // Set location auth as denied
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .denied }

        // Set up position update observer
        viewControllerUnderTest?.setUpLocationAuthorizationObserver()

        // Send notification
        mockNotificationCenter.lastBlock?(Notification(name: UIApplication.didBecomeActiveNotification))

        // Check if alert was displayed
        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        XCTAssertLocalized(
            alertController.title, key: "msdkui_app_userposition_notfound",
            "It presents an alert with the correct title."
        )

        XCTAssertEqual(
            alertController.actions.count, 2,
            "It presents an alert with the correct number of actions."
        )

        XCTAssertLocalized(
            alertController.actions[0].title, key: "msdkui_app_cancel",
            "It presents an alert with a cancel button."
        )

        XCTAssertEqual(
            alertController.actions[0].style, .cancel,
            "It presents an alert with the cancel style for the cancel button."
        )

        XCTAssertLocalized(
            alertController.actions[1].title, key: "msdkui_app_settings",
            "It presents an alert with an Settings button."
        )

        XCTAssertEqual(
            alertController.actions[1].style, .default,
            "It presents an alert with the default style for the ok button."
        )
    }

    /// Tests when the Cancel button is tapped for unauthorization location status alert.
    func testWhenCancelButtonIsTappedForUnauthorizationLocationStatusAlert() throws {
        // Set up position update observer
        viewControllerUnderTest?.setUpLocationAuthorizationObserver()

        // Set location auth as denied
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .denied }

        // Trigger the notification
        mockNotificationCenter.lastBlock?(Notification(name: UIApplication.didBecomeActiveNotification))

        // Retrieve the displayed alert
        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Tap the Cancel button (first button)
        alertController.tapButton(at: 0)

        XCTAssertNil(viewControllerUnderTest?.noLocationAlert, "It releases the no location alert")
    }

    /// Tests when the Settings button is tapped for unauthorization location status alert.
    func testWhenAppSettingsButtonIsTappedForUnauthorizationLocationStatusAlert() throws {
        // Set up position update observer
        viewControllerUnderTest?.setUpLocationAuthorizationObserver()

        // Set location auth as denied
        viewControllerUnderTest?.locationAuthorizationStatusProvider = { .denied }

        // Trigger the notification
        mockNotificationCenter.lastBlock?(Notification(name: UIApplication.didBecomeActiveNotification))

        // Retrieve the displayed alert
        let alertController = try require(viewControllerUnderTest?.presentedViewController as? UIAlertController)

        // Tap the Settings button (second button)
        alertController.tapButton(at: 1)

        XCTAssertNil(
            viewControllerUnderTest?.noLocationAlert,
            "It releases the no location alert"
        )

        XCTAssertTrue(
            mockURLOpener.didCallOpen,
            "It calls the URL Opener to open the Settings URL"
        )

        XCTAssertEqual(
            mockURLOpener.lastURL?.absoluteString, UIApplication.openSettingsURLString,
            "It opens the correct Settings URL"
        )

        XCTAssertEqual(
            mockURLOpener.lastOptions?.isEmpty, true,
            "It opens the correct Settings URL without options"
        )

        XCTAssertNil(
            mockURLOpener.lastCompletionHandler,
            "It opens the correct Settings URL without a completion handler"
        )
    }
}
