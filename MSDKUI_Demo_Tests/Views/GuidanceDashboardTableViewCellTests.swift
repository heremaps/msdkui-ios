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

final class GuidanceDashboardTableViewCellTests: XCTestCase {
    /// The cell under test.
    private var cell: GuidanceDashboardTableViewCell?

    override func setUp() {
        super.setUp()

        // Initializes the view controller which contains the table view
        let dashboardViewController = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as GuidanceDashboardViewController
        _ = dashboardViewController.view

        // Dequeues the cell from the table view
        let cellIdentifier = String(describing: GuidanceDashboardTableViewCell.self)
        cell = dashboardViewController.tableView?.dequeueReusableCell(withIdentifier: cellIdentifier) as? GuidanceDashboardTableViewCell
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

    /// Tests if the cell has the correct selected background color.
    func testSelectedBackgroundColor() {
        XCTAssertEqual(cell?.selectedBackgroundColor, .colorBackgroundPressed, "It has the correct selected background color")
    }

    /// Tests if the cell has an image view for the icon.
    func testIconImageView() {
        XCTAssertNotNil(cell?.iconImageView, "It has the icon image view")
        XCTAssertEqual(cell?.iconImageView.tintColor, .colorForeground, "It has the icon tint color")
        XCTAssertEqual(cell?.iconImageView.contentMode, .center, "It has the icon centered")
    }

    /// Tests if the cell has a title label.
    func testTitleLabel() {
        XCTAssertNotNil(cell?.titleLabel, "It has the title label")
        XCTAssertEqual(cell?.titleLabel.textColor, .colorForeground, "It has the correct label text color")
        XCTAssertEqual(cell?.titleLabel.font, .preferredFont(forTextStyle: .headline), "It has the correct label font")
    }

    /// Tests if the cell is correctly configured when model is empty.
    func testConfigureWhenModelIsEmpty() {
        cell?.configure(with: GuidanceDashboardTableViewCell.ViewModel(image: nil, title: nil))

        XCTAssertNil(cell?.iconImageView.image, "It doesn't have an image")
        XCTAssertNil(cell?.titleLabel.text, "It doesn't have title")
    }

    /// Tests if the cell is correctly configured when model is populated.
    func testConfigureWhenModelIsPopulated() {
        let image = UIImage(named: "IconButton.expand")
        let expectedImage = image?.withRenderingMode(.alwaysTemplate)

        cell?.configure(with: GuidanceDashboardTableViewCell.ViewModel(image: image, title: "Mocked Title"))

        XCTAssertEqual(cell?.iconImageView.image, expectedImage, "It has the correct image (as template)")
        XCTAssertEqual(cell?.titleLabel.text, "Mocked Title", "It has the correct title")
    }
}
