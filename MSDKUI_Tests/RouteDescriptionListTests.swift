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

class RouteDescriptionListTests: XCTestCase {
    // The list object to be tested
    private var list = RouteDescriptionList(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

    // For selecting the rows
    private let indexPath0 = IndexPath(row: 0, section: 0)
    private let indexPath1 = IndexPath(row: 1, section: 0)

    // Was the cell tapped?
    private var cellTapped = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        list.listDelegate = self
        list.routes = MockUtils.mockRoutes()
    }

    func testDelay() {
        let cell0 = list.tableView(list.tableView, cellForRowAt: indexPath0)
        let routeDescription0 = getRouteDescriptionItem(cell0)

        // Less than one minute delays should be ignored
        routeDescription0.handler.delaySeconds = 30
        XCTAssertEqual(routeDescription0.handler.trafficDelay, "No delays", "Not the expected no delays string!")

        // More than one minute delays should be stringized
        routeDescription0.handler.delaySeconds = 67
        XCTAssertEqual(routeDescription0.handler.trafficDelay, "Incl. 1 min delay", "Not the expected none-empty delay string!")
    }

    func testSortTypes() throws {
        for _ in 0 ... 1 {
            let cell0 = list.tableView(list.tableView, cellForRowAt: indexPath0)
            let cell1 = list.tableView(list.tableView, cellForRowAt: indexPath1)
            let routeDescription0 = getRouteDescriptionItem(cell0)
            let routeDescription1 = getRouteDescriptionItem(cell1)
            let route0 = try require(routeDescription0.route)
            let route1 = try require(routeDescription1.route)

            switch list.sortType {
            case .duration:
                let duration0 = route0.durationWithTraffic()
                let duration1 = route1.durationWithTraffic()

                print("sort? duration0: \(duration0), duration1: \(duration1)")

                XCTAssertLessThan(duration0, duration1, "Not the expected sort type!")

                // Switch to the next one
                list.sortType = RouteDescriptionList.SortType.length

            case .length:
                let length0 = route0.length
                let length1 = route1.length

                print("sort? length0: \(length0), length1: \(length1)")

                XCTAssertLessThan(length0, length1, "Not the expected sort type!")
            }
        }
    }

    func testSortOrders() throws {
        for _ in 0 ... 1 {
            let cell0 = list.tableView(list.tableView, cellForRowAt: indexPath0)
            let cell1 = list.tableView(list.tableView, cellForRowAt: indexPath1)
            let routeDescription0 = getRouteDescriptionItem(cell0)
            let routeDescription1 = getRouteDescriptionItem(cell1)
            let duration0 = try require(routeDescription0.route?.durationWithTraffic())
            let duration1 = try require(routeDescription1.route?.durationWithTraffic())

            switch list.sortOrder {
            case .ascending:
                print("ascending? duration0: \(duration0), duration1: \(duration1)")

                XCTAssertLessThan(duration0, duration1, "Not the expected ascending sort order!")

                // Switch to the next one
                list.sortOrder = RouteDescriptionList.SortOrder.descending

            case .descending:
                print("descending? duration0: \(duration0), duration1: \(duration1)")

                XCTAssertGreaterThan(duration0, duration1, "Not the expected descending sort order!")
            }
        }
    }

    func testDelegate() {
        // Simulate selection
        // Note that this method will not call the delegate methods (-tableView:willSelectRowAtIndexPath:
        // or -tableView:didSelectRowAtIndexPath:), nor will it send out a notification
        list.tableView.selectRow(at: indexPath1, animated: false, scrollPosition: .none)
        list.tableView(list.tableView, didSelectRowAt: indexPath1)

        // Is the tap detected?
        XCTAssertTrue(cellTapped, "The tap wasn't detected!")
    }

    func testTitleItemVisibility() {
        // Initially there should be no title
        XCTAssertNil(list.title, "Initially there should be no title!")
        XCTAssertNil(list.titleItem, "Initially there should be no title item!")
        XCTAssertFalse(list.showTitle, "Initially 'showTitle' property should be false!")

        // Set a title: is the title item created and visible?
        list.title = "List"

        XCTAssertNotNil(list.titleItem, "Setting the title property doesn't create the title item!")
        XCTAssertTrue(list.showTitle, "Setting the title property doesn't set the 'showTitle' property to true!")
        XCTAssertFalse(list.titleItem!.view.isHidden, "Setting the title property doesn't set the related 'isHidden' property to false'")

        // Hide the title
        list.showTitle = false

        XCTAssertTrue(list.titleItem!.view.isHidden,
                      "Setting the 'showTitle' property false doesn't set the related 'isHidden' property to true")

        // Show the title
        list.showTitle = true

        XCTAssertFalse(list.titleItem!.view.isHidden,
                       "Setting the 'showTitle' property true doesn't set the related 'isHidden' property to 'false")
    }

    func testTitleViewsNumber() {
        // Save initial number of stack view arranged subviews
        let initialArrangedSubviews = list.stackView.arrangedSubviews.count

        // Set a title: was title.view added to stack view?
        list.title = "List"

        XCTAssertEqual(list.stackView.arrangedSubviews.count, initialArrangedSubviews + 1,
                       "Setting the title property doesn't add titleItem.view to stack view!")

        // Set title one more time, number of subviews should not change
        list.title = "List title"

        XCTAssertEqual(list.stackView.arrangedSubviews.count, initialArrangedSubviews + 1,
                       "Setting the title property again changed number of stack view subviews!")
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

    // MARK: Private methods

    // Gets the RouteDescriptionItem view out of the cell
    private func getRouteDescriptionItem(_ item: UITableViewCell) -> RouteDescriptionItem {
        let views = item.contentView.subviews.filter { $0 is RouteDescriptionItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "Not the expected views count 1, but \(views.count)!")

        return views[0] as! RouteDescriptionItem
    }
}

// MARK: RouteDescriptionListDelegate

extension RouteDescriptionListTests: RouteDescriptionListDelegate {
    func routeSelected(_: RouteDescriptionList, index: Int, route _: NMARoute) {
        // Was the expected cell tapped?
        XCTAssertEqual(index, 1, "Not the expected index!")

        cellTapped = true
    }
}
