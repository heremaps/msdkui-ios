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

import NMAKit

/// An options panel for displaying the truck options of a routing mode.
///
/// - SeeAlso: NMARoutingMode
@IBDesignable open class TruckOptionsPanel: OptionsPanel {
    /// A string that can be used to represent the panel.
    public static var name = "msdkui_truck_options_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects it.
    ///
    /// - Important: Sets the `onChanged` callback of the underlying option item to monitor
    ///              the updates afterwards.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                // One-by-one update the items based on the id's
                for item in optionItems {
                    switch item.id {
                    case Ids.vehicleHeight.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.vehicleHeight)

                    case Ids.vehicleLength.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.vehicleLength)

                    case Ids.vehicleWidth.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.vehicleWidth)

                    case Ids.limitedVehicleWeight.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.limitedVehicleWeight)

                    case Ids.weightPerAxle.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.weightPerAxle)

                    case Ids.trailersCount.rawValue:
                        let item = item as! NumericOptionItem
                        item.value = NSNumber(value: routingMode.trailersCount)

                    case Ids.truckType.rawValue:
                        let item = item as! SingleChoiceOptionItem
                        item.selectedItemIndex = Int(routingMode.truckType.rawValue)

                    case Ids.truckRestrictionsMode.rawValue:
                        let item = item as! BooleanOptionItem
                        item.checked = (routingMode.truckRestrictionsMode == .noViolations ? false : true)

                    default:
                        assertionFailure("Unknown option!")
                    }

                    // Set the onChanged callback to monitor the updates afterwards
                    item.onChanged = onChanged
                }
            }
        }
    }

    /// The input box presenter view controller.
    public var presenter: UIViewController!

    /// The delegate object is responsible for customizing the truck type item.
    public var delegate: PickerViewDelegate! {
        didSet {
            // One-by-one check the items to find the SingleChoiceOptionItem
            for item in optionItems where item.id == Ids.truckType.rawValue {
                let item = item as! SingleChoiceOptionItem
                item.delegate = delegate
            }
        }
    }

    /// The unique ids of all the option items found on the panel.
    enum Ids: Int {
        case vehicleHeight
        case vehicleLength
        case vehicleWidth
        case limitedVehicleWeight
        case weightPerAxle
        case trailersCount
        case truckType
        case truckRestrictionsMode
    }

    /// The number formatter for validating the user input
    let numberFormatter = NumberFormatter()

    /// Assigns the labels per drive options and creates the specs for the
    /// underlying `OptionItem` objects.
    override func makePanel() {
        // Decimal numbers in current locale are supported
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        // Create the specs for the option items: note that the id's assigned
        // here is important for the updates afterwards
        specs = [
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_height".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateDecimal, title: "msdkui_height".localized),
                id: Ids.vehicleHeight.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_length".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateDecimal, title: "msdkui_length".localized),
                id: Ids.vehicleLength.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_width".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateDecimal, title: "msdkui_width".localized),
                id: Ids.vehicleWidth.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_limited_weight".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateDecimal, title: "msdkui_limited_weight".localized),
                id: Ids.limitedVehicleWeight.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_weight_per_axle".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateDecimal, title: "msdkui_weight_per_axle".localized),
                id: Ids.weightPerAxle.rawValue
            ),
            OptionItemSpec.makeNumericOptionItem(
                label: "msdkui_number_of_trailers".localized,
                inputHelper: NumericOptionItemInputHelper(validator: validateInteger, title: "msdkui_number_of_trailers".localized),
                id: Ids.trailersCount.rawValue
            ),
            OptionItemSpec.makeSingleChoiceOptionItem(
                title: "msdkui_truck_type".localized,
                labels: ["msdkui_none".localized, "msdkui_truck_type_truck".localized, "msdkui_truck_type_tractor".localized],
                id: Ids.truckType.rawValue
            ),
            OptionItemSpec.makeBooleanOptionItem(
                label: "msdkui_violate_truck_options".localized,
                id: Ids.truckRestrictionsMode.rawValue
            )
        ]
    }

    /// This method is called after each update. It updates the related properties of
    /// the underlying `NMARoutingMode` object.
    private func onChanged(_ item: OptionItem) {
        // Proceed based on the option item id
        switch item.id {
        case Ids.vehicleHeight.rawValue:
            let item = item as! NumericOptionItem
            routingMode.vehicleHeight = item.value!.floatValue

        case Ids.vehicleLength.rawValue:
            let item = item as! NumericOptionItem
            routingMode.vehicleLength = item.value!.floatValue

        case Ids.vehicleWidth.rawValue:
            let item = item as! NumericOptionItem
            routingMode.vehicleWidth = item.value!.floatValue

        case Ids.limitedVehicleWeight.rawValue:
            let item = item as! NumericOptionItem
            routingMode.limitedVehicleWeight = item.value!.floatValue

        case Ids.weightPerAxle.rawValue:
            let item = item as! NumericOptionItem
            routingMode.weightPerAxle = item.value!.floatValue

        case Ids.trailersCount.rawValue:
            let item = item as! NumericOptionItem
            routingMode.trailersCount = item.value!.uintValue

        case Ids.truckType.rawValue:
            let item = item as! SingleChoiceOptionItem
            routingMode.truckType = NMATruckType(rawValue: UInt(item.selectedItemIndex))!

        case Ids.truckRestrictionsMode.rawValue:
            let item = item as! BooleanOptionItem
            routingMode.truckRestrictionsMode = (item.checked == true ? .penalizeViolations : .noViolations)

        default:
            assertionFailure("Unknown option!")
        }

        // Has any callback set?
        onOptionChanged?(item)
    }

    /// Validates the decimal user input.
    private func validateDecimal(_ stringValue: String) -> Bool {
        // Can the string be converted to a number?
        return (numberFormatter.number(from: stringValue) != nil ? true : false)
    }

    /// Validates the integer user input.
    private func validateInteger(_ stringValue: String) -> Bool {
        let number = numberFormatter.number(from: stringValue)
        var verdict = false

        // Is the string converted to a number?
        if let number = number {
            let value = number.doubleValue

            // Is it an integer value?
            if rint(value) == value {
                verdict = true
            }
        }

        return verdict
    }
}
