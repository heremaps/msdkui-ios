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

final class GuidanceEstimatedArrivalSettingsViewController: SettingsViewController<GuidanceEstimatedArrivalSettingsViewController.Settings> {
    struct Settings {
        var estimatedTimeOfArrival: Date?
        var estimatedTimeOfArrivalFormatter: DateFormatter
        var duration: Measurement<UnitDuration>?
        var durationFormatter: MeasurementFormatter
        var distance: Measurement<UnitLength>?
        var distanceFormatter: MeasurementFormatter
        var textAligment: NSTextAlignment
        var primaryInfoTextColor: UIColor
        var secondaryInfoTextColor: UIColor
    }

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
            SettingsItem(
                title: "Without properties",
                configuration: Settings(
                    estimatedTimeOfArrival: nil,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: nil,
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: nil,
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "With all properties",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Without time of arrival",
                configuration: Settings(
                    estimatedTimeOfArrival: nil,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Without duration",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: nil,
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Without distance",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: nil,
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Left aligned, red, green",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .left,
                    primaryInfoTextColor: .red,
                    secondaryInfoTextColor: .green
                )
            ),
            SettingsItem(
                title: "Center aligned, brown, orange",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .brown,
                    secondaryInfoTextColor: .orange
                )
            ),
            SettingsItem(
                title: "Right aligned, blue, purple",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .right,
                    primaryInfoTextColor: .blue,
                    secondaryInfoTextColor: .purple
                )
            ),
            SettingsItem(
                title: "Long date formatter (.timeStyle = .long)",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentLongTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: .currentMediumUnitFormatter,
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: .currentMediumUnitFormatter,
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            ),
            SettingsItem(
                title: "Basic measurement formatter (MeasurementFormatter())",
                configuration: Settings(
                    estimatedTimeOfArrival: .distantFuture,
                    estimatedTimeOfArrivalFormatter: .currentShortTimeFormatter,
                    duration: Measurement(value: 17.1, unit: .hours),
                    durationFormatter: MeasurementFormatter(),
                    distance: Measurement(value: 33, unit: .kilometers),
                    distanceFormatter: MeasurementFormatter(),
                    textAligment: .center,
                    primaryInfoTextColor: .colorForeground,
                    secondaryInfoTextColor: .colorForegroundSecondary
                )
            )
        ]
    }
}

// MARK: - Private

private extension DateFormatter {
    static let currentLongTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
}
