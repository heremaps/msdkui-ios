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

import NMAKit

/// A dialog to select departure date and time.
@IBDesignable open class TravelTimePicker: UIViewController {

    /// The time the picker is created with.
    public var time: Date! {
        didSet {
            // Initiate the date picker
            datePicker.date = time
        }
    }

    /// The callback which is fired when a new time data is picked.
    public var onTimePicked: ((Date) -> Void)?

    /// The view holding the visuals.
    @IBOutlet private(set) var canvasView: UIView!

    /// The view holding the title along with cancel and OK buttons.
    @IBOutlet private(set) var titleView: UIView!

    /// The "Cancel" button on the panel.
    @IBOutlet private(set) var cancelButton: UIButton!

    /// The title label on the panel.
    @IBOutlet private(set) var titleLabel: UILabel!

    /// The "OK" button on the panel.
    @IBOutlet private(set) var okButton: UIButton!

    /// The date picker.
    @IBOutlet private(set) var datePicker: UIDatePicker!

    override open func viewDidLoad() {
        super.viewDidLoad()

        localize()
        setAccessibility()
        updateStyle()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let now = Date()

        // If the initial time is not set, use the current time
        if time == nil {
            time = now
        }

        // Selecting an earlier time than the current time is not supported
        datePicker.minimumDate = now
    }

    /// The "Cancel" button handler.
    @IBAction private func onCancel(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    /// The "OK" button handler.
    @IBAction private func onOK(_: UIButton) {
        dismiss(animated: true, completion: nil)

        // If there is no manual update, get the current time
        if datePicker.date != time {
            time = datePicker.date
        }

        // Has any callback set?
        onTimePicked?(time)
    }

    /// The date picker handler.
    @IBAction private func onDatePicker(_ sender: UIDatePicker) {
        // Get the date
        time = sender.date
    }

    /// Interprets an upper empty view tap as a cancel request.
    @IBAction private func onUpperEmptyView(_: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    /// Localizes all the strings used.
    func localize() {
        cancelButton.setTitle("msdkui_cancel".localized, for: .normal)
        okButton.setTitle("msdkui_ok".localized, for: .normal)

        titleLabel.text = "msdkui_pick_time_title".localized
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        canvasView.backgroundColor = Styles.shared.travelTimePickerBackgroundColor
        titleView.backgroundColor = Styles.shared.travelTimePickerTitleBackgroundColor
        datePicker.backgroundColor = Styles.shared.travelTimePickerDatePickerBackgroundColor

        titleLabel.textColor = Styles.shared.travelTimePickerTitleTextColor

        okButton.setTitleColor(Styles.shared.travelTimePickerTitleButtonsTextColor, for: .normal)
        cancelButton.setTitleColor(Styles.shared.travelTimePickerTitleButtonsTextColor, for: .normal)
    }

    /// Sets the accessibility stuff.
    func setAccessibility() {
        cancelButton.accessibilityIdentifier = "MSDKUI.TravelTimePicker.cancel"
        titleLabel.accessibilityIdentifier = "MSDKUI.TravelTimePicker.title"
        okButton.accessibilityIdentifier = "MSDKUI.TravelTimePicker.ok"
        datePicker.accessibilityIdentifier = "MSDKUI.TravelTimePicker.datePicker"
    }
}
