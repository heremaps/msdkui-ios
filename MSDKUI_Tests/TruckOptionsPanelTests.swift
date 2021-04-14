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

final class TruckOptionsPanelTests: XCTestCase {
    /// The object under test.
    private var panel = TruckOptionsPanel()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = OptionsPanelDelegateMock() // swiftlint:disable:this weak_delegate

    /// The `NMARoutingMode` object for configuring the `panel` object.
    private var routingMode = NMARoutingMode()

    /// The decimal separator in use.
    private var decimalSeparator: String!

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

        // Initial values
        routingMode.vehicleHeight = 3.0
        routingMode.vehicleLength = 5.0
        routingMode.vehicleWidth = 2.0
        routingMode.limitedVehicleWeight = 11.0
        routingMode.weightPerAxle = 8.0
        routingMode.trailersCount = 3
        routingMode.truckType = .tractorTruck
        routingMode.truckRestrictionsMode = .penalizeViolations

        // Panel settings
        panel = TruckOptionsPanel()
        panel.title = "Truck options"
        panel.routingMode = routingMode
        panel.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests the panel height.
    func testPanelHeight() {
        XCTAssertGreaterThan(panel.intrinsicContentSize.height, 0, "It has intrinsic content height")
    }

    /// Tests the panel.
    func testPanel() {
        // Is the panel title OK?
        XCTAssertNotNil(panel.titleItem, "No title item after setting the title!")
        XCTAssertNotNil(panel.titleItem?.label, "No title label in the title item!")
        XCTAssertEqual(panel.titleItem?.label?.text, "Truck options", "It has the correct title")

        // Has the panel expected number of option items?
        XCTAssertEqual(panel.optionItems.count, 8, "The panel has not expected number of option items!")
    }

