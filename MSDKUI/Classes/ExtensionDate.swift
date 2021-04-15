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

import Foundation

extension Date {

    /// Converts the given data to a String.
    ///
    /// - Parameter formatter: The date formatter to be used. If not provided, applies
    ///                        the "dMMM 'at' HH:mm" format.
    /// - Returns: The stringized distance.
    func formatted(_ formatter: DateFormatter = .dMMMHHmmFormatter) -> String {
        let calendar = Calendar.current
        let parameterYear = calendar.component(.year, from: self)
        let parameterMonth = calendar.component(.month, from: self)
        let parameterDay = calendar.component(.day, from: self)
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)

        // If the year is different, make sure to show the year, month, day and time.
        // Else if the month or day is different, make sure to show the month, day and time.
        // Otherwise, i.e. at the current day, show only the time.
        if parameterYear != currentYear {
            return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
        } else if parameterMonth != currentMonth || parameterDay != currentDay {
            return formatter.string(from: self)
        } else {
            return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
        }
    }
}
