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

import Foundation

/// `MeasurementFormatter` extensions.
public extension MeasurementFormatter {
    /// Returns a `MeasurementFormatter` for displaying units using current locale.
    static let currentMediumUnitFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.locale = .current
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
}

/// Internal `MeasurementFormatter` extensions.
extension MeasurementFormatter {
    /// Returns a `MeasurementFormatter` for displaying speed.
    static let shortSpeedFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        formatter.locale = .current
        formatter.numberFormatter = .roundUpFormatter
        return formatter
    }()

    /// Returns a `MeasurementFormatter` for reading the speed.
    static let longSpeedFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .long
        formatter.locale = .current
        formatter.numberFormatter = .roundUpFormatter
        return formatter
    }()
}
