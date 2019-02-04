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
        var addressLabelText: String?
        var distanceLabelText: String?
        var visibleSections: ManeuverItemView.Section
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(title: "Without any value and all sections visible",
                         configuration: Settings(iconImageViewImage: nil,
                                                 instructionLabelText: nil,
                                                 addressLabelText: nil,
                                                 distanceLabelText: nil,
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (short instruction)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (long instruction)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "This is a very very very long instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (long address)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "This is a very very very long address line!",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .all)),
            SettingsItem(title: "With all values (long instruction and address)",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "This is a very very very long instruction!",
                                                 addressLabelText: "This is a very very very long address line!",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .all)),
            SettingsItem(title: "visibleSections = .icon",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .icon)),
            SettingsItem(title: "visibleSections = .instructions",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .instructions)),
            SettingsItem(title: "visibleSections = .address",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .address)),
            SettingsItem(title: "visibleSections = .distance",
                         configuration: Settings(iconImageViewImage: UIImage(named: "red_sign"),
                                                 instructionLabelText: "Short instruction!",
                                                 addressLabelText: "Fuubarstrasse",
                                                 distanceLabelText: "10 km",
                                                 visibleSections: .distance))
        ]
    }
}
