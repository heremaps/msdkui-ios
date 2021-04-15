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

/// Generic button with predefined set of icons.
@IBDesignable class IconButton: UIButton {
    // MARK: - Types

    /// An enum that defines the available Button types.
    enum IconButtonType: String {
        /// Add button
        case add

        /// Collapse button
        case collapse

        /// Drag button
        case drag

        /// Expand button
        case expand

        /// Options button
        case options

        /// Remove button
        case remove

        /// Swap button
        case swap

        // MARK: - Properties

        /// Returns the localized `accessibilityLabel` string.
        var accessibilityLabel: String {
            switch self {
            case .add:
                return "msdkui_app_add".localized

            case .collapse:
                return "msdkui_app_collapse".localized

            case .drag:
                return "msdkui_app_drag".localized

            case .expand:
                return "msdkui_app_expand".localized

            case .options:
                return "msdkui_app_options".localized

            case .remove:
                return "msdkui_app_remove".localized

            case .swap:
                return "msdkui_app_swap".localized
            }
        }

        /// Returns the nonlocalized `accessibilityIdentifier` string.
        var accessibilityIdentifier: String {
            "IconButton.\(rawValue)"
        }
    }

    // MARK: - Properties

    /// Type of this button. The default value is .add.
    var type: IconButtonType = .add {
        didSet {
            // Reflect the update
            updateImage()
            setAccessibility()
        }
    }

    /// The proxy property to make the type property accessible
    /// from the Interface Builder.
    ///
    /// - Important: It shadows the type property.
    /// - Important: When setting the type property and the string does not represent an enum
    ///              value, the type remains unchanged.
    @IBInspectable var typeProxy: String? {
        get {
            type.rawValue
        }
        set {
            if let value = newValue,
                let type = IconButtonType(rawValue: value) {
                self.type = type
            }
        }
    }

    // MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    // MARK: - Private

    /// Initializes the contents of this view.
    private func setUp() {
        // Settings
        setTitle(nil, for: .normal)
        contentMode = .center
        imageView?.contentMode = .scaleAspectFill

        updateStyle()

        // Load the image for the default type
        updateImage()
    }

    /// Updates the style for the visuals.
    private func updateStyle() {
        backgroundColor = UIColor.clear
        tintColor = UIColor.colorForegroundLight
    }

    /// Updates the foreground image based on the button type.
    ///
    /// - Important: Unlike the background image, the foreground image is not stretchable.
    private func updateImage() {
        // Note that the image is rendered in the template mode
        let image = UIImage(named: "IconButton.\(type.rawValue)")

        setImage(image, for: .normal)
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityLabel = type.accessibilityLabel
        accessibilityHint = nil
        accessibilityIdentifier = type.accessibilityIdentifier + "Button"

        // As the imageView gets the button's accessibilityIdentifier, which cause
        // problems while testing, its accessibilityIdentifier must be set differently
        imageView?.accessibilityIdentifier = type.accessibilityIdentifier + "Image"
    }
}
