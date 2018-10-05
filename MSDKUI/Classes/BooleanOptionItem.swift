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

/// An option item with only one checkbox.
@IBDesignable open class BooleanOptionItem: OptionItem {

    /// The state of the checkbox.
    public var checked: Bool {
        get {
            return optionSwitch.isOn
        }
        set {
            // Any update?
            if newValue != optionSwitch.isOn {
                optionSwitch.isOn = newValue

                // Has any callback set?
                onChanged?(self)

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

    /// The label for the option text.
    var optionLabel: UILabel!

    /// The switch for the option.
    var optionSwitch: UISwitch!

    /// Initializes the item by specifying the type.
    override func setUp() {
        type = .booleanOptionItem

        super.setUp()
    }

    /// Makes the option.
    ///
    /// - Parameter label: The option string.
    func makeOption(label: String) {
        // Load the nib file
        let nibFile = UINib(nibName: "Label+SwitchOption", bundle: .MSDKUI)

        // Create an option view
        let optionView = nibFile.instantiate(withOwner: nil, options: nil)[0] as! UIView

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
    func updateStyle(_ optionView: UIView) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionSwitch.onTintColor = Styles.shared.optionItemSwitchOnTintColor
        optionSwitch.tintColor = Styles.shared.optionItemSwitchTintColor
        optionSwitch.thumbTintColor = Styles.shared.optionItemSwitchThumbTintColor
    }

    /// The switch handler method.
    ///
    /// - Parameter sender: The switch which is updated.
    @objc func onSwitch(_: UISwitch) {
        // Has any callback set?
        onChanged?(self)

        // Reflect the update
        updateAccessibility()
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        // Add a tap gesture recognizer: it is enabled only when the accessibility is turned on
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSwitch))
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged),
                                               object: nil)

        optionLabel.accessibilityTraits = .button
        optionLabel.accessibilityHint = "msdkui_hint_boolean".localized
        optionLabel.accessibilityIdentifier = "MSDKUI.BooleanOptionItem.optionLabel"

        optionSwitch.isAccessibilityElement = false
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        optionLabel.accessibilityLabel = "\(label!): \(checked ? "msdkui_enabled".localized : "msdkui_disabled".localized)"
    }

    /// Monitors the `VoiceOver` status.
    @objc private func voiceOverStatusChanged(notification _: NSNotification) {
        gestureRecognizers![0].isEnabled = UIAccessibility.isVoiceOverRunning
    }

    /// Updates the switch when tapped.
    @objc private func handleSwitch(_: UITapGestureRecognizer) {
        checked = !checked
    }
}
