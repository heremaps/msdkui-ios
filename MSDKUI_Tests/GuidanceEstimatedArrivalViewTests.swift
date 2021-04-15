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

final class GuidanceEstimatedArrivalViewTests: XCTestCase {
    /// The object under test.
    private var arrivalView = GuidanceEstimatedArrivalView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))

    // MARK: - Defaults

    /// Tests if the view exists.
    func testViewExists() {
        XCTAssertNotNil(arrivalView, "It exists")
    }

    /// Tests if the required `.GuidanceEstimatedArrivalView.init(coder:)` returns a new
    /// `GuidanceEstimatedArrivalView` instance.
    func testInitWithCoder() throws {
        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        let arrivalView = GuidanceEstimatedArrivalView(coder: coder)

        XCTAssertNotNil(arrivalView, "It exists")
        XCTAssertNotNil(arrivalView?.estimatedTimeOfArrivalLabel, "It has the ETA label")
        XCTAssertNotNil(arrivalView?.durationLabel, "It has the duration label")
        XCTAssertNotNil(arrivalView?.distanceLabel, "It has the distance label")
        XCTAssertNotNil(arrivalView?.separatorLabel, "It has the separator label")
    }

    /// Tests if the view has the estimated time of arrival label (with empty content by default).
    func testHasEstimatedTimeOfArrivalLabel() {
        XCTAssertNotNil(arrivalView.estimatedTimeOfArrivalLabel, "It has the estimated time of arrival label")
        XCTAssertNonlocalizable(arrivalView.estimatedTimeOfArrivalLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as ETA text")
        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.textColor, .colorForeground, "It has the correct text color")
        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.textAlignment, .center, "It has the correct text alignment")
        XCTAssertEqual(
            arrivalView.estimatedTimeOfArrivalLabel.font, .monospacedDigitSystemFont(ofSize: 22, weight: .bold),
            "It uses monospaced digits as the ETA label font"
        )
    }

    /// Tests if the view has the duration label (with empty content by default).
    func testHasDurationLabel() {
        XCTAssertNotNil(arrivalView.durationLabel, "It has the duration label")
        XCTAssertNonlocalizable(arrivalView.durationLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as duration text")
        XCTAssertEqual(arrivalView.durationLabel.textColor, .colorForegroundSecondary, "It has the correct text color")
        XCTAssertEqual(arrivalView.durationLabel.textAlignment, .center, "It has the correct text alignment")
        XCTAssertEqual(
            arrivalView.durationLabel.font, .monospacedDigitSystemFont(ofSize: 15, weight: .regular),
            "It uses monospaced digits as the duration label font"
        )
    }

    /// Tests if the view has the remaining distance label (with empty content by default).
    func testHasDistanceLabel() {
        XCTAssertNotNil(arrivalView.distanceLabel, "It has the distance label")
        XCTAssertNonlocalizable(arrivalView.distanceLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as distance text")
        XCTAssertEqual(arrivalView.distanceLabel.textColor, .colorForegroundSecondary, "It has the correct text color")
        XCTAssertEqual(arrivalView.distanceLabel.textAlignment, .center, "It has the correct text alignment")
        XCTAssertEqual(
            arrivalView.distanceLabel.font, .monospacedDigitSystemFont(ofSize: 15, weight: .regular),
            "It uses monospaced digits as the distance label font"
        )
    }

    /// Tests if the view has the duration/distance separator.
    func testHasSeparatorLabel() {
        XCTAssertNotNil(arrivalView.separatorLabel, "It has the separator label")
        XCTAssertEqual(arrivalView.separatorLabel.textColor, .colorForegroundSecondary, "It has the correct text color")
        XCTAssertEqual(arrivalView.separatorLabel.textAlignment, .center, "It has the correct text alignment")
        XCTAssertEqual(arrivalView.separatorLabel.text, "･", "It has the correct separator character")
    }

    // MARK: - Configure

    /// Tests if the labels have the correct content when the view has default formatters.
    func testWhenConfigureIsTriggeredWithDefaultFormatters() {
        let arrivalTime = Date.distantFuture
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.duration = duration
        arrivalView.distance = distance

        XCTAssertEqual(
            arrivalView.estimatedTimeOfArrivalLabel.text, DateFormatter.currentShortTimeFormatter.string(from: arrivalTime),
            "It shows the correct ETA"
        )
        XCTAssertEqual(
            arrivalView.durationLabel.text, MeasurementFormatter.currentMediumUnitFormatter.string(from: duration),
            "It shows the correct duration"
        )
        XCTAssertEqual(
            arrivalView.distanceLabel.text, MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
            "It shows the correct remaining distance"
        )
    }

    /// Tests if the labels have the correct content when the view has custom formatters.
    func testWhenConfigureIsTriggeredWithCustomFormatters() {
        let arrivalTime = Date.distantFuture
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.duration = duration
        arrivalView.distance = distance

        let dateFormatter = DateFormatter()
        let durationFormatter = MeasurementFormatter()
        let distanceFormatter = MeasurementFormatter()

        arrivalView.estimatedTimeOfArrivalFormatter = dateFormatter
        arrivalView.durationFormatter = durationFormatter
        arrivalView.distanceFormatter = distanceFormatter

        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.text, dateFormatter.string(from: arrivalTime), "It shows the correct ETA")
        XCTAssertEqual(arrivalView.durationLabel.text, durationFormatter.string(from: duration), "It shows the correct duration")
        XCTAssertEqual(arrivalView.distanceLabel.text, distanceFormatter.string(from: distance), "It shows the correct remaining distance")
    }

    /// Tests if the labels have the correct content when the one of the properties is missing (e.g. duration).
    func testWhenConfigureIsTriggeredWhenDurationIsMissing() {
        let arrivalTime = Date.distantFuture
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.distance = distance

        let dateFormatter = DateFormatter()
        let distanceFormatter = MeasurementFormatter()

        arrivalView.estimatedTimeOfArrivalFormatter = dateFormatter
        arrivalView.distanceFormatter = distanceFormatter

        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.text, dateFormatter.string(from: arrivalTime), "It shows the correct ETA")
        XCTAssertNonlocalizable(arrivalView.durationLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as duration text")
        XCTAssertEqual(arrivalView.distanceLabel.text, distanceFormatter.string(from: distance), "It shows the correct remaining distance")
    }

    /// Tests if the labels have the correct content when the all properties are null.
    func testWhenConfigureIsTriggeredWhenPropertiesAreNull() {
        arrivalView.estimatedTimeOfArrival = nil
        arrivalView.duration = nil
        arrivalView.distance = nil

        XCTAssertNonlocalizable(arrivalView.estimatedTimeOfArrivalLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as ETA text")
        XCTAssertNonlocalizable(arrivalView.distanceLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as duration text")
        XCTAssertNonlocalizable(arrivalView.durationLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI, "It shows dashes as distance text")
    }

    // MARK: - Accessibility

    /// Tests if the labels are elements that an assistive application can access.
    func testLabelsAccessibility() {
        XCTAssertFalse(arrivalView.estimatedTimeOfArrivalLabel.isAccessibilityElement, "It disables ETA label accessibility access")
        XCTAssertFalse(arrivalView.durationLabel.isAccessibilityElement, "It disables duration label accessibility access")
        XCTAssertFalse(arrivalView.distanceLabel.isAccessibilityElement, "It disables distance label accessibility access")
    }

    /// Tests if the view accessiblity is correct.
    func testViewAccessibility() {
        XCTAssertTrue(arrivalView.isAccessibilityElement, "It allows accessibility access")
        XCTAssertEqual(arrivalView.accessibilityTraits, .staticText, "It has the correct accessibility traits")
        XCTAssertEqual(arrivalView.accessibilityIdentifier, "MSDKUI.GuidanceEstimatedArrivalView", "It has the correct accessibility identifier")
        XCTAssertLocalized(arrivalView.accessibilityLabel, key: "msdkui_estimated_arrival", bundle: .MSDKUI, "It has the correct accessibility label")
    }

    /// Test if the view accessibility hint is correct when view is not configured.
    func testViewAccessibilityHintWhenPropertiesAreNull() {
        XCTAssertNil(arrivalView.accessibilityHint, "It returns nil as hint")
    }

    /// Test if the view accessibility hint is correct when view has default formatters.
    func testViewAccessibilityHintWithDefaultFormatters() {
        let arrivalTime = Date.distantFuture
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.duration = duration
        arrivalView.distance = distance

        let exepectedHint = DateFormatter.currentShortTimeFormatter.string(from: arrivalTime) + ", "
            + MeasurementFormatter.currentMediumUnitFormatter.string(from: duration) + ", "
            + MeasurementFormatter.currentMediumUnitFormatter.string(from: distance)

        XCTAssertEqual(arrivalView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    /// Test if the view accessibility hint is correct when view has custom formatters.
    func testViewAccessibilityHintWithCustomFormatters() {
        let arrivalTime = Date.distantFuture
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.duration = duration
        arrivalView.distance = distance

        let dateFormatter = DateFormatter()
        let durationFormatter = MeasurementFormatter()
        let distanceFormatter = MeasurementFormatter()

        arrivalView.estimatedTimeOfArrivalFormatter = dateFormatter
        arrivalView.durationFormatter = durationFormatter
        arrivalView.distanceFormatter = distanceFormatter

        let exepectedHint = dateFormatter.string(from: arrivalTime) + ", "
            + durationFormatter.string(from: duration) + ", "
            + distanceFormatter.string(from: distance)

        XCTAssertEqual(arrivalView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    /// Test if the view accessibility hint is correct when view doesn't have one of the properties (duration).
    func testViewAccessibilityHintWhenDurationIsMissing() {
        let arrivalTime = Date.distantFuture
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)

        arrivalView.estimatedTimeOfArrival = arrivalTime
        arrivalView.distance = distance

        let exepectedHint = DateFormatter.currentShortTimeFormatter.string(from: arrivalTime) + ", "
            + MeasurementFormatter.currentMediumUnitFormatter.string(from: distance)

        XCTAssertEqual(arrivalView.accessibilityHint, exepectedHint, "It returns the correct hint")
    }

    // MARK: - Style

    /// Tests the behavior when the `.primaryInfoTextColor` property is set.
    func testWhenPrimaryInfoTextColorIsSet() {
        arrivalView.primaryInfoTextColor = .purple

        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.textColor, .purple, "It sets the correct text color for the ETA label")
    }

    /// Tests the behavior when the `.secondaryInfoTextColor` property is set.
    func testWhenSecondaryInfoTextColorIsSet() {
        arrivalView.secondaryInfoTextColor = .brown

        XCTAssertEqual(arrivalView.durationLabel.textColor, .brown, "It sets the correct text color for the duration label")
        XCTAssertEqual(arrivalView.distanceLabel.textColor, .brown, "It sets the correct text color for the distance label")
        XCTAssertEqual(arrivalView.separatorLabel.textColor, .brown, "It sets the correct text color for the separator label")
    }

    /// Tests the behavior when the `.textAlignment` property is set.
    func testWhenTextAlignmentIsSet() {
        arrivalView.textAlignment = .right

        XCTAssertEqual(arrivalView.estimatedTimeOfArrivalLabel.textAlignment, .right, "It sets the correct text alignment for the ETA label")
        XCTAssertEqual(arrivalView.durationLabel.textAlignment, .right, "It sets the correct text alignment for the duration label")
        XCTAssertEqual(arrivalView.distanceLabel.textAlignment, .right, "It sets the correct text alignment for the distance label")
    }
}
