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

final class AboutTableViewCellTests: XCTestCase {
    /// The cell under test.
    private var cell: AboutTableViewCell?

    override func setUp() {
        super.setUp()

        // Initializes the view controller which contains the table view
        let aboutViewController = UIStoryboard.instantiateFromStoryboard(named: .about) as AboutViewController
        _ = aboutViewController.view

        // Dequeues the cell from the table view
        let cellIdentifier = String(describing: AboutTableViewCell.self)
        cell = aboutViewController.tableView?.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutTableViewCell
    }

    // MARK: - Tests

    /// Tests if the cell exists.
    func testIfExists() {
        XCTAssertNotNil(cell, "It exists")
    }

    /// Tests if the cell has the correct background color.
    func testBackgroundColor() {
        XCTAssertEqual(cell?.contentView.backgroundColor, .colorBackgroundViewLight, "It has the correct background color")
    }

    /// Tests if the cell has a text label.
    func testTextLabel() {
        XCTAssertNotNil(cell?.textLabel, "It has the text label")
        XCTAssertEqual(cell?.textLabel?.textColor, .colorForeground, "It has the correct label text color")
        XCTAssertEqual(cell?.textLabel?.font, .preferredFont(forTextStyle: .headline), "It has the correct label font")
        XCTAssertEqual(cell?.textLabel?.numberOfLines, 0, "It has the a label which supports as many lines as needed")
    }

    /// Tests if the cell has a detail text label.
    func testDetailTextLabel() {
        XCTAssertNotNil(cell?.detailTextLabel, "It has the text label")
        XCTAssertEqual(cell?.detailTextLabel?.textColor, .colorForegroundSecondary, "It has the correct label text color")
        XCTAssertEqual(cell?.detailTextLabel?.font, .preferredFont(forTextStyle: .subheadline), "It has the correct label font")
        XCTAssertEqual(cell?.detailTextLabel?.numberOfLines, 0, "It has the a label which supports as many lines as needed")
    }

    /// Tests if the cell is correctly configured.
    func testConfigure() {
        cell?.configure(with: AboutTableViewCell.ViewModel(title: "foo", description: "bar"))

        XCTAssertEqual(cell?.textLabel?.text, "foo", "It has the correct text")
        XCTAssertEqual(cell?.detailTextLabel?.text, "bar", "It has the correct detail text")
    }
}
