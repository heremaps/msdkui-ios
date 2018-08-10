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

/// An options panel for displaying the hazardous materials options of a `NMARoutingMode`.
///
/// - SeeAlso: `NMARoutingMode.hazardousGoods`
@IBDesignable open class HazardousMaterialsOptionsPanel: OptionsPanel {
    /// A string that can be used to represent the panel.
    public static var name = "msdkui_hazardous_materials_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects its `hazardousGoods` properties and
    /// sets the `selectedItemIndexes` based on these route options.
    ///
    /// - Important: Sets the `onChanged` callback of the underlying option item to monitor
    ///              the updates afterwards.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                var selectedItemIndexes: Set<Int> = []

                // One-by-one check
                for index in 0 ..< HazardousMaterialsOptionsPanel.options.count {
                    let isSelected = (HazardousMaterialsOptionsPanel.options[index].value.rawValue & routingMode.hazardousGoods.rawValue) > 0
                    if isSelected {
                        selectedItemIndexes.insert(index)
                    }
                }

                // Finally, set the selected options on the item
                item.selectedItemIndexes = selectedItemIndexes

                // Set the onChanged callback to monitor the updates afterwards
                item.onChanged = onChanged
            }
        }
    }

    /// All the label/value option pairs that the panel supports.
    ///
    /// - Important: The options are listed in the declaration order.
    static let options: [(label: String, value: NMAHazardousGoodsType)] = [
        ("msdkui_explosive".localized, NMAHazardousGoodsType.explosive),
        ("msdkui_gas".localized, NMAHazardousGoodsType.gas),
        ("msdkui_flammable".localized, NMAHazardousGoodsType.flammable),
        ("msdkui_combustible".localized, NMAHazardousGoodsType.combustible),
        ("msdkui_organic".localized, NMAHazardousGoodsType.organic),
        ("msdkui_poison".localized, NMAHazardousGoodsType.poison),
        ("msdkui_radioactive".localized, NMAHazardousGoodsType.radioActive),
        ("msdkui_corrosive".localized, NMAHazardousGoodsType.corrosive),
        ("msdkui_poisonous".localized, NMAHazardousGoodsType.poisonousInhalation),
        ("msdkui_harmful_to_water".localized, NMAHazardousGoodsType.harmfulToWater),
        ("msdkui_other".localized, NMAHazardousGoodsType.other)
    ]

    /// Convenience property to access the underlying `MultipleChoiceOptionItem` item.
    var item: MultipleChoiceOptionItem {
        return optionItems[0] as! MultipleChoiceOptionItem
    }

    /// Creates the spec for the underlying `MultipleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = HazardousMaterialsOptionsPanel.options.map { $0.label }

        // Create the spec for the option item
        specs = [OptionItemSpec.makeMultipleChoiceOptionItem(labels: labels)]
    }

    /// This method is called after each update. It updates the `hazardousGoods` property of
    /// the underlying `NMARoutingMode` object.
    func onChanged(_: OptionItem) {
        // Assume there is no selected item index
        var hazardousGoods: UInt = 0

        // Is there any selected item index?
        if let selectedItemIndexes = item.selectedItemIndexes {
            // One-by-one increment the hazardousGoods value
            for index in selectedItemIndexes {
                hazardousGoods += HazardousMaterialsOptionsPanel.options[index].value.rawValue
            }
        }

        // Update the value
        routingMode.hazardousGoods = NMAHazardousGoodsType(rawValue: hazardousGoods)

        // Has any callback set?
        onOptionChanged?(item)
    }
}
