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
import NMAKit
import UIKit

final class AboutTableViewDataSource: NSObject {
    // MARK: - Types

    struct Item {
        let title: String
        let description: String
    }

    // MARK: - Properties

    private let items: [Item]

    // MARK: - Public

    override init() {
        // Builds the MSDKUI and Demo application description paragraph
        let description = ["msdkui_app_about_info_part_two", "msdkui_app_about_info_part_three", "msdkui_app_about_info_part_four"]
            .map { $0.localized }
            .joined(separator: "\n\n")

        items = [
            Item(title: "msdkui_app_app_version".localized, description: Bundle.main.appVersion()),
            Item(title: "msdkui_app_ui_kit_version".localized, description: MSDKUI.Version.getString()),
            Item(title: "msdkui_app_here_sdk_version".localized, description: NMAApplicationContext.sdkVersion()),
            Item(title: "msdkui_app_about_info_part_one".localized, description: description)
        ]

        super.init()
    }

    /// Returns the item at `IndexPath`.
    ///
    /// - Parameter indexPath: The table view index path.
    /// - Returns: The item at index path.
    func item(at indexPath: IndexPath) -> Item? {
        guard 0 ..< items.count ~= indexPath.row else {
            return nil
        }

        return items[indexPath.row]
    }
}

// MARK: - UITableViewDataSource

extension AboutTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            case let cellIdentifier = String(describing: AboutTableViewCell.self),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutTableViewCell,
            let item = item(at: indexPath)
        else {
            fatalError("Failed to dequeue GuidanceDashboardTableViewCell")
        }

        cell.configure(with: AboutTableViewCell.ViewModel(title: item.title, description: item.description))

        return cell
    }
}
