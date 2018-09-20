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

class GuidanceManeuverPanelTests: XCTestCase {
    /// The panel dimensions.
    enum Dims: CGFloat {
        case width = 375.0
        case height = 139.0
    }

    /// The panel to be tested.
    private var panel = GuidanceManeuverPanel(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: Dims.width.rawValue,
                                                            height: Dims.height.rawValue))

    /// The mock image used as next road icon.
    let mockNextRoadIcon = UIImage()

    override func setUp() {
        super.setUp()

        // Make sure to be in the portrait orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    /// Tests the initial state of Data and NoData Containers after the view initialization.
    func testContainersInitialState() {
        // Check initial state
        checkInitialState()

        // Set nil data
        panel.data = nil

        // Panel should stay at initial state
        checkInitialState()
    }

    /// Tests the state of Data and NoData Containers after data is set.
    func testContainersStateWithDataSet() {
        // Sets the panel data
        panel.data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_11",
                                          distance: "30 m",
                                          info1: "Exit 30",
                                          info2: "Invalidenstr.",
                                          nextRoadIcon: mockNextRoadIcon)

        // Has data containers visible
        panel.dataContainers.forEach {
            XCTAssertFalse($0.isHidden, "Data Container is visible")
        }

        // Has busy indicators hidden
        panel.busyIndicators.forEach {
            XCTAssertTrue($0.isHidden, "Busy indicator is hidden")
            XCTAssertFalse($0.isAnimating, "Busy indicator is not animating")
        }

        // Has NoData containers hidden
        panel.noDataContainers.forEach {
            XCTAssertTrue($0.isHidden, "NoData Container is hidden")
        }

        // Reset data to nil to check busy state
        panel.data = nil

        // Has data containers hidden
        panel.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "Data Container is visible")
        }

        // Has busy indicators visible and animating
        panel.busyIndicators.forEach {
            XCTAssertFalse($0.isHidden, "Busy indicator is hidden")
            XCTAssertTrue($0.isAnimating, "Busy indicator is not animating")
        }

        // Has NoData icons hidden
        panel.noDataImageViews.forEach {
            XCTAssertTrue($0.isHidden, "NoData icons is hidden")
        }

        // Has NoData labels visible and with correct text
        panel.noDataLabels.forEach {
            XCTAssertFalse($0.isHidden, "NoData labels is visible")

            XCTAssertLocalized($0.text,
                               key: "msdkui_maneuverpanel_updating",
                               bundle: .MSDKUI,
                               "It shows the correct string for busy state")
        }
    }

    /// Tests the initial panel height.
    func testInitialPanelHeight() {
        XCTAssertEqual(panel.frame.size.height, Dims.height.rawValue, "The initial panel height is wrong!")
    }

    /// Tests the panel height when the Info1 is set in the portrait orientation.
    func testPanelWithInfo1inPortrait() {
        let data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_11",
                                        distance: "30 m",
                                        info1: "Exit 30",
                                        info2: "Invalidenstr.",
                                        nextRoadIcon: mockNextRoadIcon)

        // Pass the data to the panel
        panel.data = data

        // Is the panel height unchanged?
        XCTAssertEqual(panel.intrinsicContentSize.height, Dims.height.rawValue, "The panel height with Info1 is wrong!")

        // Are the data set correctly?
        XCTAssertFalse(panel.info1Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].isHidden,
                       "The panel landscape info1 label is hidden!")

        XCTAssertFalse(panel.info1Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].isHidden,
                       "The panel landscape info1 label is hidden!")

        checkData(data)
    }

    /// Tests the panel when the Info1 is not set in the portrait orientation.
    func testPanelWithoutInfo1inPortrait() {
        let data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_12",
                                        distance: "200 m",
                                        info1: nil,
                                        info2: "Invalidenstr.",
                                        nextRoadIcon: mockNextRoadIcon)

        // Pass the data to the panel
        panel.data = data

        // Is the panel height smaller now?
        XCTAssertLessThan(panel.intrinsicContentSize.height, Dims.height.rawValue, "The panel height without Info1 is wrong!")

        // Are the data set correctly?
        XCTAssertTrue(panel.info1Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].isHidden,
                      "The panel landscape info1 label is not hidden!")

        XCTAssertTrue(panel.info1Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].isHidden,
                      "The panel landscape info1 label is not hidden!")

        checkData(data)
    }

    /// Tests the GuidanceManeuverPanel.highlightManeuver(textColor:) method.
    func testHighlightColor() {
        // This method updates the color of Info2 labels
        panel.highlightManeuver(textColor: UIColor.red)

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor, UIColor.red,
                       "The portrait Info2 color is wrong!")

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor, UIColor.red,
                       "The landscape Info2 color is wrong!")
    }

    /// Tests the GuidanceManeuverPanel.adaptToPortrait() method.
    func testAdaptToPortrait() {
        panel.adaptToPortrait()

        XCTAssertFalse(panel.views[GuidanceManeuverPanel.Orientation.portrait.rawValue].isHidden,
                       "The portrait orientation is visible!")

        XCTAssertTrue(panel.views[GuidanceManeuverPanel.Orientation.landscape.rawValue].isHidden,
                      "The portrait orientation is hidden!")
    }

    /// Tests the GuidanceManeuverPanel.adaptToLandscape() method.
    func testadaptToLandscape() {
        panel.adaptToLandscape()

        XCTAssertTrue(panel.views[GuidanceManeuverPanel.Orientation.portrait.rawValue].isHidden,
                      "The portrait orientation is hidden!")

        XCTAssertFalse(panel.views[GuidanceManeuverPanel.Orientation.landscape.rawValue].isHidden,
                       "The portrait orientation is visible!")
    }

    /// Tests the default style.
    func testDefaultStyle() {
        checkStyle(backgroundColor: .colorBackgroundDark, foregroundColor: .colorForegroundLight)
    }

    /// Tests that the style updates are reflected.
    func testStyleUpdates() {
        let newBackgroundColor = UIColor.red
        let newForegroundColor = UIColor.green

        panel.backgroundColor = newBackgroundColor
        panel.foregroundColor = newForegroundColor

        checkStyle(backgroundColor: newBackgroundColor, foregroundColor: newForegroundColor)
    }

    // MARK: Private methods

    private func checkData(_ data: GuidanceManeuverData, line: UInt = #line) {
        XCTAssertNotNil(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].image,
                        "The portrait maneuver image is not set!",
                        line: line)

        XCTAssertEqual(panel.roadIconViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].image,
                       mockNextRoadIcon,
                       "The portrait highway image is not set!",
                       line: line)

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text,
                       data.distance,
                       "The portrait distance data is wrong!",
                       line: line)

        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text,
                       data.info1,
                       "The portrait distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text,
                       data.info2,
                       "The portrait distance info2 is wrong!",
                       line: line)

        XCTAssertNotNil(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].image,
                        "The landscape maneuver image is not set!",
                        line: line)

        XCTAssertEqual(panel.roadIconViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].image,
                       mockNextRoadIcon,
                       "The landscape highway image is not set!",
                       line: line)

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text,
                       data.distance,
                       "The landscape distance data is wrong!",
                       line: line)

        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text,
                       data.info1,
                       "The landscape distance info1 is wrong!",
                       line: line)

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text,
                       data.info2,
                       "The landscape distance info2 is wrong!",
                       line: line)
    }

    private func checkStyle(backgroundColor: UIColor, foregroundColor: UIColor, line: UInt = #line) {
        XCTAssertEqual(panel.views[GuidanceManeuverPanel.Orientation.portrait.hashValue].backgroundColor,
                       backgroundColor,
                       "The portrait panel backgroundColor is wrong!",
                       line: line)
        XCTAssertEqual(panel.views[GuidanceManeuverPanel.Orientation.landscape.hashValue].backgroundColor,
                       backgroundColor,
                       "The landscape panel backgroundColor is wrong!",
                       line: line)

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor,
                       foregroundColor,
                       "The portrait distance label text color is wrong!",
                       line: line)
        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor,
                       foregroundColor,
                       "The landscape distance label text color is wrong!",
                       line: line)

        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor,
                       foregroundColor,
                       "The portrait info1 label text color is wrong!",
                       line: line)
        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor,
                       foregroundColor,
                       "The landscape info1 label text color is wrong!",
                       line: line)

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor,
                       foregroundColor,
                       "The portrait info2 label text color is wrong!",
                       line: line)
        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor,
                       foregroundColor,
                       "The landscape info2 label text color is wrong!",
                       line: line)

        XCTAssertEqual(panel.noDataLabels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor,
                       foregroundColor,
                       "The portrait no data label text color is wrong!",
                       line: line)
        XCTAssertEqual(panel.noDataLabels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor,
                       foregroundColor,
                       "The landscape no data label text color is wrong!",
                       line: line)

        XCTAssertEqual(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].tintColor,
                       foregroundColor,
                       "The portrait maneuver icon color is wrong!",
                       line: line)
        XCTAssertEqual(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].tintColor,
                       foregroundColor,
                       "The landscape maneuver icon color is wrong!",
                       line: line)

        XCTAssertEqual(panel.roadIconViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].tintColor,
                       foregroundColor,
                       "The portrait road icon color is wrong!",
                       line: line)
        XCTAssertEqual(panel.roadIconViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].tintColor,
                       foregroundColor,
                       "The landscape road icon color is wrong!",
                       line: line)

        XCTAssertEqual(panel.noDataImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].tintColor,
                       foregroundColor,
                       "The portrait no data icon color is wrong!",
                       line: line)
        XCTAssertEqual(panel.noDataImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].tintColor,
                       foregroundColor,
                       "The landscape no data icon color is wrong!",
                       line: line)

        XCTAssertEqual(panel.busyIndicators[GuidanceManeuverPanel.Orientation.portrait.hashValue].color,
                       foregroundColor,
                       "The portrait busy indicator color is wrong!",
                       line: line)
        XCTAssertEqual(panel.busyIndicators[GuidanceManeuverPanel.Orientation.landscape.hashValue].color,
                       foregroundColor,
                       "The landscape busy indicator color is wrong!",
                       line: line)
    }

    private func checkInitialState(line: UInt = #line) {
        // Has the data containers hidden by default (when data isn't yet set)
        panel.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "Data Container is hidden", line: line)
        }

        // Has the NoData containers visible by default (when data isn't yet set)
        panel.noDataContainers.forEach {
            XCTAssertFalse($0.isHidden, "NoData Container is visible", line: line)
        }

        // Has busy indicators hidden
        panel.busyIndicators.forEach {
            XCTAssertTrue($0.isHidden, "Busy indicator is hidden", line: line)
            XCTAssertFalse($0.isAnimating, "Busy indicator is not animating", line: line)
        }

        // Shows the correct message about missing maneuver information
        panel.noDataLabels.forEach {
            XCTAssertNotEqual($0.text,
                              "msdkui_maneuverpanel_nodata",
                              "The string is localized",
                              line: line)

            XCTAssertLocalized($0.text,
                               key: "msdkui_maneuverpanel_nodata",
                               bundle: .MSDKUI,
                               "Shows the correct string when there's no maneuver data",
                               line: line)
        }
    }
}
