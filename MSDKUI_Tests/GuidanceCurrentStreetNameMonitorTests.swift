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

final class GuidanceCurrentStreetNameMonitorTests: XCTestCase {
    /// The mock delegate used to verify expectations.
    private let mockDelegate = GuidanceCurrentStreetNameMonitorDelegateMock() // swiftlint:disable:this weak_delegate

    /// The mock dispatcher used to verify expectations.
    private let mockDispatcher = NavigationManagerDelegateDispatcherMock()

    /// The object under test.
    private var monitorUnderTest: GuidanceCurrentStreetNameMonitor?

    override func setUp() {
        super.setUp()

        // Creates the current street name monitor using the mock dispatcher
        monitorUnderTest = GuidanceCurrentStreetNameMonitor(navigationManagerDelegateDispatcher: mockDispatcher)

        // Sets the current street name monitor delegate using the mock delegate
        monitorUnderTest?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the current street name monitor exists.
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

    /// Tests if the delegate is called with the current street name.
    func testWhenNavigationManagerReturnsValidCurrentManeuver() {
        let currentManeuver = MockUtils.mockManeuver("Invalidenstraße")

        monitorUnderTest?.navigationManager(.sharedInstance(), didUpdateManeuvers: currentManeuver, nil)

        XCTAssertTrue(mockDelegate.didCallDidUpdateCurrentStreetName, "It notifies delegate")
        XCTAssertEqual(mockDelegate.lastMonitor, monitorUnderTest, "It is the same object")
        XCTAssertEqual(mockDelegate.lastCurrentStreetName, currentManeuver.getCurrentStreet(), "It calls the delegate with the correct street")
    }

    /// Tests if the delegate is called when the current street name is nil.
    func testWhenNavigationManagerReturnsNilCurrentManeuver() {
        monitorUnderTest?.navigationManager(.sharedInstance(), didUpdateManeuvers: nil, nil)

        XCTAssertTrue(mockDelegate.didCallDidUpdateCurrentStreetName, "It notifies delegate")
        XCTAssertEqual(mockDelegate.lastMonitor, monitorUnderTest, "It is the same object")
        XCTAssertNil(mockDelegate.lastCurrentStreetName, "It calls the delegate with nil")
    }
}
