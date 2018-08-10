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

class ManeuverDescriptionItemTests: XCTestCase {
    // The test object
    private var item = ManeuverDescriptionItem()

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        item.setManeuver(maneuvers: MockUtils.mockRoute().maneuvers!, position: 0)
    }

    // Are the defaults OK?
    func testDefaultValues() {
        // all component should be visible first
        XCTAssertFalse(item.iconView.isHidden, "Init -> iconView is not visible")
        XCTAssertFalse(item.instructionLabel.isHidden, "Init -> instructionLabel is not visible")
        XCTAssertFalse(item.addressLabel.isHidden, "Init -> addressLabel is not visible")
        XCTAssertFalse(item.distanceLabel.isHidden, "Init -> distanceLabel is not visible")
        XCTAssertNotNil(item.maneuver, "Init -> maneuver is null")
        XCTAssertEqual(item.visibleSections, .all, "Init -> visible section returns wrong value")
    }

    // Are the contents OK?
    func testManeuverContents() {
        XCTAssertLocalized(item.instructionLabel.text, key: "msdkui_maneuver_enter_highway", bundle: .MSDKUI,
                           "item is displaying wrong instruction")

        XCTAssertEqual(item.distanceLabel.text, "200 m", "Maneuver should display distance 200 m")
    }

    // Can we change the visibilities?
    func testSectionvisibilityModifications() {
        XCTAssertTrue(item.visibleSections.contains(.icon))
        item.setSectionVisible(.icon, false)
        XCTAssertFalse(item.visibleSections.contains(.icon), "Setting visibility false not working for icon")
        XCTAssertFalse(item.isSectionVisible(.icon))

        // reset
        item.setSectionVisible(.icon, true)
        XCTAssertTrue(item.visibleSections.contains(.all))
        item.setSectionVisible(.all, false)
        XCTAssertFalse(item.visibleSections.contains(.all), "Setting visibility false not working for all")
    }

    // Are the String to Section & Section & String conversion functions OK?
    func testConversions() {
        // Unknown substrings should be ignored along with uppercases & blank spaces
        let string0 = "ICON |   Instructions | distance|unknown1|   UNKNOWN2:)unknoWn3"
        let section0 = ManeuverDescriptionItem.Section.make(from: string0)
        XCTAssertEqual(section0, [.icon, .instructions, .distance], "Not the expected conversion!")

        // If a string has "all", simply .all should be returned
        let string1 = "address|distance|   ALL | All"
        let section1 = ManeuverDescriptionItem.Section.make(from: string1)
        XCTAssertEqual(section1, .all, "Not the expected conversion!")

        // Is the "empty" String handling OK?
        let string2 = ""
        let section2 = ManeuverDescriptionItem.Section.make(from: string2)
        XCTAssertEqual(section2, [], "Not the expected conversion!")

        // Will we get the substrings in the Section declaration order?
        let section3: ManeuverDescriptionItem.Section = [.icon, .instructions, .distance]
        let string3 = section3.stringized
        XCTAssertEqual(string3, "icon|instructions|distance", "Not the expected conversion!")

        // Is the .all handling OK?
        let section4: ManeuverDescriptionItem.Section = .all
        let string4 = section4.stringized
        XCTAssertEqual(string4, "all", "Not the expected conversion!")

        // Is the "empty" Section handling OK?
        let section5 = RouteDescriptionItem.Section()
        let string5 = section5.stringized
        XCTAssertTrue(string5.isEmpty, "Not the expected conversion!")
    }
}
