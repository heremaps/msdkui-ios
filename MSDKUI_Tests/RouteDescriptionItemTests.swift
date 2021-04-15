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

final class RouteDescriptionItemTests: XCTestCase {
    /// The object under test.
    private let itemUnterTest = RouteDescriptionItem()

    // MARK: - Tests

    /// Tests default visibility.
    func testDefaultVisibilty() throws {
        let item = try require(itemUnterTest)

        XCTAssertEqual(item.visibleSections, .all, "Not the expected default visibility")
    }

    /// Tests the default style.
    func testDefaultStyle() throws {
        let item = try require(itemUnterTest)

        XCTAssertEqual(item.backgroundColor, .colorBackgroundViewLight, "It has the correct background color")
        XCTAssertEqual(item.transportModeImage.tintColor, .colorForeground, "It has the correct transport mode tint color")
        XCTAssertEqual(item.barView.progressTintColor, .colorAccentSecondary, "It has the correct bar view progress tint color")
        XCTAssertEqual(item.barView.trackTintColor, .colorBackgroundLight, "It has the correct bar view progress track color")
        XCTAssertEqual(item.durationLabel.textColor, .colorForeground, "It has the correct duration label text color")
        XCTAssertEqual(item.delayLabel.textColor, .colorForegroundSecondary, "It has the correct delay label text color")
        XCTAssertEqual(item.lengthLabel.textColor, .colorForegroundSecondary, "It has the correct length label text color")
        XCTAssertEqual(item.timeLabel.textColor, .colorForegroundSecondary, "It has the correct time label text color")
        XCTAssertEqual(item.warningIcon.tintColor, .colorAlert, "It has the correct warning icon tint color")
    }

    /// Tests the warning icon image view right after item initialization.
    func testWarningIcon() throws {
        XCTAssertTrue(try require(itemUnterTest.warningIcon.isHidden), "It is hidden by default after item initialization")
    }

    /// Tests visibility modifications.
    func testSectionVisibilityModifications() throws {
        let item = try require(itemUnterTest)

        item.setSectionVisible(.icon, false)
        item.setSectionVisible(.duration, false)
        item.setSectionVisible(.delay, false)
        item.setSectionVisible(.length, false)
        item.setSectionVisible(.bar, true)
        item.setSectionVisible(.time, false)

        XCTAssertTrue(item.transportModeView.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.durationLabel.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.delayLabel.isHidden, "Not the expected visibility setting")
        XCTAssertFalse(item.barView.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.lengthLabel.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.timeLabel.isHidden, "Not the expected visibility setting")
    }

    /// Tests the `String` to `Section` and `Section` to `String` conversion.
    func testConversions() {
        // Unknown substrings should be ignored along with uppercases & blank spaces
        let string0 = "ICON |   Duration | delay|time|unknown1|   UNKNOWN2:)unknoWn3"
        let section0 = RouteDescriptionItem.Section.make(from: string0)
        XCTAssertEqual(section0, [.icon, .duration, .delay, .time], "Not the expected conversion")

        // If a string has "all", simply .all should be returned
        let string1 = "delay|time|   ALL | All"
        let section1 = RouteDescriptionItem.Section.make(from: string1)
        XCTAssertEqual(section1, .all, "Not the expected conversion")

        // Is the "empty" String handling OK?
        let string2 = ""
        let section2 = RouteDescriptionItem.Section.make(from: string2)
        XCTAssertEqual(section2, [], "Not the expected conversion")

        // Will we get the substrings in the Section declaration order
        let section3: RouteDescriptionItem.Section = [.icon, .time, .duration, .delay, .bar]
        let string3 = section3.stringized
        XCTAssertEqual(string3, "icon|duration|delay|bar|time", "Not the expected conversion")

        // Is the .all handling OK?
        let section4: RouteDescriptionItem.Section = .all
        let string4 = section4.stringized
        XCTAssertEqual(string4, "all", "Not the expected conversion")

        // Is the "empty" Section handling OK?
        let section5 = RouteDescriptionItem.Section()
        let string5 = section5.stringized
        XCTAssertTrue(string5.isEmpty, "Not the expected conversion")
    }

    /// Tests the default `ManeuverItemView.leadingInset` and `ManeuverItemView.trailingInset`
    /// values are in line with the related constraints.
    func testDefaultInsetValues() throws {
        let item = try require(itemUnterTest)

        XCTAssertEqual(item.leadingInset, item.leadingConstraint.constant, "Not the expected default value")
        XCTAssertEqual(item.trailingInset, item.trailingConstraint.constant, "Not the expected default value")
    }

    /// Tests that `RouteDescriptionItem.leadingInset` and `RouteDescriptionItem.trailingInset` properties
    /// update the related constraints.
    func testSettingInsetsUpdateRelatedConstraints() throws {
        let item = try require(itemUnterTest)

        // Update the insets
        item.leadingInset = 17
        item.trailingInset = -38

        // Are the constraints updated?
        XCTAssertEqual(item.leadingConstraint.constant, item.leadingInset, "Not the expected default value")
        XCTAssertEqual(item.trailingConstraint.constant, item.trailingInset, "Not the expected default value")
    }
}
