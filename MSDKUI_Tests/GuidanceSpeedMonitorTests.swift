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

final class GuidanceSpeedMonitorTests: XCTestCase {
    /// The monitor under test.
    private var speedMonitor: GuidanceSpeedMonitor?

    /// The mock notification center used to verify expectations.
    private var mockNotificationCenter = NotificationCenterObservingMock()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = GuidanceSpeedMonitorDelegateMock() // swiftlint:disable:this weak_delegate

    /// The mock current position provider used to verify expectations.
    private var mockCurrentPositionProvider = CurrentPositionProviderMock()

    override func setUp() {
        super.setUp()

        // Initializes the monitor using mocks instead of singletons
        speedMonitor = GuidanceSpeedMonitor(notificationCenter: mockNotificationCenter, positioningManager: mockCurrentPositionProvider)

        // Sets the monitor delegate using the mock delegate
        speedMonitor?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the monitor exists.
    func testExists() {
        XCTAssertNotNil(speedMonitor, "It exists")
    }

    /// Tests if the monitor stops the subscriptions when deallocated.
    func testMonitorDeallocation() {
        speedMonitor = nil

        XCTAssertTrue(mockNotificationCenter.didCallRemoveObserver, "It stops observing position changes")
    }

    /// Tests if the monitor observers position updates.
    func testPositionUpdateObserver() {
        XCTAssertEqual(mockNotificationCenter.didCallAddObserverCount, 2, "It adds two observers.")
    }

    /// Tests the behavior when current speed is known.
    func testWhenCurrentSpeedIsKnown() throws {
        // Stubs the current position provider mock to return a known speed
        let position = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 100, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: position)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 1,
            "It calls the delegate method once"
        )

        XCTAssert(
            mockDelegate.lastSpeedMonitor === speedMonitor,
            "It calls the delegate with the correct speed monitor"
        )

        XCTAssertEqual(
            mockDelegate.lastCurrentSpeed, Measurement(value: 100, unit: UnitSpeed.metersPerSecond),
            "It calls the delegate with the correct speed"
        )

        XCTAssertFalse(
            try require(mockDelegate.lastIsSpeeding),
            "It calls the delegate with the correct speeding information"
        )

