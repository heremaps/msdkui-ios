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

final class WaypointItemTests: XCTestCase {
    private var list = WaypointList(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)
    private var entries: [WaypointEntry]!
    private let indexPath0 = IndexPath(row: 0, section: 0)
    private let indexPath1 = IndexPath(row: 1, section: 0)

    /// Is an entry removed?
    private var removedEntry = false

    /// Is dragging an item started?
    private var dragStarted = false

    override func setUp() {
        super.setUp()

        // Create the WaypointEntry object
        let coordinates = NMAGeoCoordinates(latitude: 52.530555, longitude: 13.379257)
        let waypoint = NMAWaypoint(geoCoordinates: coordinates)

        // Create the WaypointList object
        entries = [WaypointEntry](
            cloneValue: WaypointEntry(waypoint, name: "HERE"),
            count: list.minWaypointItems
        )
        list.waypointEntries = entries
    }

    // MARK: - Tests

    /// Tests that the default values are the expected ones.
    func testDefaultValues() throws {
        let item = try require(list.cellForRow(at: indexPath0))
        let waypoint = try getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertTrue(waypoint.removeButton.isHidden, "Remove button is visible!")

        // Is the entry name OK?
        XCTAssertEqual(waypoint.label.text, entries.first?.name, "Not the expected name \(String(describing: entries.first?.name))!")
    }

    /// Tests remove button is visible when more than minimum entries.
    func testRemoveButtonVisibleWithMoreThanMinWaypoints() throws {
        list.addEntry(try require(entries.first))

        let item = try require(list.cellForRow(at: indexPath0))
        let waypoint = try getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertFalse(waypoint.removeButton.isHidden, "Remove button is hidden!")
    }

    /// Tests remove button changes based on number of entries.
    func testRemoveButtonVisibiltyDependsOnWaypoints() throws {
        list.addEntry(try require(entries.first))

        var item = try require(list.cellForRow(at: indexPath0))
        var waypoint = try getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertFalse(waypoint.removeButton.isHidden, "Remove button should be visible!")

        list.removeEntry(at: list.entryCount - 1)
        item = try require(list.cellForRow(at: indexPath0))
        waypoint = try getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertTrue(waypoint.removeButton.isHidden, "Remove button is still visible!")
    }

    // MARK: - Private

    private func getWaypointItem(_ item: UITableViewCell) throws -> WaypointItem {
        let views = item.contentView.subviews.filter { $0 is WaypointItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "It returns a single view")

        return try require(views.first as? WaypointItem)
    }
}
