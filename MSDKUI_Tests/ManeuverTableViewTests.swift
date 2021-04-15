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

final class ManeuverTableViewTests: XCTestCase {
    /// The object under test.
    private var tableView = ManeuverTableView(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)

    override func setUp() {
        super.setUp()

        // Set up the item
        tableView.route = MockUtils.mockRoute()
    }

    // MARK: - Tests

    /// Tests the inital values.
    func testInitialValues() {
        // There should be a route
        XCTAssertNotNil(tableView.route, "Setting route returns nil")

        // There are two maneuvers in the mock route object
        XCTAssertEqual(tableView.entryCount, 2, "Route with 2 Maneuvers doesnt not have entry count 2")
    }

    /// Tests the maneuver table view.
    func testManeuverTableView() {
        XCTAssertTrue(tableView.bounces, "It bounces")
        XCTAssertFalse(tableView.allowsMultipleSelection, "It doesn't allow multiple selection")
        XCTAssertTrue(tableView.allowsSelection, "It allows selection")
        XCTAssertTrue(tableView.isScrollEnabled, "It allows scrolling")
        XCTAssertFalse(tableView.isEditing, "It's not on editing mode")
        XCTAssertFalse(tableView.alwaysBounceVertical, "It doesn't allow vertical bouncing")
        XCTAssertEqual(tableView.separatorInset, UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0), "It has the correct separator inset")
        XCTAssertEqual(tableView.backgroundColor, .colorForegroundLight, "It has the correct background color")
        XCTAssertEqual(tableView.separatorColor, .colorDivider, "It has the correct separator color")
    }

    /// Tests the maneuvers.
    func testManeuvers() throws {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let cell0 = try require(tableView.cellForRow(at: indexPath0))
        let maneuverItemView0 = try getManeuverItemView(from: cell0)
        let expectedDistance = Measurement(value: 200, unit: UnitLength.meters)
        let expectedFormattedDistance = MeasurementFormatter.currentMediumUnitFormatter.string(from: expectedDistance)

        XCTAssertFalse(maneuverItemView0.iconImageView.isHidden, "Init -> iconImageView is not visible")
        XCTAssertLocalized(
            maneuverItemView0.instructionLabel.text, key: "msdkui_maneuver_enter_highway", bundle: .MSDKUI,
            "item is displaying wrong instruction"
        )
        XCTAssertEqual(maneuverItemView0.distanceLabel.text, expectedFormattedDistance, "Maneuver should display distance '200 m'")

        let indexPath1 = IndexPath(row: 1, section: 0)
        let cell1 = try require(tableView.cellForRow(at: indexPath1))
        let maneuverItemView1 = try getManeuverItemView(from: cell1)

        XCTAssertFalse(maneuverItemView1.iconImageView.isHidden, "Init -> iconImageView is not visible")
        XCTAssertLocalized(
            maneuverItemView1.instructionLabel.text, key: "msdkui_maneuver_arrive_at_02y", bundle: .MSDKUI,
            "item is displaying wrong instruction"
        )
        XCTAssertTrue(maneuverItemView1.distanceLabel.isHidden, "Maneuver should not display a distance")
    }

    // MARK: - Private

    private func getManeuverItemView(from cell: UITableViewCell) throws -> ManeuverItemView {
        let views = cell.contentView.subviews.filter { $0 is ManeuverItemView }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "It returns a single view")

        return try require(views.first as? ManeuverItemView)
    }
}
