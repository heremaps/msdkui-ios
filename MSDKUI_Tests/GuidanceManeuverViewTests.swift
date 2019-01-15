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

        // Make sure to be in the portrait orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKeyPath: #keyPath(UIDevice.orientation))
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
            XCTAssertNotEqual($0.text,
                              "msdkui_maneuverpanel_nodata",
                              "The string is localized")

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

    /// Tests the view height when the Info1 is set in the portrait orientation.
    func testViewWithInfo1inPortrait() {
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
        XCTAssertFalse(view.info1Labels[GuidanceManeuverView.Orientation.portrait.rawValue].isHidden,
                       "The view landscape info1 label is hidden!")

        XCTAssertFalse(view.info1Labels[GuidanceManeuverView.Orientation.landscape.rawValue].isHidden,
                       "The view landscape info1 label is hidden!")

        checkData(data)
    }

    /// Tests the view when the Info1 is not set in the portrait orientation.
    func testViewWithoutInfo1inPortrait() {
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
        XCTAssertTrue(view.info1Labels[GuidanceManeuverView.Orientation.portrait.rawValue].isHidden,
                      "The view landscape info1 label is not hidden!")

        XCTAssertTrue(view.info1Labels[GuidanceManeuverView.Orientation.landscape.rawValue].isHidden,
                      "The view landscape info1 label is not hidden!")

        checkData(data)
    }

    /// Tests the `GuidanceManeuverView.highlightManeuver(textColor:)` method.
    func testHighlightColor() {
        // This method updates the color of Info2 labels
        view.highlightManeuver(textColor: UIColor.red)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.portrait.rawValue].textColor, UIColor.red,
                       "The portrait Info2 color is wrong!")

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.landscape.rawValue].textColor, UIColor.red,
                       "The landscape Info2 color is wrong!")
    }

    /// Tests the `GuidanceManeuverView.adaptToPortrait()` method.
    func testAdaptToPortrait() {
        view.adaptToPortrait()

        XCTAssertFalse(view.views[GuidanceManeuverView.Orientation.portrait.rawValue].isHidden,
                       "The portrait orientation is visible!")

        XCTAssertTrue(view.views[GuidanceManeuverView.Orientation.landscape.rawValue].isHidden,
                      "The portrait orientation is hidden!")
    }

    /// Tests the `GuidanceManeuverView.adaptToLandscape()` method.
    func testAdaptToLandscape() {
        view.adaptToLandscape()

        XCTAssertTrue(view.views[GuidanceManeuverView.Orientation.portrait.rawValue].isHidden,
                      "The portrait orientation is hidden!")

        XCTAssertFalse(view.views[GuidanceManeuverView.Orientation.landscape.rawValue].isHidden,
                       "The portrait orientation is visible!")
    }

    /// Tests the default style.
    func testDefaultStyle() {
        checkStyle(backgroundColor: .colorBackgroundDark, foregroundColor: .colorForegroundLight)
    }

    /// Tests the distance label.
    func testDistanceLabel() {
        XCTAssertEqual(view.distanceLabels.count, 2, "It has two distance labels (portrait and landscape)")

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

    // MARK: - Private

    private func checkData(_ data: GuidanceManeuverData, line: UInt = #line) {
        guard let distance = data.distance else {
            XCTFail("Missing distance")
            return
        }

        XCTAssertNotNil(view.maneuverImageViews[GuidanceManeuverView.Orientation.portrait.rawValue].image,
                        "The portrait maneuver image is not set!",
                        line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Orientation.portrait.rawValue].image,
                       mockNextRoadIcon,
                       "The portrait highway image is not set!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Orientation.portrait.rawValue].text,
                       MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
                       "The portrait distance data is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Orientation.portrait.rawValue].text,
                       data.info1,
                       "The portrait distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.portrait.rawValue].text,
                       data.info2,
                       "The portrait distance info2 is wrong!",
                       line: line)

        XCTAssertNotNil(view.maneuverImageViews[GuidanceManeuverView.Orientation.landscape.rawValue].image,
                        "The landscape maneuver image is not set!",
                        line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Orientation.landscape.rawValue].image,
                       mockNextRoadIcon,
                       "The landscape highway image is not set!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Orientation.landscape.rawValue].text,
                       MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
                       "The landscape distance data is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Orientation.landscape.rawValue].text,
                       data.info1,
                       "The landscape distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.landscape.rawValue].text,
                       data.info2,
                       "The landscape distance info2 is wrong!",
                       line: line)
    }

    private func checkStyle(backgroundColor: UIColor, foregroundColor: UIColor, line: UInt = #line) {
        XCTAssertEqual(view.views[GuidanceManeuverView.Orientation.portrait.rawValue].backgroundColor,
                       backgroundColor,
                       "The portrait view backgroundColor is wrong!",
                       line: line)
        XCTAssertEqual(view.views[GuidanceManeuverView.Orientation.landscape.rawValue].backgroundColor,
                       backgroundColor,
                       "The landscape view backgroundColor is wrong!",
                       line: line)

        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Orientation.portrait.rawValue].textColor,
                       foregroundColor,
                       "The portrait distance label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.distanceLabels[GuidanceManeuverView.Orientation.landscape.rawValue].textColor,
                       foregroundColor,
                       "The landscape distance label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Orientation.portrait.rawValue].textColor,
                       foregroundColor,
                       "The portrait info1 label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.info1Labels[GuidanceManeuverView.Orientation.landscape.rawValue].textColor,
                       foregroundColor,
                       "The landscape info1 label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.portrait.rawValue].textColor,
                       foregroundColor,
                       "The portrait info2 label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.info2Labels[GuidanceManeuverView.Orientation.landscape.rawValue].textColor,
                       foregroundColor,
                       "The landscape info2 label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.noDataLabels[GuidanceManeuverView.Orientation.portrait.rawValue].textColor,
                       foregroundColor,
                       "The portrait no data label text color is wrong!",
                       line: line)
        XCTAssertEqual(view.noDataLabels[GuidanceManeuverView.Orientation.landscape.rawValue].textColor,
                       foregroundColor,
                       "The landscape no data label text color is wrong!",
                       line: line)

        XCTAssertEqual(view.maneuverImageViews[GuidanceManeuverView.Orientation.portrait.rawValue].tintColor,
                       foregroundColor,
                       "The portrait maneuver icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.maneuverImageViews[GuidanceManeuverView.Orientation.landscape.rawValue].tintColor,
                       foregroundColor,
                       "The landscape maneuver icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Orientation.portrait.rawValue].tintColor,
                       foregroundColor,
                       "The portrait road icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.roadIconViews[GuidanceManeuverView.Orientation.landscape.rawValue].tintColor,
                       foregroundColor,
                       "The landscape road icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.noDataImageViews[GuidanceManeuverView.Orientation.portrait.rawValue].tintColor,
                       foregroundColor,
                       "The portrait no data icon color is wrong!",
                       line: line)
        XCTAssertEqual(view.noDataImageViews[GuidanceManeuverView.Orientation.landscape.rawValue].tintColor,
                       foregroundColor,
                       "The landscape no data icon color is wrong!",
                       line: line)

        XCTAssertEqual(view.busyIndicators[GuidanceManeuverView.Orientation.portrait.rawValue].color,
                       foregroundColor,
                       "The portrait busy indicator color is wrong!",
                       line: line)
        XCTAssertEqual(view.busyIndicators[GuidanceManeuverView.Orientation.landscape.rawValue].color,
                       foregroundColor,
                       "The landscape busy indicator color is wrong!",
                       line: line)
    }
}
