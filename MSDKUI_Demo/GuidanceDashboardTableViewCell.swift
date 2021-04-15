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

final class GuidanceDashboardTableViewCell: UITableViewCell {
    // MARK: - Types

    struct ViewModel {
        let image: UIImage?
        let title: String?
    }

    // MARK: - Properties

    /// The image view used for the dashboard entry icon.
    @IBOutlet private(set) var iconImageView: UIImageView!

    /// The label used for the dashboard entry title.
    @IBOutlet private(set) var titleLabel: UILabel!

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .colorBackgroundViewLight
        selectedBackgroundColor = .colorBackgroundPressed

        iconImageView.tintColor = .colorForeground

        titleLabel.textColor = .colorForeground
        titleLabel.font = .preferredFont(forTextStyle: .headline)
    }

    // MARK: - Public

    func configure(with model: ViewModel) {
        iconImageView.image = model.image?.withRenderingMode(.alwaysTemplate)
        titleLabel?.text = model.title
    }
}
