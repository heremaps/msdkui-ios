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

final class ManeuverItemViewTests: XCTestCase {
    private var view = ManeuverItemView()

    /// Tests the item view.
    func testView() {
        XCTAssertEqual(view.backgroundColor, .colorForegroundLight, "It has the correct background color")
        XCTAssertTrue(view.isAccessibilityElement, "It supports accessbility")
        XCTAssertEqual(view.accessibilityTraits, .staticText, "It has the correct accessbility traits")
        XCTAssertLocalized(view.accessibilityLabel, key: "msdkui_maneuver", bundle: .MSDKUI, "It has the correct accessbility label")
        XCTAssertEqual(view.accessibilityIdentifier, "MSDKUI.ManeuverItemView", "It has the correct accessbility identifier")
        XCTAssertNil(view.accessibilityHint, "It has the correct accessbility hint")
    }

    /// Tests the icon image view after item view initialization.
    func testIconImageView() {
        XCTAssertNil(view.iconImageView.image, "It doesn't an image by default")
        XCTAssertTrue(view.iconImageView.isHidden, "It is hidden by default")
        XCTAssertEqual(view.iconImageView.tintColor, .colorForeground, "It has the correct tint color")
        XCTAssertFalse(view.iconImageView.isAccessibilityElement, "It doesn't support accessbility")
    }

    /// Tests the instruction label after item view initialization.
    func testInstructionLabel() {
        XCTAssertNil(view.instructionLabel.text, "It doesn't text by default")
        XCTAssertTrue(view.instructionLabel.isHidden, "It is hidden by default")
        // TODO: MSDKUI-2160
        // XCTAssertEqual(view.instructionLabel.font, UIFont.preferredFont(forTextStyle: .body), "It has the correct font")
        XCTAssertEqual(view.instructionLabel.textColor, .colorForeground, "It has the correct text color")
        XCTAssertEqual(view.instructionLabel.numberOfLines, 0, "It supports multiple lines")
        XCTAssertFalse(view.instructionLabel.adjustsFontSizeToFitWidth, "It doesn't shrink the font based on the string lenght")
        XCTAssertFalse(view.instructionLabel.isAccessibilityElement, "It doesn't support accessbility")
    }

    /// Tests the address label after item view initialization.
    func testAddressLabel() {
        XCTAssertNil(view.addressLabel.text, "It doesn't text by default")
        XCTAssertTrue(view.addressLabel.isHidden, "It is hidden by default")
        // TODO: MSDKUI-2160
        // XCTAssertEqual(view.addressLabel.font, UIFont.preferredFont(forTextStyle: .subheadline), "It has the correct font")
        XCTAssertEqual(view.addressLabel.textColor, .colorForegroundSecondary, "It has the correct text color")
        XCTAssertEqual(view.addressLabel.numberOfLines, 0, "It supports multiple lines")
        XCTAssertFalse(view.addressLabel.adjustsFontSizeToFitWidth, "It doesn't shrink the font based on the string lenght")
        XCTAssertFalse(view.addressLabel.isAccessibilityElement, "It doesn't support accessbility")
    }

    /// Tests the distance label after item view initialization.
    func testDistanceLabel() {
        XCTAssertNil(view.distanceLabel.text, "It doesn't text by default")
        XCTAssertTrue(view.distanceLabel.isHidden, "It is hidden by default")
        // TODO: MSDKUI-2160
        // XCTAssertEqual(view.distanceLabel.font, UIFont.preferredFont(forTextStyle: .subheadline), "It has the correct font")
        XCTAssertEqual(view.distanceLabel.textColor, .colorForegroundSecondary, "It has the correct text color")
        XCTAssertEqual(view.distanceLabel.numberOfLines, 1, "It supports one line")
        XCTAssertFalse(view.distanceLabel.isAccessibilityElement, "It doesn't support accessbility")
    }

