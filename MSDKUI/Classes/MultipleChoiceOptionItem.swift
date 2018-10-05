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

/// An option item with a set of checkboxes. The user can can select more
/// than one option among the displayed options.
@IBDesignable open class MultipleChoiceOptionItem: OptionItem {

    /// All the selected item indexes.
    ///
    /// - Important: If there is no selected index, returns nil.
    /// - Important: Setting it nil clears the selection.
    /// - Important: Any selected item index outside of the available range has no effect.
    public var selectedItemIndexes: Set<Int>? { // swiftlint:disable:this discouraged_optional_collection
        get {
            return getSelectedSwitches()
        }

        set {
            // Are there any indexes?
            if let newValue = newValue {
                // In order to ignore the invalid indexes, we need to know
                // the valid ones
                let switches: Set<Int> = Set(labels.indices)
                let validValue = switches.intersection(newValue)

                // Are there any valid index?
                if validValue.isEmpty == false {
                    // Get the previously selected switches
                    let oldValue = getSelectedSwitches()

                    // If there is no selected switch previously, directly set the new
                    // switches on
                    // Else if there is an update, we need to know the off & on switches!
                    if oldValue == nil {
                        updateSwitches(set: validValue, state: true)
                        onChanged?(self)
                    } else if validValue != oldValue {
                        // There are 3 sets we should care for:
                        // 1 - difference(oldValue, validValue) -> offs
                        // 2 - intersection(oldValue, validValue) -> not changed ones
                        // 3 - difference(validValue, oldValue) -> ons
                        let offs = oldValue!.subtracting(validValue)
                        let ons = validValue.subtracting(oldValue!)

                        updateSwitches(set: offs, state: false)
                        updateSwitches(set: ons, state: true)
                        onChanged?(self)
                    }
                }
            } else {
                // Clear the selected switches if any
                if let selectedSwitches = getSelectedSwitches() {
                    updateSwitches(set: selectedSwitches, state: false)
                }
            }
        }
    }

    /// The initial tag for the switches which is important for accessing the switches.
    static var initialSwitchTag = 5000

    /// All the labels.
    var optionLabels: [UILabel] = []

    /// All the switches.
    var optionSwitches: [UISwitch] = []

    /// The labels accompanying the checkboxes.
    var labels: [String] = [] {
        didSet {
            // Reflect the update
            makeOptions(labels: labels)
        }
    }

    override func setUp() {
        type = .multipleChoiceOptionItem

        super.setUp()
    }

