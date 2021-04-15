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

extension String {

    /// Default string for missing value/content.
    static let missingValue = "msdkui_value_not_available".nonlocalizable

    /// Helper property for easy localization. `"string".localized` fetches a
    /// localized string having the key "string".
    var localized: String {
        if let MSDKUIBundle = Bundle.MSDKUI {
            return NSLocalizedString(self, bundle: MSDKUIBundle, value: "", comment: "")
        } else {
            return self
        }
    }

    /// Helper property for nonlocalizable strings. `"string".nonlocalizable` fetches a
    /// nonlocalizable string having the key "string" from `Base.lproj/Nonlocalizable.strings` file.
    var nonlocalizable: String {
        if let MSDKUIBundle = Bundle.MSDKUI {
            return NSLocalizedString(self, tableName: "Nonlocalizable", bundle: MSDKUIBundle, value: "", comment: "")
        } else {
            return self
        }
    }

    /// Append a comma at the end of the string if it is not empty.
    ///
    /// - Note: This method is particularly useful when concatenating strings for an `accessibilityHint` string.
    mutating func appendComma() {
        guard !isEmpty else {
            return
        }

        append(", ")
    }
}