        XCTAssertNil(
            mockDelegate.lastSpeedLimit,
            "It calls the delegate with the correct speed limit information"
        )
    }

    /// Tests the behavior when the same current speed is received multiple times.
    func testWhenSameCurrentSpeedIsUpdatedMultipleTimes() throws {
        // Stubs the current position provider mock to return a known speed
        let position = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 100, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: position)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 1,
            "It calls the delegate method once"
        )
    }

    /// Tests the behavior when current position is unknown after known.
    func testWhenCurrentPositionIsUnknownAfterKnown() {
        // Stubs the current position provider mock to return a valid position (and speed)
        let validPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 12, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: validPosition)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Stubs the current position provider mock to return nil for position
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: nil)

        // Triggers the `NMAPositioningManagerDidLosePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssert(
            mockDelegate.lastSpeedMonitor === speedMonitor,
            "It calls the delegate with the correct speed monitor"
        )

        XCTAssertNil(
            mockDelegate.lastCurrentSpeed,
            "It calls the delegate with the correct speed (nil)"
        )

        XCTAssertFalse(
            try require(mockDelegate.lastIsSpeeding),
            "It calls the delegate with the correct speeding information"
        )
    }

    /// Tests the behavior when current position is unknown after unknown.
    func testWhenCurrentPositionIsUnknownAfterUnknown() {
        // Stubs the current position provider mock to return nil for position
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: nil)

        // Triggers the `NMAPositioningManagerDidLosePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))

        XCTAssertFalse(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It doesn't tell the delegate there were changes on the speed/speed limit information"
        )
    }

    /// Tests the behavior when current speed is unknown after known.
    func testWhenCurrentSpeedIsUnknownAfterKnown() {
        // Stubs the current position provider mock to return a known speed
        let validPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 100, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: validPosition)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        let invalidPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: NMAGeoPositionUnknownValue, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: invalidPosition)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block again
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 2,
            "It calls the delegate method twice"
        )

        XCTAssert(
            mockDelegate.lastSpeedMonitor === speedMonitor,
            "It calls the delegate with the correct speed monitor"
        )

        XCTAssertNil(
            mockDelegate.lastCurrentSpeed,
            "It calls the delegate with the correct speed (nil)"
        )

        XCTAssertFalse(
            try require(mockDelegate.lastIsSpeeding),
            "It calls the delegate with the correct speeding information"
        )

        XCTAssertNil(
            mockDelegate.lastSpeedLimit,
            "It calls the delegate with the correct speed limit information"
        )
    }

    /// Tests the behavior when current speed is unknown after unknown.
    func testWhenCurrentSpeedIsUnknownAfterUnknown() {
        // Stubs the current position provider mock to return `NMAGeoPositionUnknownValue` for speed
        let position = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: NMAGeoPositionUnknownValue, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: position)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertFalse(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It doesn't tell the delegate there were changes on the speed/speed limit information"
        )
    }

    /// Tests the behavior when current position (and, therefore, speed) is unknown multiple times.
    func testWhenCurrentPositionIsUnknownMultipleTimes() {
        // Sets a valid position and speed
        let validPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 100, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: validPosition)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Sets an invalid position and speed
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: nil)

        // Triggers the `NMAPositioningManagerDidLosePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidLosePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertNil(
            mockDelegate.lastCurrentSpeed,
            "It calls the delegate with the correct current speed information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 2,
            "It calls the delegate method twice (one for the valid current speed and one for the invalid current speed)"
        )
    }

    /// Tests the behavior when current speed is known and speed limit is below current speed.
    func testWhenCurrentSpeedIsKnownAndSpeedLimitIsBelowCurrentSpeed() {
        // Stubs the current position provider mock to return a known speed
        let validPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 12, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: validPosition)

        // Creates a mock road element with speed limit below the current speed
        let mockRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 10)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssert(
            mockDelegate.lastSpeedMonitor === speedMonitor,
            "It calls the delegate with the correct speed monitor"
        )

        XCTAssertEqual(
            mockDelegate.lastCurrentSpeed, Measurement(value: 12, unit: UnitSpeed.metersPerSecond),
            "It calls the delegate with the correct speed"
        )

        XCTAssertTrue(
            try require(mockDelegate.lastIsSpeeding),
            "It calls the delegate with the correct speeding information"
        )

        XCTAssertEqual(
            mockDelegate.lastSpeedLimit, Measurement(value: 10, unit: UnitSpeed.metersPerSecond),
            "It calls the delegate with the correct speed limit information"
        )
    }

    /// Tests the behavior when current speed is known and speed limit is above current speed.
    func testWhenCurrentSpeedIsKnownAndSpeedLimitIsAboveCurrentSpeed() {
        // Stubs the current position provider mock to return a known speed
        let validPosition = NMAGeoPosition(coordinates: NMAGeoCoordinates(), speed: 12, course: 0, accuracy: 0)
        mockCurrentPositionProvider.stubCurrentPosition(toReturn: validPosition)

        // Creates a mock road element with speed limit above the current speed
        let mockRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 20)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssert(
            mockDelegate.lastSpeedMonitor === speedMonitor,
            "It calls the delegate with the correct speed monitor"
        )

        XCTAssertEqual(
            mockDelegate.lastCurrentSpeed, Measurement(value: 12, unit: UnitSpeed.metersPerSecond),
            "It calls the delegate with the correct speed"
        )

        XCTAssertFalse(
            try require(mockDelegate.lastIsSpeeding),
            "It calls the delegate with the correct speeding information"
        )

        XCTAssertEqual(
            mockDelegate.lastSpeedLimit, Measurement(value: 20, unit: UnitSpeed.metersPerSecond),
            "It calls the delegate with the correct speed limit information"
        )
    }

    /// Tests the behavior when road element is unknown.
    func testWhenRouteElementIsUnknown() {
        mockCurrentPositionProvider.stubRoadElement(toReturn: nil)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertFalse(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )
    }

    /// Tests the behavior when speed limit is unknown.
    func testWhenSpeedLimitIsUnknown() {
        // Sets a valid previous speed limit
        let mockValidRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 10)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockValidRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Creates a mock road element with speed limit 0 (unknown value, according to the HERE Maps SDK documentation)
        let mockInvalidRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 0)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockInvalidRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertNil(
            mockDelegate.lastSpeedLimit,
            "It calls the delegate with the correct speed limit information"
        )
    }

    /// Tests the behavior when speed limit is unknown multiple times.
    func testWhenSpeedLimitIsUnknownMultipleTimes() {
        // Sets a valid previous speed limit
        let mockValidRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 10)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockValidRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        // Creates a mock road element with speed limit 0 (unknown value, according to the HERE Maps SDK documentation)
        let mockInvalidRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 0)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockInvalidRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertNil(
            mockDelegate.lastSpeedLimit,
            "It calls the delegate with the correct speed limit information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 2,
            "It calls the delegate method twice (one for the valid speed limit and one for the invalid speed limit)"
        )
    }

    /// Tests the behavior when the same speed limit is updated multiple times.
    func testWhenSameSpeedLimitIsUpdatedMultipleTimes() {
        // Creates a mock road element
        let mockRoadElement = MockUtils.mockRoadElement(withSpeedLimit: 12)
        mockCurrentPositionProvider.stubRoadElement(toReturn: mockRoadElement)

        // Triggers the `NMAPositioningManagerDidUpdatePosition` notification block
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))
        mockNotificationCenter.lastBlock?(Notification(name: .NMAPositioningManagerDidUpdatePosition))

        XCTAssertTrue(
            mockDelegate.didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit,
            "It tells the delegate there were changes on the speed/speed limit information"
        )

        XCTAssertEqual(
            mockDelegate.didUpdateCurrentSpeedIsSpeedingSpeedLimitCount, 1,
            "It calls the delegate method once"
        )
    }
}
