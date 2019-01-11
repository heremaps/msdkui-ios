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

final class ManeuverItemViewTests: XCTestCase {

    /// The object under test.
    private var itemView: ManeuverItemView?

    override func setUp() {
        super.setUp()

        // Set up the item
        itemView = ManeuverItemView()

        // Make sure to have at least one maneuver
        if let maneuvers = MockUtils.mockRoute().maneuvers, maneuvers.isEmpty == false {
           itemView?.setManeuver(maneuvers: maneuvers, index: 0)
        }
    }

    // MARK: - Tests

    /// Tests default values.
    func testDefaultValues() throws {
        let item = try require(itemView)

        // All the component should be visible at first
        XCTAssertFalse(item.iconImageView.isHidden, "iconImageView is not visible")
        XCTAssertFalse(item.instructionLabel.isHidden, " instructionLabel is not visible")
        XCTAssertFalse(item.addressLabel.isHidden, "addressLabel is not visible")
        XCTAssertFalse(item.distanceLabel.isHidden, "distanceLabel is not visible")
        XCTAssertNotNil(item.maneuver, "maneuver is null")
        XCTAssertEqual(item.visibleSections, .all, "visible section returns wrong value")
    }

    /// Tests the item default colors.
    func testDefaultColors() throws {
        let item = try require(itemView)

        XCTAssertEqual(item.backgroundColor, .colorForegroundLight, "It has the correct background color")
        XCTAssertEqual(item.iconImageView.tintColor, .colorForeground, "It has the correct icon tint color")
        XCTAssertEqual(item.instructionLabel.textColor, .colorForeground, "It has the correct instruction label text color")
        XCTAssertEqual(item.addressLabel.textColor, .colorForegroundSecondary, "It has the correct address label text color")
        XCTAssertEqual(item.distanceLabel.textColor, .colorForegroundSecondary, "It has the correct distance label text color")
    }

    /// Tests default visibility.
    func testDefaultVisibilty() throws {
        let item = try require(itemView)

        XCTAssertEqual(item.visibleSections, .all, "Not the expected default visibility")
    }

    /// Tests changing visibilities.
    func testSectionVisibilityModifications() throws {
        let item = try require(itemView)

        item.setSectionVisible(.icon, false)
        item.setSectionVisible(.instructions, false)
        item.setSectionVisible(.address, true)
        item.setSectionVisible(.distance, false)

        XCTAssertTrue(item.iconImageView.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.instructionLabel.isHidden, "Not the expected visibility setting")
        XCTAssertFalse(item.addressLabel.isHidden, "Not the expected visibility setting")
        XCTAssertTrue(item.distanceLabel.isHidden, "Not the expected visibility setting")
    }

    /// Tests maneuver contents.
    func testManeuverContents() throws {
        let item = try require(itemView)
        let expectedDistance = Measurement(value: 200, unit: UnitLength.meters)
        let expectedFormattedDistance = MeasurementFormatter.currentMediumUnitFormatter.string(from: expectedDistance)
        let expectedLongFormattedDistance = MeasurementFormatter.currentLongUnitFormatter.string(from: expectedDistance)

        XCTAssertLocalized(item.instructionLabel.text, key: "msdkui_maneuver_enter_highway", bundle: .MSDKUI,
                           "item is displaying wrong instruction")

        XCTAssertEqual(item.distanceLabel.text, expectedFormattedDistance, "Maneuver should display distance 200 m")
        XCTAssertEqual(item.distanceLabel.accessibilityLabel, expectedLongFormattedDistance, "Maneuver should read distance 200 meters")
    }

    /// Tests `String` to `Section` and `Section` to `String` conversion.
    func testConversions() {
        // Unknown substrings should be ignored along with uppercases & blank spaces
        let string0 = "ICON |   Instructions | distance|unknown1|   UNKNOWN2:)unknoWn3"
        let section0 = ManeuverItemView.Section.make(from: string0)
        XCTAssertEqual(section0, [.icon, .instructions, .distance], "Not the expected conversion!")

        // If a string has "all", simply .all should be returned
        let string1 = "address|distance|   ALL | All"
        let section1 = ManeuverItemView.Section.make(from: string1)
        XCTAssertEqual(section1, .all, "Not the expected conversion!")

        // Is the "empty" String handling OK?
        let string2 = ""
        let section2 = ManeuverItemView.Section.make(from: string2)
        XCTAssertEqual(section2, [], "Not the expected conversion!")

        // Will we get the substrings in the Section declaration order?
        let section3: ManeuverItemView.Section = [.icon, .instructions, .distance]
        let string3 = section3.stringized
        XCTAssertEqual(string3, "icon|instructions|distance", "Not the expected conversion!")

        // Is the .all handling OK?
        let section4: ManeuverItemView.Section = .all
        let string4 = section4.stringized
        XCTAssertEqual(string4, "all", "Not the expected conversion!")

        // Is the "empty" Section handling OK?
        let section5 = RouteDescriptionItem.Section()
        let string5 = section5.stringized
        XCTAssertTrue(string5.isEmpty, "Not the expected conversion!")
    }

    /// Tests the default `ManeuverItemView.leadingInset` and `ManeuverItemView.trailingInset`
    /// values are in line with the related constraints.
    func testDefaultInsetValues() throws {
        let item = try require(itemView)

        XCTAssertEqual(item.leadingInset, item.leadingConstraint.constant, "Not the expected default value")
        XCTAssertEqual(item.trailingInset, item.trailingConstraint.constant, "Not the expected default value")
    }

    /// Tests that `ManeuverItemView.leadingInset` and `ManeuverItemView.trailingInset` properties
    /// update the related constraints.
    func testSettingInsetsUpdateRelatedConstraints() throws {
        let item = try require(itemView)

        // Update the insets
        item.leadingInset = 17
        item.trailingInset = -38

        // Are the constraints updated?
        XCTAssertEqual(item.leadingConstraint.constant, item.leadingInset, "Not the expected default value")
        XCTAssertEqual(item.trailingConstraint.constant, item.trailingInset, "Not the expected default value")
    }
}
