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

final class GuidanceManeuverViewTests: XCTestCase {

    /// The object under test.
    private var view = GuidanceManeuverView(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 139.0)))

    /// The mock image used as next road icon.
    private let mockNextRoadIcon = UIImage()

    override func setUp() {
        super.setUp()
    }

    // MARK: - Tests

    /// Tests the initial state of Data and NoData Containers after the view initialization.
    func testInitialState() {
        XCTAssertEqual(view.state, .noData, "It has the correct initial state")

        // Has the data containers hidden by default (when data isn't yet set)
        view.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "Data Container is hidden")
        }

        // Has the NoData containers visible by default (when data isn't yet set)
        view.noDataContainers.forEach {
            XCTAssertFalse($0.isHidden, "NoData Container is visible")
        }

        // Has busy indicators hidden
        view.busyIndicators.forEach {
            XCTAssertTrue($0.isHidden, "Busy indicator is hidden")
            XCTAssertFalse($0.isAnimating, "Busy indicator is not animating")
        }

        // Shows the correct message about missing maneuver information
        view.noDataLabels.forEach {
            XCTAssertLocalized($0.text,
                               key: "msdkui_maneuverpanel_nodata",
                               bundle: .MSDKUI,
                               "Shows the correct string when there's no maneuver data")
        }
    }

    /// Tests the initial view height.
    func testInitialViewHeight() {
        XCTAssertEqual(view.frame.size.height, 139.0, "The initial view height is wrong!")
    }

    /// Tests the view height when the Info1 is set for default axis.
    func testViewWithInfo1() {
        let data = GuidanceManeuverData(maneuverIcon: UIImage(),
                                        distance: Measurement(value: 30, unit: UnitLength.meters),
                                        info1: "Exit 30",
                                        info2: "Invalidenstr.",
                                        nextRoadIcon: mockNextRoadIcon)

        // Pass the data to the view
        view.state = .data(data)

        // Is the view height unchanged?
        XCTAssertEqual(view.intrinsicContentSize.height, 139.0, "The view height with Info1 is wrong!")

        // Are the data set correctly?
        XCTAssertFalse(view.info1Labels[GuidanceManeuverView.Axis.vertical.rawValue].isHidden,
                       "The view info1 label is hidden!")

        XCTAssertFalse(view.info1Labels[GuidanceManeuverView.Axis.horizontal.rawValue].isHidden,
                       "The view info1 label is hidden!")

        checkData(data)
    }

    /// Tests the view when the Info1 is not set for default axis.
    func testViewWithoutInfo() {
        let data = GuidanceManeuverData(maneuverIcon: UIImage(),
                                        distance: Measurement(value: 30, unit: UnitLength.meters),
                                        info1: nil,
                                        info2: "Invalidenstr.",
                                        nextRoadIcon: mockNextRoadIcon)

        // Pass the data to the view
        view.state = .data(data)

        // Is the view height smaller now?
        XCTAssertLessThan(view.intrinsicContentSize.height, 139.0, "The view height without Info1 is wrong!")

        // Are the data set correctly?
        XCTAssertTrue(view.info1Labels[GuidanceManeuverView.Axis.vertical.rawValue].isHidden,
                      "The view info1 label is not hidden!")

        XCTAssertTrue(view.info1Labels[GuidanceManeuverView.Axis.horizontal.rawValue].isHidden,
                      "The view info1 label is not hidden!")

        checkData(data)
    }

    /// Tests the `GuidanceManeuverView.highlightManeuver(textColor:)` method.
    func testHighlightColor() {
        // This method updates the color of Info2 labels
        view.highlightManeuver(textColor: UIColor.red)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.vertical.rawValue].textColor, UIColor.red,
                       "The Info2 color is wrong!")

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.horizontal.rawValue].textColor, UIColor.red,
                       "The Info2 color is wrong!")
    }

    /// Tests the behavior when axis is set to horizontal.
    func testWhenAxisIsSetToHorizontal() {
        view.axis = .horizontal

        XCTAssertFalse(view.views[GuidanceManeuverView.Axis.vertical.rawValue].isHidden,
                       "The vertical view is visible!")

        XCTAssertTrue(view.views[GuidanceManeuverView.Axis.horizontal.rawValue].isHidden,
                      "Th horizontal view is hidden!")
    }

    /// Tests the behavior when axis is set to vertical.
    func testWhenAxisIsSetToVertical() {
        view.axis = .vertical

        XCTAssertTrue(view.views[GuidanceManeuverView.Axis.vertical.rawValue].isHidden,
                      "The vertical view is hidden!")

        XCTAssertFalse(view.views[GuidanceManeuverView.Axis.horizontal.rawValue].isHidden,
                       "The horizontal view is visible!")
    }

    /// Tests the default style.
    func testDefaultStyle() {
        checkStyle(backgroundColor: .colorBackgroundDark, foregroundColor: .colorForegroundLight)
    }

    /// Tests the distance label.
    func testDistanceLabel() {
        XCTAssertEqual(view.distanceLabels.count, 2, "It has two distance labels (vertical and horizontal)")

        view.distanceLabels.forEach {
            XCTAssertEqual($0.font, .monospacedDigitSystemFont(ofSize: 34, weight: .regular), "It uses monospaced font for distance labels")
        }
    }

    /// Tests that the style updates are reflected.
    func testStyleUpdates() {
        let newBackgroundColor = UIColor.red
        let newForegroundColor = UIColor.green

        view.backgroundColor = newBackgroundColor
        view.foregroundColor = newForegroundColor

        checkStyle(backgroundColor: newBackgroundColor, foregroundColor: newForegroundColor)
    }

    // MARK: - Guidance Maneuver Data

    /// Tests the behavior when maneuver data is set.
    func testWhenManeuverDataIsSet() {
        // Sets the view data
        view.state = .data(GuidanceManeuverData(maneuverIcon: UIImage(),
                                                distance: Measurement(value: 30, unit: UnitLength.meters),
                                                info1: "Exit 30",
                                                info2: "Invalidenstr.",
                                                nextRoadIcon: mockNextRoadIcon))

        // Has data containers visible
        view.dataContainers.forEach {
            XCTAssertFalse($0.isHidden, "Data Container is visible")
        }

        // Has busy indicators hidden
        view.busyIndicators.forEach {
            XCTAssertTrue($0.isHidden, "Busy indicator is hidden")
            XCTAssertFalse($0.isAnimating, "Busy indicator is not animating")
        }

        // Has NoData containers hidden
        view.noDataContainers.forEach {
            XCTAssertTrue($0.isHidden, "NoData Container is hidden")
        }
    }

    /// Tests the behavior when state is .updating
    func testWhenStateIsUpdating() {
        view.state = .updating

        // Has data containers hidden
        view.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "Data Container is visible")
        }

        // Has busy indicators visible and animating
        view.busyIndicators.forEach {
            XCTAssertFalse($0.isHidden, "Busy indicator is hidden")
            XCTAssertTrue($0.isAnimating, "Busy indicator is not animating")
        }

        // Has NoData icons hidden
        view.noDataImageViews.forEach {
            XCTAssertTrue($0.isHidden, "NoData icons is hidden")
        }

        // Has NoData labels visible and with correct text
        view.noDataLabels.forEach {
            XCTAssertFalse($0.isHidden, "NoData labels is visible")

            XCTAssertLocalized($0.text,
                               key: "msdkui_maneuverpanel_updating",
                               bundle: .MSDKUI,
                               "It shows the correct string for busy state")
        }
    }

    /// Tests the behavior when maneuverIcon is nil.
    func testWhenManeuverIconIsNil() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.maneuverImageViews.filter { $0.image == nil }.isEmpty,
                       "It doesn't have maneuver image")
    }

    /// Tests the behavior when maneuverIcon is valid.
    func testWhenManeuverIconIsValid() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: UIImage(), distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.maneuverImageViews.filter { $0.image != nil }.isEmpty,
                       "It has maneuver image")
    }

    /// Tests the behavior when distance is nil.
    func testWhenDistanceIsNil() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.distanceLabels.filter { $0.text == nil }.isEmpty,
                       "It doesn't have distance text")
    }

    /// Tests the behavior when distance is valid.
    func testWhenDistanceIsValid() {
        let distance = Measurement(value: 30, unit: UnitLength.furlongs)
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: distance, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.distanceLabels.filter { $0.text != nil }.isEmpty,
                       "It has distance text")
    }

    /// Tests the behavior when info1 is nil.
    func testWhenInfo1IsNil() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.info1Labels.filter { $0.text == nil }.isEmpty,
                       "It doesn't have info1 text")

        XCTAssertFalse(view.info1Labels.filter { $0.isHidden }.isEmpty,
                       "It hides the info1 labels")
    }

    /// Tests the behavior when info1 is valid.
    func testWhenInfo1IsValid() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: "Foobar", info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.info1Labels.filter { $0.text != nil }.isEmpty,
                       "It has info1 text")

        XCTAssertTrue(view.info1Labels.filter { $0.isHidden }.isEmpty,
                      "It shows the info1 labels")
    }

    /// Tests the behavior when info2 is nil.
    func testWhenInfo2IsNil() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.info2Labels.filter { $0.text == nil }.isEmpty,
                       "It doesn't have info2 text")

        XCTAssertFalse(view.info2Labels.filter { $0.isHidden }.isEmpty,
                       "It hides the info2 labels")
    }

    /// Tests the behavior when info2 is valid.
    func testWhenInfo2IsValid() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: "Foobar", nextRoadIcon: nil))

        XCTAssertFalse(view.info2Labels.filter { $0.text != nil }.isEmpty,
                       "It has info2 text")

        XCTAssertTrue(view.info2Labels.filter { $0.isHidden }.isEmpty,
                      "It shows the info2 labels")
    }

    /// Tests the behavior when nextRoadIcon is nil.
    func testWhenNextRoadIconIsNil() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: nil))

        XCTAssertFalse(view.roadIconViews.filter { $0.image == nil }.isEmpty,
                       "It doesn't have road icon image")
    }

    /// Tests the behavior when nextRoadIcon is valid.
    func testWhenNextRoadIconIsValid() {
        view.state = .data(GuidanceManeuverData(maneuverIcon: nil, distance: nil, info1: nil, info2: nil, nextRoadIcon: UIImage()))

        XCTAssertFalse(view.roadIconViews.filter { $0.image != nil }.isEmpty,
                       "It has road icon image")
    }

    /// Tests the default distance formatter used by the view.
    func testDistanceFormatter() {
        XCTAssertEqual(view.distanceFormatter, .currentMediumUnitFormatter, "It has the correct default formatter")
    }

    /// Tests the behavior when a new distance formatter is set and the view has data.
    func testWhenDistanceFormatterIsSetAndViewHasManeuverData() {
        let maneuverData = GuidanceManeuverData(maneuverIcon: nil,
                                                distance: Measurement(value: 30, unit: .meters),
                                                info1: nil,
                                                info2: nil,
                                                nextRoadIcon: nil)
        view.state = .data(maneuverData)

        // Sets a different formatter
        view.distanceFormatter = MeasurementFormatter()

        let expectedDistance = MeasurementFormatter().string(from: Measurement(value: 30, unit: UnitLength.meters))

        view.dataContainers.forEach {
            XCTAssertFalse($0.isHidden, "It has the data view container visible")
        }

        view.distanceLabels.forEach {
            XCTAssertEqual($0.text, expectedDistance, "It has the correct distance set")
            XCTAssertFalse($0.isHidden, "It has the distance labels visible")
        }
    }

    /// Tests the behavior when a new distance formatter is set and the view doesn't have data.
    func testWhenDistanceFormatterIsSetAndViewDoesntHaveManeuverData() {
        view.state = .updating

        // Sets a different formatter
        view.distanceFormatter = MeasurementFormatter()

        view.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "It has the data view containers hidden")
        }
    }

    // MARK: - Private

    private func checkData(_ data: GuidanceManeuverData, line: UInt = #line) {
        guard let distance = data.distance else {
            XCTFail("Missing distance")
            return
        }

        XCTAssertNotNil(view.maneuverImageViews[GuidanceManeuverView.Axis.vertical.rawValue].image,
                        "The maneuver image is not set!",
                        line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Axis.vertical.rawValue].image,
                       mockNextRoadIcon,
                       "The highway image is not set!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Axis.vertical.rawValue].text,
                       MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
                       "The distance data is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Axis.vertical.rawValue].text,
                       data.info1,
                       "The distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.vertical.rawValue].text,
                       data.info2,
                       "The distance info2 is wrong!",
                       line: line)

        XCTAssertNotNil(view.maneuverImageViews[GuidanceManeuverView.Axis.horizontal.rawValue].image,
                        "The maneuver image is not set!",
                        line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Axis.horizontal.rawValue].image,
                       mockNextRoadIcon,
                       "The highway image is not set!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Axis.horizontal.rawValue].text,
                       MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
                       "The distance data is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Axis.horizontal.rawValue].text,
                       data.info1,
                       "The distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.horizontal.rawValue].text,
                       data.info2,
                       "The distance info2 is wrong!",
                       line: line)
    }

    private func checkStyle(backgroundColor: UIColor, foregroundColor: UIColor, line: UInt = #line) {
        XCTAssertEqual(view.views[GuidanceManeuverView.Axis.vertical.rawValue].backgroundColor,
                       backgroundColor,
                       "The view backgroundColor is wrong!",
                       line: line)
        XCTAssertEqual(view.views[GuidanceManeuverView.Axis.horizontal.rawValue].backgroundColor,
                       backgroundColor,
                       "The view backgroundColor is wrong!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Axis.vertical.rawValue].textColor,
                       foregroundColor,
                       "The distance label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Axis.horizontal.rawValue].textColor,
                       foregroundColor,
                       "The distance label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Axis.vertical.rawValue].textColor,
                       foregroundColor,
                       "The info1 label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Axis.horizontal.rawValue].textColor,
                       foregroundColor,
                       "The info1 label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.vertical.rawValue].textColor,
                       foregroundColor,
                       "The info2 label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Axis.horizontal.rawValue].textColor,
                       foregroundColor,
                       "The info2 label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.noDataLabels[GuidanceManeuverView.Axis.vertical.rawValue].textColor,
                       foregroundColor,
                       "The no data label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.noDataLabels[GuidanceManeuverView.Axis.horizontal.rawValue].textColor,
                       foregroundColor,
                       "The no data label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.maneuverImageViews[GuidanceManeuverView.Axis.vertical.rawValue].tintColor,
                       foregroundColor,
                       "The maneuver icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.maneuverImageViews[GuidanceManeuverView.Axis.horizontal.rawValue].tintColor,
                       foregroundColor,
                       "The maneuver icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Axis.vertical.rawValue].tintColor,
                       foregroundColor,
                       "The road icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Axis.horizontal.rawValue].tintColor,
                       foregroundColor,
                       "The road icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.noDataImageViews[GuidanceManeuverView.Axis.vertical.rawValue].tintColor,
                       foregroundColor,
                       "The no data icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.noDataImageViews[GuidanceManeuverView.Axis.horizontal.rawValue].tintColor,
                       foregroundColor,
                       "The no data icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.busyIndicators[GuidanceManeuverView.Axis.vertical.rawValue].color,
                       foregroundColor,
                       "The busy indicator color is wrong!",
                       line: line)
        XCTAssertEqual(view.busyIndicators[GuidanceManeuverView.Axis.horizontal.rawValue].color,
                       foregroundColor,
                       "The busy indicator color is wrong!",
                       line: line)
    }
}
