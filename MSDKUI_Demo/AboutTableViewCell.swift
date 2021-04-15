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

final class AboutTableViewCell: UITableViewCell {
    // MARK: - Types

    struct ViewModel {
        let title: String
        let description: String
    }

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .colorBackgroundViewLight

        textLabel?.font = .preferredFont(forTextStyle: .headline)
        textLabel?.textColor = .colorForeground

        detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        detailTextLabel?.textColor = .colorForegroundSecondary
    }

    // MARK: - Public

    func configure(with model: ViewModel) {
        textLabel?.text = model.title
        detailTextLabel?.text = model.description
    }
}
