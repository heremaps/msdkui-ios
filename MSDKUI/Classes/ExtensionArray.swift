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

extension Array {
    // Moves the element from the source index to the to the destination
    // index.
    ///
    /// - Parameter from: The source index.
    /// - Parameter to: The destination index.
    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes: from \(from), to: \(to)!")

        insert(remove(at: from), at: to)
    }

    /// Creates array with specified number of repeating different values.
    /// - Parameter cloneValue: Autoclosure called to provide new array value.
    /// - Parameter count: Number of times repeat value will be called.
    init(cloneValue: @autoclosure () -> Element, count: Int) {
        self = (0..<count).map { _ in cloneValue() }
    }
}
