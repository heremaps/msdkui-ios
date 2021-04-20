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
@testable import MSDKUI_Demo
import UIKit
import XCTest

final class AboutTableViewDataSourceTests: XCTestCase {
    /// The object under test.
    private var dataSource: AboutTableViewDataSource?

    /// The table view linked to the data source under test.
    private var tableView: UITableView?

    override func setUp() {
        super.setUp()

        // Initializes the view controller which contains the table view
        let aboutViewController = UIStoryboard.instantiateFromStoryboard(named: .about) as AboutViewController
        _ = aboutViewController.view

        // Takes the data source from the View Controller
        dataSource = aboutViewController.tableViewDataSource

        // Takes the table view from the View Controller
        tableView = aboutViewController.tableView
    }

    // MARK: - Tests

    /// Tests if the data source exists.
    func testIfExists() {
        XCTAssertNotNil(dataSource, "It exists")
    }

    // swiftlint:disable localized_string

    /// Tests if `.item(at:)` returns the correct item for a given index path.
    func testItem() throws {
        // First item
        let firstItem = try require(dataSource?.item(at: IndexPath(row: 0, section: 0)))
        XCTAssertLocalized(firstItem.title, key: "msdkui_app_app_version", "It has the correct title")
        XCTAssertEqual(firstItem.description, "2.1.8", "It has the correct description")

        // Second item
        let secondItem = try require(dataSource?.item(at: IndexPath(row: 1, section: 0)))
        XCTAssertLocalized(secondItem.title, key: "msdkui_app_ui_kit_version", "It has the correct title")
        XCTAssertEqual(secondItem.description, "2.1.8", "It has the correct description")

        // Third item
        let thirdItem = try require(dataSource?.item(at: IndexPath(row: 2, section: 0)))
        XCTAssertLocalized(thirdItem.title, key: "msdkui_app_here_sdk_version", "It has the correct title")
        XCTAssertTrue(thirdItem.description.contains("3.18.2"), "It has the correct description")

        // Fourth item
        let fourthItem = try require(dataSource?.item(at: IndexPath(row: 3, section: 0)))
        let fourthItemExpectedDescription =
            """
            \(NSLocalizedString("msdkui_app_about_info_part_two", comment: ""))

            \(NSLocalizedString("msdkui_app_about_info_part_three", comment: ""))

            \(NSLocalizedString("msdkui_app_about_info_part_four", comment: ""))
            """

        XCTAssertLocalized(fourthItem.title, key: "msdkui_app_about_info_part_one", "It has the correct title")
        XCTAssertEqual(fourthItem.description, fourthItemExpectedDescription, "It has the correct description")

        // Invalid item
        let invalidItem = dataSource?.item(at: IndexPath(row: 4, section: 0))
        XCTAssertNil(invalidItem, "It returns nil")
    }

    // swiftlint:enable localized_string

    // MARK: - UITableViewDataSource

    /// Tests if `.tableView(_:numberOfRowsInSection:) returns the correct number of items.
    func testTableViewNumberOfRowsInSection() throws {
        let numberOfItems = dataSource?.tableView(try require(tableView), numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfItems, 4, "It returns the correct number of items")
    }

    /// Tests if `.tableView(_:cellForRowAt:)` returns the a correct cell.
    func testTableViewCellForRowAt() throws {
        let cell = dataSource?.tableView(try require(tableView), cellForRowAt: IndexPath(row: 1, section: 0)) as? AboutTableViewCell

        XCTAssertLocalized(cell?.textLabel?.text, key: "msdkui_app_ui_kit_version", "It has the correct text")
        XCTAssertEqual(cell?.detailTextLabel?.text, "2.1.8", "It has the correct detail text")
    }
}
