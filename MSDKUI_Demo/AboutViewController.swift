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

import UIKit

final class AboutViewController: UIViewController {

    // MARK: - Outlets

    /// The dashboard table view.
    @IBOutlet private(set) weak var tableView: UITableView!

    /// The exist button.
    @IBOutlet private(set) weak var exitButton: UIBarButtonItem!

    /// The view controller's navigation item.
    @IBOutlet private(set) weak var titleItem: UINavigationItem!

    // MARK: - Public properties

    /// The table view data source.
    let tableViewDataSource = AboutTableViewDataSource()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItems()
        setUpTableView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    /// Dismisses the view controller when the exit button is tapped.
    ///
    /// - Parameter sender: The exit button tapped.
    @IBAction private func dismissViewController(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
}
