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
    // The panel dimensions
    enum Dims: CGFloat {
        case width = 375.0
        case height = 133.0
    }

    // The panel to be tested
    private var panel = GuidanceManeuverPanel(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: Dims.width.rawValue,
                                                            height: Dims.height.rawValue))

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Make sure to be in the portrait orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    // Tests the initial state of Data and No Data Containers after the view initialization
    func testContainersInitialState() {
        // Has the data containers hidden by default (when data isn't yet set)
        panel.dataContainers.forEach {
            XCTAssertTrue($0.isHidden, "Data Container should be hidden")
        }

        // Has the no data containers visible by default (when data isn't yet set)
        panel.noDataContainers.forEach {
            XCTAssertFalse($0.isHidden, "No Data Container should be visible")
        }

        // Shows the correct message about missing maneuver information
        panel.noDataLabels.forEach {
            XCTAssertNotEqual($0.text, "msdkui_maneuverpanel_nodata",
                              "The string should be localized")

            XCTAssertLocalized($0.text, key: "msdkui_maneuverpanel_nodata", bundle: .MSDKUI,
                               "It should show the correct string when there's no maneuver data")
        }
    }

    // Tests the state of Data and No Data Containers after data is set
    func testContainersStateWithDataSet() {
        // Sets the panel data
        panel.data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_11", distance: "30 m", info1: "Exit 30", info2: "Invalidenstr.")

        // Has the data containers hidden by default (when data isn't yet set)
        panel.dataContainers.forEach {
            XCTAssertFalse($0.isHidden, "Data Container should be visible")
        }

        // Has the no data containers visible by default (when data isn't yet set)
        panel.noDataContainers.forEach {
            XCTAssertTrue($0.isHidden, "No Data Container should be hidden")
        }
    }

    // Tests the initial panel height
    func testInitialPanelHeight() {
        XCTAssertEqual(panel.frame.size.height, Dims.height.rawValue, "The initial panel height is wrong!")
    }

    // Tests the panel height when the Info1 is set in the portrait orientation
    func testPanelWithInfo1inPortrait() {
        let data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_11",
                                        distance: "30 m",
                                        info1: "Exit 30",
                                        info2: "Invalidenstr.")

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

    // Tests the panel when the Info1 is not set in the portrait orientation
    func testPanelWithoutInfo1inPortrait() {
        let data = GuidanceManeuverData(maneuverIcon: "maneuver_icon_12",
                                        distance: "200 m",
                                        info1: nil,
                                        info2: "Invalidenstr.")

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

    // Tests the MSDKUI.GuidanceManeuverPanel.highlightManeuver(textColor:) method
    func testHighlightColor() {
        // This method updates the color of Info2 labels
        panel.highlightManeuver(textColor: UIColor.red)

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor, UIColor.red,
                       "The portrait Info2 color is wrong!")

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor, UIColor.red,
                       "The landscape Info2 color is wrong!")
    }

    // Tests the MSDKUI.GuidanceManeuverPanel.adaptToPortrait() method
    func testAdaptToPortrait() {
        panel.adaptToPortrait()

        XCTAssertFalse(panel.views[GuidanceManeuverPanel.Orientation.portrait.rawValue].isHidden,
                       "The portrait orientation should be visible!")

        XCTAssertTrue(panel.views[GuidanceManeuverPanel.Orientation.landscape.rawValue].isHidden,
                      "The portrait orientation should be hidden!")
    }

    // Tests the MSDKUI.GuidanceManeuverPanel.adaptToLandscape() method
    func testadaptToLandscape() {
        panel.adaptToLandscape()

        XCTAssertTrue(panel.views[GuidanceManeuverPanel.Orientation.portrait.rawValue].isHidden,
                      "The portrait orientation should be hidden!")

        XCTAssertFalse(panel.views[GuidanceManeuverPanel.Orientation.landscape.rawValue].isHidden,
                       "The portrait orientation should be visible!")
    }

    // Tests that the style updates are monitored and reflected
    func testStyleUpdates() {
        // Initially the panel should have the expected style
        checkStyle()

        // Update the monitored style properties
        Styles.shared.guidanceManeuverPanelBackgroundColor = .red
        Styles.shared.guidanceManeuverIconAndTextColor = .green

        // After the properties are updated, the panel should have the new style, too
        checkStyle()
    }

    // MARK: Private methods

    // Checks the data passed one-by-one to make sure the panel is set correctly
    private func checkData(_ data: GuidanceManeuverData) {
        XCTAssertNotNil(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].image,
                        "The panel portrait maneuver image is not set!")

        XCTAssertNil(panel.highwayImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].image,
                     "The panel portrait highway image is set!")

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text, data.distance,
                       "The panel portrait distance data is wrong!")

        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text, data.info1,
                       "The panel portrait distance info1 is wrong!")

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.portrait.hashValue].text, data.info2,
                       "The panel portrait distance info2 is wrong!")

        XCTAssertNotNil(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].image,
                        "The panel landscape maneuver image is not set!")

        XCTAssertNil(panel.highwayImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].image,
                     "The panel landscape highway image is set!")

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text, data.distance,
                       "The panel landscape distance data is wrong!")

        XCTAssertEqual(panel.info1Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text, data.info1,
                       "The panel landscape distance info1 is wrong!")

        XCTAssertEqual(panel.info2Labels[GuidanceManeuverPanel.Orientation.landscape.hashValue].text, data.info2,
                       "The panel landscape distance info2 is wrong!")
    }

    private func checkStyle() {
        XCTAssertEqual(panel.views[GuidanceManeuverPanel.Orientation.portrait.hashValue].backgroundColor,
                       Styles.shared.guidanceManeuverPanelBackgroundColor,
                       "The panel backgroundColor is wrong!")
        XCTAssertEqual(panel.views[GuidanceManeuverPanel.Orientation.landscape.hashValue].backgroundColor,
                       Styles.shared.guidanceManeuverPanelBackgroundColor,
                       "The panel backgroundColor is wrong!")

        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.portrait.hashValue].textColor,
                       Styles.shared.guidanceManeuverIconAndTextColor,
                       "The panel text color is wrong!")
        XCTAssertEqual(panel.distanceLabels[GuidanceManeuverPanel.Orientation.landscape.hashValue].textColor,
                       Styles.shared.guidanceManeuverIconAndTextColor,
                       "The panel text color is wrong!")

        XCTAssertEqual(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.portrait.hashValue].tintColor,
                       Styles.shared.guidanceManeuverIconAndTextColor,
                       "The panel maneuver icon color is wrong!")
        XCTAssertEqual(panel.maneuverImageViews[GuidanceManeuverPanel.Orientation.landscape.hashValue].tintColor,
                       Styles.shared.guidanceManeuverIconAndTextColor,
                       "The panel maneuver icon color is wrong!")
    }
}
