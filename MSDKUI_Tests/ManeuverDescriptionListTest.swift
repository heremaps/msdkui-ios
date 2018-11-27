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

final class ManeuverDescriptionListTests: XCTestCase {

    /// The object under test.
    private var list = ManeuverDescriptionList(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)

    override func setUp() {
        super.setUp()

        // Set up the item
        list.route = MockUtils.mockRoute()
    }

    // MARK: - Tests

    /// Tests the inital values.
    func testInitialValues() {
        // There should be a route
        XCTAssertNotNil(list.route, "Setting route returns nil")

        // There are two maneuvers in the mock route object
        XCTAssertEqual(list.entryCount, 2, "Route with 2 Maneuvers doesnt not have entry count 2")
    }

    /// Tests the maneuver table view.
    func testManeuverTableView() {
        XCTAssertTrue(list.bounces, "It bounces")
        XCTAssertFalse(list.allowsMultipleSelection, "It doesn't allow multiple selection")
        XCTAssertTrue(list.allowsSelection, "It allows selection")
        XCTAssertTrue(list.isScrollEnabled, "It allows scrolling")
        XCTAssertFalse(list.isEditing, "It's not on editing mode")
        XCTAssertFalse(list.alwaysBounceVertical, "It doesn't allow vertical bouncing")
        XCTAssertEqual(list.separatorInset, UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0), "It has the correct separator inset")
        XCTAssertEqual(list.backgroundColor, .colorForegroundLight, "It has the correct background color")
        XCTAssertEqual(list.separatorColor, .colorDivider, "It has the correct separator color")
    }

    /// Tests the maneuvers.
    func testManeuvers() throws {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let cell0 = try require(list.cellForRow(at: indexPath0))
        let maneuverDescriptionItem0 = try getManeuverDescriptionItem(cell0)
        let expectedDistance = Measurement(value: 200, unit: UnitLength.meters)
        let expectedFormattedDistance = MeasurementFormatter.currentMediumUnitFormatter.string(from: expectedDistance)

        XCTAssertFalse(maneuverDescriptionItem0.iconImageView.isHidden, "Init -> iconImageView is not visible")
        XCTAssertLocalized(maneuverDescriptionItem0.instructionLabel.text, key: "msdkui_maneuver_enter_highway", bundle: .MSDKUI,
                           "item is displaying wrong instruction")
        XCTAssertEqual(maneuverDescriptionItem0.distanceLabel.text, expectedFormattedDistance, "Maneuver should display distance '200 m'")

        let indexPath1 = IndexPath(row: 1, section: 0)
        let cell1 = try require(list.cellForRow(at: indexPath1))
        let maneuverDescriptionItem1 = try getManeuverDescriptionItem(cell1)

        XCTAssertFalse(maneuverDescriptionItem1.iconImageView.isHidden, "Init -> iconImageView is not visible")
        XCTAssertLocalized(maneuverDescriptionItem1.instructionLabel.text, key: "msdkui_maneuver_arrive_at_02y", bundle: .MSDKUI,
                           "item is displaying wrong instruction")
        XCTAssertFalse(maneuverDescriptionItem1.isSectionVisible(.distance), "Maneuver should not display a distance")
    }

    // MARK: - Private

    private func getManeuverDescriptionItem(_ item: UITableViewCell) throws -> ManeuverDescriptionItem {
        let views = item.contentView.subviews.filter { $0 is ManeuverDescriptionItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "It returns a single view")

        return try require(views.first as? ManeuverDescriptionItem)
    }
}
