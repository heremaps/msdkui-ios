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

/// An option item with a set of checkboxes. The user can can select more
/// than one option among the displayed options.
@IBDesignable open class MultipleChoiceOptionItem: OptionItem {

    // MARK: - Properties

    /// All the selected item indexes.
    ///
    /// - Note: If there is no selected index, returns nil.
    /// - Note: Setting it nil clears all the selections.
    /// - Note: Any selected item index outside of the available range has no effect.
    public var selectedItemIndexes: Set<Int>? { // swiftlint:disable:this discouraged_optional_collection
        get {
            getSelectedSwitches()
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
                    // Gets the previously selected switches
                    if let oldValue = getSelectedSwitches() {
                        // If there is an update, we need to know the off & on switches
                        if validValue != oldValue {
                            // There are 3 sets we should care for:
                            // 1 - difference(oldValue, validValue) -> offs
                            // 2 - intersection(oldValue, validValue) -> not changed ones
                            // 3 - difference(validValue, oldValue) -> ons
                            let offs = oldValue.subtracting(validValue)
                            let ons = validValue.subtracting(oldValue)

                            updateSwitches(set: offs, state: false)
                            updateSwitches(set: ons, state: true)
                            delegate?.optionItemDidChange(self)
                        }
                    } else {
                        // If there is no selected switch previously, directly set the new switches on
                        updateSwitches(set: validValue, state: true)
                        delegate?.optionItemDidChange(self)
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

    /// All the switches.
    var optionSwitches: [UISwitch] = []

    /// The labels accompanying the checkboxes.
    var labels: [String] = [] {
        didSet {
            // Reflect the update
            makeOptions(labels: labels)
        }
    }

    /// The initial tag for the switches which is important for accessing the switches.
    private static var initialSwitchTag = 5000

    /// All the labels.
    private var optionLabels: [UILabel] = []

    /// Stack view with `optionLabels` and `optionSwitches`.
    private var stackView = UIStackView()

    // MARK: - Public

    override func setUp() {
        type = .multipleChoiceOptionItem

        // Stackview settings
        stackView.spacing = 0.0
        stackView.distribution = .fillEqually
        stackView.axis = .vertical

        // Adds the stackview to the view
        addSubviewBindToEdges(stackView)

        super.setUp()
    }

    // MARK: - Private

    /// Makes the options based on the first one which is used as a
    /// template to create other options.
    ///
    /// - Parameter labels: The strings to be used on each option.
    private func makeOptions(labels: [String]) {
        // Clear previously added options
        stackView.subviews.forEach { stackView.removeArrangedSubview($0) }
        optionLabels.removeAll()
        optionSwitches.removeAll()

        // One-by-one create options
        for label in labels {
            // Creates new nib instance for each label
            let nibInstance = UINib(nibName: "Label+SwitchOption", bundle: .MSDKUI).instantiate(withOwner: nil)
            // Gets the views
            if
                let optionView = nibInstance.first as? UIView,
                let optionLabel = optionView.viewWithTag(1000) as? UILabel,
                let optionSwitch = optionView.viewWithTag(1001) as? UISwitch {

                // Sets the label text & append it to the labels array
                let elementIndex = optionLabels.count
                optionLabel.text = label
                optionLabels.append(optionLabel)

                // Sets the switch action handler & its tag & append it to the swicthes array
                optionSwitch.tag = MultipleChoiceOptionItem.initialSwitchTag + elementIndex
                optionSwitch.addTarget(self, action: #selector(onSwitch), for: .valueChanged)
                optionSwitches.append(optionSwitch)

                updateStyle(optionView, optionLabel, optionSwitch)
                stackView.addArrangedSubview(optionView)
                setAccessibility(elementIndex)

                // Reflects the initial state
                updateAccessibility(elementIndex)
            }
        }

        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()

        // Sets the line height per option out of the last nib view
        let lineHeight = stackView.arrangedSubviews.last?.frame.size.height ?? 0

        // Sets the very important intrinsic content height
        intrinsicContentHeight = lineHeight * CGFloat(labels.count)
        invalidateIntrinsicContentSize()

        // We want to monitor VoiceOver status updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(voiceOverStatusChanged),
                                               name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                               object: nil)
    }

    /// Updates the style for the visuals.
    private func updateStyle(_ optionView: UIView, _ optionLabel: UILabel, _ optionSwitch: UISwitch) {
        optionView.backgroundColor = Styles.shared.optionItemBackgroundColor

        optionLabel.textColor = Styles.shared.optionItemTextColor

        optionSwitch.onTintColor = Styles.shared.optionItemSwitchOnTintColor
        optionSwitch.tintColor = Styles.shared.optionItemSwitchTintColor
        optionSwitch.thumbTintColor = Styles.shared.optionItemSwitchThumbTintColor
    }

    /// Returns all the selected indexes.
    ///
    /// - Returns: A set containing the indexes of all the selected switches.
    private func getSelectedSwitches() -> Set<Int>? { // swiftlint:disable:this discouraged_optional_collection
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
    private func updateSwitches(set: Set<Int>, state: Bool) {
        for index in set {
            optionSwitches[index].isOn = state

            // Reflects the update
            updateAccessibility(index)
        }
    }

    /// Sets the accessibility stuff.
    private func setAccessibility(_ index: Int) {
        // Adds a tap gesture recognizer: it is enabled only when the accessibility is turned on
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
    ///
    /// - Parameter index: The index of label to be updated.
    private func updateAccessibility(_ index: Int) {
        let checked = optionSwitches[index].isOn
        optionLabels[index].accessibilityLabel = "\(labels[index]): \(checked ? "msdkui_enabled".localized : "msdkui_disabled".localized)"
    }

    /// The switch handler method.
    ///
    /// - Parameter sender: The switch which is updated.
    @objc private func onSwitch(_ sender: UISwitch) {
        // Reflects the update
        let index = sender.tag - MultipleChoiceOptionItem.initialSwitchTag
        updateAccessibility(index)

        // Notifies the delegate
        delegate?.optionItemDidChange(self)
    }

    /// Updates the related switch when tapped.
    @objc private func handleSwitch(sender: UITapGestureRecognizer) {
        if let index = (optionLabels.firstIndex { $0 === sender.view }) {
            optionSwitches[index].setOn(!optionSwitches[index].isOn, animated: true)
            updateAccessibility(index)

            // Notifies the delegate
            delegate?.optionItemDidChange(self)
        }
    }

    /// Monitors the VoiceOver status.
    @objc private func voiceOverStatusChanged(notification _: NSNotification) {
        // One-by-one turn on/off the tap gesture recognizers
        for index in 0 ..< labels.count {
            if let gestureRecognizer = optionLabels[index].gestureRecognizers?.first {
                gestureRecognizer.isEnabled = UIAccessibility.isVoiceOverRunning
            }
        }
    }
}
