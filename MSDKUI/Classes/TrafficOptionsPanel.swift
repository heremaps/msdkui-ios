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

/// An options panel for displaying the traffic options of a dynamic penalty.
///
/// - SeeAlso: `NMADynamicPenalty.trafficPenaltyMode`
@IBDesignable open class TrafficOptionsPanel: OptionsPanel {
    /// A string that can be used to represent the panel.
    public static var name = "msdkui_traffic".localized

    /// The underlying `NMADynamicPenalty` object. The panel reflects its `trafficPenaltyMode` properties and
    /// sets the `selectedItemIndex` based on it.
    ///
    /// - Important: Sets the `onChanged` callback of the underlying option item to monitor
    ///              the updates afterwards.
    public var dynamicPenalty: NMADynamicPenalty! {
        didSet {
            if let dynamicPenalty = dynamicPenalty {
                // One-by-one check
                for index in 0 ..< TrafficOptionsPanel.options.count where TrafficOptionsPanel.options[index].value == dynamicPenalty.trafficPenaltyMode {
                    item.selectedItemIndex = index
                    break
                }

                // Set the onChanged callback to monitor the updates afterwards
                item.onChanged = onChanged
            }
        }
    }

    /// The delegate object is responsible for customising the panel.
    public var delegate: PickerViewDelegate! {
        didSet {
            item.delegate = delegate
        }
    }

    /// All the label/value option pairs that the panel supports.
    ///
    /// - Important: The options are listed in the declaration order.
    static let options: [(label: String, value: NMATrafficPenaltyMode)] = [
        ("msdkui_disabled".localized, NMATrafficPenaltyMode.disabled),
        ("msdkui_optimal".localized, NMATrafficPenaltyMode.optimal),
        ("msdkui_avoid_long_term_closures".localized, NMATrafficPenaltyMode.avoidLongTermClosures)
    ]

    /// Convenience property to access the underlying `SingleChoiceOptionItem` item.
    var item: SingleChoiceOptionItem {
        return optionItems[0] as! SingleChoiceOptionItem
    }

    /// Creates the spec for the underlying `SingleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = TrafficOptionsPanel.options.map { $0.label }

        // Create the spec for the option item
        specs = [OptionItemSpec.makeSingleChoiceOptionItem(title: nil, labels: labels)]
    }

    /// This method is called after each update. It updates the `trafficPenaltyMode` property of
    /// the underlying `NMADynamicPenalty` object.
    private func onChanged(_: OptionItem) {
        dynamicPenalty.trafficPenaltyMode = NMATrafficPenaltyMode(rawValue: TrafficOptionsPanel.options[item.selectedItemIndex].value.rawValue)!

        // Has any callback set?
        onOptionChanged?(item)
    }
}
