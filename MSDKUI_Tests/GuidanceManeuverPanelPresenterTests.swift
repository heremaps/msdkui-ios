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
import XCTest

class GuidanceManeuverPanelPresenterTests: XCTestCase {
    /// The presenter.
    private var presenter: GuidanceManeuverPanelPresenter?

    /// The mock delegate used to verify expectations.
    private var mockDelegate = GuidanceManeuverPanelPresenterDelegateMock() // swiftlint:disable:this weak_delegate

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// This is the real `NMANavigationManager` method.
    private static var realNavigationManagerMethod: Method?

    /// This is the method used for mocking the real `NMANavigationManager` method.
    private static var mockNavigationManagerMethod: Method?

    /// This is the real `NMAPositioningManager` method.
    private static var realPositioningManagerMethod: Method?

    /// This is the method used for mocking the real `NMAPositioningManager` method.
    private static var mockPositioningManagerMethod: Method?

    /// Sets the method static variables.
    private static let setMethods: Void = {
        let realNavigationManagerInstance = NMANavigationManager.sharedInstance()
        let realNavigationManagerClass: AnyClass! = object_getClass(realNavigationManagerInstance)
        realNavigationManagerMethod = class_getClassMethod(realNavigationManagerClass, #selector(NMANavigationManager.sharedInstance))

        let mockNavigationManagerInstance = MockUtils()
        let mockNavigationManagerClass: AnyClass! = object_getClass(mockNavigationManagerInstance)
        mockNavigationManagerMethod = class_getClassMethod(mockNavigationManagerClass, #selector(MockUtils.mockNavigationManager))

        let realPositioningManagerInstance = NMAPositioningManager.sharedInstance()
        let realPositioningManagerClass: AnyClass! = object_getClass(realPositioningManagerInstance)
        realPositioningManagerMethod = class_getClassMethod(realPositioningManagerClass, #selector(NMAPositioningManager.sharedInstance))

        let mockPositioningManagerInstance = MockUtils()
        let mockPositioningManagerClass: AnyClass! = object_getClass(mockPositioningManagerInstance)
        mockPositioningManagerMethod = class_getClassMethod(mockPositioningManagerClass, #selector(MockUtils.mockPositioningManager))
    }()

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Once set the methods
        _ = GuidanceManeuverPanelPresenterTests.setMethods

        // Set up
        presenter = GuidanceManeuverPanelPresenter(route: MockUtils.mockRoute(), notificationCenter: mockNotificationCenter)
        presenter?.delegate = mockDelegate
        GuidanceManeuverPanelPresenterTests.swizzleMethods()
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        GuidanceManeuverPanelPresenterTests.deswizzleMethods()

        super.tearDown()
    }

    /// Tests the default observers, added when the object is initialized.
    func testDefaultObservables() {
        XCTAssertTrue(mockNotificationCenter.didCallAddObserver,
                      "It adds an observer.")

        XCTAssertEqual(mockNotificationCenter.lastNotificationName, .NMAPositioningManagerDidUpdatePosition,
                       "It adds an observer for the correct event.")
    }

    /// Tests when the delegate method `.navigationManager(_:didUpdateManeuvers:nextManeuver:)` is triggered.
    func testWhenNavigationManagerDidUpdateManeuversNextManeuverIsTriggered() {
        let expectedGuidanceData = GuidanceManeuverData(maneuverIcon: "maneuver_icon_4",
                                                        distance: "300 m",
                                                        info1: nil,
                                                        info2: "Invalidenstr.",
                                                        nextRoadIcon: nil)

        presenter?.navigationManager(.sharedInstance(), didUpdateManeuvers: NMANavigationManager.sharedInstance().currentManeuver, nil)

        XCTAssertTrue(mockDelegate.didCallDidUpdateData,
                      "It tells the delegate that data has been updated.")

        XCTAssertEqual(mockDelegate.lastData, expectedGuidanceData,
                       "It calls the delegate method with the correct guidance maneuver data")
    }

    /// Tests when the delegate method `.navigationManagerDidReachDestination(_:)` is triggered
    func testWhenNavigationManagerDidReachDestinationIsTriggered() {
        presenter?.navigationManagerDidReachDestination(.sharedInstance())

        XCTAssertTrue(mockDelegate.didCallDidReachDestination,
                      "It tells the delegate that destination has been reached.")

        XCTAssertEqual(mockDelegate.lastPresenter, presenter,
                       "It calls the delegate method with the correct presenter.")
    }

    /// Tests when a `NMAPositioningManagerDidUpdatePosition` notification is received.
    func testWhenNMAPositioningManagerDidUpdatePositionNotificationIsReceived() {
        let expectedGuidanceData = GuidanceManeuverData(maneuverIcon: "maneuver_icon_4",
                                                        distance: "300 m",
                                                        info1: nil,
                                                        info2: "Invalidenstr.",
                                                        nextRoadIcon: nil)

        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(mockDelegate.didCallDidUpdateData,
                      "It tells the delegate that data has been updated.")

        XCTAssertEqual(mockDelegate.lastData, expectedGuidanceData,
                       "It calls the delegate method with the correct guidance maneuver data")
    }

    /// Tests that voice feedback is controlled by the `GuidanceManeuverPanelPresenter.isVoiceEnabled` property.
    func testVoiceFeedbackDuringGuidance() {
        // By default voice should be enabled
        XCTAssertTrue(try require(presenter?.isVoiceEnabled), "By default, GuidanceManeuverPanelPresenter.isVoiceEnabled should be set to true")

        // Consequently, by default, voice feedbacks should be played
        var shouldPlayVoiceFeedback = presenter?.navigationManager(NMANavigationManager.sharedInstance(), shouldPlayVoiceFeedback: nil)
        XCTAssertTrue(try require(shouldPlayVoiceFeedback), "By default, voice feedbacks should be played")

        // When voice is disabled, the presenter should not let any voice feedback
        presenter?.isVoiceEnabled = false
        shouldPlayVoiceFeedback = presenter?.navigationManager(NMANavigationManager.sharedInstance(), shouldPlayVoiceFeedback: nil)
        XCTAssertFalse(try require(shouldPlayVoiceFeedback), "No voice feedback should be played")
    }

    /// Tests when "will reroute" callback is received.
    func testWhenNMAPositioningManagerWillRerouteNotificationIsReceived() {
        presenter?.navigationManagerWillReroute(.sharedInstance())

        XCTAssertTrue(mockDelegate.didCallDidUpdateData, "It calls the delegate")
        XCTAssertNil(mockDelegate.lastData, "Data set to nil")
        XCTAssertEqual(mockDelegate.lastPresenter, presenter, "It calls the delegate with correct presenter")
    }

    // MARK: - Private

    private static func swizzleMethods() {
        guard
            let realNavigationManagerMethod = realNavigationManagerMethod,
            let mockNavigationManagerMethod = mockNavigationManagerMethod,
            let realPositioningManagerMethod = realPositioningManagerMethod,
            let mockPositioningManagerMethod = mockPositioningManagerMethod else {
                XCTFail("Method swizzling failed!")
                return
        }

        method_exchangeImplementations(realNavigationManagerMethod, mockNavigationManagerMethod)
        method_exchangeImplementations(realPositioningManagerMethod, mockPositioningManagerMethod)
    }

    private static func deswizzleMethods() {
        guard
            let mockNavigationManagerMethod = mockNavigationManagerMethod,
            let realNavigationManagerMethod = realNavigationManagerMethod,
            let mockPositioningManagerMethod = mockPositioningManagerMethod,
            let realPositioningManagerMethod = realPositioningManagerMethod else {
                XCTFail("Method deswizzling failed!")
                return
        }

        method_exchangeImplementations(mockNavigationManagerMethod, realNavigationManagerMethod)
        method_exchangeImplementations(mockPositioningManagerMethod, realPositioningManagerMethod)
    }
}
