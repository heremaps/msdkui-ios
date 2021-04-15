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

final class GuidanceEstimatedArrivalMonitorTests: XCTestCase {

    /// The object under test.
    private var estimatedArrivalMonitor: GuidanceEstimatedArrivalMonitor?

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = GuidanceEstimatedArrivalMonitorDelegateMock() // swiftlint:disable:this weak_delegate

    /// The mock provider used to stub and verify expectations.
    private var mockEstimatedArrivalProvider = EstimatedArrivalProviderMock()

    override func setUp() {
        super.setUp()

        // Initializes the arrival monitor using mocks instead of NotificationCenter and NMANavigationManager singletons
        estimatedArrivalMonitor = GuidanceEstimatedArrivalMonitor(notificationCenter: mockNotificationCenter,
                                                                  estimatedArrivalProvider: mockEstimatedArrivalProvider)

        // Sets the arrival monitor delegate using the mock delegate
        estimatedArrivalMonitor?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the estimated arrival monitor exists.
    func testExists() {
        XCTAssertNotNil(estimatedArrivalMonitor, "It exists")
    }

    /// Tests if the estimated arrival monitor stops observing position updates when deallocated.
    func testMonitorDeallocation() {
        estimatedArrivalMonitor = nil

        XCTAssertTrue(mockNotificationCenter.didCallRemoveObserver, "It stops observing position changes")
    }

    /// Tests if the estimated arrival monitor observers position updates.
    func testPositionUpdateObserver() {
        XCTAssertEqual(mockNotificationCenter.lastNotificationName, .NMAPositioningManagerDidUpdatePosition,
                       "It is registered to receive notifications when the position changes")
    }

    /// Tests the behavior when the `.NMAPositioningManagerDidUpdatePosition` notification is triggered.
    func testWhenUpdatePositionNotificationIsTriggeredWithValidEstimatedValues() throws {
        // Stubs the estimated arrival provider to return '100 meters' to reach destination
        mockEstimatedArrivalProvider.stubDistanceToDestination(toReturn: 100)

        // Stubs the estimated arrival provider to return '10 seconds' to reach destination
        mockEstimatedArrivalProvider.stubTimeToArrival(forTrafficModel: .optimal, toReturn: 10)

        // Triggers the notification observer block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Checks if the delegate got called (with the correct parameters)
        XCTAssertTrue(mockDelegate.didCallDidChangeTimeOfArrivalDistanceDuration, "It tells the delegate the estimated arrival changed")
        XCTAssertTrue(mockDelegate.lastEstimatedArrivalMonitor === estimatedArrivalMonitor, "It calls the delegate with the correct monitor")
        XCTAssert(try require(mockDelegate.lastTimeOfArrival) > Date(), "It calls the delegate with a estimate time of arrival in the future")
        XCTAssertEqual(mockDelegate.lastDistance, Measurement<UnitLength>(value: 100, unit: .meters), "It calls the delegate with the correct distance")
        XCTAssertEqual(mockDelegate.lastDuration, Measurement<UnitDuration>(value: 10, unit: .seconds), "It calls the delegate with the correct duration")
    }

    /// Tests the behavior when the `.NMAPositioningManagerDidUpdatePosition` notification is triggered with
    /// inconsistent distance to destination.
    func testWhenUpdatePositionNotificationIsTriggeredWithValidInvalidDistance() throws {
        // Stubs the estimated arrival provider to return `NMANavigationManagerInvalidValue` to reach destination
        mockEstimatedArrivalProvider.stubDistanceToDestination(toReturn: NMANavigationManagerInvalidValue)

        // Stubs the estimated arrival provider to return '10 seconds' to reach destination
        mockEstimatedArrivalProvider.stubTimeToArrival(forTrafficModel: .optimal, toReturn: 10)

        // Triggers the notification observer block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Checks if the delegate got called (with the correct parameters)
        XCTAssertTrue(mockDelegate.didCallDidChangeTimeOfArrivalDistanceDuration, "It tells the delegate the estimated arrival changed")
        XCTAssertTrue(mockDelegate.lastEstimatedArrivalMonitor === estimatedArrivalMonitor, "It calls the delegate with the correct monitor")
        XCTAssert(try require(mockDelegate.lastTimeOfArrival) > Date(), "It calls the delegate with a estimate time of arrival in the future")
        XCTAssertNil(mockDelegate.lastDistance, "It calls the delegate with nil distance")
        XCTAssertEqual(mockDelegate.lastDuration, Measurement<UnitDuration>(value: 10, unit: .seconds), "It calls the delegate with the correct duration")
    }

    /// Tests the behavior when the `.NMAPositioningManagerDidUpdatePosition` notification is triggered with
    /// inconsistent travel duration to destination.
    func testWhenUpdatePositionNotificationIsTriggeredWithValidInvalidDuration() throws {
        // Stubs the estimated arrival provider to return '100 meters' to reach destination
        mockEstimatedArrivalProvider.stubDistanceToDestination(toReturn: 100)

        // Stubs the estimated arrival provider to return -DBL_MAX to reach destination
        mockEstimatedArrivalProvider.stubTimeToArrival(forTrafficModel: .optimal, toReturn: -.greatestFiniteMagnitude)

        // Triggers the notification observer block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Checks if the delegate got called (with the correct parameters)
        XCTAssertTrue(mockDelegate.didCallDidChangeTimeOfArrivalDistanceDuration, "It tells the delegate the estimated arrival changed")
        XCTAssertTrue(mockDelegate.lastEstimatedArrivalMonitor === estimatedArrivalMonitor, "It calls the delegate with the correct monitor")
        XCTAssertNil(mockDelegate.lastTimeOfArrival, "It calls the delegate with nil arrival in the future")
        XCTAssertEqual(mockDelegate.lastDistance, Measurement<UnitLength>(value: 100, unit: .meters), "It calls the delegate with the correct distance")
        XCTAssertNil(mockDelegate.lastDuration, "It calls the delegate with nil duration")
    }
}
