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

final class GuidanceDashboardTableViewDataSourceTests: XCTestCase {
    /// The object under test.
    private var dataSource: GuidanceDashboardTableViewDataSource?

    /// The table view linked to the data source under test.
    private var tableView: UITableView?

    override func setUp() {
        super.setUp()

        // Initializes the view controller which contains the table view
        let dashboardViewController = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as GuidanceDashboardViewController
        _ = dashboardViewController.view

        // Takes the data source from the View Controller
        dataSource = dashboardViewController.tableViewDataSource

        // Takes the table view from the View Controller
        tableView = dashboardViewController.tableView
    }

    // MARK: - Tests

    /// Tests if the data source exists.
    func testIfExists() {
        XCTAssertNotNil(dataSource, "It exists")
    }

    /// Tests if `.item(at:)` returns the correct item for a given index path.
    func testItem() {
        // First Item
        let settingsItem = dataSource?.item(at: IndexPath(row: 0, section: 0))
        XCTAssertLocalized(settingsItem?.title, key: "msdkui_app_settings", "It has the correct item title")
        XCTAssertEqual(settingsItem?.icon, UIImage(named: "IconButton.options"), "It has the correct item image")

        // Second item
        let aboutItem = dataSource?.item(at: IndexPath(row: 1, section: 0))
        XCTAssertLocalized(aboutItem?.title, key: "msdkui_app_about", "It has the correct item title")
        XCTAssertEqual(aboutItem?.icon, UIImage(named: "Info"), "It has the correct item image")

        // Invalid item
        let invalidItem = dataSource?.item(at: IndexPath(row: 2, section: 0))
        XCTAssertNil(invalidItem, "It returns nil")
    }

    // MARK: - UITableViewDataSource

    /// Tests if `.tableView(_:numberOfRowsInSection:) returns the correct number of items.
    func testTableViewNumberOfRowsInSection() throws {
        let numberOfItems = dataSource?.tableView(try require(tableView), numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfItems, 2, "It returns the correct number of items")
    }

    /// Tests if `.tableView(_:cellForRowAt:)` returns the a correct cell.
    func testTableViewCellForRowAtRow0() throws {
        let cell = dataSource?.tableView(try require(tableView), cellForRowAt: IndexPath(row: 0, section: 0)) as? GuidanceDashboardTableViewCell
        let expectedImage = UIImage(named: "IconButton.options")?.withRenderingMode(.alwaysTemplate)

        XCTAssertLocalized(cell?.titleLabel.text, key: "msdkui_app_settings", "It has the correct title")
        XCTAssertEqual(cell?.iconImageView.image, expectedImage, "It has the correct image")
    }

    /// Tests if `.tableView(_:cellForRowAt:)` returns the a correct cell.
    func testTableViewCellForRowAtRow1() throws {
        let cell = dataSource?.tableView(try require(tableView), cellForRowAt: IndexPath(row: 1, section: 0)) as? GuidanceDashboardTableViewCell
        let expectedImage = UIImage(named: "Info")?.withRenderingMode(.alwaysTemplate)

        XCTAssertLocalized(cell?.titleLabel.text, key: "msdkui_app_about", "It has the correct title")
        XCTAssertEqual(cell?.iconImageView.image, expectedImage, "It has the correct image")
    }
}