    /// Tests the address and distance stack view after item view initialization.
    func testAddressDistanceStackView() {
        XCTAssertTrue(view.distanceLabel.isHidden, "It is hidden by default")
        XCTAssertEqual(view.addressDistanceStackView.alignment, .lastBaseline, "It has the correct alignemnt for address and distance labels")
    }

    /// Tests the behavior when all the properties are set.
    func testWhenPropertiesAreSet() {
        let mockImage = UIImage()
        let distance = Measurement(value: 50, unit: UnitLength.meters)
        let expectedFormattedDistance = MeasurementFormatter.currentMediumUnitFormatter.string(from: distance)
        let expectedFormattedAccessbilityDistance = MeasurementFormatter.currentLongUnitFormatter.string(from: distance)
        let expectedAccessibilityHint = "mocked instructions, mocked address, \(expectedFormattedAccessbilityDistance)"

        view.icon = mockImage
        view.instructions = "mocked instructions"
        view.address = "mocked address"
        view.distance = distance

        XCTAssertEqual(view.iconImageView.image, mockImage, "It has the correct icon")
        XCTAssertFalse(view.iconImageView.isHidden, "It shows the icon image view")
        XCTAssertEqual(view.instructionLabel.text, "mocked instructions", "It has the correct instruction text")
        XCTAssertFalse(view.instructionLabel.isHidden, "It shows the instruction label")
        XCTAssertEqual(view.addressLabel.text, "mocked address", "It has the correct address text")
        XCTAssertFalse(view.addressLabel.isHidden, "It shows the address label")
        XCTAssertEqual(view.distanceLabel.text, expectedFormattedDistance, "It has the correct distance text")
        XCTAssertFalse(view.distanceLabel.isHidden, "It shows the distance label")
        XCTAssertFalse(view.addressDistanceStackView.isHidden, "It shows the address and distance stack view")
        XCTAssertEqual(view.accessibilityHint, expectedAccessibilityHint, "It has the correct accessbility hint")
    }

    /// Tests the behavior when the icon is set.
    func testWhenIconIsset() {
        let mockImage = UIImage()

        view.icon = mockImage

        XCTAssertEqual(view.iconImageView.image, mockImage, "It has the correct icon")
        XCTAssertFalse(view.iconImageView.isHidden, "It shows the icon image view")
        XCTAssertNil(view.accessibilityHint, "It has the correct accessbility hint")
    }

    /// Tests the behavior when the instructions are set.
    func testWhenInstructionsAreSet() {
        view.instructions = "mocked instructions"

        XCTAssertEqual(view.instructionLabel.text, "mocked instructions", "It has the correct instruction text")
        XCTAssertFalse(view.instructionLabel.isHidden, "It shows the instruction label")
        XCTAssertEqual(view.accessibilityHint, "mocked instructions", "It has the correct accessbility hint")
    }

    /// Tests the behavior when address is set.
    func testWhenAddressIsSet() {
        view.address = "mocked address"

        XCTAssertEqual(view.addressLabel.text, "mocked address", "It has the correct address text")
        XCTAssertFalse(view.addressLabel.isHidden, "It shows the address label")
        XCTAssertFalse(view.addressDistanceStackView.isHidden, "It shows the address and distance stack view")
        XCTAssertEqual(view.accessibilityHint, "mocked address", "It has the correct accessbility hint")
    }

    /// Tests the behavior when distance is set.
    func testWhenDistanceIsSet() {
        let distance = Measurement(value: 50, unit: UnitLength.meters)
        let expectedFormattedDistance = MeasurementFormatter.currentMediumUnitFormatter.string(from: distance)
        let expectedFormattedAccessbilityDistance = MeasurementFormatter.currentLongUnitFormatter.string(from: distance)

        view.distance = distance

        XCTAssertEqual(view.distanceLabel.text, expectedFormattedDistance, "It has the correct distance text")
        XCTAssertFalse(view.distanceLabel.isHidden, "It shows the distance label")
        XCTAssertFalse(view.addressDistanceStackView.isHidden, "It shows the address and distance stack view")
        XCTAssertEqual(view.accessibilityHint, expectedFormattedAccessbilityDistance, "It has the correct accessbility hint")
    }

