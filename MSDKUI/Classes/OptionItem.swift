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

/// The delegate of an `OptionItem` object must adopt the `OptionItemDelegate`
/// protocol to get notified on updates.
public protocol OptionItemDelegate: AnyObject {

    /// Tells the delegate when the option item is changed.
    ///
    /// - Parameter item: The option item which changed.
    func optionItemDidChange(_ item: OptionItem)
}

/// The base class for all the available option items.
open class OptionItem: UIView {

    // MARK: - Types

    /// All the available option item types.
    public enum ItemType: Int {
        /// An option item indicating one of two states.
        case booleanOptionItem

        /// An option item indicating one state selectable from more than two states.
        case multipleChoiceOptionItem

        /// An option item indicating a numeric value.
        case numericOptionItem

        /// An option item indicating a single choice.
        case singleChoiceOptionItem
    }

    // MARK: - Properties

    override open var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// The unique id assigned to this option item. The id is useful for setting the initial
    /// values or monitoring the changes when a panel contains a lot of option items. For
    /// example, assume a panel has more than one `NumericOptionItem` object. In this case,
    /// setting an id will help to differentiate the items.
    public internal(set) var id: Int = 0

    /// The type of the option item.
    public internal(set) var type: ItemType!

    /// The object which acts as the delegate of the option item.
    public weak var delegate: OptionItemDelegate?

    /// The intrinsic content height is important for setting the `intrinsicContentSize`.
    var intrinsicContentHeight: CGFloat = 0.0

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    /// Sets up the item view.
    func setUp() {
        // Customise the view settings
        isUserInteractionEnabled = true
    }
}
