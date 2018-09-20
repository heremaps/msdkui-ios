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

/// Class containing helper utility methods.
class Utils { // swiftlint:disable:this convenience_type
    /// Sets when to switch to meter unit.
    private static let meterThreshold = 998

    /// Sets when to use the kilometer unit with simple divide by 1000.
    private static let kilometerThreshold = 9950

    /// Converts the given distance to a String with a unit which is either mt or km.
    ///
    /// - Parameter distance: The distance to be formatted.
    /// - Returns: The stringized distance.
    static func formatDistance(_ distance: Int) -> String {
        var value: String?
        var unit: String
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        if distance < 0 { // invalid
            value = "msdkui_value_not_available".localized
            unit = "msdkui_unit_meter".localized
        } else if distance < meterThreshold {
            value = numberFormatter.string(from: NSNumber(value: distance))
            unit = "msdkui_unit_meter".localized
        } else if distance < kilometerThreshold {
            value = numberFormatter.string(from: NSNumber(value: roundToSignificantDigits(number: Double(distance / 1000), significantDigits: 2)))
            unit = "msdkui_unit_kilometer".localized
        } else {
            value = numberFormatter.string(from: NSNumber(value: round(Double(distance / 1000))))
            unit = "msdkui_unit_kilometer".localized
        }

        if let value = value {
            return String(format: "msdkui_distance_value_with_unit".localized, value, unit)
        } else {
            return String(format: "msdkui_distance_value_with_unit".localized, String(distance), "msdkui_unit_meter".localized)
        }
    }

    /// Given a number, rounds it to the specified significant digits.
    ///
    /// - Parameter number: The number to be rounded.
    /// - Parameter significantDigits: The digits to round to.
    /// - Returns: The rounded number.
    static func roundToSignificantDigits(number: Double, significantDigits: Int) -> Double {
        guard number != 0 else {
            return 0
        }

        let exponent = floor(log10(abs(number))) + 1 - Double(significantDigits)
        let factor = pow(10.0, exponent)

        return round(number / factor) * factor
    }
}
