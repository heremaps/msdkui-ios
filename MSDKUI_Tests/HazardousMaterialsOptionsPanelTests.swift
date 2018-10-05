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

class HazardousMaterialsOptionsPanelTests: XCTestCase {
    // The panel
    private var panel = HazardousMaterialsOptionsPanel()

    // For panel testing
    private var routingMode = NMARoutingMode()

    // Is the panel created?
    private var isPanelCreated = false

    // Is the panel changed?
    private var isPanelChanged = false

    // Run the tests: note that first the panel and then its option are tested, i.e. the order is important
    func testPanel() {
        panelTests()
        optionTests()
    }

    // Tests the panel: it has one MultipleChoiceOptionItem object
    func panelTests() {
        // Initial value
        routingMode.hazardousGoods = NMAHazardousGoodsType(rawValue: NMAHazardousGoodsType.explosive.rawValue + NMAHazardousGoodsType.corrosive.rawValue)

        let panelTitle = "Hazardous materials"

        // Panel settings
        panel.title = panelTitle
        panel.routingMode = routingMode
        panel.onOptionCreated = onOptionCreated
        panel.onOptionChanged = onOptionChanged

        // Is the panel created?
        XCTAssertTrue(isPanelCreated, "The panel is not created!")

        // Is the panel title OK?
        XCTAssertNotNil(panel.titleItem, "No title item after setting the title!")
        XCTAssertNotNil(panel.titleItem?.label, "No title label in the title item!")
        XCTAssertEqual(panel.titleItem?.label?.text, panelTitle, "Not the expected panel title \(panelTitle)!")

        // Has the panel expected number of option items?
        XCTAssertEqual(panel.optionItems.count, 1, "The panel has not expected number of option items!")
    }

    // Tests the option
    func optionTests() {
        let item = panel.optionItems[0] as? MultipleChoiceOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "The panel has not the expected MultipleChoiceOptionItem object!")

        // Has the panel expected number of options?
        XCTAssertEqual(item?.labels.count, HazardousMaterialsOptionsPanel.options.count, "The panel has not expected number of options!")

        // Change the selected options
        item?.selectedItemIndexes = [2, 4]

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.hazardousGoods.rawValue, 20, "Not the expected MARoutingMode.hazardousGoods value!")

        // Set the same selected items again
        isPanelChanged = false
        item?.selectedItemIndexes = [2, 4]

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    // For testing the panel creation
    func onOptionCreated(_ item: OptionItem) {
        let item = item as! MultipleChoiceOptionItem

        XCTAssertEqual(item.selectedItemIndexes, [0, 7], "Not the expected options selected!")

        isPanelCreated = true
    }

    // For testing the changes
    func onOptionChanged(_ item: OptionItem) {
        let item = item as! MultipleChoiceOptionItem

        XCTAssertEqual(item.selectedItemIndexes, [2, 4], "Not the expected options selected!")

        isPanelChanged = true
    }
}
