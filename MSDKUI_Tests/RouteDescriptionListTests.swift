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

final class RouteDescriptionListTests: XCTestCase {
    /// The object under test.
    private var list = RouteDescriptionList(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

    /// The mock delegate used to verify expectations.
    private var mockDelegate = RouteDescriptionListDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Set up the item
        list.listDelegate = mockDelegate
        list.routes = MockUtils.mockRoutes()
    }

    // MARK: - Tests

    /// Tests the background color.
    func testBackgroundColor() {
        XCTAssertEqual(list.backgroundColor, .colorForegroundLight, "It has the correct background color")
        XCTAssertNil(list.stackView.backgroundColor, "It's transparent")
        XCTAssertNil(list.tableView.backgroundColor, "It's transparent")
    }

    /// Tests the stack view.
    func testStackView() {
        XCTAssertEqual(list.stackView.spacing, 0.0, "It has the correct spacing between items")
        XCTAssertEqual(list.stackView.distribution, .fill, "It has the correct distribution")
        XCTAssertEqual(list.stackView.axis, .vertical, "It has vertical axis")
    }

    /// Tests the table view.
    func testTableView() {
        XCTAssertTrue(list.tableView.bounces, "It bounces")
        XCTAssertFalse(list.tableView.allowsMultipleSelection, "It doesn't allow multiple selection")
        XCTAssertTrue(list.tableView.allowsSelection, "It allows selection")
        XCTAssertTrue(list.tableView.isScrollEnabled, "It allows scrolling")
        XCTAssertFalse(list.tableView.isEditing, "It's not in editing mode")
        XCTAssert(list.tableView.dataSource === list, "It has the correct data source")
        XCTAssert(list.tableView.delegate === list, "It has the correct delegate")
        XCTAssertFalse(list.alwaysBounceVertical, "It doesn't bounce vertically")
        XCTAssertEqual(list.separatorInset, UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0), "It has the correct separator inset")
        XCTAssertEqual(list.separatorColor, .colorDivider, "It has the correct separator color")
        XCTAssertEqual(list.tableView.tableFooterView?.bounds.height, 0.0, "It hides unused tableview rows")
    }

    func testDelay() throws {
        let cell0 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let routeDescription0 = try getRouteDescriptionItem(cell0)

        // Less than one minute delays should be ignored
        routeDescription0.handler.delaySeconds = 30
        XCTAssertEqual(routeDescription0.handler.trafficDelay, "No delays", "Not the expected no delays string!")

        // More than one minute delays should be stringized
        routeDescription0.handler.delaySeconds = 67
        XCTAssertEqual(routeDescription0.handler.trafficDelay, "Incl. 1 min delay", "Not the expected none-empty delay string!")
    }

    func testSortTypes() throws {
        for _ in 0 ... 1 {
            let cell0 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            let cell1 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
            let routeDescription0 = try getRouteDescriptionItem(cell0)
            let routeDescription1 = try getRouteDescriptionItem(cell1)
            let route0 = try require(routeDescription0.route)
            let route1 = try require(routeDescription1.route)

            switch list.sortType {
            case .duration:
                let duration0 = route0.durationWithTraffic()
                let duration1 = route1.durationWithTraffic()

                XCTAssertLessThan(duration0, duration1, "Not the expected sort type!")

                // Switch to the next one
                list.sortType = RouteDescriptionList.SortType.length

            case .length:
                let length0 = route0.length
                let length1 = route1.length

                XCTAssertLessThan(length0, length1, "Not the expected sort type!")
            }
        }
    }

    func testSortOrders() throws {
        for _ in 0 ... 1 {
            let cell0 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            let cell1 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
            let routeDescription0 = try getRouteDescriptionItem(cell0)
            let routeDescription1 = try getRouteDescriptionItem(cell1)
            let duration0 = try require(routeDescription0.route?.durationWithTraffic())
            let duration1 = try require(routeDescription1.route?.durationWithTraffic())

            switch list.sortOrder {
            case .ascending:
                XCTAssertLessThan(duration0, duration1, "Not the expected ascending sort order!")

                // Switch to the next one
                list.sortOrder = RouteDescriptionList.SortOrder.descending

            case .descending:
                XCTAssertGreaterThan(duration0, duration1, "Not the expected descending sort order!")
            }
        }
    }

    func testRouteBarScalings() throws {
        let cell0 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let cell1 = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        let routeDescription0 = try getRouteDescriptionItem(cell0)
        let routeDescription1 = try getRouteDescriptionItem(cell1)

        // The first route bar should have less than 1.0 progress whereas
        // the second route bar should have exactly 1.0 progress
        XCTAssertLessThan(routeDescription0.barView.progress, 1.0, "The first route bar scaling is less than 1.0")
        XCTAssertEqual(routeDescription1.barView.progress, 1.0, "The second route bar scaling is exactly 1.0")
    }

    // MARK: - UITableViewDataSource

    /// Tests when `.tableView(_:cellForRowAt:)` is triggered.
    func testWhenTableViewCellForRowAtIsTriggered() {
        // Triggers the `UITableViewDataSource` method
        _ = list.tableView(list.tableView, cellForRowAt: IndexPath(row: 1, section: 0))

        // Checks if the delegate method is called with correct paramaters
        XCTAssertTrue(mockDelegate.didCallWillDisplayItem, "It calls the delegate method telling the item is about to be displayed")
        XCTAssert(mockDelegate.lastList == list, "It calls the delegate method with the correct list")
        XCTAssertNotNil(mockDelegate.lastRouteItem, "It calls the delegate method with a valid route description item")
    }

    // MARK: - UITableViewDelegate

    /// Tests when `.tableView(_:didSelectRowAt:)` is triggered.
    func testWhenTableViewDidSelectRowAtIsTriggered() {
        // Triggers the `UITableViewDelegate` method
        list.tableView(list.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))

        // Checks if the delegate method is called with correct paramaters
        XCTAssertTrue(mockDelegate.didCallRouteSelected, "It calls the delegate method telling the route is selected")
        XCTAssert(mockDelegate.lastList == list, "It calls the delegate method with the correct list")
        XCTAssertEqual(mockDelegate.lastIndex, 1, "It calls the delegate method with the correct index")
        XCTAssertEqual(mockDelegate.lastRoute, list.routes[1], "It calls the delegate method with the correct route")
    }

    func testTitleItemVisibility() throws {
        // Initially there should be no title
        XCTAssertNil(list.title, "Initially there should be no title!")
        XCTAssertNil(list.titleItem, "Initially there should be no title item!")
        XCTAssertFalse(list.showTitle, "Initially 'showTitle' property should be false!")

        // Set a title: is the title item created and visible?
        list.title = "List"

        let titleItem = try require(list.titleItem)
        XCTAssertTrue(list.showTitle, "Setting the title property doesn't set the 'showTitle' property to true!")
        XCTAssertFalse(titleItem.view.isHidden, "Setting the title property doesn't set the related 'isHidden' property to false'")

        // Hide the title
        list.showTitle = false

        XCTAssertTrue(
            titleItem.view.isHidden,
            "Setting the 'showTitle' property false doesn't set the related 'isHidden' property to true"
        )

        // Show the title
        list.showTitle = true

        XCTAssertFalse(
            titleItem.view.isHidden,
            "Setting the 'showTitle' property true doesn't set the related 'isHidden' property to 'false"
        )
    }

    func testTitleViewsNumber() {
        // Save initial number of stack view arranged subviews
        let initialArrangedSubviews = list.stackView.arrangedSubviews.count

        // Set a title: was title.view added to stack view?
        list.title = "List"

        XCTAssertEqual(
            list.stackView.arrangedSubviews.count, initialArrangedSubviews + 1,
            "Setting the title property doesn't add titleItem.view to stack view!"
        )

        // Set title one more time, number of subviews should not change
        list.title = "List title"

        XCTAssertEqual(
            list.stackView.arrangedSubviews.count, initialArrangedSubviews + 1,
            "Setting the title property again changed number of stack view subviews!"
        )
    }

    func testSetTitleNil() {
        // Set the title nil
        list.title = nil
        XCTAssertNil(list.title, "There should be no title!")
        XCTAssertNil(list.titleItem, "There should be no title item!")
        XCTAssertFalse(list.showTitle, "'showTitle' property should be false!")

        // When the title is set to a non-nil string, the titleItem should be visible now
        list.title = "List"
        XCTAssertNotNil(list.title, "There should be a title!")
        XCTAssertNotNil(list.titleItem, "There should be a title item!")
        XCTAssertTrue(list.showTitle, "'showTitle' property should be true!")

        // When the title set to nil now, the titleItem should not visible
        list.title = nil
        XCTAssertNil(list.title, "There should be no title!")
        XCTAssertNil(list.titleItem, "There should be no title item!")
        XCTAssertFalse(list.showTitle, "'showTitle' property should be false!")
    }

    // MARK: - Private

    private func getRouteDescriptionItem(_ item: UITableViewCell) throws -> RouteDescriptionItem {
        let views = item.contentView.subviews.filter { $0 is RouteDescriptionItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "It returns a single view")

        return try require(views.first as? RouteDescriptionItem)
    }
}
