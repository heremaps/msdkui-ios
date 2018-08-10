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

class WaypointItemTests: XCTestCase {
    // The list, index paths and entry objects available for the tests
    private var list = WaypointList(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)
    private var entries: [WaypointEntry]!
    private let indexPath0 = IndexPath(row: 0, section: 0)
    private let indexPath1 = IndexPath(row: 1, section: 0)

    // Is an entry removed?
    private var removedEntry = false

    // Is dragging an item started?
    private var dragStarted = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Create the WaypointEntry object
        let coordinates = NMAGeoCoordinates(latitude: 52.530555, longitude: 13.379257)
        let waypoint = NMAWaypoint(geoCoordinates: coordinates)

        // Create the WaypointList object
        entries = [WaypointEntry](cloneValue: WaypointEntry(waypoint, name: "HERE"),
                                  count: list.minWaypointItems)
        list.waypointEntries = entries
    }

    // Tests that the default values are the expected ones
    func testDefaultValues() {
        let item = list.cellForRow(at: indexPath0)!
        let waypoint = getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertTrue(waypoint.removeButton.isHidden, "Remove button is visible!")

        // Is the entry name OK?
        XCTAssertEqual(waypoint.label.text, entries.first?.name, "Not the expected name \(entries.first!.name)!")
    }

    // Tests remove button is visible when more than minimum entries
    func testRemoveButtonVisibleWithMoreThanMinWaypoints() {
        list.addEntry(entries.first!)

        let item = list.cellForRow(at: indexPath0)!
        let waypoint = getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertFalse(waypoint.removeButton.isHidden, "Remove button is hidden!")
    }

    // Tests remove button changes based on number of entries
    func testRemoveButtonVisibiltyDependsOnWaypoints() {
        list.addEntry(entries.first!)

        var item = list.cellForRow(at: indexPath0)!
        var waypoint = getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertFalse(waypoint.removeButton.isHidden, "Remove button should be visible!")

        list.removeEntry(at: list.entryCount - 1)
        item = list.cellForRow(at: indexPath0)!
        waypoint = getWaypointItem(item)

        // Is the remove button visible?
        XCTAssertTrue(waypoint.removeButton.isHidden, "Remove button is still visible!")
    }

    // Tests that when the remove button is tapped, the item's remove callback is called
    func testItemCallsRemoveCallbackWhenRemoveButtonTapped() {
        list.addEntry(entries.first!)
        let item = list.cellForRow(at: indexPath0)!
        let waypoint = getWaypointItem(item)

        // make sure remove button is visible
        XCTAssertFalse(waypoint.removeButton.isHidden, "Remove button is not visible and cannot be tapped")

        //  Set the item's onRemoveClicked var
        waypoint.onRemoveClicked = onRemoveClicked

        // Simulate touching the item with a point inside the remove button
        // and with a fake event object having one touch
        let point = CGPoint(x: waypoint.removeButton.frame.origin.x + 5, y: waypoint.removeButton.frame.origin.y + 5)
        let touches: Set<UITouch> = [UITouch()]
        let event = MockUtils.mockEvent(withTouches: touches, timestamp: TimeInterval(1.0))

        _ = waypoint.hitTest(point, with: event)

        // Has the assigned callback called?
        XCTAssertTrue(removedEntry, "The row remove operation is not detected!")
    }

    // Tests that when the drag button is tapped, the item's drag started callback is called
    func testItemCallsDragStartedCallbackWhenDragged() {
        // Get the rows and record their names
        var item0 = list.cellForRow(at: indexPath0) as! WaypointListCell
        var item1 = list.cellForRow(at: indexPath1) as! WaypointListCell
        var waypoint0 = getWaypointItem(item0)
        var waypoint1 = getWaypointItem(item1)
        let name0 = waypoint0.entry!.name
        let name1 = waypoint1.entry!.name

        // Set the waypoint1's onDragStarted var
        waypoint1.onDragStarted = onDragStarted

        // Simulate touching the item: will it call onDragStarted()?
        // Note that we need to simulate touches on the drag button!
        waypoint1.dragStarted(item1)

        // Has the assigned callback called?
        XCTAssertTrue(dragStarted, "The drag operation is not detected!")

        // Programmatically drag row1 and row0
        list.beginUpdates()
        list.moveRow(at: indexPath1, to: indexPath0)
        list.endUpdates()

        // Do the entry names reflect the drag operation?
        item0 = list.cellForRow(at: indexPath0) as! WaypointListCell
        item1 = list.cellForRow(at: indexPath1) as! WaypointListCell
        waypoint0 = getWaypointItem(item0)
        waypoint1 = getWaypointItem(item1)

        XCTAssertEqual(waypoint0.label.text, name1, "Not the expected name \(name1)!")
        XCTAssertEqual(waypoint1.label.text, name0, "Not the expected name \(name0)!")
    }

    // Gets the WaypointItem view out of the cell
    func getWaypointItem(_ item: UITableViewCell) -> WaypointItem {
        let views = item.contentView.subviews.filter { $0 is WaypointItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "Not the expected views count 1, but \(views.count)!")

        return views[0] as! WaypointItem
    }

    // Callback for the remove
    func onRemoveClicked(_: WaypointEntry) {
        removedEntry = true
    }

    // Callback for the drag start
    func onDragStarted(_: WaypointEntry) {
        dragStarted = true
    }
}
