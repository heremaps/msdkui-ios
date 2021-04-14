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

/// This protocol provides the methods to customize a pickerview.
@objc public protocol PickerViewDelegate: AnyObject {

    /// This method is called whenever the label for a row is needed.
    ///
    /// - Parameter pickerView: The picker view requesting a label.
    /// - Parameter text: The text to be displayed on the label.
    /// - Returns: A customized UILabel object having the specified text.
    /// - Note: When there is no delegate, a standard UILabel object with
    ///              center text alignment is used.
    func makeLabel(_ pickerView: UIPickerView, text: String) -> UILabel

    /// This optional method is called whenever the row width is needed.
    ///
    /// - Parameter pickerView: The picker view requesting this information.
    /// - Returns: A custom value for the row width.
    @objc optional func rowWidth(_ pickerView: UIPickerView) -> CGFloat

    /// This optional method is called whenever the row height is needed.
    ///
    /// - Parameter pickerView: The picker view requesting this information.
    /// - Returns: A custom value for the row height.
    @objc optional func rowHeight(_ pickerView: UIPickerView) -> CGFloat
}

/// An option item with a `UIPickerView`. The user can select only one option among
/// the displayed options. Plus, there must be always a selected option.
@IBDesignable open class SingleChoiceOptionItem: OptionItem {

    // MARK: - Properties

    /// The title view.
    @IBOutlet private(set) var titleView: UIView!

    /// The title label.
    @IBOutlet private(set) var titleLabel: UILabel!

    /// The picker view showing the options.
    @IBOutlet private(set) var pickerView: UIPickerView!

    /// The leading constraint of the title.
    @IBOutlet private(set) var leadingTitleConstraint: NSLayoutConstraint!

    /// The trailing constraint of the title.
    @IBOutlet private(set) var trailingTitleConstraint: NSLayoutConstraint!

    /// This view holds the related XIB file contents.
    @IBOutlet private var view: UIView!

    /// The currently selected button.
    ///
    /// - Note: Setting an index outside of the available range has no effect.
    public var selectedItemIndex: Int {
        get {
            backupSelectedItemIndex
        }
        set {
            // Is it valid? Otherwise, just ignore it: keep the
            // previous value
            guard labels.indices.contains(newValue) else {
                return
            }

            // Is it different?
            if newValue != backupSelectedItemIndex {
                backupSelectedItemIndex = newValue
            }
        }
    }

    /// The optional delegate object. When it is set, the delegate object
    /// customizes the `UIPickerView`.
    public weak var pickerDelegate: PickerViewDelegate?

    /// The title of the pickerview.
    var title: String?

    /// The labels of the pickerview.
    var labels: [String] = [] {
        didSet {
            // Reflect the update: UIPickerViewDelegate
            // method pickerView(_:viewForRow:forComponent:reusing:)
            // uses the labels
            makeOptions()
        }
    }

    // MARK: - Public

    override func setUp() {
        super.setUp()

        type = .singleChoiceOptionItem

        // Instantiate view
        UINib(nibName: String(describing: SingleChoiceOptionItem.self), bundle: .MSDKUI).instantiate(withOwner: self)

        // Uses the view's bounds
        bounds = view.bounds

        // Adds the view to the hierarchy
        addSubviewBindToEdges(view)
    }

    // MARK: - Private

    /// Makes the options.
    private func makeOptions() {
        updateStyle()

        // Sets the delegates of the pickerview
        pickerView.delegate = self
        pickerView.dataSource = self

        // Is there a title? Set the very important intrinsic content height accordingly
        if let title = self.title {
            titleLabel.text = title
            intrinsicContentHeight = view.bounds.size.height
        } else {
            titleView.isHidden = true // Sets its height 0
            intrinsicContentHeight = view.bounds.size.height - titleView.frame.size.height
        }

        invalidateIntrinsicContentSize()
    }

    /// Updates the style for the visuals.
    private func updateStyle() {
        view.backgroundColor = Styles.shared.singleChoiceOptionItemBackgroundColor
        titleView.backgroundColor = Styles.shared.singleChoiceOptionItemTitleBackgroundColor
        titleLabel.textAlignment = Styles.shared.singleChoiceOptionItemTitleTextAlignment

        leadingTitleConstraint.constant = Styles.shared.singleChoiceOptionItemTitleLeadingConstraint
        trailingTitleConstraint.constant = Styles.shared.singleChoiceOptionItemTitleTrailingConstraint

        // As we updated the constraints, we need to force an update
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }

    /// The backup property for the selectedButtonIndex.
    private var backupSelectedItemIndex = 0 {
        didSet {
            // Select the item on the pickerview
            pickerView.selectRow(backupSelectedItemIndex, inComponent: 0, animated: false)

            // Notify the delegate
            delegate?.optionItemDidChange(self)
        }
    }
}

// MARK: - UIPickerViewDataSource

extension SingleChoiceOptionItem: UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        labels.count
    }
}

// MARK: - UIPickerViewDelegate

extension SingleChoiceOptionItem: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        // If there is a delegate having the optional rowHeight(_:) method implemented, call it
        if let rowHeight = pickerDelegate?.rowHeight {
            return rowHeight(pickerView)
        }

        return 30.0
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        // If there is a delegate having the optional rowWidth(_:) method implemented, call it
        if let rowWidth = pickerDelegate?.rowWidth {
            return rowWidth(pickerView)
        }

        return pickerView.frame.size.width
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel

        // If there is a delegate, ask the custom label and otherwise, use the default one
        if let pickerDelegate = self.pickerDelegate {
            pickerLabel = pickerDelegate.makeLabel(pickerView, text: labels[row])
        } else {
            pickerLabel = UILabel()
            pickerLabel.text = labels[row]
            pickerLabel.textAlignment = Styles.shared.singleChoiceOptionItemTextAlignment
        }

        return pickerLabel
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItemIndex = row
    }
}
