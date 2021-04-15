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

final class WaypointEntryTests: XCTestCase {
    /// Note that we round up the values to 5th decimal
    /// when create the name out of the coordinates.
    private var waypoint = NMAWaypoint(geoCoordinates: NMAGeoCoordinates(latitude: 52.530555, longitude: 13.379257))

    // MARK: - Tests

    /// Tests that the default values are the expected ones.
    func testDefaultValues() {
        let entry = WaypointEntry(waypoint)

        // Has the draggable expected value?
        XCTAssertTrue(entry.draggable, "Not the expected draggable true value!")

        // Has the removable expected value?
        XCTAssertTrue(entry.removable, "Not the expected removable true value!")

        // Street address is nil
        XCTAssertNil(entry.streetAddress, "Street address is nil")
    }

    /// Tests that it is possible to a create `WaypointEntry` object with only a `NMAWaypoint` object.
    func testWaypointEntryWithoutName() {
        let expectedName = "52.53055, 13.37926"
        let entry = WaypointEntry(waypoint)

        // Is the waypoint set?
        XCTAssertNotNil(entry.waypoint, "No waypoint is set!")

        // Has the name expected value?
        XCTAssertEqual(entry.name, expectedName, "Not the expected name \"\(expectedName)\" but \"\(entry.name)\"!")

        // Steet address should be nil
        XCTAssertNil(entry.streetAddress, "Street address is not set")
    }

    /// Tests that when the `WaypointEntry` object is created with an empty `NMAWaypoint` object,
    /// it can be detected.
    func testWaypointEntryWithoutCoordinates() {
        let entry = WaypointEntryFixture.empty()

        // Has no coordinates?
        XCTAssertFalse(entry.isValid(), "Not the expected waypoint without coordinates!")
    }

    /// Tests that it is possible to a create `WaypointEntry` object with a `NMAWaypoint` object and a name.
    func testWaypointEntryWithName() {
        let entry = WaypointEntry(waypoint, name: "HERE")

        // Is the waypoint set?
        XCTAssertNotNil(entry.waypoint, "No waypoint is set!")

        // Has the name expected value?
        XCTAssertEqual(entry.name, "HERE", "Not the expected name \"HERE\"!")

        // Street address should be nil
        XCTAssertNil(entry.streetAddress, "Street address is not set")
    }

    /// Tests that it is possible to a create `WaypointEntry` object with a `NMAWaypoint` object, name and street address.
    func testWaypointEntryWithNameAndStreetAddress() {
        let entry = WaypointEntry(waypoint, name: "HERE", streetAddress: "Street address")

        // Is the waypoint set?
        XCTAssertNotNil(entry.waypoint, "No waypoint is set!")

        // Has the name expected value?
        XCTAssertEqual(entry.name, "HERE", "Not the expected name \"HERE\"!")

        // Has the street address expected value?
        XCTAssertEqual(entry.streetAddress, "Street address", "Not the expected street address \"Street address\"!")
    }

    /// Tests that it is possible to modify a `WaypointEntry` object afterwards.
    func testModifyWaypointEntry() {
        let entry = WaypointEntry(waypoint, name: "HERE")

        // Update the settings
        entry.name = "Invaliden Straße"
        entry.draggable = false
        entry.removable = false

        // Has the name updated value?
        XCTAssertEqual(entry.name, "Invaliden Straße", "Not the expected name \"Invaliden Straße\"!")

        // Has the draggable expected value?
        XCTAssertFalse(entry.draggable, "Not the expected draggable false value!")

        // Has the removable expected value?
        XCTAssertFalse(entry.removable, "Not the expected removable false value!")
    }
}
