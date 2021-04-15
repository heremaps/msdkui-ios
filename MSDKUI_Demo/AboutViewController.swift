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

final class AboutViewController: UIViewController {
    // MARK: - Properties

    /// The dashboard table view.
    @IBOutlet private(set) var tableView: UITableView!

    /// The exist button.
    @IBOutlet private(set) var exitButton: UIBarButtonItem!

    /// The view controller's navigation item.
    @IBOutlet private(set) var titleItem: UINavigationItem!

    /// The table view data source.
    let tableViewDataSource = AboutTableViewDataSource()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItems()
        setUpTableView()
    }

    // MARK: - Private

    /// Sets up navigation items.
    private func setUpNavigationItems() {
        titleItem.title = "msdkui_app_about".localized
        exitButton.title = "msdkui_app_exit".localized
    }

    /// Sets up the about table view.
    private func setUpTableView() {
        tableView.separatorColor = .colorHint
        tableView.dataSource = tableViewDataSource
        tableView.reloadData()
    }

    /// Dismisses the view controller when the exit button is tapped.
    ///
    /// - Parameter sender: The exit button tapped.
    @IBAction private func dismissViewController(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
