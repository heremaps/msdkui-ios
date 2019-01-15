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

@testable import MSDKUI
import UIKit

final class GuidanceManeuverSettingsViewController: SettingsViewController<GuidanceManeuverSettingsViewController.Settings> {

    struct Settings {
        var state: GuidanceManeuverView.State
        var foregroundColor: UIColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(title: ".data, with all data properties",
                         configuration: Settings(state: .data(.allProperties), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, without maneuver icon",
                         configuration: Settings(state: .data(.withoutManeuverIcon), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, without distance",
                         configuration: Settings(state: .data(.withoutDistance), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, without info1",
                         configuration: Settings(state: .data(.withoutInfo1), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, without into2",
                         configuration: Settings(state: .data(.withoutInfo2), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, without road icon",
                         configuration: Settings(state: .data(.withoutRoadIcon), foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".data, all properties, red",
                         configuration: Settings(state: .data(.allProperties), foregroundColor: .red)),
            SettingsItem(title: ".noData",
                         configuration: Settings(state: .noData, foregroundColor: .colorForegroundLight)),
            SettingsItem(title: ".updating",
                         configuration: Settings(state: .updating, foregroundColor: .colorForegroundLight))
        ]
    }
}

// MARK: - Private

private extension GuidanceManeuverData {

    static let allProperties = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: "Useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutManeuverIcon = GuidanceManeuverData(
        maneuverIcon: nil,
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: "Useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutDistance = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: nil,
        info1: "Useful information 1",
        info2: "Useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutInfo1 = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: nil,
        info2: "Useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutInfo2 = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: nil,
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutRoadIcon = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: "Useful information 2",
        nextRoadIcon: nil
    )
}
