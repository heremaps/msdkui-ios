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

    /// The cancel button on the panel.
    @IBOutlet private(set) var cancelButton: UIButton!

    /// The title label on the panel.
    @IBOutlet private(set) var titleLabel: UILabel!

    /// The OK button on the panel.
    @IBOutlet private(set) var okButton: UIButton!

    /// The date picker.
    @IBOutlet private(set) var datePicker: UIDatePicker!

    /// The time picker background color.
    public var backgroundColor: UIColor? {
        didSet { canvasView.backgroundColor = backgroundColor }
    }

    /// The title view background color.
    public var titleViewBackgroundColor: UIColor? {
        didSet { titleView.backgroundColor = titleViewBackgroundColor }
    }

    /// The title label text color.
    public var titleLabelTextColor: UIColor? {
        didSet { titleLabel.textColor = titleLabelTextColor }
    }

    /// The OK button title color.
    public var okButtonTitleColor: UIColor? {
        didSet { okButton.setTitleColor(okButtonTitleColor, for: .normal) }
    }

    /// The cancel button title color.
    public var cancelButtonTitleColor: UIColor? {
        didSet { cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal) }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        localize()
        setAccessibility()
        setUpStyle()
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

    /// Dismiss action.
    @IBAction private func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    /// The OK button handler.
    @IBAction private func pickTime(_: UIButton) {
        dismiss(animated: true, completion: nil)

        // If there is no manual update, get the current time
        if datePicker.date != time {
            time = datePicker.date
        }

        // Has any callback set?
        onTimePicked?(time)
    }

    /// The date picker handler.
    @IBAction private func updateTime(_ sender: UIDatePicker) {
        time = sender.date
    }

    /// Localizes all the strings used.
    private func localize() {
        cancelButton.setTitle("msdkui_cancel".localized, for: .normal)
        okButton.setTitle("msdkui_ok".localized, for: .normal)
        titleLabel.text = "msdkui_pick_time_title".localized
    }

    /// Sets up the picker visual style.
    private func setUpStyle() {
        backgroundColor = .colorForegroundLight
        titleViewBackgroundColor = .colorBackgroundLight

        titleLabelTextColor = .colorForeground

        okButtonTitleColor = .colorAccent
        cancelButtonTitleColor = .colorAccent
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        cancelButton.accessibilityIdentifier = "MSDKUI.TravelTimePicker.cancelButton"
        titleLabel.accessibilityIdentifier = "MSDKUI.TravelTimePicker.titleLabel"
        okButton.accessibilityIdentifier = "MSDKUI.TravelTimePicker.okButton"
        datePicker.accessibilityIdentifier = "MSDKUI.TravelTimePicker.datePicker"
    }
}
