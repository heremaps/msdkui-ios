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

/// An options panel for displaying the tunnel options of the underlying `NMARoutingMode`.
///
/// - SeeAlso: `NMARoutingMode.tunnelCategory`
@IBDesignable open class TunnelOptionsPanel: OptionsPanel {
    /// A string that can be used to represent the panel.
    public static var name = "msdkui_tunnels_allowed_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects its `tunnelCategory` properties and
    /// sets the `selectedItemIndex` based on it.
    ///
    /// - Important: Sets the `onChanged` callback of the underlying option item to monitor
    ///              the updates afterwards.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                // One-by-one check
                for index in 0 ..< TunnelOptionsPanel.options.count where TunnelOptionsPanel.options[index].value == routingMode.tunnelCategory {
                    item.selectedItemIndex = index
                    break
                }

                // Set the onChanged callback to monitor the updates afterwards
                item.onChanged = onChanged
            }
        }
    }

    /// The delegate object is responsible for customizing the panel.
    public var delegate: PickerViewDelegate! {
        didSet {
            item.delegate = delegate
        }
    }

    /// All the label/value option pairs that the panel supports.
    ///
    /// - Important: The options are listed in the declaration order.
    static let options: [(label: String, value: NMATunnelCategory)] = [
        ("msdkui_none".localized, NMATunnelCategory.none),
        ("msdkui_tunnel_cat_b".localized, NMATunnelCategory.b),
        ("msdkui_tunnel_cat_c".localized, NMATunnelCategory.c),
        ("msdkui_tunnel_cat_d".localized, NMATunnelCategory.d),
        ("msdkui_tunnel_cat_e".localized, NMATunnelCategory.e)
    ]

    /// Convenience property to access the underlying `SingleChoiceOptionItem` item.
    var item: SingleChoiceOptionItem {
        return optionItems[0] as! SingleChoiceOptionItem
    }

    /// Creates the spec for the underlying `SingleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = TunnelOptionsPanel.options.map { $0.label }

        // Create the spec for the option item
        specs = [OptionItemSpec.makeSingleChoiceOptionItem(title: nil, labels: labels)]
    }

    /// This method is called after each update. It updates the `tunnelCategory` property of
    /// the underlying `NMARoutingMode` object.
    private func onChanged(_: OptionItem) {
        routingMode.tunnelCategory = NMATunnelCategory(rawValue: TunnelOptionsPanel.options[item.selectedItemIndex].value.rawValue)!

        // Has any callback set?
        onOptionChanged?(item)
    }
}
