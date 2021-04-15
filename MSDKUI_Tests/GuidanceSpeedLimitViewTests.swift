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

final class GuidanceSpeedLimitViewTests: XCTestCase {
    /// The object under test.
    private var speedLimitView = GuidanceSpeedLimitView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))

    override func setUp() {
        super.setUp()

        speedLimitView.unit = .kilometersPerHour
    }

    // MARK: - Tests

    /// Tests if the view exists.
    func testViewExists() {
        XCTAssertNotNil(speedLimitView, "It exists")
    }

    /// Tests if view has the correct background color (and container background color from nib).
    func testViewBackgroundColor() {
        XCTAssertEqual(speedLimitView.backgroundColor, .white, "It has the correct background color")
        XCTAssertNil(speedLimitView.subviews.first?.backgroundColor, "It has a transparent container view")
    }

    /// Tests if the required `.GuidanceSpeedLimitView.init(coder:)` returns a new `GuidanceSpeedLimit` instance.
    func testInitWithCoder() throws {
        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        let speedLimitView = GuidanceSpeedLimitView(coder: coder)

        XCTAssertNotNil(speedLimitView, "It exists")
        XCTAssertNotNil(speedLimitView?.speedLimitLabel, "It has the speed limit label")
        XCTAssertNotNil(speedLimitView?.backgroundImageView, "It has the background image view")
    }

    /// Tests if the view has the speed limit label (empty by the default).
    func testHasSpeedLimitLabel() {
        XCTAssertNotNil(speedLimitView.speedLimitLabel, "It has the speed limit label")
        XCTAssertNil(speedLimitView.speedLimitLabel.text, "It doesn't have speed limit")
        XCTAssertEqual(speedLimitView.speedLimitLabel.textAlignment, .center, "It shows the correct text alignment")
        XCTAssertEqual(
            speedLimitView.speedLimitLabel.font, .monospacedDigitSystemFont(ofSize: 22, weight: .bold),
            "It uses monospaced digits as the speed limit label font"
        )
    }

    /// Tests if the view has the background image view (empty by the default).
    func testHasBackgroundImageView() {
        XCTAssertNotNil(speedLimitView.backgroundImageView, "It has the background image view")
        XCTAssertNil(speedLimitView.backgroundImageView.image, "It doesn't have an image set")
    }

    /// Tests if the view accessiblity is correct.
    func testViewAccessibility() {
        XCTAssertTrue(speedLimitView.isAccessibilityElement, "It allows accessibility access")
        XCTAssertEqual(speedLimitView.accessibilityTraits, .staticText, "It has the correct accessibility traits")
        XCTAssertEqual(speedLimitView.accessibilityIdentifier, "MSDKUI.GuidanceSpeedLimitView", "It has the correct accessibility identifier")
        XCTAssertLocalized(speedLimitView.accessibilityLabel, key: "msdkui_speed_limit", bundle: .MSDKUI, "It has the correct accessibility label")
    }

    /// Tests if the label is an element that an assistive application can access.
    func testLabelAccessibility() {
        XCTAssertFalse(speedLimitView.speedLimitLabel.isAccessibilityElement, "It disables accessibility access")
        XCTAssertFalse(speedLimitView.backgroundImageView.isAccessibilityElement, "It disables accessibility access")
    }

    /// Test if the view accessibility hint is correct when speed limit isn't set.
    func testViewAccessibilityHintWhenSpeedLimitIsntSet() {
        XCTAssertNil(speedLimitView.accessibilityHint, "It doesn't return accessibility hint")
    }

    /// Test if the label is correct for valid speed limit.
    func testWhenSpeedIsSetWithValidValue() {
        speedLimitView.speedLimit = Measurement(value: 80, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedLimitView.speedLimitLabel.text, "80", "It shows the correct speed value")
        XCTAssertEqual(speedLimitView.speedLimitLabel.textColor, .colorForeground, "It shows the label with correct color")
        XCTAssertEqual(speedLimitView.accessibilityHint, "80 kilometers per hour", "It returns the correct hint")
    }

    /// Test if the label is correct for nil speed limit.
    func testWhenSpeedIsSetWithNilValue() {
        speedLimitView.speedLimit = nil

        XCTAssertNil(speedLimitView.speedLimitLabel.text, "It doesn't have speed limit")
        XCTAssertNil(speedLimitView.accessibilityHint, "It doesn't return accessibility hint")
    }

    /// Tests if the label is correct when a different unit is provided.
    func testWhenSpeedLimitIsSetWithDifferentUnit() {
        speedLimitView.unit = .knots
        speedLimitView.speedLimit = Measurement(value: 80, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedLimitView.speedLimitLabel.text, "43", "It shows the correct speed value")
        XCTAssertEqual(speedLimitView.speedLimitLabel.textColor, .colorForeground, "It shows the label with correct color")
        XCTAssertEqual(speedLimitView.accessibilityHint, "43 knots", "It returns the correct hint")
    }

    /// Test if the background image view shows the correct image when set.
    func testBackgroundImageViewWithValidImage() {
        let mockImage = UIImage()

        speedLimitView.backgroundImageView.image = mockImage

        XCTAssertTrue(speedLimitView.backgroundImageView.image === mockImage, "It shows the correct image")
    }

    /// Test if the background image view removes the image when nil is set.
    func testBackgroundImageViewWithNilImage() {
        speedLimitView.backgroundImageView.image = UIImage()
        speedLimitView.backgroundImageView.image = nil

        XCTAssertNil(speedLimitView.backgroundImageView.image, "It doesn't have an image set")
    }

    /// Tests if the label is correct when `.speedLimitTextColor` is changed.
    func testWhenTextColorsChange() {
        speedLimitView.speedLimit = Measurement(value: 80, unit: UnitSpeed.kilometersPerHour)

        XCTAssertNotEqual(speedLimitView.speedLimitLabel.textColor, .purple, "It shows the label with correct color before the change")

        speedLimitView.speedLimitTextColor = .purple

        XCTAssertEqual(speedLimitView.speedLimitLabel.textColor, .purple, "It shows the label with correct color after the change")
    }

    /// Tests if the label is correct when `.unit` is changed.
    func testWhenUnitChanges() {
        speedLimitView.speedLimit = Measurement(value: 80, unit: UnitSpeed.kilometersPerHour)

        XCTAssertEqual(speedLimitView.speedLimitLabel.text, "80", "It shows the correct speed value before the change")

        speedLimitView.unit = .knots

        XCTAssertEqual(speedLimitView.speedLimitLabel.text, "43", "It shows the correct speed value after the change")
    }
}
