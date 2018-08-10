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

class RouteTypeOptionsPanelTests: XCTestCase, PickerViewDelegate {
    // The panel
    private var panel = RouteTypeOptionsPanel()

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

    // Tests the panel: it has one SingleChoiceOptionItem object
    func panelTests() {
        // Initial value
        routingMode.routingType = .shortest

        let panelTitle = "Route type options"

        // Panel settings
        panel.title = panelTitle
        panel.routingMode = routingMode
        panel.delegate = self
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
        let item = panel.optionItems[0] as? SingleChoiceOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "The panel has not the expected SingleChoiceOptionItem object!")

        // Is the delegate set?
        XCTAssertNotNil(item?.delegate, "The SingleChoiceOptionItem object has no delegate!")

        // Has the panel expected number of options?
        XCTAssertEqual(item?.labels.count, RouteTypeOptionsPanel.options.count, "The panel has not expected number of options!")

        // Change the selected option
        item?.selectedItemIndex = 2

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying MARoutingMode object updated?
        XCTAssertEqual(routingMode.routingType, .fastest, "Not the expected MARoutingMode.routingType value!")

        // Set the same selected item again
        isPanelChanged = false
        item?.selectedItemIndex = 2

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    // For testing the panel creation
    func onOptionCreated(_ item: OptionItem) {
        let item = item as! SingleChoiceOptionItem

        print("onOptionCreated called: selectedItemIndex = \(item.selectedItemIndex)")

        XCTAssertEqual(item.selectedItemIndex, 0, "Not the expected option selected!")

        isPanelCreated = true
    }

    // For testing the changes
    func onOptionChanged(_ item: OptionItem) {
        let item = item as! SingleChoiceOptionItem

        print("onOptionChanged called: selectedItemIndex = \(item.selectedItemIndex)")

        XCTAssertEqual(item.selectedItemIndex, 2, "Not the expected option selected!")

        isPanelChanged = true
    }

    // MARK: PickerViewDelegate

    func makeLabel(_: UIPickerView, text: String) -> UILabel {
        let pickerLabel = UILabel()
        let title = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: UIFont(name: "Verdana", size: 17.0)!, NSAttributedStringKey.foregroundColor: UIColor.colorAccent
        ])

        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
}
