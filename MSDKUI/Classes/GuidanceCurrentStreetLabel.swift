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

import Foundation
import UIKit

/// Label for displaying the current street name,
/// which depends on position and map tracking data.
@IBDesignable open class GuidanceCurrentStreetLabel: UILabel {

    // MARK: - Public properties

    /// Sets the content's insets.
    open var contentsInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Background color of label when it's accented.
    open var accentBackgroundColor: UIColor = .colorPositive {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Background color of label when it's not accented.
    open var plainBackgroundColor: UIColor = .colorForegroundSecondary {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Sets the background color.
    /// If `true` it uses `accentBackgroundColor`, otherwise `plainBackgroundColor` is used.
    open var isAccented = true {
        didSet {
            updateBackgroundColor()
        }
    }

    /// Sets text of label that should be displayed when `isLookingForPosition` is `true`.
    open var lookingForPositionText: String? {
        didSet {
            if isLookingForPosition {
                text = lookingForPositionText
            }
        }
    }

    /// Sets the state to "looking for position".
    ///
    /// When set to `true` the label sets it's `isHidden` property to `true`,
    /// uses `plainBackgroundColor` as it's `backgroundColor` and sets `lookingForPositionText` as it's `text`.
    ///
    /// When set to `false` the label sets it's `isHidden` property to `false`,
    /// uses `accentBackgroundColor` as it's `backgroundColor` and sets it's `text` property `nil`.
    ///
    /// - Note: When this property is set, `text` property is invalidated and should be configured again.
    open var isLookingForPosition = false {
        didSet {
            updateIsLookingForPosition()
        }
    }

    // MARK: - Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    // MARK: UIEdgeInsets

    override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = UIEdgeInsetsInsetRect(bounds, contentsInsets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        let negatedInsets = UIEdgeInsets(top: -contentsInsets.top, left: -contentsInsets.left,
                                         bottom: -contentsInsets.bottom, right: -contentsInsets.right)
        return UIEdgeInsetsInsetRect(textRect, negatedInsets)
    }

    override open func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, contentsInsets))
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
        layer.cornerRadius = 16

        // Background color
        updateBackgroundColor()

        // Accessibility
        accessibilityIdentifier = String(reflecting: GuidanceCurrentStreetLabel.self)
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
}
