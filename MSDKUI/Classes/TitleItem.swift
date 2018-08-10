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

/// This class holds all the visuals for a panel title.
open class TitleItem {
    /// The view for the title and the switch showing on/off the panel.
    var view: UIView!

    /// The title label.
    var label: UILabel!

    /// The label observer.
    var observer: LabelObserverForAccessibility!

    /// Loads the related nib file and creates the title.
    public init() {
        // Load the nib file and create the title view
        let nibFile = UINib(nibName: String(describing: TitleItem.self), bundle: .MSDKUI)

        // Create the title view
        view = nibFile.instantiate(withOwner: nil, options: nil)[0] as! UIView

        // We use autolayout
        view.translatesAutoresizingMaskIntoConstraints = false

        // The title height should remain constant
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: .equal,
                                                  toItem: nil, attribute: NSLayoutAttribute.notAnAttribute,
                                                  multiplier: 1, constant: view.bounds.size.height)
        heightConstraint.priority = 999 // iOS10 warns when the title is hidden
        view.addConstraint(heightConstraint)

        // Line view for the border
        let lineView = view.viewWithTag(1000)!

        // Set up the title
        label = view.viewWithTag(1001) as! UILabel

        updateStyle(lineView)
        setAccessibility()
    }

    /// Updates the style for the visuals.
    func updateStyle(_ lineView: UIView) {
        view.backgroundColor = Styles.shared.titleItemBackgroundColor

        lineView.backgroundColor = Styles.shared.titleItemLineColor

        label.textColor = Styles.shared.titleItemTextColor
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        // The view is the only accessibility element
        view.accessibilityTraits = UIAccessibilityTraitHeader
        view.accessibilityIdentifier = "MSDKUI.TitleItem.view"

        // The view's accessibility label depends on the label
        observer = LabelObserverForAccessibility(label, view: view)
    }
}
