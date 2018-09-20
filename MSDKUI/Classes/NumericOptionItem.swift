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

/// This struct helps a NumericOptionItem object to display an input box.
public struct NumericOptionItemInputHelper {
    /// The optional title of the input box.
    ///
    /// - Important: Either title or message should not be nil.
    var title: String?

    /// The optional message of the input box.
    ///
    /// - Important: Either title or message should not be nil.
    var message: String?

    /// The keyboard type for the input box.
    var keyboardType: UIKeyboardType

    /// The optional placeholder string for the input box.
    ///
    /// - Important: When it is not provided, the current value of the item
    ///              is used as the placeholder when available.
    var placeholder: String?

    /// This function validates the user input string, accepting or rejecting it.
    var validator: ((String) -> Bool)

    /// Creates a new NumericOptionItemInputHelper object.
    ///
    /// - Parameters:
    ///   - title: Title of the input box.
    ///   - message: Message of the input box.
    ///   - keyboardType: Type of the input keyboard.
    ///   - placeholder: Placeholder of the input box.
    ///   - validator: Input validator function.
    /// - Important: Either title or message must be provided.
    public init(title: String? = nil,
                message: String? = nil,
                keyboardType: UIKeyboardType = .numbersAndPunctuation,
                placeholder: String? = nil,
                validator: @escaping ((String) -> Bool)) {
        // There must be either a title or message for the input box
        if title == nil && message == nil {
            preconditionFailure("Both the title and message can't be nil!")
        }

        self.title = title
        self.message = message
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.validator = validator
    }
}

/// An option item to set a numeric value.
@IBDesignable open class NumericOptionItem: OptionItem {
    /// The value set for the option.
    public var value: NSNumber? {
        didSet {
            // Any value?
            if let value = value {
                let stringValue = value.description(withLocale: NSLocale.current)

                // Any update?
                if stringValue != getButtonTitle() {
                    // Reflect the update
                    setButtonTitle(stringValue)

                    // Has any callback set?
                    onChanged?(self)
                }
            }
        }
    }

    /// The label for the option.
    var label: String! {
        didSet {
            // Reflect the update
            makeOption(label: label)
        }
    }

    /// The input helper object helps to display an input box.
    var inputHelper: NumericOptionItemInputHelper?

    /// The presenter object is responsible for presenting the input box.
    var presenter: UIViewController?

    /// The label for the option text.
    var optionLabel: UILabel!

    /// The button for the option.
    var optionButton: UIButton!

    /// The number formatter with locale support.
    var numberFormatter = NumberFormatter()

    /// Initializes the item by specifying the type.
    override func setUp() {
        type = .numericOptionItem

        // Decimal numbers in current locale are supported
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        super.setUp()
    }

    /// Makes the option.
    ///
    /// - Parameter label: The option string.
    func makeOption(label: String) {
        // Load the nib file
        let nibFile = UINib(nibName: "Label+ButtonOption", bundle: .MSDKUI)

        // Create an option view
        let optionView = nibFile.instantiate(withOwner: nil, options: nil)[0] as! UIView

        // Set the label text
        optionLabel = optionView.viewWithTag(1000) as! UILabel
        optionLabel.text = label

        // Set the button title & action handler
        optionButton = optionView.viewWithTag(1001) as! UIButton
        setButtonTitle("msdkui_set".localized)
        optionButton.addTarget(self, action: #selector(onButton), for: .touchUpInside)

        updateStyle(optionView)
        addSubviewBindToEdges(optionView)
        setAccessibility()

        // Reflect the initial state
        updateAccessibility()

        // Set the very important intrinsic content height
        intrinsicContentHeight = optionView.bounds.size.height
        invalidateIntrinsicContentSize()
    }

    /// Updates the style for the visuals.
    func updateStyle(_ optionView: UIView) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionButton.backgroundColor = Styles.shared.optionItemButtonBackgroundColor
        optionButton.setTitleColor(Styles.shared.optionItemButtonTitleColor, for: .normal)
        optionButton.tintColor = Styles.shared.optionItemButtonTintColor
    }

    /// The button handler method.
    ///
    /// - Parameter sender: The button which is tapped.
    @objc func onButton(_: UIButton) {
        displayInputBox()
    }

    /// The OK button handler for the input box. It validates the
    /// user input.
    ///
    /// - Parameter userInput: The input received from the user.
    func okHandler(userInput: String?) {
        guard
            let userInput = userInput,
            userInput.isEmpty == false,
            inputHelper?.validator(userInput) == true else {
                return
        }

        // The button title will be updated automatically
        value = numberFormatter.number(from: userInput)
    }

    /// Displays an input box for updating the value.
    func displayInputBox() {
        guard let presenter = presenter else {
            return
        }

        let alertController = UIAlertController(title: inputHelper?.title,
                                                message: inputHelper?.message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .default) { _ in
            self.okHandler(userInput: alertController.textFields?[0].text)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { _ in }

        alertController.addTextField { textField in
            // Set the placeholder
            if let placeholder = self.inputHelper?.placeholder {
                textField.placeholder = placeholder
            } else if let value = self.value {
                textField.placeholder = value.stringValue
            }

            // Set the keyboard type
            if let keyboardType = self.inputHelper?.keyboardType {
                textField.keyboardType = keyboardType
            }
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the alert
        presenter.present(alertController, animated: true)
    }

    /// Returns the button title.
    func getButtonTitle() -> String {
        return optionButton.title(for: .normal)!
    }

    /// Sets the button title.
    ///
    /// - Parameter title: The new title input string.
    func setButtonTitle(_ title: String) {
        optionButton.setTitle(title, for: .normal)

        // Reflect the update
        updateAccessibility()
    }

    /// The callback method which brings data from the input box.
    func onInputSet(_ input: String?) {
        okHandler(userInput: input)
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        // Add a tap gesture recognizer: it is enabled only when the accessibility is turned on
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLabel))
        tapGestureRecognizer.isEnabled = UIAccessibilityIsVoiceOverRunning()

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged),
                                               object: nil)

        optionLabel.accessibilityTraits = UIAccessibilityTraitButton
        optionLabel.accessibilityHint = "msdkui_hint_numeric".localized
        optionLabel.accessibilityIdentifier = "MSDKUI.NumericOptionItem.button"
        optionLabel.isUserInteractionEnabled = true
        optionLabel.addGestureRecognizer(tapGestureRecognizer)

        // Note that "optionButton.isAccessibilityElement = false" doesn't work!
        optionButton.accessibilityElementsHidden = true
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        optionLabel.accessibilityLabel = "\(label!): \(getButtonTitle())"
    }

    /// Monitors the VoiceOver status.
    @objc private func voiceOverStatusChanged(notification _: NSNotification) {
        let gestureRecognizer = optionLabel.gestureRecognizers![0]
        gestureRecognizer.isEnabled = UIAccessibilityIsVoiceOverRunning()
    }

    /// Displays the input box just like the option button.
    @objc private func handleLabel(sender _: UITapGestureRecognizer) {
        displayInputBox()
    }
}
