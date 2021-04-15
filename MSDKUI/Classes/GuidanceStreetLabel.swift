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

import Foundation
import UIKit

/// Label for displaying the street name,
/// which depends on position and map tracking data.
@IBDesignable open class GuidanceStreetLabel: UILabel {

    // MARK: - Properties

    /// Sets the content insets.
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    /// Background color of the label when it's accented.
    /// The default value is `UIColor.colorPositive`.
    public var accentBackgroundColor: UIColor = .colorPositive {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Background color of label when it's not accented.
    /// The default value is `UIColor.colorForegroundSecondary`.
    public var plainBackgroundColor: UIColor = .colorForegroundSecondary {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Sets the background color.
    /// If `true` it uses `accentBackgroundColor`, otherwise `plainBackgroundColor` is used.
    /// The default value is `true`.
    public var isAccented = true {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Sets the text of the label that should be displayed when `isLookingForPosition` is `true`.
    public var lookingForPositionText: String? {
        didSet {
            if isLookingForPosition {
                text = lookingForPositionText
            }
        }
    }

    /// Sets the state to "looking for position".
    ///
    /// When set to `true`, the label sets its `isHidden` property to `true`,
    /// uses `plainBackgroundColor` as its `backgroundColor` and sets `lookingForPositionText` as its `text`.
    ///
    /// When set to `false`, the label sets its `isHidden` property to `false`,
    /// uses `accentBackgroundColor` as its `backgroundColor` and sets its `text` property `nil`.
    ///
    /// - Note: When this property is set, `text` property is invalidated and should be configured again.
    ///
    /// The default value is `false`.
    public var isLookingForPosition = false {
        didSet {
            updateIsLookingForPosition()
        }
    }

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: contentInsets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        let negatedInsets = UIEdgeInsets(top: -contentInsets.top, left: -contentInsets.left,
                                         bottom: -contentInsets.bottom, right: -contentInsets.right)
        return textRect.inset(by: negatedInsets)
    }

    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        applyRoundedCorners()
    }

    // MARK: - Private

    /// Initializes the contents of this view.
    private func setUp() {
        // Style
        font = .preferredFont(forTextStyle: .subheadline)
        clipsToBounds = true
        textAlignment = .center
        numberOfLines = 1
        textColor = .colorForegroundLight
        applyRoundedCorners()

        // Background color
        updateBackgroundColor()

        // Accessibility
        accessibilityIdentifier = String(reflecting: GuidanceStreetLabel.self)
    }

    private func updateIsLookingForPosition() {
        if isLookingForPosition {
            isAccented = false
            text = lookingForPositionText
            isHidden = false
        } else {
            isHidden = true
            text = nil
            isAccented = true
        }
    }

    private func updateBackgroundColor() {
        backgroundColor = isAccented ? accentBackgroundColor : plainBackgroundColor
    }

    private func applyRoundedCorners() {
        layer.cornerRadius = bounds.height / 2
    }
}
