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

/// This class holds all the visuals for a panel title.
open class TitleItem: NSObject {

    // MARK: - Properties

    /// Title item background color.
    public var backgroundColor: UIColor? {
        didSet { view.backgroundColor = backgroundColor }
    }

    /// Title item line color.
    public var lineColor: UIColor? {
        didSet { lineView.backgroundColor = lineColor }
    }

    /// Title item text color.
    public var textColor: UIColor? {
        didSet { label.textColor = textColor }
    }

    /// The view for the title and the switch showing on/off the panel.
    var view: UIView!

    /// The line view.
    var lineView: UIView!

    /// The title label.
    @objc dynamic var label: UILabel!

    /// The label observer.
    private var labelObservation: NSKeyValueObservation?

    // MARK: - Public

    /// Loads the related nib file and creates the title.
    override public init() {
        // Loads the nib file and create the title view
        let nibFile = UINib(nibName: String(describing: TitleItem.self), bundle: .MSDKUI)

        // Creates the title view
        view = nibFile.instantiate(withOwner: nil).first as? UIView

        // We use autolayout
        view.translatesAutoresizingMaskIntoConstraints = false

        // The title height should remain constant
        let heightConstraint = NSLayoutConstraint(item: view as Any, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute,
                                                  multiplier: 1, constant: view.bounds.size.height)
        heightConstraint.priority = UILayoutPriority(rawValue: 999) // iOS10 warns when the title is hidden
        view.addConstraint(heightConstraint)

        // Line view for the border
        lineView = view.viewWithTag(1000)

        // Sets up the title
        label = view.viewWithTag(1001) as? UILabel

        super.init()

        setUpStyle()
        setAccessibility()
    }

    // MARK: - Private

    /// Sets up item style.
    private func setUpStyle() {
        view.backgroundColor = .colorForegroundLight
        lineView.backgroundColor = .colorDivider
        label.textColor = .colorForeground
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        // The view is the only accessibility element
        view.accessibilityTraits = .header
        view.accessibilityIdentifier = "MSDKUI.TitleItem.view"

        // Ignores the label for accessibility
        view.isAccessibilityElement = true
        label.isAccessibilityElement = false

        // Updates the view's `accessibilityLabel` whenever the label `text` is updated
        labelObservation = observe(\.label.text, options: [.new]) { [weak self] _, change in
            self?.view.accessibilityLabel = change.newValue as? String
        }
    }
}