    /// Tests the panel delegate object.
    func testDelegate() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.truckType) as? SingleChoiceOptionItem)

        // Is the delegate set?
        XCTAssertNotNil(item.delegate, "The SingleChoiceOptionItem object has no delegate!")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.truckRestrictionsMode` option.
    func testRestrictionModeOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.truckRestrictionsMode) as? BooleanOptionItem)

        // Change the value
        item.checked = false

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(
            routingMode.truckRestrictionsMode, .noViolations,
            "Not the expected NMARoutingMode.truckRestrictionsMode value!"
        )

        // Set the same value again
        item.checked = false

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.vehicleHeight` option.
    func testHeightOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.vehicleHeight) as? NumericOptionItem)

        // Set an invalid value
        item.okHandler(userInput: "Height")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 3.0, "Not the expected height value!")
        XCTAssertEqual(item.getButtonTitle(), "3", "Not the expected height button title!")

        // Set a valid value
        item.okHandler(userInput: "4" + decimalSeparator + "5")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 4.5, "Not the expected height value!")
        XCTAssertEqual(item.getButtonTitle(), "4" + decimalSeparator + "5", "Not the expected height button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleHeight, 4.5, "Not the expected NMARoutingMode.vehicleHeight value!")

        // Set the same value again
        item.okHandler(userInput: "4" + decimalSeparator + "5")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.vehicleLength` option.
    func testLengthOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.vehicleLength) as? NumericOptionItem)

        // Set an invalid value
        item.okHandler(userInput: "Length")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 5.0, "Not the expected length value!")
        XCTAssertEqual(item.getButtonTitle(), "5", "Not the expected length button title!")

        // Set a valid value
        item.okHandler(userInput: "5" + decimalSeparator + "7")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 5.7, "Not the expected length value!")
        XCTAssertEqual(item.getButtonTitle(), "5" + decimalSeparator + "7", "Not the expected length button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleLength, 5.7, "Not the expected NMARoutingMode.vehicleLength value!")

        // Set the same value again
        item.okHandler(userInput: "5" + decimalSeparator + "7")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.vehicleWidth` option.
    func testWidthOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.vehicleWidth) as? NumericOptionItem)

        // Set an invalid value
        item.okHandler(userInput: "Width")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 2.0, "Not the expected width value!")
        XCTAssertEqual(item.getButtonTitle(), "2", "Not the expected width button title!")

        // Set a valid value
        item.okHandler(userInput: "2" + decimalSeparator + "1")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 2.1, "Not the expected width value!")
        XCTAssertEqual(item.getButtonTitle(), "2" + decimalSeparator + "1", "Not the expected width button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.vehicleWidth, 2.1, "Not the expected NMARoutingMode.vehicleWidth value!")

        // Set the same value again
        item.okHandler(userInput: "2" + decimalSeparator + "1")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.limitedVehicleWeight` option.
    func testLimitedWeightOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.limitedVehicleWeight) as? NumericOptionItem)

        // Set an invalid value
        item.okHandler(userInput: "Limited Weight")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 11.0, "Not the expected limited weight value!")
        XCTAssertEqual(item.getButtonTitle(), "11", "Not the expected limited weight button title!")

        // Set a valid value
        item.okHandler(userInput: "11" + decimalSeparator + "1")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 11.1, "Not the expected limited weight value!")
        XCTAssertEqual(item.getButtonTitle(), "11" + decimalSeparator + "1", "Not the expected limited weight button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.limitedVehicleWeight, 11.1, "Not the expected NMARoutingMode.limitedVehicleWeight value!")

        // Set the same value again
        item.okHandler(userInput: "11" + decimalSeparator + "1")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.weightPerAxle` option.
    func testWeightPerAxleOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.weightPerAxle) as? NumericOptionItem)

        // Set an invalid value
        item.okHandler(userInput: "Weight per Axle")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 8.0, "Not the expected weight per axle value!")
        XCTAssertEqual(item.getButtonTitle(), "8", "Not the expected weight per axle button title!")

        // Set a valid value
        item.okHandler(userInput: "7" + decimalSeparator + "8")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 7.8, "Not the expected weight per axle value!")
        XCTAssertEqual(item.getButtonTitle(), "7" + decimalSeparator + "8", "Not the expected weight per axle button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.weightPerAxle, 7.8, "Not the expected NMARoutingMode.weightPerAxle value!")

        // Set the same value again
        item.okHandler(userInput: "7" + decimalSeparator + "8")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.trailersCount` option.
    func testTrailersCountOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.trailersCount) as? NumericOptionItem)

        // Set an invalid value: decimal numbers are not accepted for this option
        item.okHandler(userInput: "3" + decimalSeparator + "7")

        // No change is expected
        XCTAssertEqual(item.value?.doubleValue, 3.0, "Not the expected trailers count value!")
        XCTAssertEqual(item.getButtonTitle(), "3", "Not the expected trailers count button title!")

        // Set a valid value
        item.okHandler(userInput: "4" + decimalSeparator + "0")

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        XCTAssertEqual(item.value?.doubleValue, 4.0, "Not the expected trailers count value!")
        XCTAssertEqual(item.getButtonTitle(), "4", "Not the expected trailers count button title!")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.trailersCount, 4, "Not the expected NMARoutingMode.trailersCount value!")

        // Set the same value again
        item.okHandler(userInput: "4" + decimalSeparator + "0")

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    /// Tests the `TruckOptionsPanel.OptionItemID.truckType` option.
    func testTruckTypeOption() throws {
        let item = try require(getOptionItem(id: TruckOptionsPanel.OptionItemID.truckType) as? SingleChoiceOptionItem)

        // Change the value
        item.selectedItemIndex = 0

        // Is the panel change detected?
        XCTAssertTrue(mockDelegate.didChangeToOption, "It tells the delegate method about the option change")
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It calls the delegate method only once")

        // Is the underlying NMARoutingMode object updated?
        XCTAssertEqual(routingMode.truckType, NMATruckType.none, "Not the expected NMARoutingMode.truckType value!")

        // Set the same value again
        item.selectedItemIndex = 0

        // Is the panel change not detected?
        XCTAssertEqual(mockDelegate.didChangeToOptionCount, 1, "It doesn't call the delegate method again")
    }

    // MARK: - Private

    private func getOptionItem(id: TruckOptionsPanel.OptionItemID) -> OptionItem? {
        let optionItems = panel.optionItems.filter { $0.id == id.rawValue }

        // There should be one and only one option item with the given id
        XCTAssertEqual(optionItems.count, 1, "It returns a single item")

        return optionItems.first
    }
}
