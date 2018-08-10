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

/// The base class for all the panels containing set of options.
open class OptionsPanel: UIView {
    /// The optional panel title.
    ///
    /// - Important: When it is set, the `titleItem` property is set
    ///              and the title is displayed at the top of the panel.
    @IBInspectable public var title: String? {
        didSet {
            titleItem = TitleItem()
            titleItem!.label.text = title

            // Make sure it is placed at the top
            stackView.insertArrangedSubview(titleItem!.view, at: 0)

            // Update the vertical content height
            intrinsicContentHeight += titleItem!.view.frame.size.height
            invalidateIntrinsicContentSize()
        }
    }

    /// All the available option item specs that are used to build the available option items.
    public var specs: [OptionItemSpec] = [] {
        didSet {
            // Reflect the update
            makeItems()
        }
    }

    /// The callback which is fired when an option item is changed.
    public var onOptionChanged: ((OptionItem) -> Void)?

    /// The callback which is fired for each option item once.
    public var onOptionCreated: ((OptionItem) -> Void)? {
        didSet {
            if let onOptionCreated = onOptionCreated {
                for item in optionItems {
                    onOptionCreated(item)
                }
            }
        }
    }

    /// All the option items.
    var optionItems: [OptionItem] = []

    /// The intrinsic content height is important for supporting the scroll views.
    var intrinsicContentHeight: CGFloat = 0.0

    /// This vertical stackview holds the title view and the option views.
    let stackView = UIStackView()

    /// All the title visuals are found on this item.
    ///
    /// - Important: This is an optional property and it is created only
    ///              when the `title` property is set.
    var titleItem: TitleItem?

    /// This vertical stackview holds all the option items.
    var optionsView = UIStackView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// Makes all the option items required for the panel by setting the specs property.
    func makePanel() {
        assertionFailure("OptionsPanel class has to be subclassed.")
    }

    /// Sets up the options panel.
    ///
    /// - Important: The `onOptionCreated` and `onOptionChanged` properties are
    ///              optional.
    private func setUp() {
        // Stackview settings
        optionsView.spacing = 0.0
        optionsView.distribution = .fill
        optionsView.axis = .vertical
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.addArrangedSubview(optionsView)

        // Make the underlying option item specs
        makePanel()

        addSubviewBindToEdges(stackView)

        // Refresh
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }

    /// Makes the items based on the specs.
    private func makeItems() {
        for spec in specs {
            let item = spec.makeOptionItem()

            // Add the item to the items array & stackview
            optionItems.append(item)
            optionsView.addArrangedSubview(item)

            // Update the vertical content height
            intrinsicContentHeight += item.intrinsicContentSize.height
        }

        invalidateIntrinsicContentSize()
    }
}
