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

@testable import MSDKUI
import UIKit

final class GuidanceManeuverSettingsViewController: SettingsViewController<GuidanceManeuverSettingsViewController.Settings> {
    struct Settings {
        var state: GuidanceManeuverView.State
        var axis: NSLayoutConstraint.Axis
        var foregroundColor: UIColor
        var highlightManeuver: Bool
    }

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: ".data without properties, .horizontal",
                configuration: Settings(
                    state: .data(.allNill),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with all data properties, .horizontal",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without maneuver icon, .horizontal",
                configuration: Settings(
                    state: .data(.withoutManeuverIcon),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without distance, .horizontal",
                configuration: Settings(
                    state: .data(.withoutDistance),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without info1, .horizontal",
                configuration: Settings(
                    state: .data(.withoutInfo1),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without into2, .horizontal",
                configuration: Settings(
                    state: .data(.withoutInfo2),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without road icon, .horizontal",
                configuration: Settings(
                    state: .data(.withoutRoadIcon),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with all properties, red, .horizontal",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .horizontal,
                    foregroundColor: .red,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with highlighted info2, .horizontal",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: true
                )
            ),
            SettingsItem(
                title: ".noData, .horizontal",
                configuration: Settings(
                    state: .noData,
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".updating, .horizontal",
                configuration: Settings(
                    state: .updating,
                    axis: .horizontal,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without properties, .vertical",
                configuration: Settings(
                    state: .data(.allNill),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with all data properties, .vertical",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without maneuver icon, .vertical",
                configuration: Settings(
                    state: .data(.withoutManeuverIcon),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without distance, .vertical",
                configuration: Settings(
                    state: .data(.withoutDistance),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without info1, .vertical",
                configuration: Settings(
                    state: .data(.withoutInfo1),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without into2, .vertical",
                configuration: Settings(
                    state: .data(.withoutInfo2),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data without road icon, .vertical",
                configuration: Settings(
                    state: .data(.withoutRoadIcon),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with all properties, red, .vertical",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .vertical,
                    foregroundColor: .red,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".data with highlighted info2, .vertical",
                configuration: Settings(
                    state: .data(.allProperties),
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: true
                )
            ),
            SettingsItem(
                title: ".noData, .vertical",
                configuration: Settings(
                    state: .noData,
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            ),
            SettingsItem(
                title: ".updating, .vertical",
                configuration: Settings(
                    state: .updating,
                    axis: .vertical,
                    foregroundColor: .colorForegroundLight,
                    highlightManeuver: false
                )
            )
        ]
    }
}

// MARK: - Private

private extension GuidanceManeuverData {
    static let allProperties = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: "Very very long useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutManeuverIcon = GuidanceManeuverData(
        maneuverIcon: nil,
        distance: Measurement(value: 4, unit: .kilometers),
        info1: "Useful information 1",
        info2: "Very very long useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutDistance = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: nil,
        info1: "Useful information 1",
        info2: "Very very long useful information 2",
        nextRoadIcon: UIImage(named: "red_sign")
    )

    static let withoutInfo1 = GuidanceManeuverData(
        maneuverIcon: UIImage(named: "red_sign"),
        distance: Measurement(value: 4, unit: .kilometers),
        info1: nil,
        info2: "Very very long useful information 2",
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
        info2: "Very very long useful information 2",
        nextRoadIcon: nil
    )

    static let allNill = GuidanceManeuverData(
        maneuverIcon: nil,
        distance: nil,
        info1: nil,
        info2: nil,
        nextRoadIcon: nil
    )
}