    /// Tests the behavior when address and distance are missing.
    func testWhenAddressAndDistanceAreMissing() {
        let mockImage = UIImage()

        view.icon = mockImage
        view.instructions = "mocked instructions"

        XCTAssertEqual(view.iconImageView.image, mockImage, "It has the correct icon")
        XCTAssertFalse(view.iconImageView.isHidden, "It shows the icon image view")
        XCTAssertEqual(view.instructionLabel.text, "mocked instructions", "It has the correct instruction text")
        XCTAssertFalse(view.instructionLabel.isHidden, "It shows the instruction label")
        XCTAssertNil(view.addressLabel.text, "It doesn't have the address text")
        XCTAssertTrue(view.addressLabel.isHidden, "It hides the address label")
        XCTAssertNil(view.distanceLabel.text, "It doesn't have the distance text")
        XCTAssertTrue(view.distanceLabel.isHidden, "It hides the distance label")
        XCTAssertTrue(view.addressDistanceStackView.isHidden, "It hides the address and distance stack view")
        XCTAssertEqual(view.accessibilityHint, "mocked instructions", "It has the correct accessbility hint")
    }

    /// Tests the behavior when distance formatter is set.
    func testWhenDistanceFormatterIsSet() {
        let distance = Measurement(value: 50, unit: UnitLength.meters)
        let mockFormatter = MeasurementFormatter()
        let expectedFormattedDistance = mockFormatter.string(from: distance)

        view.distance = distance
        view.distanceFormatter = mockFormatter

        XCTAssertEqual(view.distanceLabel.text, expectedFormattedDistance, "It has the correct distance text")
        XCTAssertFalse(view.distanceLabel.isHidden, "It shows the distance label")
        XCTAssertFalse(view.addressDistanceStackView.isHidden, "It shows the address and distance stack view")
    }

    /// Tests the behavior when accessbility distance formatter is set.
    func testWhenAccessibilityDistanceFormatterIsSet() {
        let distance = Measurement(value: 50, unit: UnitLength.meters)
        let mockFormatter = MeasurementFormatter()
        let expectedFormattedAccessbilityDistance = mockFormatter.string(from: distance)

        view.distance = distance
        view.accessibilityDistanceFormatter = mockFormatter

        XCTAssertEqual(view.accessibilityHint, expectedFormattedAccessbilityDistance, "It has the correct accessbility hint")
    }

    /// Tests the behavior when the icon has a different color set.
    func testWhenIconColorIsSet() {
        view.iconTintColor = .red

        XCTAssertEqual(view.iconImageView.tintColor, .red, "It sets the correct icon image view tint color")
    }

    /// Tests the behavior when instructions has a different color set.
    func testWhenInstructionsColorIsSet() {
        view.instructionsTextColor = .purple

        XCTAssertEqual(view.instructionLabel.textColor, .purple, "It sets the correct label text color")
    }

    /// Tests the behavior when address has a different color set.
    func testWhenAddressColorIsSet() {
        view.addressTextColor = .brown

        XCTAssertEqual(view.addressLabel.textColor, .brown, "It sets the correct label text color")
    }

    /// Tests the behavior when distance has a different color set.
    func testWhenDistanceColorIsSet() {
        view.distanceTextColor = .yellow

        XCTAssertEqual(view.distanceLabel.textColor, .yellow, "It sets the correct label text color")
    }

    /// Tests if the required `.init(coder:)` returns a new instance.
    func testInitWithCoder() throws {
        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        let itemView = ManeuverItemView(coder: coder)

        XCTAssertNotNil(itemView, "It exists")
    }
}
