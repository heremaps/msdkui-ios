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

class ManeuverDescriptionListTests: XCTestCase {
    private var list = ManeuverDescriptionList(frame: CGRect(x: 0, y: 0, width: 500, height: 500), style: .plain)

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        list.route = MockUtils.mockRoute()
    }

    func testInitialValues() {
        // There should be a route
        XCTAssertNotNil(list.route, "Setting route returns nil")

        // There is one maneuver so entry count should be 1
        XCTAssertEqual(list.entryCount, 2, "Route with 2 Maneuvers doesnt not have entry count 2")
    }

    func testManeuvers() {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let cell0 = list.cellForRow(at: indexPath0)
        let maneuverDescriptionItem0 = getManeuverDescriptionItem(cell0!)

        XCTAssertFalse(maneuverDescriptionItem0.iconView.isHidden, "Init -> iconView is not visible")
        XCTAssertLocalized(maneuverDescriptionItem0.instructionLabel.text, key: "msdkui_maneuver_enter_highway", bundle: .MSDKUI,
                           "item is displaying wrong instruction")
        XCTAssertEqual(maneuverDescriptionItem0.distanceLabel.text, "200 m",
                       "Maneuver should display distance '200 m'")

        let indexPath1 = IndexPath(row: 1, section: 0)
        let cell1 = list.cellForRow(at: indexPath1)
        let maneuverDescriptionItem1 = getManeuverDescriptionItem(cell1!)

        XCTAssertFalse(maneuverDescriptionItem1.iconView.isHidden, "Init -> iconView is not visible")
        XCTAssertLocalized(maneuverDescriptionItem1.instructionLabel.text, key: "msdkui_maneuver_arrive_at_02y", bundle: .MSDKUI,
                           "item is displaying wrong instruction")
        XCTAssertFalse(maneuverDescriptionItem1.isSectionVisible(.distance),
                       "Maneuver should not display a distance")
    }

    // Gets the ManeuverDescriptionItem view out of the cell
    func getManeuverDescriptionItem(_ item: UITableViewCell) -> ManeuverDescriptionItem {
        let views = item.contentView.subviews.filter { $0 is ManeuverDescriptionItem }

        // There should be one and only one view in the views
        XCTAssertEqual(views.count, 1, "Not the expected views count 1, but \(views.count)!")

        return views[0] as! ManeuverDescriptionItem
    }
}
