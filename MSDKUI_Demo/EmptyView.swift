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

/// The view is designed to handle the cases when there is nothing to show.
/// Note that when the orientation is landscape, the image is not shown.
/// The default `.backgroundColor` is `.colorBackgroundLight`.
@IBDesignable class EmptyView: UIView {
    // MARK: - Types

    /// The view model used to populate the empty view.
    struct ViewModel {
        // MARK: - Properties

        var image: UIImage?

        var title: String

        var subtitle: String
    }

    // MARK: - Properties

    @IBOutlet private(set) var stackView: UIStackView!

    @IBOutlet private(set) var imageView: UIImageView!

    @IBOutlet private(set) var titleLabel: UILabel!

    @IBOutlet private(set) var subtitleLabel: UILabel!

    /// The default `.titleColor` is `.colorForeground`.
    var titleColor: UIColor? {
        didSet {
            titleLabel?.textColor = titleColor
        }
    }

    /// The default `.subtitleColor` is `.colorForegroundSecondaryLight`.
    var subtitleColor: UIColor? {
        didSet {
            subtitleLabel?.textColor = subtitleColor
        }
    }

    // MARK: - Life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }

    // MARK: - Public

    /// Configures the empty view.
    ///
    /// - Parameter model: The model used to configure the empty view.
    func configure(with model: ViewModel) {
        imageView.image = model.image
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }

    // MARK: - Private

    private func setUpView() {
        loadFromNib(bundle: Bundle.main)
        setUpViewAccessibility()

        // Apply the default styles
        backgroundColor = .colorBackgroundLight
        titleColor = .colorForeground
        subtitleColor = .colorForegroundSecondary
    }

    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .none
        accessibilityLabel =
            "\("msdkui_app_routeplanner_getdirections".localized), \("msdkui_app_routeplanner_startchoosingwaypoint".localized)"
        accessibilityIdentifier = "EmptyView"
    }
}
