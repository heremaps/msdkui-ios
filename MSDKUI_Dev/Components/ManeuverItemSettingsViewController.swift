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

import MSDKUI
import UIKit

final class ManeuverItemSettingsViewController: SettingsViewController<ManeuverItemSettingsViewController.Settings> {
    struct Settings {
        var icon: UIImage?
        var iconTintColor: UIColor?
        var instructions: String?
        var instructionsTextColor: UIColor?
        var address: String?
        var addressTextColor: UIColor?
        var distance: Measurement<UnitLength>?
        var distanceTextColor: UIColor?

        init(
            icon: UIImage?,
            iconTintColor: UIColor? = .colorForeground,
            instructions: String?,
            instructionsTextColor: UIColor? = .colorForeground,
            address: String?,
            addressTextColor: UIColor? = .colorForegroundSecondary,
            distance: Measurement<UnitLength>?,
            distanceTextColor: UIColor? = .colorForegroundSecondary
        ) {
            self.icon = icon
            self.iconTintColor = iconTintColor
            self.instructions = instructions
            self.instructionsTextColor = instructionsTextColor
            self.address = address
            self.addressTextColor = addressTextColor
            self.distance = distance
            self.distanceTextColor = distanceTextColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "Without any value",
                configuration: Settings(
                    icon: nil,
                    instructions: nil,
                    address: nil,
                    distance: nil
                )
            ),
            SettingsItem(
                title: "With all values (short instruction)",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "Short instruction!",
                    address: "Fuubarstrasse",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "With all values (long instruction)",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "This is a very very very long instruction!",
                    address: "Fuubarstrasse",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "With all values (long address)",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "Short instruction!",
                    address: "This is a very very very long address line!",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "With all values (long instruction and address)",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "This is a very very very long instruction!",
                    address: "This is a very very very long address line!",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "Without icon",
                configuration: Settings(
                    icon: nil,
                    instructions: "Short instruction!",
                    address: "Fuubarstrasse",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "Without instructions",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: nil,
                    address: "Fuubarstrasse",
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "Without address",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "Short instruction!",
                    address: nil,
                    distance: Measurement(value: 50, unit: .meters)
                )
            ),
            SettingsItem(
                title: "Without distance",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "Short instruction!",
                    address: "Fuubarstrasse",
                    distance: nil
                )
            ),
            SettingsItem(
                title: "Without address and distance",
                configuration: Settings(
                    icon: UIImage(named: "red_sign"),
                    instructions: "Short instruction!",
                    address: nil,
                    distance: nil
                )
            ),
            SettingsItem(
                title: "With custom colors (blue, green, red, black)",
                configuration: Settings(
                    icon: UIImage(named: "red_sign")?.withRenderingMode(.alwaysTemplate),
                    iconTintColor: .blue,
                    instructions: "Short instruction!",
                    instructionsTextColor: .green,
                    address: "Fuubarstrasse",
                    addressTextColor: .red,
                    distance: Measurement(value: 50, unit: .meters),
                    distanceTextColor: .black
                )
            )
        ]
    }
}
