//
// Copyright (C) 2017-2019 HERE Europe B.V.
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
        var iconImageViewImage: UIImage?
        var instructionLabelText: String?
        var instructionLabelTextColor: UIColor?
        var addressLabelText: String?
        var addressLabelTextColor: UIColor?
        var distanceLabelText: String?
        var distanceLabelTextColor: UIColor?
        var visibleSections: ManeuverItemView.Section
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(title: "Without any value and all sections visible",
                         configuration: Settings(iconImageViewImage: nil,
                                                 instructionLabelText: nil,
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: nil,
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: nil,
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (short instruction)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (red, green, yellow)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: .red,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: .green,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: .yellow,
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (long instruction)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "This is a very very very long instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .all)),
            SettingsItem(title: "visibleSections = .icon",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .icon)),
            SettingsItem(title: "visibleSections = .instructions",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .instructions)),
            SettingsItem(title: "visibleSections = .address",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .address)),
            SettingsItem(title: "visibleSections = .distance",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 instructionLabelTextColor: nil,
                                                 addressLabelText: "Fuubarstrasse",
                                                 addressLabelTextColor: nil,
                                                 distanceLabelText: "10 km",
                                                 distanceLabelTextColor: nil,
                                                 visibleSections: .distance))
        ]
    }
}
