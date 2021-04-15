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

final class GuidanceSpeedLimitSettingsViewController: SettingsViewController<GuidanceSpeedLimitSettingsViewController.Settings> {
    struct Settings {
        var speedLimit: Measurement<UnitSpeed>?
        var unit: UnitSpeed
        var speedLimitTextColor: UIColor
        var backgroundImage: UIImage?
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "km/h, red",
                configuration: Settings(
                    speedLimit: Measurement(value: 42, unit: .kilometersPerHour),
                    unit: .kilometersPerHour,
                    speedLimitTextColor: .red,
                    backgroundImage: nil
                )
            ),
            SettingsItem(
                title: "mph, brown",
                configuration: Settings(
                    speedLimit: Measurement(value: 42, unit: .kilometersPerHour),
                    unit: .milesPerHour,
                    speedLimitTextColor: .brown,
                    backgroundImage: nil
                )
            ),
            SettingsItem(
                title: "km/h, black, background image",
                configuration: Settings(
                    speedLimit: Measurement(value: 42, unit: .kilometersPerHour),
                    unit: .kilometersPerHour,
                    speedLimitTextColor: .black,
                    backgroundImage: UIImage(named: "red_sign")
                )
            ),
            SettingsItem(
                title: "Without speed",
                configuration: Settings(
                    speedLimit: nil,
                    unit: .kilometersPerHour,
                    speedLimitTextColor: .red,
                    backgroundImage: nil
                )
            ),
            SettingsItem(
                title: "Without speed, background image",
                configuration: Settings(
                    speedLimit: nil,
                    unit: .kilometersPerHour,
                    speedLimitTextColor: .black,
                    backgroundImage: UIImage(named: "red_sign")
                )
            )
        ]
    }
}
