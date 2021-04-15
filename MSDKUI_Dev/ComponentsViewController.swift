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

final class ComponentsViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var segmentedControl: UISegmentedControl!

    private var dataSource: ComponentsDataSource?
    private let allComponents: [ComponentEntry] = [
        ComponentEntry(title: "GuidanceEstimatedArrivalView", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceEstimatedArrivalView", presentationType: .constrained),
        ComponentEntry(title: "GuidanceSpeedView", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceSpeedView", presentationType: .constrained),
        ComponentEntry(title: "GuidanceSpeedLimitView", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceSpeedLimitView", presentationType: .constrained),
        ComponentEntry(title: "GuidanceNextManeuverView", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceNextManeuverView", presentationType: .constrained),
        ComponentEntry(title: "GuidanceManeuverView", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceManeuverView", presentationType: .constrained),
        ComponentEntry(title: "GuidanceStreetLabel", presentationType: .intrinsic),
        ComponentEntry(title: "GuidanceStreetLabel", presentationType: .constrained),
        ComponentEntry(title: "ManeuverItemView", presentationType: .intrinsic),
        ComponentEntry(title: "ManeuverItemView", presentationType: .constrained)
    ]

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = ComponentsDataSource(tableView: tableView)
        dataSource?.components = allComponents

        tableView.dataSource = dataSource
        tableView.backgroundColor = UIColor(named: "colorBackgroundLight")
        tableView.hideEmptyCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - Private

    @IBAction private func filterComponents(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            dataSource?.components = allComponents.filter { $0.presentationType == .intrinsic }

        case 2:
            dataSource?.components = allComponents.filter { $0.presentationType == .constrained }

        default:
            dataSource?.components = allComponents
        }
    }
}

// MARK: - UITableViewDelegate

extension ComponentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let component = dataSource?.component(at: indexPath) else {
            return
        }

        performSegue(withIdentifier: component.segueID, sender: nil)
    }
}
