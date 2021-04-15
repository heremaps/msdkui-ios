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

import Foundation
@testable import MSDKUI
import XCTest

final class GuidanceNextManeuverMonitorTests: XCTestCase {
    /// The mock delegate used to verify expectations.
    private var mockDelegate = GuidanceNextManeuverMonitorDelegateMock() // swiftlint:disable:this weak_delegate

    /// The mock dispatcher used to verify expectations.
    private let mockDispatcher = NavigationManagerDelegateDispatcherMock()

    /// The object under test.
    private var monitorUnderTest: GuidanceNextManeuverMonitor?

    override func setUp() {
        super.setUp()

        // Creates the next maneuver monitor using the mock dispatcher
        monitorUnderTest = GuidanceNextManeuverMonitor(route: MockUtils.mockRoute(), navigationManagerDelegateDispatcher: mockDispatcher)

        // Sets the next maneuver delegate using the mock delegate
        monitorUnderTest?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the next maneuver monitor exists.
    func testExists() {
        XCTAssertNotNil(monitorUnderTest, "It exists")
    }

    /// Tests the monitor adds/removes itself from the dispatcher.
    func testMonitorUsesDispather() throws {
        XCTAssertTrue(mockDispatcher.didCallAdd, "The monitor is added")
        XCTAssertTrue(mockDispatcher.lastPassedDelegate === monitorUnderTest, "It is the same object")

        monitorUnderTest = nil

        XCTAssertTrue(mockDispatcher.didCallRemove, "The monitor is removed")
    }

    /// Tests if the route is updated with `GuidanceNextManeuverMonitor.updateRoute(_:)`.
    func testUpdateRoute() {
        let newRoute = MockUtils.mockRoute()

        monitorUnderTest?.updateRoute(newRoute)

        XCTAssertEqual(monitorUnderTest?.route, newRoute, "The route is updated")
    }

    /// Tests when there is no next maneuver,
    /// `GuidanceNextManeuverMonitorDelegate.guidanceNextManeuverMonitorDidReceiveError(_:)`
    /// is called.
    func testWhenNoNextManeuverExistsDelegateDidReceiveErrorMethodIsCalled() {
        monitorUnderTest?.navigationManager(NMANavigationManager.sharedInstance(), didUpdateManeuvers: nil, nil)

        XCTAssertEqual(mockDelegate.lastNextManeuverMonitor, monitorUnderTest, "It calls the delegate with the correct monitor")
        XCTAssertTrue(mockDelegate.didCallDidReceiveError, "It calls the did receive error method")
    }

    /// Tests when the `NMAManeuver.distanceFromPreviousManeuver` property has a large value,
    /// `GuidanceNextManeuverMonitorDelegate.guidanceNextManeuverMonitorDidReceiveError(_:)`
    /// is called.
    func testWhenNextManeuverIsFarAwayDelegateDidReceiveErrorMethodIsCalled() {
        let nextManuever = MockUtils.mockNextManeuver(
            UInt(3756),
            with: NMAManeuverIcon.uTurnLeft,
            andNextStreet: "Friedrichstr."
        )
        monitorUnderTest?.navigationManager(NMANavigationManager.sharedInstance(), didUpdateManeuvers: nil, nextManuever)

        XCTAssertEqual(mockDelegate.lastNextManeuverMonitor, monitorUnderTest, "It calls the delegate with the correct monitor")
        XCTAssertTrue(mockDelegate.didCallDidReceiveError, "It calls the did receive error method")
    }

    /// Tests when the `NMAManeuver.distanceFromPreviousManeuver` property has a small value,
    /// `GuidanceNextManeuverMonitor.navigationManager(_:didUpdateManeuvers:_:)`
    /// is called.
    func testWhenNextManeuverIsCloseDelegateDidReveiveDataMethodIsCalled() {
        let mockData = (
            distance: UInt(97),
            nextStreet: "Invalidenstr."
        )
        let nextManuever = MockUtils.mockNextManeuver(
            mockData.distance,
            with: NMAManeuverIcon.keepRight,
            andNextStreet: mockData.nextStreet
        )
        monitorUnderTest?.navigationManager(NMANavigationManager.sharedInstance(), didUpdateManeuvers: nil, nextManuever)

        XCTAssertEqual(mockDelegate.lastNextManeuverMonitor, monitorUnderTest, "It calls the delegate with the correct monitor")
        XCTAssertTrue(mockDelegate.didCallDidReceiveManeuverData, "It calls the did receive data method")
        XCTAssertNotNil(mockDelegate.lastManeuverIcon, "It passes a maneuver icon image")
        XCTAssertEqual(mockDelegate.lastStreetName, mockData.nextStreet, "It passes the correct next street name")
        XCTAssertEqual(
            mockDelegate.lastDistance,
            Measurement<UnitLength>(value: Double(mockData.distance), unit: .meters),
            "It passes the correct next maneuver distance"
        )
    }

    /// Tests when there `NMAManeuver` is well formed,
    /// `GuidanceNextManeuverMonitor.navigationManager(_:didUpdateManeuvers:_:)`
    /// is called.
    func testWhenNextManeuverHasNoNextStreetNameDelegateDidReveiveDataMethodIsCalled() {
        let mockDistance = UInt(796)
        let nextManuever = MockUtils.mockNextManeuver(
            mockDistance,
            with: NMAManeuverIcon.lightLeft,
            andNextStreet: nil
        )

        monitorUnderTest?.navigationManager(NMANavigationManager.sharedInstance(), didUpdateManeuvers: nil, nextManuever)

        XCTAssertEqual(mockDelegate.lastNextManeuverMonitor, monitorUnderTest, "It calls the delegate with the correct monitor")
        XCTAssertTrue(mockDelegate.didCallDidReceiveManeuverData, "It calls the did receive data method")
        XCTAssertNotNil(mockDelegate.lastManeuverIcon, "It passes a maneuver icon image")
        XCTAssertNil(mockDelegate.lastStreetName, "It passes the nil street name")
        XCTAssertEqual(
            mockDelegate.lastDistance,
            Measurement<UnitLength>(value: Double(mockDistance), unit: .meters),
            "It passes the correct next maneuver distance"
        )
    }
}
