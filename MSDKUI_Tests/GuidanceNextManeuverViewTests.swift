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

import Foundation
@testable import MSDKUI
import XCTest

final class GuidanceNextManeuverViewTests: XCTestCase {

    /// The `GuidanceNextManeuverView` under test.
    var nextManeuverView = GuidanceNextManeuverView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))

    /// Tests if the view exists.
    func testViewExists() {
        XCTAssertNotNil(nextManeuverView, "It exists")
    }

    /// Tests if the view has the distance label with empty content by default.
    func testHasDistanceLabel() {
        XCTAssertNotNil(nextManeuverView.distanceLabel, "It has the distance label")
        XCTAssertNil(nextManeuverView.distanceLabel.text, "It doesn't show the distance text")
        XCTAssertEqual(nextManeuverView.distanceLabel.textColor, nextManeuverView.foregroundColor, "It has the correct text color")
        XCTAssertEqual(nextManeuverView.distanceLabel.textAlignment, .left, "It has the correct text alignment")
    }

    /// Tests if the view has the distance/street name separator.
    func testHasSeparatorLabel() {
        XCTAssertNotNil(nextManeuverView.separatorLabel, "It has the separator label")
        XCTAssertEqual(nextManeuverView.separatorLabel.text, "·", "It has the correct separator character")
        XCTAssertEqual(nextManeuverView.separatorLabel.textColor, nextManeuverView.foregroundColor, "It has the correct text color")
        XCTAssertEqual(nextManeuverView.separatorLabel.textAlignment, .center, "It has the correct text alignment")
    }

    /// Tests if the view has the street name label with empty content by default.
    func testHaSstreetNameLabel() {
        XCTAssertNotNil(nextManeuverView.streetNameLabel, "It has the street name label")
        XCTAssertNil(nextManeuverView.streetNameLabel.text, "It doesn't show the street name text")
        XCTAssertEqual(nextManeuverView.streetNameLabel.textColor, nextManeuverView.foregroundColor, "It has the correct text color")
        XCTAssertEqual(nextManeuverView.streetNameLabel.textAlignment, .left, "It has the correct text alignment")
    }

    /// Tests if the subview vsibilities are correct when model is populated with a complete model.
    func testSubviewVisibilitiesWhenModelIsComplete() {
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: "Invalidenstr.")

        nextManeuverView.configure(with: viewModel)

        XCTAssertFalse(nextManeuverView.maneuverImageView.isHidden, "The maneuver icon is visible")
        XCTAssertFalse(nextManeuverView.distanceLabel.isHidden, "The distance label is visible")
        XCTAssertFalse(nextManeuverView.separatorLabel.isHidden, "The separator label is visible")
        XCTAssertFalse(nextManeuverView.streetNameLabel.isHidden, "The street name label is visible")
    }

    /// Tests if the subview vsibilities are correct when model is populated with an incomplete model.
    func testSubviewVisibilitiesWhenModelIsIncomplete() {
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: nil)

        nextManeuverView.configure(with: viewModel)

        XCTAssertFalse(nextManeuverView.maneuverImageView.isHidden, "The maneuver icon is visible")
        XCTAssertFalse(nextManeuverView.distanceLabel.isHidden, "The distance label is visible")
        XCTAssertTrue(nextManeuverView.separatorLabel.isHidden, "The separator label is hidden")
        XCTAssertTrue(nextManeuverView.streetNameLabel.isHidden, "The street name label is hidden")
    }

    /// Tests if the subviews are elements that an assistive application can access.
    func testSubviewAccessibility() {
        XCTAssertFalse(nextManeuverView.maneuverImageView.isAccessibilityElement,
                       "It disables icon image view accessibility access")
        XCTAssertFalse(nextManeuverView.distanceLabel.isAccessibilityElement,
                       "It disables distance label accessibility access")
        XCTAssertFalse(nextManeuverView.separatorLabel.isAccessibilityElement,
                       "It disables separator label accessibility access")
        XCTAssertFalse(nextManeuverView.streetNameLabel.isAccessibilityElement,
                       "It disables street name label accessibility access")
    }

    /// Tests if the view accessiblity is correct.
    func testViewAccessibility() {
        XCTAssertTrue(nextManeuverView.isAccessibilityElement,
                      "It allows accessibility access")
        XCTAssertEqual(nextManeuverView.accessibilityTraits,
                       .staticText,
                       "It has the correct accessibility traits")
        XCTAssertEqual(nextManeuverView.accessibilityIdentifier,
                       "MSDKUI.GuidanceNextManeuverView",
                       "It has the correct accessibility identifier")
        XCTAssertLocalized(nextManeuverView.accessibilityLabel,
                           key: "msdkui_next_maneuver",
                           bundle: .MSDKUI,
                           "It has the correct accessibility label")
    }

    /// Tests if the view accessibility hint is correct when view is not configured.
    func testViewAccessibilityHintWhenModelIsEmpty() {
        XCTAssertNil(nextManeuverView.accessibilityHint, "It returns nil as hint")
    }

    /// Tests if the view accessibility hint is correct when model is populated with the default distance formatter.
    func testViewAccessibilityHintWithDefaultDistanceFormatter() {
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: "Invalidenstr.")

        nextManeuverView.configure(with: viewModel)

        let exepectedHint = MeasurementFormatter.currentMediumUnitFormatter.string(from: distance) + ", "
            + (viewModel.streetName ?? "")

        XCTAssertEqual(nextManeuverView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    /// Tests if the view accessibility hint is correct when model is populated with a custom distance formatter.
    func testViewAccessibilityHintWithCustomDistanceFormatter() {
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let distanceFormatter = MeasurementFormatter()
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: "Invalidenstr.",
                                                           distanceFormatter: distanceFormatter)

        nextManeuverView.configure(with: viewModel)

        let exepectedHint = distanceFormatter.string(from: distance) + ", "
            + (viewModel.streetName ?? "")

        XCTAssertEqual(nextManeuverView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    /// Tests if the view accessibility hint is correct when model is populated with an incomplete model.
    func testViewAccessibilityHintWhenModelIsIncomplete() {
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: nil)

        nextManeuverView.configure(with: viewModel)

        let exepectedHint = MeasurementFormatter.currentMediumUnitFormatter.string(from: distance)

        XCTAssertEqual(nextManeuverView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    /// Tests the behavior when the `.foregroundColor` prpperty is set.
    func testWhenForegroundColorIsSet() {
        let testForegroundColor = UIColor.yellow

        nextManeuverView.foregroundColor = testForegroundColor

        // Make sure that the labels switch to the new foregroundColor
        XCTAssertEqual(nextManeuverView.distanceLabel.textColor, testForegroundColor, "It sets the correct foreground color for the view")
        XCTAssertEqual(nextManeuverView.separatorLabel.textColor, testForegroundColor, "It sets the correct foreground color for the view")
        XCTAssertEqual(nextManeuverView.streetNameLabel.textColor, testForegroundColor, "It sets the correct foreground color for the view")

        // Make sure that the icon is tinted with the new foregroundColor
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: UIImage(),
                                                           distance: distance,
                                                           streetName: nil)

        nextManeuverView.configure(with: viewModel)

        XCTAssertEqual(nextManeuverView.maneuverImageView.tintColor, testForegroundColor, "It sets the correct foreground color for the view")
    }

    /// Tests the behavior when the `.textAlignment` prpperty is set.
    func testWhenTextAlignmentIsSet() {
        nextManeuverView.textAlignment = .right

        // Make sure that the distanceLabel & streetNameLabel switch to the new text alignment
        XCTAssertEqual(nextManeuverView.distanceLabel.textAlignment, .right, "It sets the correct text alignment for the distance label")
        XCTAssertEqual(nextManeuverView.streetNameLabel.textAlignment, .right, "It sets the correct text alignment for the street name label")

        // Note that the separatorLabel.textAlignment should not be updated at all
        XCTAssertEqual(nextManeuverView.separatorLabel.textAlignment, .center, "It sets the correct text alignment for the street name label")
    }
}
