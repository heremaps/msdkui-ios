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

/// An options panel for displaying the traffic options of a dynamic penalty.
///
/// - SeeAlso: `NMADynamicPenalty.trafficPenaltyMode`
@IBDesignable open class TrafficOptionsPanel: OptionsPanel {

    // MARK: - Properties

    /// A string that can be used to represent the panel.
    public static let name = "msdkui_traffic".localized

    /// The underlying `NMADynamicPenalty` object. The panel reflects its `trafficPenaltyMode` properties and
    /// sets the `selectedItemIndex` based on it.
    public var dynamicPenalty: NMADynamicPenalty! {
        didSet {
            if let dynamicPenalty = dynamicPenalty {
                // One-by-one check
                for index in 0 ..< TrafficOptionsPanel.options.count where TrafficOptionsPanel.options[index].value == dynamicPenalty.trafficPenaltyMode {
                    item?.selectedItemIndex = index
                    break
                }

                // Sets the item delegate
                item?.delegate = self
            }
        }
    }

    /// The delegate object is responsible for customising the panel.
    public weak var pickerDelegate: PickerViewDelegate? {
        didSet {
            item?.pickerDelegate = pickerDelegate
        }
    }

    /// All the label/value option pairs that the panel supports.
    ///
    /// - Note: The options are listed in the declaration order.
    static let options: [(label: String, value: NMATrafficPenaltyMode)] = [
        ("msdkui_disabled".localized, NMATrafficPenaltyMode.disabled),
        ("msdkui_optimal".localized, NMATrafficPenaltyMode.optimal),
        ("msdkui_avoid_long_term_closures".localized, NMATrafficPenaltyMode.avoidLongTermClosures)
    ]

    /// Convenience property to access the underlying `SingleChoiceOptionItem` item.
    private var item: SingleChoiceOptionItem? {
        optionItems.first as? SingleChoiceOptionItem
    }

    // MARK: - Public

    /// Creates the spec for the underlying `SingleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = TrafficOptionsPanel.options.map { $0.label }

        // Creates the spec for the option item
        specs = [OptionItemSpec.makeSingleChoiceOptionItem(title: nil, labels: labels)]
    }
}

// MARK: - OptionItemDelegate

extension TrafficOptionsPanel: OptionItemDelegate {

    public func optionItemDidChange(_ item: OptionItem) {
        guard let singleChoiceOptionItem = item as? SingleChoiceOptionItem else {
            return
        }

        if let trafficPenaltyMode = NMATrafficPenaltyMode(rawValue: TrafficOptionsPanel.options[singleChoiceOptionItem.selectedItemIndex].value.rawValue) {
            dynamicPenalty.trafficPenaltyMode = trafficPenaltyMode
        }

        // Notifies the delegate
        delegate?.optionsPanel(self, didChangeTo: item)
    }
}
