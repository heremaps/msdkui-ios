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

final class GuidanceNextManeuverSettingsViewController: SettingsViewController<GuidanceNextManeuverSettingsViewController.Settings> {
    struct Settings {
        var maneuverIcon: UIImage?
        var distance: Measurement<UnitLength>?
        var streetName: String?
        var distanceFormatter: MeasurementFormatter
        var foregroundColor: UIColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "Without parameters",
                configuration: Settings(
                    maneuverIcon: nil,
                    distance: nil,
                    streetName: nil,
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "With all parameters",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: "Foobarstrasse 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "With all parameters (very long address)",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: "Lorem ipsum dolor sit amet, consectetur adipiscing elit 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "With all parameters (w/ template image)",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign")?.withRenderingMode(.alwaysTemplate),
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: "Foobarstrasse 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "Without icon",
                configuration: Settings(
                    maneuverIcon: nil,
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: "Foobarstrasse 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "Without distance",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: nil,
                    streetName: "Foobarstrasse 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "Without street",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: nil,
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "Without distance and street",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: nil,
                    streetName: nil,
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .colorForegroundSecondaryLight
                )
            ),
            SettingsItem(
                title: "With all parameters in red",
                configuration: Settings(
                    maneuverIcon: UIImage(named: "red_sign"),
                    distance: Measurement(value: 12, unit: .kilometers),
                    streetName: "Foobarstrasse 123",
                    distanceFormatter: .currentMediumUnitFormatter,
                    foregroundColor: .red
                )
            )
        ]
    }
}