    /// Makes the options based on the first one which is used as a
    /// template to create other options.
    ///
    /// - Parameter labels: The strings to be used on each option.
    func makeOptions(labels: [String]) {
        let stackView = UIStackView()

        // Stackview settings
        stackView.spacing = 0.0
        stackView.distribution = .fillEqually
        stackView.axis = .vertical

        // Load the nib file
        let nibFile = UINib(nibName: "Label+SwitchOption", bundle: .MSDKUI)

        // One-by-one create options
        var optionView: UIView!
        for index in 0 ..< labels.count {
            // Create an option view
            optionView = nibFile.instantiate(withOwner: nil, options: nil)[0] as? UIView

            // Set the label text & append it to the labels array
            let optionLabel = optionView.viewWithTag(1000) as! UILabel
            optionLabel.text = labels[index]
            optionLabels.append(optionLabel)

            // Set the switch action handler & its tag & append it to the swicthes array
            let optionSwitch = optionView.viewWithTag(1001) as! UISwitch
            optionSwitch.tag = MultipleChoiceOptionItem.initialSwitchTag + index
            optionSwitch.addTarget(self, action: #selector(onSwitch), for: .valueChanged)
            optionSwitches.append(optionSwitch)

            updateStyle(optionView, optionLabel, optionSwitch)
            stackView.addArrangedSubview(optionView)
            setAccessibility(index)

            // Reflect the initial state
            updateAccessibility(index)
        }

        // Add the stackview to the view
        addSubviewBindToEdges(stackView)
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()

        // Set the line height per option out of the last nib view
        let lineHeight = optionView.frame.size.height

        // Set the very important intrinsic content height
        intrinsicContentHeight = lineHeight * CGFloat(labels.count)
        invalidateIntrinsicContentSize()

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged),
                                               object: nil)
    }

    /// Updates the style for the visuals.
    func updateStyle(_ optionView: UIView, _ optionLabel: UILabel, _ optionSwitch: UISwitch) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionSwitch.onTintColor = Styles.shared.optionItemSwitchOnTintColor
        optionSwitch.tintColor = Styles.shared.optionItemSwitchTintColor
        optionSwitch.thumbTintColor = Styles.shared.optionItemSwitchThumbTintColor
    }

    /// The switch handler method.
    ///
    /// - Parameter sender: The switch which is updated.
    @objc func onSwitch(_ sender: UISwitch) {
        // Reflect the update
        let index = sender.tag - MultipleChoiceOptionItem.initialSwitchTag
        updateAccessibility(index)

        // Has any callback set?
        onChanged?(self)
    }

    /// Returns all the selected indexes.
    ///
    /// - Returns: A set containing the indexes of all the selected switches.
    func getSelectedSwitches() -> Set<Int>? { // swiftlint:disable:this discouraged_optional_collection
        var indexes: Set<Int> = []

        // One-by-one get the "on" switches
        for index in 0 ..< labels.count {
            let state = optionSwitches[index].isOn

            if state == true {
                indexes.insert(index)
            }
        }

        // If there is no selected index, return nil
        return indexes.isEmpty ? nil : indexes
    }

    /// Updates the indexed set of switches to the specified state.
    ///
    /// - Parameter set: The indexes of switches to be updated.
    /// - Parameter state: The new switch state of the targeted switches.
    func updateSwitches(set: Set<Int>, state: Bool) {
        for index in set {
            optionSwitches[index].isOn = state

            // Reflect the update
            updateAccessibility(index)
        }
    }

    /// Sets the accessibility stuff.
    private func setAccessibility(_ index: Int) {
        // Add a tap gesture recognizer: it is enabled only when the accessibility is turned on
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSwitch))
        tapGestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning

        optionLabels[index].accessibilityTraits = .button
        optionLabels[index].accessibilityHint = "msdkui_hint_boolean".localized
        optionLabels[index].accessibilityIdentifier = "MSDKUI.MultipleChoiceOptionItem.optionLabel_\(index)"
        optionLabels[index].isUserInteractionEnabled = true
        optionLabels[index].addGestureRecognizer(tapGestureRecognizer)

        optionSwitches[index].isAccessibilityElement = false
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility(_ index: Int) {
        let checked = optionSwitches[index].isOn
        optionLabels[index].accessibilityLabel = "\(labels[index]): \(checked ? "msdkui_enabled".localized : "msdkui_disabled".localized)"
    }

    /// Find the index of the passed view which is a UILabel.
    ///
    /// - Parameter optionLabel: The label which will be converted to an index number.
    /// - Returns: The index of the view.
    private func getIndex(of optionLabel: UILabel) -> Int {
        var index = 0

        for newIndex in 0 ..< optionLabels.count where optionLabels[newIndex] == optionLabel {
            index = newIndex
        }

        return index
    }

    /// Updates the related switch when tapped.
    @objc private func handleSwitch(sender: UITapGestureRecognizer) {
        let index = getIndex(of: sender.view! as! UILabel)

        optionSwitches[index].isOn = !optionSwitches[index].isOn
        updateAccessibility(index)

        // Has any callback set?
        onChanged?(self)
    }

    /// Monitors the VoiceOver status.
    @objc private func voiceOverStatusChanged(notification _: NSNotification) {
        // One-by-one turn on/off the tap gesture recognizers
        for index in 0 ..< labels.count {
            let gestureRecognizer = optionLabels[index].gestureRecognizers![0]
            gestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning
        }
    }
}
