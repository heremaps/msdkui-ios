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

import NMAKit

/// An options panel for displaying the truck options of a routing mode.
///
/// - SeeAlso: NMARoutingMode
@IBDesignable open class TruckOptionsPanel: OptionsPanel {

    // MARK: - Types

    /// The unique ids of all the option items found on the panel.
    enum OptionItemID: Int {
        case vehicleHeight
        case vehicleLength
        case vehicleWidth
        case limitedVehicleWeight
        case weightPerAxle
        case trailersCount
        case truckType
        case truckRestrictionsMode
    }

    // MARK: - Properties

    /// A string that can be used to represent the panel.
    public static let name = "msdkui_truck_options_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects it.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                // One-by-one update the items based on the id's
                for item in optionItems {
                    switch item.id {
                    case OptionItemID.vehicleHeight.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.vehicleHeight)

                    case OptionItemID.vehicleLength.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.vehicleLength)

                    case OptionItemID.vehicleWidth.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.vehicleWidth)

                    case OptionItemID.limitedVehicleWeight.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.limitedVehicleWeight)

                    case OptionItemID.weightPerAxle.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.weightPerAxle)

                    case OptionItemID.trailersCount.rawValue:
                        let item = item as? NumericOptionItem
                        item?.value = NSNumber(value: routingMode.trailersCount)

                    case OptionItemID.truckType.rawValue:
                        let item = item as? SingleChoiceOptionItem
                        item?.selectedItemIndex = Int(routingMode.truckType.rawValue)

                    case OptionItemID.truckRestrictionsMode.rawValue:
                        let item = item as? BooleanOptionItem
                        item?.checked = (routingMode.truckRestrictionsMode == .noViolations ? false : true)

                    default:
                        assertionFailure("Unknown option!")
                    }

                    // Set the item delegate
                    item.delegate = self
                }
            }
        }
    }

    /// The presenter object is responsible for presenting the `NumericOptionItem` input boxes.
    public var presenter: UIViewController? {
        didSet {
            optionItems.compactMap { $0 as? NumericOptionItem }.forEach { $0.presenter = presenter }
        }
    }

    /// The delegate object is responsible for customizing the `SingleChoiceOptionItem` objects.
    public weak var pickerDelegate: PickerViewDelegate? {
        didSet {
            optionItems.compactMap { $0 as? SingleChoiceOptionItem }.forEach { $0.pickerDelegate = pickerDelegate }
        }
    }

    /// The number formatter for validating the user input
    private let numberFormatter = NumberFormatter()

    // MARK: - Public

    /// Assigns the labels per drive options and creates the specs for the
    /// underlying `OptionItem` objects.
    override func makePanel() {
        // Decimal numbers in current locale are supported
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        // Creates the specs for the option items: note that the id's assigned
        // here is important for the updates afterwards
        specs = [
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_height".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_height".localized, validator: validateDecimal),
                id: OptionItemID.vehicleHeight.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_length".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_length".localized, validator: validateDecimal),
                id: OptionItemID.vehicleLength.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_width".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_width".localized, validator: validateDecimal),
                id: OptionItemID.vehicleWidth.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_limited_weight".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_limited_weight".localized, validator: validateDecimal),
                id: OptionItemID.limitedVehicleWeight.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_weight_per_axle".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_weight_per_axle".localized, validator: validateDecimal),
                id: OptionItemID.weightPerAxle.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_number_of_trailers".localized,
                inputHelper: NumericOptionItemInputHelper(title: "msdkui_number_of_trailers".localized, validator: validateInteger),
                id: OptionItemID.trailersCount.rawValue
            ),
            OptionItemSpec.makeSingleChoiceOptionItem(
                title: "msdkui_truck_type".localized,
                labels: ["msdkui_none".localized, "msdkui_truck_type_truck".localized, "msdkui_truck_type_tractor".localized],
                id: OptionItemID.truckType.rawValue
            ),
            OptionItemSpec.makeBooleanOptionItem(
                label: "msdkui_violate_truck_options".localized,
                id: OptionItemID.truckRestrictionsMode.rawValue
            )
        ]
    }

    // MARK: - Private

    /// Validates the decimal user input.
    private func validateDecimal(_ stringValue: String) -> Bool {
        // Can the string be converted to a number?
        return (numberFormatter.number(from: stringValue) != nil ? true : false)
    }

    /// Validates the integer user input.
    private func validateInteger(_ stringValue: String) -> Bool {
        let number = numberFormatter.number(from: stringValue)
        var verdict = false

        // Can the string be converted to an integer number?
        if let number = number {
            let value = number.doubleValue

            if rint(value) == value {
                verdict = true
            }
        }

        return verdict
    }
}

// MARK: - OptionItemDelegate

extension TruckOptionsPanel: OptionItemDelegate {

    public func optionItemDidChange(_ item: OptionItem) { // swiftlint:disable:this cyclomatic_complexity
        // Proceeds based on the option item id
        switch item.id {
        case OptionItemID.vehicleHeight.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.floatValue {
                routingMode.vehicleHeight = itemValue
            }

        case OptionItemID.vehicleLength.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.floatValue {
                routingMode.vehicleLength = itemValue
            }

        case OptionItemID.vehicleWidth.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.floatValue {
                routingMode.vehicleWidth = itemValue
            }

        case OptionItemID.limitedVehicleWeight.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.floatValue {
                routingMode.limitedVehicleWeight = itemValue
            }

        case OptionItemID.weightPerAxle.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.floatValue {
                routingMode.weightPerAxle = itemValue
            }

        case OptionItemID.trailersCount.rawValue:
            if let itemValue = (item as? NumericOptionItem)?.value?.uintValue {
                routingMode.trailersCount = itemValue
            }

        case OptionItemID.truckType.rawValue:
            if
                let selectedItemIndex = (item as? SingleChoiceOptionItem)?.selectedItemIndex,
                let truckType = NMATruckType(rawValue: UInt(clamping: selectedItemIndex)) {

                routingMode.truckType = truckType
            }

        case OptionItemID.truckRestrictionsMode.rawValue:
            if let isChecked = (item as? BooleanOptionItem)?.checked {
                routingMode.truckRestrictionsMode = isChecked ? .penalizeViolations : .noViolations
            }

        default:
            assertionFailure("Unknown option!")
        }

        // Notifies the delegate
        delegate?.optionsPanel(self, didChangeTo: item)
    }
}
