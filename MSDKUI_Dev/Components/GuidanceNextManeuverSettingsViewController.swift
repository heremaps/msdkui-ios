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

final class GuidanceNextManeuverSettingsViewController: SettingsViewController<GuidanceNextManeuverSettingsViewController.Settings> {

    struct Settings {
        var maneuverIcon: UIImage?
        var distance: Measurement<UnitLength>
        var streetName: String?
        var distanceFormatter: MeasurementFormatter
        var foregroundColor: UIColor
        var textAlignment: NSTextAlignment
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(title: "Distance, left aligned, red",
                         configuration: Settings(maneuverIcon: nil,
                                                 distance: Measurement(value: 12, unit: .kilometers),
                                                 streetName: nil,
                                                 distanceFormatter: .currentMediumUnitFormatter,
                                                 foregroundColor: .red,
                                                 textAlignment: .left)),
            SettingsItem(title: "Distance, street name, left aligned, green",
                         configuration: Settings(maneuverIcon: nil,
                                                 distance: Measurement(value: 12, unit: .kilometers),
                                                 streetName: "Foobarstrasse 123",
                                                 distanceFormatter: .currentMediumUnitFormatter,
                                                 foregroundColor: .green,
                                                 textAlignment: .left)),
            SettingsItem(title: "Icon, distance, street name, left aligned",
                         configuration: Settings(maneuverIcon: UIImage(named: "red_sign"),
                                                 distance: Measurement(value: 12, unit: .kilometers),
                                                 streetName: "Foobarstrasse 123",
                                                 distanceFormatter: .currentMediumUnitFormatter,
                                                 foregroundColor: .colorForegroundSecondaryLight,
                                                 textAlignment: .left)),
            SettingsItem(title: "Icon, distance, street name, center aligned, orange",
                         configuration: Settings(maneuverIcon: UIImage(named: "red_sign"),
                                                 distance: Measurement(value: 12, unit: .kilometers),
                                                 streetName: "Foobarstrasse 123",
                                                 distanceFormatter: .currentMediumUnitFormatter,
                                                 foregroundColor: .orange,
                                                 textAlignment: .center)),
            SettingsItem(title: "Distance, street name, right aligned",
                         configuration: Settings(maneuverIcon: nil,
                                                 distance: Measurement(value: 12, unit: .kilometers),
                                                 streetName: "Foobarstrasse 123",
                                                 distanceFormatter: .currentMediumUnitFormatter,
                                                 foregroundColor: .colorForegroundSecondaryLight,
                                                 textAlignment: .right))
        ]
    }
}
