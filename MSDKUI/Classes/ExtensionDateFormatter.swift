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

/// Extension for `DateFormatter`.
public extension DateFormatter {

    /// Returns a `DateFormatter` for displaying the short time using current locale.
    static let currentShortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter
    }()
}

extension DateFormatter {

    /// Returns a dMMM 'at' HH:mm Date Formatter for current locale.
    static let dMMMHHmmFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("dMMM 'at' HH:mm")

        return formatter
    }()
}
