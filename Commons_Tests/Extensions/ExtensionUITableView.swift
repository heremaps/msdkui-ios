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

import UIKit

extension UITableView {
    /// Returns all the index paths from a table view.
    ///
    /// - Returns: An array of index paths.
    func indexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []

        for section in 0 ..< numberOfSections {
            for row in 0 ..< numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
        }

        return indexPaths
    }
}
