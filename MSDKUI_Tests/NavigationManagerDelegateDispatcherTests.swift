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

@testable import MSDKUI
import XCTest

final class NavigationManagerDelegateDispatcherTests: XCTestCase {
    /// The object under test.
    private var dispatcherUnderTest = NavigationManagerDelegateDispatcher()

    // MARK: - Add

    /// Tests when one delegate is added.
    func testWhenADelegateObjectIsAdded() {
        let mockDelegate = NMANavigationManagerDelegateMock()

        // Adds a delegate
        dispatcherUnderTest.add(delegate: mockDelegate)

        XCTAssertFalse(
            dispatcherUnderTest.isEmpty,
            "It has delegates."
        )

        XCTAssertEqual(
            dispatcherUnderTest.count, 1,
            "It has one delegate."
        )

        XCTAssertTrue(
            NMANavigationManager.sharedInstance().delegate === dispatcherUnderTest,
            "It sets the dispatcher as the NMANavigationManager delegate."
        )
    }

    /// Tests when two delegates are added.
    func testWhenTwoDelegateObjectAreAdded() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds two delegate
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        XCTAssertFalse(
            dispatcherUnderTest.isEmpty,
            "It has delegates."
        )

        XCTAssertEqual(
            dispatcherUnderTest.count, 2,
            "It has two delegates."
        )

