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

final class GuidanceStreetSettingsViewController: SettingsViewController<GuidanceStreetSettingsViewController.Settings> {
    struct Settings {
        var text: String?
        var accentBackgroundColor: UIColor
        var plainBackgroundColor: UIColor
        var isAccented: Bool
        var font: UIFont?
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "With address, accented true",
                configuration: Settings(
                    text: "Fuubarstrasse",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: true,
                    font: nil
                )
            ),
            SettingsItem(
                title: "With very long address, accented true",
                configuration: Settings(
                    text: "12345 Fuubarstrasse North Tower Building 2 Unit 1",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: true,
                    font: nil
                )
            ),
            SettingsItem(
                title: "Looking for position (custom msg)",
                configuration: Settings(
                    text: "👀 for position",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: true,
                    font: nil
                )
            ),
            SettingsItem(
                title: "Looking for position (font size: 11 points)",
                configuration: Settings(
                    text: "👀 for position",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: true,
                    font: .systemFont(ofSize: 11)
                )
            ),
            SettingsItem(
                title: "Looking for position (font size: 22 points)",
                configuration: Settings(
                    text: "👀 for position",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: true,
                    font: .systemFont(ofSize: 22)
                )
            ),
            SettingsItem(
                title: "With address, accented: false",
                configuration: Settings(
                    text: "Fuubarstrasse",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: false,
                    font: nil
                )
            ),
            SettingsItem(
                title: "Looking for position, accented: false",
                configuration: Settings(
                    text: "👀 for position",
                    accentBackgroundColor: .colorPositive,
                    plainBackgroundColor: .colorForegroundSecondary,
                    isAccented: false,
                    font: nil
                )
            )
        ]
    }
}
