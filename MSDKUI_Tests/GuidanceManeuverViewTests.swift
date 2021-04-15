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

final class GuidanceManeuverViewTests: XCTestCase {
    /// The object under test.
    let view = GuidanceManeuverView(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 139.0)))

    /// Tests the default state after view initialization.
    func testDefaultState() {
        XCTAssertEqual(view.state, .noData, "It has the correct states")
    }

    /// Tests the default axis after view initialization.
    func testDefaultAxis() {
        XCTAssertEqual(view.axis, .horizontal, "It has the content laid out along the correct axis")
    }

    /// Tests the default distance formatter after view initialization.
    func testDefaultDistanceFormatter() {
        XCTAssertEqual(view.distanceFormatter, .currentMediumUnitFormatter, "It has the correct measurement formatter for the distance")
    }

    /// Tests the default foreground color after view initialization.
    func testDefaultForegroundColor() {
        XCTAssertEqual(view.foregroundColor, .colorForegroundLight, "It has the correct foreground color")
    }

    /// Tests the default background color after view initialization.
    func testDefaultBackgroundColor() {
        XCTAssertEqual(view.backgroundColor, .colorBackgroundDark, "It has the correct background color")
    }

    /// Tests if the maneuver is highlighted by default.
    func testDefaultHighlightManeuver() {
        XCTAssertFalse(view.highlightManeuver, "It doesn't hightlight the maneuver")
    }

    /// Tests the activity indicator.
    func testActivityIndicator() {
        XCTAssertEqual(view.activityIndicator.style, .whiteLarge, "It has the correct style")
        XCTAssertTrue(view.activityIndicator.hidesWhenStopped, "It hides the activity indicator when stopped")
    }

    /// Tests the maneuver icon image view.
    func testManeuverIconImageView() {
        XCTAssertEqual(view.maneuverIconImageView.contentMode, .scaleToFill, "It has the correct content mode")
    }

    /// Tests the distance label.
    func testDistanceLabel() {
        XCTAssertEqual(view.distanceLabel.font, .monospacedDigitSystemFont(ofSize: 34, weight: .regular), "It has the correct monospaced font")
        XCTAssertEqual(view.distanceLabel.numberOfLines, 1, "It supports a single line")
    }

    /// Tests the info1 label.
    func testInfo1Label() {
        XCTAssertEqual(view.info1Label.font, .systemFont(ofSize: 22, weight: .medium), "It has the correct font")
        XCTAssertEqual(view.info1Label.numberOfLines, 0, "It supports multiple lines")
    }

    /// Tests the info2 label.
    func testInfo2Label() {
        XCTAssertEqual(view.info2Label.font, .systemFont(ofSize: 22, weight: .medium), "It has the correct font")
        XCTAssertEqual(view.info2Label.numberOfLines, 0, "It supports multiple lines")
    }

    /// Tests the message label.
    func testMessageLabel() {
        XCTAssertEqual(view.messageLabel.font, .systemFont(ofSize: 22, weight: .medium), "It has the correct font")
        XCTAssertEqual(view.messageLabel.numberOfLines, 0, "It supports multiple lines")
    }

    /// Tests the next road image view.
    func testNextRoadImageView() {
        XCTAssertEqual(view.nextRoadIconImageView.contentMode, .scaleAspectFit, "It has the correct content mode")
    }

    /// Tests the content stack view.
    func testContentStackView() {
        XCTAssertEqual(view.contentStackView.spacing, 16, "It has the correct spacing between elements by default")
    }

    /// Tests the labels stack view.
    func testLabelsStackView() {
        XCTAssertEqual(view.labelsStackView.alignment, .leading, "It sets the correct alignment for the labels stack view")
        XCTAssertEqual(view.labelsStackView.spacing, 0, "It has the correct spacing between elements")
    }

    /// Tests if the message separator view is shown by default.
    func testMessageSeparatorView() {
        XCTAssertFalse(view.messageSeparatorView.isHidden, "It shows the message separator view")
    }

    /// Tests the view behavior when the foreground color is changed.
    func testWhenForegroundColorChanges() {
        view.foregroundColor = .purple

        XCTAssertEqual(view.distanceLabel.textColor, .purple, "It sets the correct distance label text color")
        XCTAssertEqual(view.info1Label.textColor, .purple, "It sets the correct info1 label text color")
        XCTAssertEqual(view.info2Label.textColor, .purple, "It sets the correct info2 label text color")
        XCTAssertEqual(view.messageLabel.textColor, .purple, "It sets the correct message label text color")

        XCTAssertEqual(view.maneuverIconImageView.tintColor, .purple, "It sets the correct maneuver icon tint color")
        XCTAssertEqual(view.nextRoadIconImageView.tintColor, .purple, "It sets the correct next road icon tint color")
        XCTAssertEqual(view.activityIndicator.color, .purple, "It sets the correct activity indicator color")
    }

    /// Tests the view behavior when the axis changes to vertical.
    func testWhenAxisChangesToVertical() {
        view.axis = .vertical

        XCTAssertEqual(view.contentStackView.alignment, .leading, "It sets the correct alignment for the content stack view")
    }

    /// Tests the view behavior when the axis changes to horizontal.
    func testWhenAxisChangesToHorizontal() {
        view.axis = .horizontal

        XCTAssertEqual(view.contentStackView.alignment, .top, "It sets the correct alignment for the content stack view")
    }

    /// Tests the behavior when a new distance formatter is set and the view has data.
    func testWhenDistanceFormatterChangesAndStateHasManeuverData() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: nil,
            distance: Measurement(value: 30, unit: .meters),
            info1: nil,
            info2: nil,
            nextRoadIcon: nil
        )
        view.state = .data(maneuverData)

        view.distanceFormatter = MeasurementFormatter()

        let expectedDistance = MeasurementFormatter().string(from: Measurement(value: 30, unit: UnitLength.meters))

        XCTAssertEqual(view.distanceLabel.text, expectedDistance, "It has the correct distance set")
    }

    /// Tests the behavior when a new distance formatter is set and the view doesn't have data.
    func testWhenDistanceFormatterChangesAndStateDoesntHaveManeuverData() {
        view.state = .updating

        view.distanceFormatter = MeasurementFormatter()

        XCTAssertNil(view.distanceLabel.text, "It doesn't have a distance set")
    }

    /// Tests the behavior when state is .noData.
    func testWhenStateIsNoData() {
        view.state = .noData

        XCTAssertFalse(view.activityIndicator.isAnimating, "It doesn't animate the activity indicator")
        XCTAssertTrue(view.activityIndicator.isHidden, "It hides the activity indicator")

        XCTAssertNotNil(view.maneuverIconImageView.image, "It has a instruction icon")
        XCTAssertFalse(view.maneuverIconImageView.isHidden, "It shows the icon image view")

        XCTAssertLocalized(view.messageLabel.text, key: "msdkui_maneuverpanel_nodata", bundle: .MSDKUI, "It has the correct message text")
        XCTAssertFalse(view.messageLabel.isHidden, "It shows the message label")

        XCTAssertNil(view.distanceLabel.text, "It doesn't have a distance text")
        XCTAssertTrue(view.distanceLabel.isHidden, "It hides the distance label")

        XCTAssertNil(view.info1Label.text, "It doesn't have a info1 text")
        XCTAssertTrue(view.info1Label.isHidden, "It hides the info1 label")

        XCTAssertNil(view.info2Label.text, "It doesn't have a info2 text")
        XCTAssertTrue(view.info2Label.isHidden, "It hides the info2 label")

        XCTAssertNil(view.nextRoadIconImageView.image, "It doesn't have a next road icon")
        XCTAssertTrue(view.nextRoadIconImageView.isHidden, "It hides the next road icon image view")
    }

    /// Tests the behavior when state is .updating.
    func testWhenStateIsUpdating() {
        view.state = .updating

        XCTAssertTrue(view.activityIndicator.isAnimating, "It animates the activity indicator")
        XCTAssertFalse(view.activityIndicator.isHidden, "It shows the activity indicator")

        XCTAssertNil(view.maneuverIconImageView.image, "It doesn't have a maneuver icon")
        XCTAssertTrue(view.maneuverIconImageView.isHidden, "It hides the maneuver icon image view")

        XCTAssertLocalized(view.messageLabel.text, key: "msdkui_maneuverpanel_updating", bundle: .MSDKUI, "It has the correct message text")
        XCTAssertFalse(view.messageLabel.isHidden, "It shows the message label")

        XCTAssertNil(view.distanceLabel.text, "It doesn't have a distance text")
        XCTAssertTrue(view.distanceLabel.isHidden, "It hides the distance label")

        XCTAssertNil(view.info1Label.text, "It doesn't have a info1 text")
        XCTAssertTrue(view.info1Label.isHidden, "It hides the info1 label")

        XCTAssertNil(view.info2Label.text, "It doesn't have a info2 text")
        XCTAssertTrue(view.info2Label.isHidden, "It hides the info2 label")

        XCTAssertNil(view.nextRoadIconImageView.image, "It doesn't have a next road icon")
        XCTAssertTrue(view.nextRoadIconImageView.isHidden, "It hides the next road icon image view")
    }

    /// Tests the behavior when state is .data with all parameters.
    func testWhenStateIsDataWithAllParameters() {
        let maneuverIcon = UIImage()
        let roadIcon = UIImage()
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: maneuverIcon,
            distance: Measurement(value: 30, unit: .meters),
            info1: "Useful info1",
            info2: "Useful info2",
            nextRoadIcon: roadIcon
        )

        view.state = .data(maneuverData)

        XCTAssertFalse(view.activityIndicator.isAnimating, "It doesn't animate the activity indicator")
        XCTAssertTrue(view.activityIndicator.isHidden, "It hides the activity indicator")

        XCTAssertEqual(view.maneuverIconImageView.image, maneuverIcon, "It has the correct maneuver icon")
        XCTAssertFalse(view.maneuverIconImageView.isHidden, "It shows the maneuver icon image view")

        let expectedDistance = maneuverData.distance.map(MeasurementFormatter.currentMediumUnitFormatter.string)
        XCTAssertEqual(view.distanceLabel.text, expectedDistance, "It has the correct distance text")
        XCTAssertFalse(view.distanceLabel.isHidden, "It shows the distance label")

        XCTAssertEqual(view.info1Label.text, "Useful info1", "It has the correct info1 text")
        XCTAssertFalse(view.info1Label.isHidden, "It shows the info1 label")

        XCTAssertEqual(view.info2Label.text, "Useful info2", "It has the correct info2 text")
        XCTAssertFalse(view.info2Label.isHidden, "It shows the info2 label")

        XCTAssertNil(view.messageLabel.text, "It doesn't have a message text")
        XCTAssertTrue(view.messageLabel.isHidden, "It hides the message label")

        XCTAssertEqual(view.nextRoadIconImageView.image, roadIcon, "It has the correct next road icon")
        XCTAssertFalse(view.nextRoadIconImageView.isHidden, "It shows the next road icon image view")
    }

    /// Tests the behavior when state is .data without maneuver icon.
    func testWhenStateIsDataWithoutManeuverIcon() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: nil,
            distance: Measurement(value: 30, unit: .meters),
            info1: "Useful info1",
            info2: "Useful info2",
            nextRoadIcon: UIImage()
        )

        view.state = .data(maneuverData)

        XCTAssertNil(view.maneuverIconImageView.image, "It doesn't have a maneuver icon")
        XCTAssertTrue(view.maneuverIconImageView.isHidden, "It hides the maneuver icon image view")
    }

    /// Tests the behavior when state is .data without distance.
    func testWhenStateIsDataWithoutDistance() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: UIImage(),
            distance: nil,
            info1: "Useful info1",
            info2: "Useful info2",
            nextRoadIcon: UIImage()
        )

        view.state = .data(maneuverData)

        XCTAssertNil(view.distanceLabel.text, "It doesn't have a distance text")
        XCTAssertTrue(view.distanceLabel.isHidden, "It hides the distance label")
    }

    /// Tests the behavior when state is .data with info1.
    func testWhenStateIsDataWithoutInfo1() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: UIImage(),
            distance: Measurement(value: 30, unit: .meters),
            info1: nil,
            info2: "Useful info2",
            nextRoadIcon: UIImage()
        )

        view.state = .data(maneuverData)

        XCTAssertNil(view.info1Label.text, "It doesn't have the info1 text")
        XCTAssertTrue(view.info1Label.isHidden, "It hides the info1 label")
    }

    /// Tests the behavior when state is .data with info2.
    func testWhenStateIsDataWithoutInfo2() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: UIImage(),
            distance: Measurement(value: 30, unit: .meters),
            info1: "Useful info1",
            info2: nil,
            nextRoadIcon: UIImage()
        )

        view.state = .data(maneuverData)

        XCTAssertNil(view.info2Label.text, "It doesn't have the info2 text")
        XCTAssertTrue(view.info2Label.isHidden, "It hides the info2 label")
    }

    /// Tests the behavior when state is .data without next road icon.
    func testWhenStateIsDataWithoutNextRoadIcon() {
        let maneuverData = GuidanceManeuverData(
            maneuverIcon: UIImage(),
            distance: Measurement(value: 30, unit: .meters),
            info1: "Useful info1",
            info2: "Useful info2",
            nextRoadIcon: nil
        )

        view.state = .data(maneuverData)

        XCTAssertNil(view.nextRoadIconImageView.image, "It doesn't have a next road icon")
        XCTAssertTrue(view.nextRoadIconImageView.isHidden, "It hides the next road image view")
    }

    /// Tests the behavior when the property is set to true.
    func testWhenHighlightManeuverIsSetToTrue() {
        view.highlightManeuver = true

        XCTAssertEqual(view.info2Label.textColor, view.tintColor, "It set the correct info2 label text color, to match the view tint color")
    }

    /// Tests the behavior when the property is set to false.
    func testWhenHighlightManeuverIsSetToFalse() {
        view.highlightManeuver = false

        XCTAssertEqual(view.info2Label.textColor, view.foregroundColor, "It restores the correct info2 label text color, to match the foreground color")
    }

    /// Tests the behavior when the property is set to true before changing the foreground color.
    func testWhenHighlightManeuverIsSetToTrueBeforeForegroundColorChange() {
        view.highlightManeuver = true
        view.foregroundColor = .red

        XCTAssertEqual(view.info2Label.textColor, view.tintColor, "It keeps the info2 label highlighted")
    }

    /// Tests the behavior when the property is set to false after changing the foreground color.
    func testWhenHighlightManeuverIsSetToFalseAfterForegroundColorChange() {
        view.foregroundColor = .purple
        view.highlightManeuver = false

        XCTAssertEqual(view.info2Label.textColor, .purple, "It restores the correct info2 label text color, to match the foreground color")
    }

    /// Tests the message separator view behavior when axis is horizontal and state changes.
    func testMessageSepartorViewWhenAxisIsHorizontalAndStateChanges() {
        view.axis = .horizontal

        view.state = .noData

        XCTAssertFalse(view.messageSeparatorView.isHidden, "It shows the message separator view")

        view.state = .updating

        XCTAssertFalse(view.messageSeparatorView.isHidden, "It shows the message separator view")

        view.state = .data(GuidanceManeuverData())

        XCTAssertTrue(view.messageSeparatorView.isHidden, "It hides the message separator view")
    }

    /// Tests the message separator view behavior when axis is vertical and state changes.
    func testMessageSepartorViewWhenAxisIsVerticalAndStateChanges() {
        view.axis = .vertical

        view.state = .noData

        XCTAssertTrue(view.messageSeparatorView.isHidden, "It hides the message separator view")

        view.state = .updating

        XCTAssertTrue(view.messageSeparatorView.isHidden, "It hides the message separator view")

        view.state = .data(GuidanceManeuverData())

        XCTAssertTrue(view.messageSeparatorView.isHidden, "It hides the message separator view")
    }

    /// Thes the content stack view separation when the axis is horizontal.
    func testContentStackViewSeparationWhenAxisIsHorizontal() {
        view.axis = .horizontal

        XCTAssertEqual(view.contentStackView.spacing, 16, "It has the correct spacing between elements")
    }

    /// Thes the content stack view separation when the axis is vertical.
    func testContentStackViewSeparationWhenAxisIsVertical() {
        view.axis = .vertical

        XCTAssertEqual(view.contentStackView.spacing, 12, "It has the correct spacing between elements")
    }

    /// Tests if the required `.init(coder:)` returns a new instance.
    func testInitWithCoder() throws {
        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        let maneuverView = GuidanceManeuverView(coder: coder)

        XCTAssertNotNil(maneuverView, "It exists")
    }
}
