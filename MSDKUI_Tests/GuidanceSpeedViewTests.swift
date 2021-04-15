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

import Foundation
@testable import MSDKUI
import XCTest

final class GuidanceSpeedViewTests: XCTestCase {
    /// The object under test.
    private var speedView = GuidanceSpeedView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))

    override func setUp() {
        super.setUp()

        speedView.unit = .kilometersPerHour
    }

    // MARK: - Tests

    /// Tests if the view exists.
    func testViewExists() {
        XCTAssertNotNil(speedView, "It exists")
    }

    /// Tests if view has the correct background color (and container background color from nib).
    func testViewBackgroundColor() {
        XCTAssertEqual(speedView.backgroundColor, .white, "It has the correct background color")
        XCTAssertNil(speedView.subviews.first?.backgroundColor, "It has a transparent container view")
    }

    /// Tests if the view has the speed value label (with '--' as current speed by the default).
    func testHasSpeedValueLabel() {
        XCTAssertNotNil(speedView.speedValueLabel, "It has the speed value label")
        XCTAssertNonlocalizable(speedView.speedValueLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as current speed value")
        XCTAssertEqual(speedView.speedValueLabel.textAlignment, .left, "It shows the correct text alignment")
        XCTAssertEqual(
            speedView.speedValueLabel.font, .monospacedDigitSystemFont(ofSize: 22, weight: .bold),
            "It uses monospaced digits as the speed value label font"
        )
    }

    /// Tests if the view has the the speed unit label.
    func testHasSpeedUnitLabel() {
        XCTAssertNotNil(speedView.speedUnitLabel, "It has the speed unit label")
        XCTAssertNil(speedView.speedUnitLabel.text, "It hides the speed unit")
        XCTAssertEqual(speedView.speedUnitLabel.textAlignment, .left, "It shows the correct text alignment")
        XCTAssertEqual(
            speedView.speedUnitLabel.font, .monospacedDigitSystemFont(ofSize: 15, weight: .regular),
            "It uses monospaced digits as the duration label font"
        )
    }

    /// Tests if the labels are elements that an assistive application can access.
    func testLabelsAccessibility() {
        XCTAssertFalse(speedView.speedValueLabel.isAccessibilityElement, "It disables speed value label accessibility access")
        XCTAssertFalse(speedView.speedUnitLabel.isAccessibilityElement, "It disables speed unit label accessibility access")
    }

    /// Tests if the view accessiblity is correct.
    func testViewAccessibility() {
        XCTAssertTrue(speedView.isAccessibilityElement, "It allows accessibility access")
        XCTAssertEqual(speedView.accessibilityTraits, .staticText, "It has the correct accessibility traits")
        XCTAssertEqual(speedView.accessibilityIdentifier, "MSDKUI.GuidanceSpeedView", "It has the correct accessibility identifier")
        XCTAssertLocalized(speedView.accessibilityLabel, key: "msdkui_speed", bundle: .MSDKUI, "It has the correct accessibility label")
    }

    /// Test if the view accessibility hint is correct when view is not configured.
    func testViewAccessibilityHintWhenModelIsEmpty() {
        XCTAssertNil(speedView.accessibilityHint, "It doesn't return any accessibility hint")
    }

    /// Test if the labels are correct when speed is provided.
    func testWhenSpeedIsSet() {
        speedView.speed = Measurement(value: 10, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedView.speedValueLabel.text, "10", "It shows the correct speed value")
        XCTAssertEqual(speedView.speedUnitLabel.text, "km/hr", "It shows the correct speed unit")
        XCTAssertEqual(speedView.speedValueLabel.textColor, .colorForeground, "It shows the label with correct color")
        XCTAssertEqual(speedView.speedUnitLabel.textColor, .colorForegroundSecondary, "It shows the label with correct color")
        XCTAssertEqual(speedView.accessibilityHint, "10 kilometers per hour", "It returns the correct hint")
    }

    /// Tests if the labels are correct when speed is nil.
    func testWhenSpeedIsNil() {
        speedView.speed = nil

        XCTAssertNonlocalizable(speedView.speedValueLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as speed value")
        XCTAssertNil(speedView.speedUnitLabel.text, "It hides the speed unit")
        XCTAssertNil(speedView.accessibilityHint, "It doesn't return any accessibility hint")
    }

    /// Tests if the labels are correct when a different unit is provided.
    func testWhenSpeedIsSetWithDifferentUnit() {
        speedView.unit = .knots
        speedView.speed = Measurement(value: 10, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedView.speedValueLabel.text, "5", "It shows the correct speed value")
        XCTAssertEqual(speedView.speedUnitLabel.text, "kn", "It shows the correct speed unit")
        XCTAssertEqual(speedView.speedValueLabel.textColor, .colorForeground, "It shows the label with correct color")
        XCTAssertEqual(speedView.speedUnitLabel.textColor, .colorForegroundSecondary, "It shows the label with correct color")
        XCTAssertEqual(speedView.accessibilityHint, "5 knots", "It returns the correct hint")
    }

    /// Tests if the labels are correct when `.speedValueTextColor` and `.speedUnitTextColor` are changed.
    func testWhenTextColorsChange() {
        speedView.speed = Measurement(value: 10, unit: UnitSpeed.kilometersPerHour)

        XCTAssertNotEqual(speedView.speedValueLabel.textColor, .purple, "It shows the label with correct color before the change")
        XCTAssertNotEqual(speedView.speedUnitLabel.textColor, .red, "It shows the label with correct color before the change")

        speedView.speedValueTextColor = .purple
        speedView.speedUnitTextColor = .red

        XCTAssertEqual(speedView.speedValueLabel.textColor, .purple, "It shows the label with correct color after the change")
        XCTAssertEqual(speedView.speedUnitLabel.textColor, .red, "It shows the label with correct color after the change")
    }

    /// Tests if the labels are correct when `.unit` is changed.
    func testWhenUnitChanges() {
        speedView.speed = Measurement(value: 10, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedView.speedValueLabel.text, "10", "It shows the correct speed value before the change")
        XCTAssertEqual(speedView.speedUnitLabel.text, "km/hr", "It shows the correct speed unit before the change")

        speedView.unit = .knots

        XCTAssertEqual(speedView.speedValueLabel.text, "5", "It shows the correct speed value after the change")
        XCTAssertEqual(speedView.speedUnitLabel.text, "kn", "It shows the correct speed unit after the change")
    }

    /// Tests the behavior when the `.textAlignment` property is set.
    func testWhenTextAlignmentChanges() {
        speedView.textAlignment = .right

        XCTAssertEqual(speedView.speedValueLabel.textAlignment, .right, "It sets the correct text alignment for the speed value label")
        XCTAssertEqual(speedView.speedUnitLabel.textAlignment, .right, "It sets the correct text alignment for the speed unit label")
    }

    /// Tests if the required `.GuidanceSpeedView.init(coder:)` returns a new `GuidanceSpeedView` instance.
    func testInitWithCoder() throws {
        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        let speedView = GuidanceSpeedView(coder: coder)

        XCTAssertNotNil(speedView, "It exists")
        XCTAssertNotNil(speedView?.speedValueLabel, "It has the speed value label")
        XCTAssertNotNil(speedView?.speedUnitLabel, "It has the speed unit label")
    }
}
