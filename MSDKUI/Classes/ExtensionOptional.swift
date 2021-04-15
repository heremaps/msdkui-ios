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

/// Extension for optional `String`.
public extension Optional where Wrapped == String {

    /// This method is an adaptation of isEmpty() method for the `Optional String`.
    /// Note that it ignores the whitespace content when checking for emptiness.
    /// For example, "  \t  ".hasContent is false. For a nil String, hasContent
    /// returns false, too.
    ///
    /// - Returns: True if the string is neither nil nor empty and false otherwise.
    var hasContent: Bool {
        guard let strongSelf = self else {
            return false
        }

        return strongSelf.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
}
