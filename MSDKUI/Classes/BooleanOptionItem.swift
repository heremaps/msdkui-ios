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

/// An option item with only one checkbox.
@IBDesignable open class BooleanOptionItem: OptionItem {

    // MARK: - Properties

    /// The state of the checkbox.
    public var checked: Bool {
        get {
            optionSwitch.isOn
        }
        set {
            // Any update?
            if newValue != optionSwitch.isOn {
                optionSwitch.isOn = newValue

                // Notify the delegate
                delegate?.optionItemDidChange(self)

                // Reflect the update
                updateAccessibility()
            }
        }
    }

    /// The label accompanying the checkbox.
    var label: String! {
        didSet {
            // Reflect the update
            makeOption(label: label)
        }
    }

    /// The switch for the option.
    var optionSwitch: UISwitch!

    /// The label for the option text.
    private var optionLabel: UILabel!

    /// Option view containing label and a switch.
    private var optionView: UIView!

    // MARK: - Public

    /// Initializes the item by specifying the type.
    override func setUp() {
        type = .booleanOptionItem

        super.setUp()
    }

    /// The switch handler method.
    ///
    /// - Parameter sender: The switch which is updated.
    @objc func onSwitch(_ sender: UISwitch) {
        delegate?.optionItemDidChange(self)

        // Reflect the update
        updateAccessibility()
    }

    // MARK: - Private

    /// Makes the option.
    ///
    /// - Parameter label: The option string.
    private func makeOption(label: String) {
        // Instantiate option view
        optionView = UINib(nibName: "Label+SwitchOption", bundle: .MSDKUI).instantiate(withOwner: nil).first as? UIView

        // Set the label text
        optionLabel = optionView.viewWithTag(1000) as? UILabel
        optionLabel.text = label

        // Set the switch action handler
        optionSwitch = optionView.viewWithTag(1001) as? UISwitch
        optionSwitch.addTarget(self, action: #selector(onSwitch), for: .valueChanged)

        updateStyle(optionView)
        addSubviewBindToEdges(optionView)

        // Set the very important intrinsic content height
        intrinsicContentHeight = optionView.bounds.size.height
        invalidateIntrinsicContentSize()

        setAccessibility()

        // Reflect the initial state
        updateAccessibility()
    }

    /// Updates the style for the visuals.
    ///
    /// - Parameter optionView: The view representing option.
    private func updateStyle(_ optionView: UIView) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionSwitch.onTintColor = Styles.shared.optionItemSwitchOnTintColor
        optionSwitch.tintColor = Styles.shared.optionItemSwitchTintColor
        optionSwitch.thumbTintColor = Styles.shared.optionItemSwitchThumbTintColor
    }

    /// Sets the accessibility contents.
    private func setAccessibility() {
        // Add a tap gesture recognizer: it is enabled only when the accessibility is turned on
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSwitch))
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)

        optionLabel.accessibilityTraits = .button
        optionLabel.accessibilityHint = "msdkui_hint_boolean".localized
        optionLabel.accessibilityIdentifier = "MSDKUI.BooleanOptionItem.optionLabel"

        optionSwitch.isAccessibilityElement = false
    }

    /// Updates the accessibility contents.
    private func updateAccessibility() {
        optionLabel.accessibilityLabel = "\(label as String): \(checked ? "msdkui_enabled".localized : "msdkui_disabled".localized)"
    }

    /// Monitors the `VoiceOver` status.
    ///
    /// - Parameter notification: The notification received.
    @objc private func voiceOverStatusChanged(_ notification: NSNotification) {
        if let gestureRecognizer = gestureRecognizers?.first {
            gestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning
        }
    }

    /// Updates the switch when tapped.
    ///
    /// - Parameter sender: The tap gesture recognizer.
    @objc private func handleSwitch(_ sender: UITapGestureRecognizer) {
        checked.toggle()
    }
}
