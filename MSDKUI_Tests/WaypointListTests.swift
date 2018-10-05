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

class WaypointListTests: XCTestCase {
    // The list object to be tested
    private var list = WaypointList(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)

    // Is an entry added?
    private var addedEntry = false

    // Is an entry tapped?
    private var tappedEntry = false

    // Is an entry removed?
    private var removedEntry = false

    // Are the entries dragged?
    private var draggedEntries = false

    // Is an entry updated?
    private var updatedEntry = false

    // On which index path the long press started?
    private var indexPathForBeganState: IndexPath?

    // The drag expectation to be fulfilled
    private var dragExpectation: XCTestExpectation?

    // The tap expectation to be fulfilled
    private var tapExpectation: XCTestExpectation?

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        list.listDelegate = self
    }

    /// Tests the default style.
    func testDefaultStyle() {
        XCTAssertFalse(list.alwaysBounceVertical, "It doesn't have vertical bounce")
        XCTAssertEqual(list.separatorStyle, .singleLine, "It has the correct separator style")
        XCTAssertEqual(list.separatorInset, .zero, "It has the correct separator inset")
        XCTAssertEqual(list.backgroundColor, .colorBackgroundDark, "It has the correct background color")
        XCTAssertEqual(list.separatorColor, .colorDividerLight, "It has the correct separator color")
    }

    // Tests that the default values are the expected ones
    func testDefaultValues() {
        // Initially there should be the minimum number of entries to allow a route calculation
        XCTAssertEqual(list.minWaypointItems, 2, "Not the expected default number of entries needed to calculate a route!")
        XCTAssertEqual(list.maxWaypointItems, 16, "Not the expected default number of maximum waypoint items!")
        XCTAssertEqual(list.maxVisibleItems, 4, "Not the expected number of maximum visible items!")
        XCTAssertEqual(list.entryCount, list.minWaypointItems, "Not the expected default number of entries!")
    }

    // Tests the minimum number of entries to allow a route calculation is never lower than 2
    func testMinWaypointItemsNotLowerThanTwo() {
        list.minWaypointItems = 1

        XCTAssertGreaterThanOrEqual(list.minWaypointItems, 2, "MinWaypointItems cannot be set to a value lower than 2")
    }

    // Tests the minimum number of entries is never greater than the current number of entries
    func testMinWaypointItemsNotGreaterThanCurrentNumberOfEntries() {
        list.minWaypointItems = list.entryCount + 1

        XCTAssertLessThanOrEqual(list.minWaypointItems, list.entryCount,
                                 "MinWaypointItems cannot be set to a value greater than existing number of entries")
    }

    // Tests the maximum number of entries is never lower than minWaypointItems
    func testMaxWaypointItemsNotLowerThanMinWaypointItems() {
        list.maxWaypointItems = list.minWaypointItems - 1

        XCTAssertGreaterThanOrEqual(list.maxWaypointItems, list.minWaypointItems,
                                    "MaxWaypointItems cannot be set to a value lower than minWaypointItems")
    }

    // Tests the maximum number of entries is never lower than existing entries
    func testMaxWaypointItemsNotLowerThanNumberOfExistingEntries() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.maxWaypointItems)
        list.maxWaypointItems = list.entryCount - 1

        XCTAssertGreaterThanOrEqual(list.maxWaypointItems, list.entryCount,
                                    "MaxWaypointItems cannot be set to a value lower than existing entries")
    }

    // Tests the maximum number of entries is never lower than existing maxVisibleItems
    func testMaxWaypointItemsNotLowerThanMaxVisibleItems() {
        list.maxWaypointItems = list.maxVisibleItems - 1

        XCTAssertGreaterThanOrEqual(list.maxWaypointItems, list.maxVisibleItems,
                                    "MaxWaypointItems cannot be set to a value lower than maxVisibleItems")
    }

    // Tests the maxVisibleItems cannot be lower than minWaypointItems
    func testMaxVisibleItemsNotLowerThanMinWaypointItems() {
        list.maxVisibleItems = list.minWaypointItems - 1

        XCTAssertGreaterThanOrEqual(list.maxVisibleItems, list.minWaypointItems,
                                    "Max number of visible items should not be lower than the minimum number of entries to allow a route calculation!")
    }

    // Tests the maxVisibleItems cannot be greater than maxWaypointItems
    func testMaxVisibleItemsNotGreaterThanMaxWaypointItems() {
        list.maxVisibleItems = list.maxWaypointItems + 1

        XCTAssertLessThanOrEqual(list.maxVisibleItems, list.maxWaypointItems,
                                 "Max number of visible items should not be greater than the maximum number of waypoint items!")
    }

    // Tests cannot set entries to a number lower than minWaypointItems
    func testEntriesCannotBeLessThanMinWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.minWaypointItems - 1)

        XCTAssertGreaterThanOrEqual(list.entryCount, list.minWaypointItems,
                                    "Entries should not be less than minWaypointItems!")
    }

    // Tests cannot set entries to a number greater than maxWaypointItems
    func testEntriesCannotBeGreaterThanMaxWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.maxWaypointItems + 1)

        XCTAssertLessThanOrEqual(list.entryCount, list.maxWaypointItems, "Entries should not be greater than maxWaypointItems!")
    }

    // Tests cannot add more entries than maxWaypointItems
    func testCannotAddOneEntryMoreThanMaxWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.maxWaypointItems)
        list.addEntry(WaypointEntryFixture.berlin())

        XCTAssertLessThanOrEqual(list.entryCount, list.maxWaypointItems, "Entries should not be greater than maxWaypointItems!")
    }

    // Tests cannot insert more entries than maxWaypointItems
    func testCannotInsertOneEntryMoreThanMaxWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.maxWaypointItems)
        list.insertEntry(WaypointEntryFixture.berlin(), at: 0)

        XCTAssertLessThanOrEqual(list.entryCount, list.maxWaypointItems, "Entries should not be greater than maxWaypointItems!")
    }

    // Tests cannot add one more empty entry than maxWaypointItems
    func testCannotAddOneEmptyEntryMoreThanMaxWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.maxWaypointItems)
        list.addEmptyEntry()

        XCTAssertLessThanOrEqual(list.entryCount, list.maxWaypointItems, "Entries should not be greater than maxWaypointItems!")
    }

    // Tests can insert an empty entry when the index is valid
    func testCanInsertEmptyEntriesWhenIndexIsValid() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: 6)

        // Can insert at a valid in-the-list position?
        var last = list.entryCount
        let mid = last / 2
        list.insertEmptyEntry(at: mid)

        XCTAssertEqual(list.entryCount, last + 1, "The empty entry should be inserted!")
        XCTAssertEqual(list.waypointEntries[mid].name, "Choose waypoint", "The empty entry should be at the specified \(mid) index!")

        // Can insert at the last position?
        last = list.entryCount
        list.insertEmptyEntry(at: last)

        XCTAssertEqual(list.entryCount, last + 1, "The empty entry should be inserted!")
        XCTAssertEqual(list.waypointEntries[last].name, "Choose waypoint", "The empty entry should be at the \(last) index!")
    }

    // Tests cannot insert an empty entry when the index is invalid
    func testCannotInsertAnEmptyEntryWhenIndexIsInvalid() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: 6)

        // Can insert at the last + 2 position?
        let last = list.entryCount
        list.insertEmptyEntry(at: last + 2)

        XCTAssertEqual(list.entryCount, last, "The empty entry should not be inserted!")
    }

    // Tests cannot remove an entry and have less than minWaypointItems
    func testCannotRemoveEntryAndHaveLessThanMinWaypointItems() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.minWaypointItems)
        list.removeEntry(at: 0)

        XCTAssertGreaterThanOrEqual(list.entryCount, list.minWaypointItems,
                                    "Entries should not be less than minWaypointItems!")
    }

    // Tests that reset restores initial number of empty entries
    func testResetRestoresInitialNumberOfEmptyEntries() {
        list.reset()

        XCTAssertEqual(list.entryCount, list.minWaypointItems, "Not the expected default number of entries!")
    }

    // Tests it reverses the order of the WaypointEntries completely
    func testsReverse() {
        let waypoint0 = WaypointEntryFixture.berlin()
        let waypoint1 = WaypointEntryFixture.berlin()
        let waypoint2 = WaypointEntryFixture.frankfurt()
        let waypoint3 = WaypointEntryFixture.frankfurt()
        list.waypointEntries = [waypoint0, waypoint1, waypoint2, waypoint3]
        let expectedResult = [waypoint3, waypoint2, waypoint1, waypoint0]

        list.reverse()

        XCTAssertEqual(list.waypointEntries, expectedResult, "Not the expected reversed order!")
    }

    // Tests Swaps the specified entries
    func testsSwap() {
        let waypoint0 = WaypointEntryFixture.berlin()
        let waypoint1 = WaypointEntryFixture.berlin()
        list.waypointEntries = [waypoint0, waypoint1]

        list.swap(firstIndex: 0, secondIndex: 1)
        let expectedResult = [waypoint1, waypoint0]

        XCTAssertEqual(list.waypointEntries, expectedResult, "Not the expected swapped order!")
    }

    // Tests each callback one-by-one
    // trick: UIView.hitTest(_:with:) method expects the point specified
    //        in the receiver’s local coordinate system
    func testCallbacks() {
        // Add two entries to the list
        let entry0 = WaypointEntryFixture.berlin()
        let entry1 = WaypointEntryFixture.frankfurt()

        list.addEntry(entry0)

        // Has the assigned callback called?
        XCTAssertTrue(addedEntry, "The add callback is not called!")

        list.addEntry(entry1)

        // Tap row0, swap row0 and row1, remove row0 and update 0th entry to test the callbacks
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        let item0 = list.cellForRow(at: indexPath0)!
        let waypoint0 = getWaypointItem(item0)
        let point0 = CGPoint(x: waypoint0.label.frame.origin.x + 3, y: waypoint0.label.frame.origin.y + 3)
        let touches: Set<UITouch> = [UITouch()]

        // Tap an entry:
        // Simulate touching the 0th item with a point on the label with a fake
        // event object having one touch
        tapExpectation = expectation(description: "tappedEntry == true")
        let event = MockUtils.mockEvent(withTouches: touches, timestamp: TimeInterval(1.0))
        _ = item0.hitTest(point0, with: event)

        // Callback...
        waitForExpectations(timeout: 5, handler: nil)

        // Programmatically drag row1 and row0
        dragExpectation = expectation(description: "draggedEntries == true")
        list.beginUpdates()
        list.tableView(list, moveRowAt: indexPath1, to: indexPath0)
        list.endUpdates()

        // Callback...
        waitForExpectations(timeout: 5, handler: nil)

        // Remove an entry
        list.removeEntry(at: indexPath0.row)

        // Has the assigned callback called?
        XCTAssertTrue(removedEntry, "The remove callback is not called!")

        // Update an entry
        let entry2 = WaypointEntryFixture.frankfurt()

        list.updateEntry(entry2, at: 0)

        // Has the assigned callback called?
        XCTAssertTrue(updatedEntry, "The update callback is not called!")
    }

    // Tests the entryCount property
    func testEntryCount() {
        // Add two entries to the list
        let entry0 = WaypointEntryFixture.berlin()

        list.addEntry(entry0)

        // There should be two entries
        XCTAssertEqual(list.entryCount, list.minWaypointItems + 1, "Not the expected number of entries!")

        // Remove an entry
        list.removeEntry(at: 0)

        // There should be one entry
        XCTAssertEqual(list.entryCount, list.minWaypointItems, "Not the expected number of entries!")
    }

    // Tests the NMAWaypoint objects are retrieved
    func testWaypoints() {
        // Initially, the waypoints array should not be empty
        XCTAssertFalse(list.waypoints.isEmpty, "Empty waypoints array!")

        // Add two entries to the list
        list.addEntry(WaypointEntryFixture.berlin())
        list.addEntry(WaypointEntryFixture.frankfurt())

        // Get the waypoints
        let waypoints = list.waypoints

        // The waypoints array should not be empty now
        XCTAssertFalse(waypoints.isEmpty, "Empty waypoints array!")

        // The waypoints array should have as much object as the list has entries
        XCTAssertEqual(waypoints.count, list.entryCount, "Waypoints count and entries count does not match!")
    }

    // Tests it is not possible to calculate a route with invalid entries
    func testRoutingIsNotPossibleWithOneInvalidEntry() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.minWaypointItems)
        list.addEntry(WaypointEntryFixture.empty())

        XCTAssertFalse(list.isRoutingPossible, "Should not be able to calculate route when there are invalid entries")
    }

    // Tests it is possible to calculate routes when all entries are valid
    func testRoutingIsPossibleWhenAllEntriesAreValid() {
        list.waypointEntries = [WaypointEntry](cloneValue: WaypointEntryFixture.berlin(),
                                               count: list.minWaypointItems)

        XCTAssertTrue(list.isRoutingPossible, "Should be able to calculate route")
    }

    // Tests if initial waypoint labels have correct values
    func testInitialWaypointsLabels() {
        // Initially, the waypoints array should not be empty
        XCTAssertEqual(list.waypointEntries.count, 2, "Waypoints does not have 2 initiall points!")

        // Check string localization
        let stringChooseWaypoint = getLocalizedString(forKey: "msdkui_waypoint_select_location")
        let removeString = getLocalizedString(forKey: "msdkui_remove")

        // First element should be start and placeholder
        checkRow(at: 0,
                 expectedType: .startPoint,
                 expectedName: stringChooseWaypoint,
                 expectedDisplayedText: getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: stringChooseWaypoint))

        var expectedCellAccessibilityLabel = getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: stringChooseWaypoint)
        var expectedCellRemoveAccessibilityLabel = removeString + ": " + expectedCellAccessibilityLabel
        checkAccessilibityForRow(at: 0,
                                 expectedCellLabel: expectedCellAccessibilityLabel,
                                 expectedRemoveLabel: expectedCellRemoveAccessibilityLabel)

        // Second element should be end and placeholder
        checkRow(at: 1,
                 expectedType: .endPoint,
                 expectedName: stringChooseWaypoint,
                 expectedDisplayedText: getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: stringChooseWaypoint))

        expectedCellAccessibilityLabel = getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: stringChooseWaypoint)
        expectedCellRemoveAccessibilityLabel = removeString + ": " + expectedCellAccessibilityLabel
        checkAccessilibityForRow(at: 1,
                                 expectedCellLabel: expectedCellAccessibilityLabel,
                                 expectedRemoveLabel: expectedCellRemoveAccessibilityLabel)
    }

    // Tests if labels stay correct when waypoints are reordered
    func testWaypointsReordering() {
        // Initially, the waypoints array should not be empty
        XCTAssertEqual(list.waypointEntries.count, 2, "Waypoints does not have 2 initial points!")

        // Update waypoints
        list.updateEntry(WaypointEntryFixture.makeWaypoint(name: "One", latitude: 10.0, longitude: 10.0), at: 1)
        list.addEntry(WaypointEntryFixture.makeWaypoint(name: "Two", latitude: 10.0, longitude: 10.0))

        // List should have 3 elements
        XCTAssertEqual(list.waypointEntries.count, 3, "List does not contain 3 waypoints!")

        // Check string localization
        let stringChooseWaypoint = getLocalizedString(forKey: "msdkui_waypoint_select_location")
        let removeString = getLocalizedString(forKey: "msdkui_remove")

        // Check labels and names of waypoints
        checkRow(at: 0,
                 expectedType: .startPoint,
                 expectedName: stringChooseWaypoint,
                 expectedDisplayedText: getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: stringChooseWaypoint))

        // Check accessibility strings
        var accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: stringChooseWaypoint)
        var accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 0,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 1,
                 expectedType: .waypoint,
                 expectedName: "One",
                 expectedDisplayedText: "One")

        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_waypoint_in_list", arguments: 1) + ": One"
        accessibilityRemoveCellLabel = getLocalizedFormattedString(forKey: "msdkui_remove_waypoint_in_list", arguments: 1) + ": One"
        checkAccessilibityForRow(at: 1,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 2,
                 expectedType: .endPoint,
                 expectedName: "Two",
                 expectedDisplayedText: "Two")

        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: "Two")
        accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 2,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        // Move first waypoint
        list.waypointEntries.rearrange(from: 0, to: 1)

        // Labels should be updated
        checkRow(at: 0,
                 expectedType: .startPoint,
                 expectedName: "One",
                 expectedDisplayedText: "One")

        // Accessibility strings should be updated
        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: "One")
        accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 0,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 1, expectedType: .waypoint,
                 expectedName: stringChooseWaypoint,
                 expectedDisplayedText: stringChooseWaypoint)

        accessibilityCellLabel = String(format: "msdkui_waypoint_in_list".localized, arguments: [1]) + ": " + stringChooseWaypoint
        accessibilityRemoveCellLabel = getLocalizedFormattedString(forKey: "msdkui_remove_waypoint_in_list", arguments: 1) + ": " + stringChooseWaypoint
        checkAccessilibityForRow(at: 1,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 2,
                 expectedType: .endPoint,
                 expectedName: "Two",
                 expectedDisplayedText: "Two")

        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: "Two")
        accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 2,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        // Move last waypoint to beginning
        list.waypointEntries.rearrange(from: 2, to: 0)

        // Labels should be updated
        checkRow(at: 0,
                 expectedType: .startPoint,
                 expectedName: "Two",
                 expectedDisplayedText: "Two")

        // Accessibility strings should be updated
        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_from", arguments: "Two")
        accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 0,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 1,
                 expectedType: .waypoint,
                 expectedName: "One",
                 expectedDisplayedText: "One")

        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_waypoint_in_list", arguments: 1) + ": One"
        accessibilityRemoveCellLabel = getLocalizedFormattedString(forKey: "msdkui_remove_waypoint_in_list", arguments: 1) + ": One"
        checkAccessilibityForRow(at: 1,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)

        checkRow(at: 2,
                 expectedType: .endPoint,
                 expectedName: stringChooseWaypoint,
                 expectedDisplayedText: getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: stringChooseWaypoint))

        accessibilityCellLabel = getLocalizedFormattedString(forKey: "msdkui_rp_to", arguments: stringChooseWaypoint)
        accessibilityRemoveCellLabel = removeString + ": " + accessibilityCellLabel
        checkAccessilibityForRow(at: 2,
                                 expectedCellLabel: accessibilityCellLabel,
                                 expectedRemoveLabel: accessibilityRemoveCellLabel)
    }

    // Gets the WaypointItem view out of the cell
    func getWaypointItem(_ item: UITableViewCell) -> WaypointItem {
        let views = item.contentView.subviews.filter { $0 is WaypointItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "Not the expected views count 1, but \(views.count)!")

        return views[0] as! WaypointItem
    }

    // MARK: Private methods

    private func checkRow(at index: Int, expectedType: WaypointItem.ItemType, expectedName: String, expectedDisplayedText: String) {
        let indexPath = IndexPath(row: index, section: 0)

        // Check cell
        let cell = list.cellForRow(at: indexPath)
        XCTAssertNotNil(cell, "Cell for index \(index) should not be nil!")

        // Check cell view
        let cellView = getWaypointItem(cell!)
        XCTAssertEqual(cellView.type, expectedType, "Type is different than expected!")

        // Check displayed text
        XCTAssertEqual(cellView.label.text, expectedDisplayedText, "Cell displayed name is different than expected!")

        // Check data item
        let entry = list.waypointEntries[index]
        XCTAssertEqual(entry.name, expectedName, "WaypointEntry name is different than expected!")
    }

    private func checkAccessilibityForRow(at index: Int,
                                          expectedCellLabel: String,
                                          expectedRemoveLabel: String) {
        let indexPath = IndexPath(row: index, section: 0)

        // Get cell
        let cell = list.cellForRow(at: indexPath)
        XCTAssertNotNil(cell, "Cell for index \(index) should not be nil!")

        // Check cell accessibility label
        XCTAssertEqual(cell?.accessibilityLabel, expectedCellLabel, "Cell accessibility label is different than expected!")

        // Get cell view
        let cellView = getWaypointItem(cell!)

        // Check remove accessibility label
        XCTAssertEqual(cellView.removeButton.accessibilityLabel, expectedRemoveLabel, "Cell remove accessibility label is different that expected!")
    }

    // Gets localized string for key and checks if localization is available
    private func getLocalizedString(forKey key: String) -> String {
        let localizedString = key.localized
        XCTAssertNotEqual(localizedString, key, "String not localized!")
        return localizedString
    }

    /// Gets localized string using a format from translated string with provided arguments
    private func getLocalizedFormattedString(forKey key: String, arguments: CVarArg) -> String {
        let keyString = getLocalizedString(forKey: key)
        return String(format: keyString, arguments)
    }
}

// MARK: - WaypointListDelegate

extension WaypointListTests: WaypointListDelegate {

    func waypointList(_ list: WaypointList, didAdd entry: WaypointEntry, at index: Int) {
        addedEntry = true
    }

    func waypointList(_ list: WaypointList, didSelect entry: WaypointEntry, at index: Int) {
        tappedEntry = true

        // Mark the expectation as fulfilled
        tapExpectation!.fulfill()
    }

    func waypointList(_ list: WaypointList, didRemove entry: WaypointEntry, at index: Int) {
        removedEntry = true
    }

    func waypointList(_ list: WaypointList, didDragFrom from: Int, to: Int) {
        draggedEntries = true

        // Mark the expectation as fulfilled
        dragExpectation!.fulfill()
    }

    func waypointList(_ list: WaypointList, didUpdate entry: WaypointEntry, at index: Int) {
        updatedEntry = true
    }
}
