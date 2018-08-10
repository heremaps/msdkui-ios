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

import UIKit

/// This class works in conjuction with the `NumericOptionItem` class. It is used by this
/// class for getting the user input.
///
/// - Important: The title label is 1-line only. The message label supports
///              at most 5-lines only: if there is more text, first the font
///              size is reduced and then truncated.
@IBDesignable class InputBox: UIViewController {
    /// The value set for the option.
    var value: NSNumber?

    /// The input helper object helps to display an input box.
    var inputHelper: NumericOptionItemInputHelper!

    /// The callback which is fired when input is submitted.
    var onInputSet: ((String?) -> Void)?

    /// The view holding all the input box views.
    @IBOutlet private(set) var canvasView: UIView!

    /// The view holding the title label.
    @IBOutlet private(set) var titleView: UIView!

    /// The title label.
    @IBOutlet private(set) var titleLabel: UILabel!

    /// The view holding the message label.
    @IBOutlet private(set) var messageView: UIView!

    /// The message label.
    @IBOutlet private(set) var messageLabel: UILabel!

    /// The view holding the text field.
    @IBOutlet private(set) var textFieldView: UIView!

    /// The text field.
    @IBOutlet private(set) var textField: UITextField!

    /// The view holding the buttons.
    @IBOutlet private(set) var buttonsView: UIView!

    /// The 'Cancel' button.
    @IBOutlet private(set) var cancelButton: UIButton!

    /// The 'OK' button.
    @IBOutlet private(set) var okButton: UIButton!

    /// The line above the buttons.
    @IBOutlet private(set) var topButtonLine: UIView!

    /// The line between the buttons.
    @IBOutlet private(set) var midButtonLine: UIView!

    /// The vertical centering constraint. Note that it is updated when
    /// the keyboard is displayed and it overlaps the canvasView.
    @IBOutlet private(set) var centerYConstraint: NSLayoutConstraint!

    /// The top message constraint. Note that it is updated when
    /// there is no title.
    @IBOutlet private(set) var messageTopConstraint: NSLayoutConstraint!

    /// The bottom message constraint. It is used to update the `messageTopConstraint`.
    @IBOutlet private(set) var messageBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUp()

        // We want to monitor the keyboardWillShow notification:
        // in case the keyboard overlaps the input box, we will
        // move it up
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)

        setAccessibility()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Done
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
    }

    /// The 'Cancel' button handler.
    ///
    /// - Parameter sender: The button which is tapped.
    @IBAction private func onCancel(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /// The 'OK' button handler.
    ///
    /// - Parameter sender: The button which is tapped.
    @IBAction private func onOK(_: UIButton) {
        okHandler()
    }

    /// Localizes all the strings used.
    func localize() {
        cancelButton.setTitle("msdkui_cancel".localized, for: .normal)
        okButton.setTitle("msdkui_ok".localized, for: .normal)
    }

    /// Sets up the input box.
    func setUp() {
        // We use autolayout: no interference please
        view.useAutoLayout()

        // Title
        if let title = inputHelper.title {
            titleLabel.text = title
        } else {
            titleView.isHidden = true

            // Then, we need to add space to the topside of the messageView
            // equal in size to the bottomside space
            messageTopConstraint.constant = messageBottomConstraint.constant
        }

        // Message
        if let message = inputHelper.message {
            messageLabel.text = message
        } else {
            messageView.isHidden = true
        }

        // Text field
        textField.text = nil
        textField.delegate = self
        textField.keyboardType = inputHelper.keyboardType

        // Set the placeholder:
        // If a placeholder is provided, use it
        // Else if a value is available, use its string value
        if let placeholder = inputHelper.placeholder {
            setPlaceHolderText(placeholder)
        } else if let value = value {
            setPlaceHolderText(value.stringValue)
        }
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        canvasView.backgroundColor = Styles.shared.inputBoxBackgroundColor
        canvasView.layer.cornerRadius = Styles.shared.inputBoxCornerRadius

        titleLabel.textAlignment = Styles.shared.inputBoxTitleTextAlignment
        titleLabel.textColor = Styles.shared.inputBoxTitleTextColor

        messageLabel.textAlignment = Styles.shared.inputBoxMessageTextAlignment
        messageLabel.textColor = Styles.shared.inputBoxMessageTextColor

        textField.textColor = Styles.shared.inputBoxTextFieldTextColor
        textField.borderStyle = Styles.shared.inputBoxTextFieldBorderStyle

        topButtonLine.backgroundColor = Styles.shared.inputBoxLineColor
        midButtonLine.backgroundColor = Styles.shared.inputBoxLineColor

        okButton.setTitleColor(Styles.shared.inputBoxTitleOkButtonTextColor, for: .normal)
        cancelButton.setTitleColor(Styles.shared.inputBoxCancelButtonTextColor, for: .normal)
    }

    /// The OK button handler for the input box.
    func okHandler() {
        // Any update?
        if let text = textField.text {
            if text.isEmpty == false && textField.placeholder != text {
                // Has any callback set?
                onInputSet?(textField.text)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        titleLabel.accessibilityIdentifier = "MSDKUI.InputBox.title"
        messageLabel.accessibilityIdentifier = "MSDKUI.InputBox.message"
        textField.accessibilityIdentifier = "MSDKUI.InputBox.textField"
        cancelButton.accessibilityIdentifier = "MSDKUI.InputBox.cancel"
        okButton.accessibilityIdentifier = "MSDKUI.InputBox.ok"

        // Focus on the text field initially
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, textField)
    }

    /// Sets the place holder text with the `Styles.shared.inputBoxTextFieldPlaceHolderTextColor` color.
    private func setPlaceHolderText(_ text: String) {
        let attributes = [NSForegroundColorAttributeName: Styles.shared.inputBoxTextFieldPlaceHolderTextColor]
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }

    /// Handles the `UIKeyboardWillShow` notification.
    @objc private func keyboardWillShow(notification: NSNotification) {
        // By default, assume centering the input box is OK
        centerYConstraint.constant = 0

        // Is it indeed so?
        var info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let overlappingHeight = view.frame.height - canvasView.frame.origin.y - canvasView.frame.size.height - (keyboardFrame?.size.height)!
        if overlappingHeight < 0 {
            // Animate to show the buttons
            UIView.animate(withDuration: TimeInterval(0.010),
                           animations: {
                               self.centerYConstraint.constant += overlappingHeight
                           },
                           completion: { _ in
            })
        }
    }
}

// MARK: UITextFieldDelegate

extension InputBox: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        okHandler()

        // Done
        textField.resignFirstResponder()
        return true
    }
}
