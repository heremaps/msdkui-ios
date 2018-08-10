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

class RouteDescriptionItemTests: XCTestCase {
    // The test object
    private var item = RouteDescriptionItem()

    // Is the default visibility OK?
    func testDefaultVisibilty() {
        // Is the switch state in line with the checked property?
        XCTAssertEqual(item.visibleSections, .all, "Not the expected default visibility!")
    }

    // Can we change the visibilities?
    func testSectionVisibilityModifications() {
        item.setSectionVisible(.icon, false)
        item.setSectionVisible(.duration, false)
        item.setSectionVisible(.delay, false)
        item.setSectionVisible(.length, false)
        item.setSectionVisible(.bar, true)
        item.setSectionVisible(.time, false)

        XCTAssertTrue(item.transportModeView.isHidden, "Not the expected hidden setting!")
        XCTAssertTrue(item.durationLabel.isHidden, "Not the expected hidden setting!")
        XCTAssertTrue(item.delayLabel.isHidden, "Not the expected hidden setting!")
        XCTAssertFalse(item.barView.isHidden, "Not the expected hidden setting!")
        XCTAssertTrue(item.lengthLabel.isHidden, "Not the expected hidden setting!")
        XCTAssertTrue(item.timeLabel.isHidden, "Not the expected hidden setting!")
    }

    // Are the String to Section & Section & String conversion functions OK?
    func testConversions() {
        // Unknown substrings should be ignored along with uppercases & blank spaces
        let string0 = "ICON |   Duration | delay|time|unknown1|   UNKNOWN2:)unknoWn3"
        let section0 = RouteDescriptionItem.Section.make(from: string0)
        XCTAssertEqual(section0, [.icon, .duration, .delay, .time], "Not the expected conversion!")

        // If a string has "all", simply .all should be returned
        let string1 = "delay|time|   ALL | All"
        let section1 = RouteDescriptionItem.Section.make(from: string1)
        XCTAssertEqual(section1, .all, "Not the expected conversion!")

        // Is the "empty" String handling OK?
        let string2 = ""
        let section2 = RouteDescriptionItem.Section.make(from: string2)
        XCTAssertEqual(section2, [], "Not the expected conversion!")

        // Will we get the substrings in the Section declaration order
        let section3: RouteDescriptionItem.Section = [.icon, .time, .duration, .delay, .bar]
        let string3 = section3.stringized
        XCTAssertEqual(string3, "icon|duration|delay|bar|time", "Not the expected conversion!")

        // Is the .all handling OK?
        let section4: RouteDescriptionItem.Section = .all
        let string4 = section4.stringized
        XCTAssertEqual(string4, "all", "Not the expected conversion!")

        // Is the "empty" Section handling OK?
        let section5 = RouteDescriptionItem.Section()
        let string5 = section5.stringized
        XCTAssertTrue(string5.isEmpty, "Not the expected conversion!")
    }
}