        XCTAssertTrue(
            NMANavigationManager.sharedInstance().delegate === dispatcherUnderTest,
            "It sets the dispatcher as the NMANavigationManager delegate."
        )
    }

    // MARK: - Remove

    /// Tests when the delegate is added and then removed.
    func testWhenADelegateObjectIsAddedAndRemoved() {
        let mockDelegate = NMANavigationManagerDelegateMock()

        // Adds and removes the delegate
        dispatcherUnderTest.add(delegate: mockDelegate)
        dispatcherUnderTest.remove(delegate: mockDelegate)

        XCTAssertTrue(
            dispatcherUnderTest.isEmpty,
            "It doesn't have delegates."
        )

        XCTAssertNil(
            NMANavigationManager.sharedInstance().delegate,
            "It removes the NMANavigationManager's delegate."
        )
    }

    /// Tests when two delegates are added but one is removed.
    func testWhenTwoDelegateObjectAreAddedAndOneRemoved() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds two delegates but removes one
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)
        dispatcherUnderTest.remove(delegate: mockDelegateA)

        XCTAssertFalse(
            dispatcherUnderTest.isEmpty,
            "It has delegates."
        )

        XCTAssertEqual(
            dispatcherUnderTest.count, 1,
            "It has one delegate."
        )

        XCTAssertTrue(
            NMANavigationManager.sharedInstance().delegate === dispatcherUnderTest,
            "It sets the dispatcher as the NMANavigationManager delegate."
        )
    }

    /// Tests when two delegates are added and then removed.
    func testWhenTwoDelegateObjectAreAddedAndRemoved() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds and removes both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)
        dispatcherUnderTest.remove(delegate: mockDelegateA)
        dispatcherUnderTest.remove(delegate: mockDelegateB)

        XCTAssertTrue(
            dispatcherUnderTest.isEmpty,
            "It doesn't have delegates."
        )

        XCTAssertNil(
            NMANavigationManager.sharedInstance().delegate,
            "It removes the NMANavigationManager's delegate."
        )
    }

    // MARK: - NMANavigationManagerDelegate Methods

    /// Tests when the method `.navigationManagerDidReachDestination(_:)` is triggered.
    func testWhenNavigationManagerDidReachDestinationIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidReachDestination(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManager(_:didUpdateManeuvers:_:)` is triggered.
    func testWhenNavigationManagerDidUpdateManeuversIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didUpdateManeuvers: nil, nil)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManager(_:didReachStopover:)` is triggered.
    func testWhenNavigationManagerDidReachStopoverIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let stopover = NMAWaypoint(geoCoordinates: NMAGeoCoordinates(latitude: 40, longitude: 2))

        dispatcherUnderTest.navigationManager(.sharedInstance(), didReachStopover: stopover)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateA.lastStopOver === stopover,
            "It calls the delegate method with the correct stopover."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastStopOver === stopover,
            "It calls the delegate method with the correct stopover."
        )
    }

    /// Tests when the method `.navigationManager(_:didUpdateLaneInformation:roadElement:)` is triggered.
    func testWhenNavigationManagerDidUpdateLaneInformationRoadElementIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didUpdateLaneInformation: [], roadElement: nil)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastLaneInformations?.isEmpty, true,
            "It calls the delegate method with the correct lane information."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastLaneInformations?.isEmpty, true,
            "It calls the delegate method with the correct lane information."
        )
    }

    /// Tests when the method `.navigationManager(_:didUpdateRealisticViewsForCurrentManeuver:)` is triggered.
    func testWhenNavigationManagerDidUpdateRealisticViewsForCurrentManeuverIsTriggered() throws {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let image = try require(NMAImageFixture.image())
        let realisticViews = [NSNumber(value: 42): ["mock_string": image]]

        dispatcherUnderTest.navigationManager(.sharedInstance(), didUpdateRealisticViewsForCurrentManeuver: realisticViews)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            try require(mockDelegateA.lastRealisticViews), realisticViews,
            "It calls the delegate method with the correct realistic views."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            try require(mockDelegateB.lastRealisticViews), realisticViews,
            "It calls the delegate method with the correct realistic views."
        )
    }

    /// Tests when the method `.navigationManager(_:didUpdateRealisticViewsForNextManeuver:)` is triggered.
    func testWhenNavigationManagerDidUpdateRealisticViewsForNextManeuverIsTriggered() throws {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let image = try require(NMAImageFixture.image())
        let realisticViews = [NSNumber(value: 42): ["mock_string": image]]

        dispatcherUnderTest.navigationManager(.sharedInstance(), didUpdateRealisticViewsForNextManeuver: realisticViews)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            try require(mockDelegateA.lastRealisticViews), realisticViews,
            "It calls the delegate method with the correct realistic views."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            try require(mockDelegateB.lastRealisticViews), realisticViews,
            "It calls the delegate method with the correct realistic views."
        )
    }

    /// Tests when the method `.navigationManagerDidInvalidateRealisticViews(_:)` is triggered.
    func testWhenNavigationManagerDidInvalidateRealisticViewsIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidInvalidateRealisticViews(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManager(_:didUpdateSpeedingStatus:forCurrentSpeed:speedLimit:)` is triggered.
    func testWhenNavigationManagerDidUpdateSpeedingStatusForCurrentSpeedSpeedLimitIsTriggered() throws {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didUpdateSpeedingStatus: true, forCurrentSpeed: 42.0, speedLimit: 40.0)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            try require(mockDelegateA.lastSpeedingStatus),
            "It calls the delegate method with the correct speeding status."
        )

        XCTAssertEqual(
            mockDelegateA.lastSpeed, 42.0,
            "It calls the delegate method with the correct speed."
        )

        XCTAssertEqual(
            mockDelegateA.lastSpeedLimit, 40.0,
            "It calls the delegate method with the correct speed limit."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            try require(mockDelegateB.lastSpeedingStatus),
            "It calls the delegate method with the correct speeding status."
        )

        XCTAssertEqual(
            mockDelegateB.lastSpeed, 42.0,
            "It calls the delegate method with the correct speed."
        )

        XCTAssertEqual(
            mockDelegateB.lastSpeedLimit, 40.0,
            "It calls the delegate method with the correct speed limit."
        )
    }

    /// Tests when the method `.navigationManagerDidLosePosition(_:)` is triggered.
    func testWhenNavigationManagerDidLosePositionIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidLosePosition(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManagerDidFindPosition(_:)` is triggered.
    func testWhenNavigationManagerDidFindPositionIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidFindPosition(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManagerWillReroute(_:)` is triggered.
    func testWhenNavigationManagerWillRerouteIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerWillReroute(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManagerDidReroute(_:)` is triggered.
    func testWhenNavigationManagerDidRerouteIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didRerouteWithError: .unknown)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
        XCTAssertEqual(mockDelegateA.lastError, .unknown, "It calls the delegate method with the correct error.")

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
        XCTAssertEqual(mockDelegateB.lastError, .unknown, "It calls the delegate method with the correct error.")
    }

    /// Tests when the method `.navigationManager(_:didChangeRoutingState:)` is triggered.
    func testWhenNavigationManagerDidChangeRoutingStateIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didChangeRoutingState: .on)

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastTrafficEnabledRoutingState, .on,
            "It calls the delegate method with the correct routing state."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastTrafficEnabledRoutingState, .on,
            "It calls the delegate method with the correct routing state."
        )
    }

    /// Tests when the method `.navigationManager(_:shouldPlayVoiceFeedback:)` is triggered.
    func testWhenNavigationManagerShouldPlayVoiceFeedbackIsTriggeredAndBothDelegatesReturnFalse() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Stubs both delegates to return 'false'
        mockDelegateA.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: false)
        mockDelegateB.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: false)

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let shouldPlay = dispatcherUnderTest.navigationManager(.sharedInstance(), shouldPlayVoiceFeedback: "Turn left. There's water ahead!")

        XCTAssertFalse(shouldPlay, "It returns false.")

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )
    }

    /// Tests when the method `.navigationManager(_:shouldPlayVoiceFeedback:)` is triggered.
    func testWhenNavigationManagerShouldPlayVoiceFeedbackIsTriggeredAndOneDelegateReturnsTrue() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Stubs one of the delegates to return 'true'
        mockDelegateA.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: true)
        mockDelegateB.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: false)

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let shouldPlay = dispatcherUnderTest.navigationManager(.sharedInstance(), shouldPlayVoiceFeedback: "Turn left. There's water ahead!")

        XCTAssertTrue(shouldPlay, "It returns true.")

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )
    }

    /// Tests when the method `.navigationManager(_:shouldPlayVoiceFeedback:)` is triggered.
    func testWhenNavigationManagerShouldPlayVoiceFeedbackIsTriggeredAndBothDelegatesReturnTrue() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Stubs both delegates to return 'true'
        mockDelegateA.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: true)
        mockDelegateB.stubNavigationManagerShouldPlayVoiceFeedback(andReturn: true)

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        let shouldPlay = dispatcherUnderTest.navigationManager(.sharedInstance(), shouldPlayVoiceFeedback: "Turn left. There's water ahead!")

        XCTAssertTrue(shouldPlay, "It returns true.")

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )
    }

    /// Tests when the method `.navigationManager(_:willPlayVoiceFeedback:)` is triggered.
    func testWhenNavigationManagerWillPlayVoiceFeedbackIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), willPlayVoiceFeedback: "Turn left. There's water ahead!")

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )
    }

    /// Tests when the method `.navigationManager(_:didPlayVoiceFeedback:)` is triggered.
    func testNavigationManagerDidPlayVoiceFeedbackIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManager(.sharedInstance(), didPlayVoiceFeedback: "Turn left. There's water ahead!")

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateA.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertEqual(
            mockDelegateB.lastText, "Turn left. There's water ahead!",
            "It calls the delegate method with the correct text."
        )
    }

    /// Tests when the method `.navigationManagerDidSuspendDueToInsufficientMapData(_:)` is triggered.
    func testWhenNavigationManagerDidSuspendDueToInsufficientMapDataIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidSuspendDueToInsufficientMapData(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    /// Tests when the method `.navigationManagerDidResumeDueToMapDataAvailability(_:)` is triggered.
    func testWhenNavigationManagerDidResumeDueToMapDataAvailabilityIsTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = NMANavigationManagerDelegateMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidResumeDueToMapDataAvailability(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )

        XCTAssertTrue(
            mockDelegateB.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }

    // MARK: - Corner Cases

    /// Tests when the object is added and removed before the method is triggered.
    func testWhenDelegateIsAddedAndRemovedAndMethodTriggered() {
        let mockDelegateA = NMANavigationManagerDelegateMock()

        // Adds and remove the delegate
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.remove(delegate: mockDelegateA)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidResumeDueToMapDataAvailability(.sharedInstance())

        XCTAssertNil(
            mockDelegateA.lastNavigationManager,
            "It doesn't call the delegate method."
        )
    }

    /// Tests when both comform to the protocol but only one implements the triggered method.
    func testWhenOnlyOneDelegateImplementsTheMethodTriggered() {
        class EmptyMock: NSObject, NMANavigationManagerDelegate {}

        let mockDelegateA = NMANavigationManagerDelegateMock()
        let mockDelegateB = EmptyMock()

        // Adds both delegates
        dispatcherUnderTest.add(delegate: mockDelegateA)
        dispatcherUnderTest.add(delegate: mockDelegateB)

        // Triggers the method
        dispatcherUnderTest.navigationManagerDidResumeDueToMapDataAvailability(.sharedInstance())

        XCTAssertTrue(
            mockDelegateA.lastNavigationManager === NMANavigationManager.sharedInstance(),
            "It calls the delegate method with the correct navigation manager."
        )
    }
}
