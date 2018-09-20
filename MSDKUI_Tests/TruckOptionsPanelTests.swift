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

class TruckOptionsPanelTests: XCTestCase, PickerViewDelegate {
    // The panel
    private var panel = TruckOptionsPanel()

    // For panel testing
    private var routingMode = NMARoutingMode()

    // Is the panel created?
    private var isPanelCreated = false

    // Is the panel changed?
    private var isPanelChanged = false

    // The decimal separator in use
    private var decimalSeparator: String!

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Get the current decimal separator symbol
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = NSLocale.current
        decimalSeparator = numberFormatter.decimalSeparator

        // Make sure that there is a decimal separator symbol
        if decimalSeparator == nil {
            decimalSeparator = "."
        }
    }

    // Run the tests: note that first the panel and then its option are tested, i.e. the order is important
    func testPanel() {
        panelTests()
        delegateTests()
        heightOptionTests()
        lengthOptionTests()
        widthOptionTests()
        limitedWeightOptionTests()
        weightPerAxleOptionTests()
        trailersCountOptionTests()
        truckTypeOptionTests()
        restrictionModeOptionTests()
    }

    // Tests the panel: it has six NumericOptionItem, one SingleChoiceOptionItem and
    // one BooleanOptionItem objects
    func panelTests() {
        // Initial values
        routingMode.vehicleHeight = 3.0
        routingMode.vehicleLength = 5.0
        routingMode.vehicleWidth = 2.0
        routingMode.limitedVehicleWeight = 11.0
        routingMode.weightPerAxle = 8.0
        routingMode.trailersCount = 3
        routingMode.truckType = .tractorTruck
        routingMode.truckRestrictionsMode = .penalizeViolations

        let panelTitle = "Truck options"

        // Panel settings
        panel = TruckOptionsPanel()
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
        XCTAssertEqual(panel.optionItems.count, 8, "The panel has not expected number of option items!")
    }

    private func delegateTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.truckType) as? SingleChoiceOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "The panel has not the expected SingleChoiceOptionItem object!")

        // Is the delegate set?
        XCTAssertNotNil(item!.delegate, "The SingleChoiceOptionItem object has no delegate!")
    }

    private func restrictionModeOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.truckRestrictionsMode) as? BooleanOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected BooleanOptionItem object!")

        // Change the value
        item?.checked = false

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.truckRestrictionsMode, .noViolations,
                       "Not the expected NMARoutingMode.truckRestrictionsMode value!")

        // Set the same value again
        isPanelChanged = false
        item?.checked = false

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func heightOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.vehicleHeight) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value
        item?.okHandler(userInput: "Height")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 3.0, "Not the expected height value!")
        XCTAssertEqual(item?.getButtonTitle(), "3", "Not the expected height button title!")

        // Set a valid value
        item?.okHandler(userInput: "4" + decimalSeparator + "5")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleHeight, 4.5, "Not the expected NMARoutingMode.vehicleHeight value!")

        // Set the same value again
        isPanelChanged = false
        item?.okHandler(userInput: "4" + decimalSeparator + "5")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func lengthOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.vehicleLength) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value
        item?.okHandler(userInput: "Length")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 5.0, "Not the expected length value!")
        XCTAssertEqual(item?.getButtonTitle(), "5", "Not the expected length button title!")

        // Set a valid value
        item?.okHandler(userInput: "5" + decimalSeparator + "7")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleLength, 5.7, "Not the expected NMARoutingMode.vehicleLength value!")

        // Set the same value again
        isPanelChanged = false
        item?.okHandler(userInput: "5" + decimalSeparator + "7")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func widthOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.vehicleWidth) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value
        item?.okHandler(userInput: "Width")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 2.0, "Not the expected width value!")
        XCTAssertEqual(item?.getButtonTitle(), "2", "Not the expected width button title!")

        // Set a valid value
        item?.okHandler(userInput: "2" + decimalSeparator + "1")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleWidth, 2.1, "Not the expected NMARoutingMode.vehicleWidth value!")

        // Set the same value again
        isPanelChanged = false
        item?.okHandler(userInput: "2" + decimalSeparator + "1")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func limitedWeightOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.limitedVehicleWeight) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value
        item?.okHandler(userInput: "Limited Weight")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 11.0, "Not the expected limited weight value!")
        XCTAssertEqual(item?.getButtonTitle(), "11", "Not the expected limited weight button title!")

        // Set a valid value
        item?.okHandler(userInput: "11" + decimalSeparator + "1")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.limitedVehicleWeight, 11.1, "Not the expected NMARoutingMode.limitedVehicleWeight value!")

        // Set the same value again
        isPanelChanged = false
        item?.okHandler(userInput: "11" + decimalSeparator + "1")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func weightPerAxleOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.weightPerAxle) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value
        item?.okHandler(userInput: "Weight per Axle")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 8.0, "Not the expected weight per axle value!")
        XCTAssertEqual(item?.getButtonTitle(), "8", "Not the expected weight per axle button title!")

        // Set a valid value
        item?.okHandler(userInput: "7" + decimalSeparator + "8")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.weightPerAxle, 7.8, "Not the expected NMARoutingMode.weightPerAxle value!")

        // Set the same value again
        isPanelChanged = false
        item!.okHandler(userInput: "7" + decimalSeparator + "8")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func trailersCountOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.trailersCount) as? NumericOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected NumericOptionItem object!")

        // Set an invalid value: decimal numbers are not accepted for this option
        item?.okHandler(userInput: "3" + decimalSeparator + "7")

        // No change is expected
        XCTAssertEqual(item?.value?.doubleValue, 3.0, "Not the expected trailers count value!")
        XCTAssertEqual(item?.getButtonTitle(), "3", "Not the expected trailers count button title!")

        // Set a valid value
        item?.okHandler(userInput: "4" + decimalSeparator + "0")

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.trailersCount, 4, "Not the expected NMARoutingMode.trailersCount value!")

        // Set the same value again
        isPanelChanged = false
        item?.okHandler(userInput: "4" + decimalSeparator + "0")

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func truckTypeOptionTests() {
        let item = getOptionItem(id: TruckOptionsPanel.Ids.truckType) as? SingleChoiceOptionItem

        // Is the item of expected type?
        XCTAssertNotNil(item, "Not found the expected SingleChoiceOptionItem object!")

        // Change the value
        item?.selectedItemIndex = 0

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.truckType, NMATruckType.none, "Not the expected NMARoutingMode.truckType value!")

        // Set the same value again
        isPanelChanged = false
        item?.selectedItemIndex = 0

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    private func getOptionItem(id: TruckOptionsPanel.Ids) -> OptionItem! {
        let count = panel.optionItems.count

        for index in 0 ... count {
            let optionItem = panel.optionItems[index]
            if optionItem.id == id.rawValue {
                return optionItem
            }
        }

        return nil
    }

    // For testing the panel creation
    private func onOptionCreated(_ item: OptionItem) {
        switch item.id {
        case TruckOptionsPanel.Ids.truckRestrictionsMode.rawValue:
            let item = item as! BooleanOptionItem
            XCTAssertTrue(item.checked, "Not the expected checked value!")

        case TruckOptionsPanel.Ids.vehicleHeight.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 3.0, "Not the expected height value!")
            XCTAssertEqual(item.getButtonTitle(), "3", "Not the expected height button title!")

        case TruckOptionsPanel.Ids.vehicleLength.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 5.0, "Not the expected length value!")
            XCTAssertEqual(item.getButtonTitle(), "5", "Not the expected length button title!")

        case TruckOptionsPanel.Ids.vehicleWidth.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 2.0, "Not the expected width value!")
            XCTAssertEqual(item.getButtonTitle(), "2", "Not the expected width button title!")

        case TruckOptionsPanel.Ids.limitedVehicleWeight.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 11.0, "Not the expected limited weight value!")
            XCTAssertEqual(item.getButtonTitle(), "11", "Not the expected limited weight button title!")

        case TruckOptionsPanel.Ids.weightPerAxle.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 8.0, "Not the expected weight per axle value!")
            XCTAssertEqual(item.getButtonTitle(), "8", "Not the expected weight per axle button title!")

        case TruckOptionsPanel.Ids.trailersCount.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 3.0, "Not the expected trailers count value!")
            XCTAssertEqual(item.getButtonTitle(), "3", "Not the expected trailers count button title!")

        case TruckOptionsPanel.Ids.truckType.rawValue:
            let item = item as! SingleChoiceOptionItem
            XCTAssertEqual(item.selectedItemIndex, 2, "Not the expected truck type value!")

        default:
            assertionFailure("Unknown option!")
        }

        isPanelCreated = true
    }

    // For testing the changes
    private func onOptionChanged(_ item: OptionItem) {
        switch item.id {
        case TruckOptionsPanel.Ids.truckRestrictionsMode.rawValue:
            let item = item as! BooleanOptionItem
            XCTAssertFalse(item.checked, "Not the expected checked value!")

        case TruckOptionsPanel.Ids.vehicleHeight.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 4.5, "Not the expected height value!")
            XCTAssertEqual(item.getButtonTitle(), "4" + decimalSeparator + "5", "Not the expected height button title!")

        case TruckOptionsPanel.Ids.vehicleLength.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 5.7, "Not the expected length value!")
            XCTAssertEqual(item.getButtonTitle(), "5" + decimalSeparator + "7", "Not the expected length button title!")

        case TruckOptionsPanel.Ids.vehicleWidth.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 2.1, "Not the expected width value!")
            XCTAssertEqual(item.getButtonTitle(), "2" + decimalSeparator + "1", "Not the expected width button title!")

        case TruckOptionsPanel.Ids.limitedVehicleWeight.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 11.1, "Not the expected limited weight value!")
            XCTAssertEqual(item.getButtonTitle(), "11" + decimalSeparator + "1", "Not the expected limited weight button title!")

        case TruckOptionsPanel.Ids.weightPerAxle.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 7.8, "Not the expected weight per axle value!")
            XCTAssertEqual(item.getButtonTitle(), "7" + decimalSeparator + "8", "Not the expected weight per axle button title!")

        case TruckOptionsPanel.Ids.trailersCount.rawValue:
            let item = item as! NumericOptionItem
            XCTAssertEqual(item.value?.doubleValue, 4.0, "Not the expected trailers count value!")
            XCTAssertEqual(item.getButtonTitle(), "4", "Not the expected trailers count button title!")

        case TruckOptionsPanel.Ids.truckType.rawValue:
            let item = item as! SingleChoiceOptionItem
            XCTAssertEqual(item.selectedItemIndex, 0, "Not the expected truck type value!")

        default:
            assertionFailure("Unknown option!")
        }

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
