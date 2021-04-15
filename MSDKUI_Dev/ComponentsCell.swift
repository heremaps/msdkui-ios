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

final class ComponentsCell: UITableViewCell {
    // MARK: - Life cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setUpCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpCell()
    }

    // MARK: - Private

    private func setUpCell() {
        // Colors
        textLabel?.textColor = UIColor(named: "colorForeground")
        detailTextLabel?.textColor = UIColor(named: "colorForegroundSecondary")
        selectedBackgroundColor = UIColor(named: "colorBackgroundLight")

        // Fonts
        textLabel?.font = .preferredFont(forTextStyle: .headline)
        detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
    }
}
