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

/// This struct helps a NumericOptionItem object to display an input box.
public struct NumericOptionItemInputHelper {

    // MARK: - Properties

    /// The optional title of the input box.
    ///
    /// - Note: Either title or message should not be nil.
    var title: String?

    /// The optional message of the input box.
    ///
    /// - Note: Either title or message should not be nil.
    var message: String?

    /// The keyboard type for the input box.
    var keyboardType: UIKeyboardType

    /// The optional placeholder string for the input box.
    ///
    /// - Note: When it is not provided, the current value of the item
    ///              is used as the placeholder when available.
    var placeholder: String?

    /// This function validates the user input string, accepting or rejecting it.
    var validator: ((String) -> Bool)

    // MARK: - Public

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

    // MARK: - Properties

    /// The value set for the option.
    public var value: NSNumber? {
        didSet {
            // Any value?
            if let value = value {
                let stringValue = value.description(withLocale: NSLocale.current)

                // Any update?
                if stringValue != getButtonTitle() {
                    // Reflects the update
                    setButtonTitle(stringValue)

                    // Notifies the delegate
                    delegate?.optionItemDidChange(self)
                }
            }
        }
    }

    /// The label for the option.
    var label: String? {
        didSet {
            // Reflects the update
            makeOption(label: label)
        }
    }

    /// The input helper object helps to display an input box.
    var inputHelper: NumericOptionItemInputHelper?

    /// The presenter object is responsible for presenting the input box.
    var presenter: UIViewController?

    /// The label for the option text.
    private var optionLabel: UILabel!

    /// The button for the option.
    private var optionButton: UIButton!

    /// The number formatter with locale support.
    private var numberFormatter = NumberFormatter()

    /// Option view containing label and a button.
    private var optionView: UIView!

    // MARK: - Public

    /// Initializes the item by specifying the type.
    override func setUp() {
        type = .numericOptionItem

        // Decimal numbers in current locale are supported
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        super.setUp()
    }

    /// Returns the button title or empty string when there is no title.
    func getButtonTitle() -> String {
        optionButton?.title(for: .normal) ?? ""
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

    /// The button handler method.
    ///
    /// - Parameter sender: The button which is tapped.
    @objc func onButton(_ sender: UIButton) {
        displayInputBox()
    }

    // MARK: - Private

    /// Makes the option.
    ///
    /// - Parameter label: The option string.
    private func makeOption(label: String?) {
        // Loads the view from nib file
        optionView = UINib(nibName: "Label+ButtonOption", bundle: .MSDKUI).instantiate(withOwner: nil).first as? UIView

        // Sets the label text
        optionLabel = optionView.viewWithTag(1000) as? UILabel
        optionLabel.text = label

        // Sets the button title & action handler
        optionButton = optionView.viewWithTag(1001) as? UIButton
        setButtonTitle("msdkui_set".localized)
        optionButton.addTarget(self, action: #selector(onButton), for: .touchUpInside)

        updateStyle(optionView)
        addSubviewBindToEdges(optionView)

        // Sets the very important intrinsic content height
        intrinsicContentHeight = optionView.bounds.size.height
        invalidateIntrinsicContentSize()

        setAccessibility()

        // Reflects the initial state
        updateAccessibility()
    }

    /// Updates the style for the visuals.
    private func updateStyle(_ optionView: UIView) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionButton.backgroundColor = Styles.shared.optionItemButtonBackgroundColor
        optionButton.setTitleColor(Styles.shared.optionItemButtonTitleColor, for: .normal)
        optionButton.tintColor = Styles.shared.optionItemButtonTintColor
    }

    /// Displays an input box for updating the value.
    private func displayInputBox() {
        guard let presenter = presenter else {
            return
        }

        let alertController = UIAlertController(title: inputHelper?.title,
                                                message: inputHelper?.message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .default) { _ in
            self.okHandler(userInput: alertController.textFields?.first?.text)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { _ in }

        alertController.addTextField { textField in
            // Sets the placeholder
            if let placeholder = self.inputHelper?.placeholder {
                textField.placeholder = placeholder
            } else if let value = self.value {
                textField.placeholder = value.stringValue
            }

            // Sets the keyboard type
            if let keyboardType = self.inputHelper?.keyboardType {
                textField.keyboardType = keyboardType
            }
        }

        // Adds the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Presents the alert
        presenter.present(alertController, animated: true)
    }

    /// Sets the button title.
    ///
    /// - Parameter title: The new title input string.
    private func setButtonTitle(_ title: String) {
        optionButton.setTitle(title, for: .normal)

        // Reflects the update
        updateAccessibility()
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        // Adds a tap gesture recognizer: it is enabled only when the accessibility is turned on
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLabel))
        tapGestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)

        optionLabel.accessibilityTraits = .button
        optionLabel.accessibilityHint = "msdkui_hint_numeric".localized
        optionLabel.accessibilityIdentifier = "MSDKUI.NumericOptionItem.optionLabel"
        optionLabel.isUserInteractionEnabled = true
        optionLabel.addGestureRecognizer(tapGestureRecognizer)

        // Note that "optionButton.isAccessibilityElement = false" doesn't work!
        optionButton.accessibilityElementsHidden = true
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        if let label = label {
            optionLabel.accessibilityLabel = "\(label): \(getButtonTitle())"
        }
    }

    /// Monitors the VoiceOver status.
    @objc private func voiceOverStatusChanged(notification _: NSNotification) {
        optionLabel.gestureRecognizers?.first?.isEnabled = UIAccessibility.isVoiceOverRunning
    }

    /// Displays the input box just like the option button.
    @objc private func handleLabel(sender _: UITapGestureRecognizer) {
        displayInputBox()
    }
}
