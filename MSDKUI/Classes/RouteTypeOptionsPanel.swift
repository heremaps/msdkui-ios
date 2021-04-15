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

/// An options panel for displaying the route type options of a routing mode.
///
/// - SeeAlso: `NMARoutingMode.routingType`
@IBDesignable open class RouteTypeOptionsPanel: OptionsPanel {

    // MARK: - Properties

    /// A string that can be used to represent the panel.
    public static let name = "msdkui_route_type_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects its `routingType` properties and
    /// sets the `selectedItemIndex` based on it.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                // One-by-one check
                for index in 0 ..< RouteTypeOptionsPanel.options.count where RouteTypeOptionsPanel.options[index].value == routingMode.routingType {
                    item?.selectedItemIndex = index
                    break
                }

                // Set the item delegate
                item?.delegate = self
            }
        }
    }

    /// The delegate object is responsible for customizing the panel.
    public weak var pickerDelegate: PickerViewDelegate? {
        didSet {
            item?.pickerDelegate = pickerDelegate
        }
    }

    /// All the label/value option pairs that the panel supports.
    ///
    /// - Important: The options are listed in the declaration order.
    static let options: [(label: String, value: NMARoutingType)] = [
        ("msdkui_shortest".localized, NMARoutingType.shortest),
        ("msdkui_balanced".localized, NMARoutingType.balanced),
        ("msdkui_fastest".localized, NMARoutingType.fastest)
    ]

    /// Convenience property to access the underlying `SingleChoiceOptionItem` item.
    private var item: SingleChoiceOptionItem? {
        optionItems.first as? SingleChoiceOptionItem
    }

    // MARK: - Public

    /// Creates the spec for the underlying `SingleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = RouteTypeOptionsPanel.options.map { $0.label }

        // Creates the spec for the option item
        specs = [OptionItemSpec.makeSingleChoiceOptionItem(title: nil, labels: labels)]
    }
}

// MARK: - OptionItemDelegate

extension RouteTypeOptionsPanel: OptionItemDelegate {

    public func optionItemDidChange(_ item: OptionItem) {
        guard let singleChoiceOptionItem = item as? SingleChoiceOptionItem else {
            return
        }

        if let routingType = NMARoutingType(rawValue: RouteTypeOptionsPanel.options[singleChoiceOptionItem.selectedItemIndex].value.rawValue) {
            routingMode.routingType = routingType
        }

        // Notifies the delegate
        delegate?.optionsPanel(self, didChangeTo: item)
    }
}
