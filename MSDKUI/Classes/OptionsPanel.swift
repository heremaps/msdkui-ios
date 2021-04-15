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

/// The delegate of an `OptionsPanel` object must adopt the `OptionsPanelDelegate`
/// protocol to get notified on updates.
public protocol OptionsPanelDelegate: AnyObject {

    /// Tells the delegate the panel changes to a new option item.
    ///
    /// - Parameters:
    ///   - panel: The panel notifying the change of option item.
    ///   - option: The new option item.
    func optionsPanel(_ panel: OptionsPanel, didChangeTo option: OptionItem)
}

/// The base class for all the panels containing set of options.
open class OptionsPanel: UIView {

    // MARK: - Properties

    /// The optional panel title.
    ///
    /// - Important: When it is set, the `titleItem` property is set
    ///              and the title is displayed at the top of the panel.
    @IBInspectable public var title: String? {
        didSet {
            let titleItem = TitleItem()
            titleItem.label.text = title

            // Make sure it is placed at the top
            stackView.insertArrangedSubview(titleItem.view, at: 0)
            self.titleItem = titleItem

            // Updates the vertical content height
            intrinsicContentHeight += titleItem.view.frame.size.height
            invalidateIntrinsicContentSize()
        }
    }

    override open var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// All the available option item specs that are used to build the available option items.
    public var specs: [OptionItemSpec] = [] {
        didSet {
            // Reflects the update
            makeItems()
        }
    }

    /// The object which acts as the delegate of the options panel.
    public weak var delegate: OptionsPanelDelegate?

    /// All the option items.
    var optionItems: [OptionItem] = []

    /// All the title visuals are found on this item.
    ///
    /// - Note: This is an optional property and it is created only
    ///              when the `title` property is set.
    var titleItem: TitleItem?

    /// This vertical stackview holds all the option items.
    private var optionsView = UIStackView()

    /// This vertical stackview holds the title view and the option views.
    private let stackView = UIStackView()

    /// The intrinsic content height is important for setting the `intrinsicContentSize`.
    private var intrinsicContentHeight: CGFloat = 0.0

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    /// Makes all the option items required for the panel by setting the specs property.
    func makePanel() {
        assertionFailure("OptionsPanel class has to be subclassed.")
    }

    // MARK: - Private

    /// Sets up the options panel.
    private func setUp() {
        // Stackview settings
        optionsView.spacing = 0.0
        optionsView.distribution = .fill
        optionsView.axis = .vertical
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.addArrangedSubview(optionsView)

        // Makes the underlying option item specs
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

            // Adds the item to the items array & stackview
            optionItems.append(item)
            optionsView.addArrangedSubview(item)

            // Updates the vertical content height
            intrinsicContentHeight += item.intrinsicContentSize.height
        }

        invalidateIntrinsicContentSize()
    }
}
