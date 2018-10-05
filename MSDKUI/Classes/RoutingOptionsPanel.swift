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

/// An options panel for displaying the drive options of a routing mode.
///
/// - SeeAlso: `NMARoutingMode.routingOptions` property.
@IBDesignable open class RoutingOptionsPanel: OptionsPanel {

    /// A string that can be used to represent the panel.
    public static var name = "msdkui_routing_options_title".localized

    /// The underlying `NMARoutingMode` object. The panel reflects its `routingOptions` properties and
    /// sets the `selectedItemIndexes` based on it.
    ///
    /// - Important: Sets the `onChanged` callback of the underlying option item to monitor
    ///              the updates afterwards.
    public var routingMode: NMARoutingMode! {
        didSet {
            if let routingMode = routingMode {
                var selectedItemIndexes: Set<Int> = []

                // One-by-one check
                for index in 0 ..< RoutingOptionsPanel.options.count {
                    let isSelected = routingMode.routingOptions.contains(RoutingOptionsPanel.options[index].value)
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
    static let options: [(label: String, value: NMARoutingOption)] = [
        ("msdkui_avoid_toll_roads".localized, NMARoutingOption.avoidTollRoad),
        ("msdkui_avoid_tunnels".localized, NMARoutingOption.avoidTunnel),
        ("msdkui_avoid_highways".localized, NMARoutingOption.avoidHighway),
        ("msdkui_avoid_car_shuttle".localized, NMARoutingOption.avoidCarShuttleTrain),
        ("msdkui_avoid_ferries".localized, NMARoutingOption.avoidBoatFerry),
        ("msdkui_avoid_car_pool".localized, NMARoutingOption.avoidCarpool),
        ("msdkui_avoid_dirt_roads".localized, NMARoutingOption.avoidDirtRoad),
        ("msdkui_avoid_parks".localized, NMARoutingOption.avoidPark)
    ]

    /// Convenience property to access the underlying `MultipleChoiceOptionItem` item.
    var item: MultipleChoiceOptionItem {
        return optionItems[0] as! MultipleChoiceOptionItem
    }

    /// Creates the spec for the underlying `MultipleChoiceOptionItem` object.
    override func makePanel() {
        // Map the options to strings
        let labels: [String] = RoutingOptionsPanel.options.map { $0.label }

        // Create the spec for the option item
        specs = [OptionItemSpec.makeMultipleChoiceOptionItem(labels: labels)]
    }

    /// This method is called after each update. It updates the `routingOptions` property of
    /// the underlying `NMARoutingMode` object.
    ///
    /// - Parameter item: The `OptionItem` that was changed.
    func onChanged(_ item: OptionItem) {
        guard let multipleChoiceOptionItem = item as? MultipleChoiceOptionItem else {
            return
        }

        // Assume there is no selected item index
        var routingOptions = NMARoutingOption(rawValue: 0)

        // Is there any selected item index?
        if let selectedItemIndexes = multipleChoiceOptionItem.selectedItemIndexes {
            // One-by-one increment the routingOptions value
            for index in selectedItemIndexes {
                routingOptions.insert(RoutingOptionsPanel.options[index].value)
            }
        }

        // Update the value
        routingMode.routingOptions = routingOptions

        // Has any callback set?
        onOptionChanged?(item)
    }
}
