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

final class GuidanceSpeedSettingsViewController: SettingsViewController<GuidanceSpeedSettingsViewController.Settings> {
    struct Settings {
        var speed: Measurement<UnitSpeed>?
        var textAligment: NSTextAlignment
        var unit: UnitSpeed
        var speedValueTextColor: UIColor
        var speedUnitTextColor: UIColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "Without speed",
                configuration: Settings(
                    speed: nil,
                    textAligment: .left,
                    unit: .kilometersPerHour,
                    speedValueTextColor: .colorForeground,
                    speedUnitTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Left aligned, km/h, red, blue",
                configuration: Settings(
                    speed: Measurement(value: 32, unit: .kilometersPerHour),
                    textAligment: .left,
                    unit: .kilometersPerHour,
                    speedValueTextColor: .red,
                    speedUnitTextColor: .blue
                )
            ),
            SettingsItem(
                title: "Center aligned, mph, brown, orange",
                configuration: Settings(
                    speed: Measurement(value: 32, unit: .kilometersPerHour),
                    textAligment: .center,
                    unit: .milesPerHour,
                    speedValueTextColor: .brown,
                    speedUnitTextColor: .orange
                )
            ),
            SettingsItem(
                title: "Right aligned, knots, blue, purple",
                configuration: Settings(
                    speed: Measurement(value: 32, unit: .kilometersPerHour),
                    textAligment: .right,
                    unit: .knots,
                    speedValueTextColor: .blue,
                    speedUnitTextColor: .purple
                )
            )
        ]
    }
}
