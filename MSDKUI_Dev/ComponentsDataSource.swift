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

struct ComponentEntry {
    enum ComponentPresentation: String, CustomStringConvertible {
        case intrinsic
        case constrained

        var description: String {
            switch self {
            case .intrinsic:
                return "Using Intrinsic Content Size"
            case .constrained:
                return "Using Layout Constraints"
            }
        }
    }

    let title: String
    let presentationType: ComponentPresentation

    var segueID: String {
        "\(title)_\(presentationType.rawValue)"
    }
}

final class ComponentsDataSource: NSObject, UITableViewDataSource {
    private var tableView: UITableView

    var components: [ComponentEntry] = [] {
        didSet {
            components.sort { $0.title.lowercased() < $1.title.lowercased() }
            tableView.reloadData()
        }
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.register(ComponentsCell.self, forCellReuseIdentifier: "ComponentsCell")
    }

    func component(at indexPath: IndexPath) -> ComponentEntry {
        components[indexPath.row]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        components.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as ComponentsCell

        cell.textLabel?.text = components[indexPath.row].title
        cell.detailTextLabel?.text = components[indexPath.row].presentationType.description

        return cell
    }
}
