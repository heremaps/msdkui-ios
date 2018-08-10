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

/// Displays the selected time from `TravelTimePicker` and when tapped,
/// opens a `TravelTimePicker` to update the selected time.
///
/// - Important: Currently, arrival time is not supported by all the HERE Maps SDK routing modes.
///              Please check the relevant HERE Maps SDK documentation before using the
///              arrival time option for a routing mode.
@IBDesignable open class TravelTimePanel: UIView {
    /// The time displayed date on the panel.
    ///
    /// - Important: It is initialized with the current time.
    public var time = Date() {
        didSet {
            // Reflect the update
            updateText()
        }
    }

    /// The callback which is fired when the time data is updated.
    public var onTimeChanged: ((Date) -> Void)?

    /// For the icon displayed on the panel.
    @IBOutlet private(set) var iconView: UIImageView!

    /// For the text displayed on the panel.
    @IBOutlet private(set) var timeLabel: UILabel!

    /// This view holds the related XIB file contents.
    @IBOutlet private var view: UIView!

    /// The intrinsic content height is important for supporting the scroll views.
    var intrinsicContentHeight: CGFloat = 0.0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// Sets up the panel.
    private func setUp() {
        // Load the nib file
        let nibFile = UINib(nibName: String(describing: TravelTimePanel.self), bundle: .MSDKUI)
        view = nibFile.instantiate(withOwner: self, options: nil)[0] as! UIView

        // Add the tag gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)

        // We need to update the style before assignments due to the iconView:
        // setting tintColor after image is set doesn't work!
        updateStyle()

        setAccessibility()

        // Create the image in the template mode for customization as the backgroundColor and tintColor
        // properties works well with layered images
        iconView.image = UIImage(named: "TravelTimePanel.icon", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        addSubviewBindToEdges(view)

        // Set the very important intrinsic content height
        intrinsicContentHeight = view.bounds.size.height
        invalidateIntrinsicContentSize()

        // Finally
        updateText()
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        view.backgroundColor = Styles.shared.travelTimePanelBackgroundColor
        timeLabel.textColor = Styles.shared.travelTimePanelTextColor
        iconView.tintColor = Styles.shared.travelTimePanelIconTintColor
    }

    // The tap handler method.
    @objc func handleTap(_: UITapGestureRecognizer) {
        // Do we know the view controller?
        if let presenter = self.viewController {
            // Load the nib file
            let nibFile = UINib(nibName: "TravelTimePicker", bundle: .MSDKUI)

            // Create the time picker view controller
            let viewController = nibFile.instantiate(withOwner: nil, options: nil)[0] as! TravelTimePicker

            // Init the time picker view
            viewController.time = time
            viewController.onTimePicked = onTimePicked

            // The upper/lower empty views should show the view below
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

            // Present it
            presenter.present(viewController, animated: true)
        }
    }

    /// The callback method which brings data from the time picker.
    func onTimePicked(_ time: Date) {
        // Is there an update?
        if time != self.time {
            // Update
            self.time = time

            // Has any callback set?
            onTimeChanged?(time)
        }
    }

    /// Updates the string displayed on the panel.
    private func updateText() {
        // We need locale support
        let dateTimeString = DateFormatter.localizedString(from: time, dateStyle: .short, timeStyle: .short)

        timeLabel.text = "\("msdkui_depart_at".localized) \(dateTimeString)"
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.TravelTimePanel"

        iconView.isAccessibilityElement = false
        timeLabel.accessibilityHint = "msdkui_hint_travel_time".localized
        timeLabel.accessibilityIdentifier = "MSDKUI.TravelTimePanel.time"
    }
}
