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

import NMAKit

/// The delegate of a `TravelTimePanel` object must adopt the `TravelTimePanelDelegate` protocol to get notified on updates.
@objc public protocol TravelTimePanelDelegate: AnyObject {

    /// Tells the delegate the date was updated.
    ///
    /// - Parameters:
    ///   - panel: The panel notifying the delegate about the date update.
    ///   - date: The updated date.
    func travelTimePanel(_ panel: TravelTimePanel, didUpdate date: Date)

    /// Tells the delegate the panel is about to present the travel time picker.
    ///
    /// A travel time panel sends this message to its delegate just before it presents a travel time picker,
    /// thereby permitting the delegate to customize the picker object before it is displayed. This method gives
    /// the delegate a chance to override state-based properties, such as background and text colors.
    ///
    /// - Parameters:
    ///   - panel: The panel presenting the travel time picker view controller.
    ///   - pickerViewController: The travel time picker to be presented.
    @objc optional func travelTimePanel(_ panel: TravelTimePanel, willDisplay pickerViewController: TravelTimePicker)
}

/// Displays the selected time from `TravelTimePicker` and when tapped,
/// opens a `TravelTimePicker` to update the selected time.
///
/// - Note: Currently, arrival time is not supported by all the HERE Maps SDK routing modes.
///              Please, check the relevant HERE Maps SDK documentation before using the
///              arrival time option for a routing mode.
@IBDesignable open class TravelTimePanel: UIView {

    // MARK: - Properties

    /// For the icon displayed on the panel.
    @IBOutlet private(set) var iconImageView: UIImageView!

    /// For the text displayed on the panel.
    @IBOutlet private(set) var timeLabel: UILabel!

    override open var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// The time displayed date on the panel.
    ///
    /// - Note: It is initialized with the current time.
    public var time = Date() {
        didSet {
            // Reflect the update
            updateText()
        }
    }

    /// The icon color.
    public var iconColor: UIColor = .colorForegroundSecondary {
        didSet { iconImageView.tintColor = iconColor }
    }

    /// The time label text color.
    public var timeLabelTextColor: UIColor = .colorForegroundSecondary {
        didSet { timeLabel.textColor = timeLabelTextColor }
    }

    /// The object which acts as the delegate of the travel time panel.
    public weak var delegate: TravelTimePanelDelegate?

    /// The intrinsic content height is important for setting the `intrinsicContentSize`.
    private var intrinsicContentHeight: CGFloat = 0.0

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    // The tap handler method.
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Instantiate travel time picker to present
        if
            let presenter = self.viewController,
            let viewControllerToPresent = UINib(nibName: String(describing: TravelTimePicker.self),
                                                bundle: .MSDKUI).instantiate(withOwner: nil).first as? TravelTimePicker {
            // Init the time picker view
            viewControllerToPresent.time = time
            viewControllerToPresent.delegate = self

            // The upper/lower empty views should show the view below
            viewControllerToPresent.modalPresentationStyle = .overCurrentContext

            // Tells the delegate the view travel time picker is about to be displayed
            delegate?.travelTimePanel?(self, willDisplay: viewControllerToPresent)

            // Presents it
            presenter.present(viewControllerToPresent, animated: true)
        }
    }

    // MARK: - Private

    /// Sets up the panel.
    private func setUp() {
        // Instantiate view
        if
            case let nibInstance = UINib(nibName: String(describing: TravelTimePanel.self), bundle: .MSDKUI).instantiate(withOwner: self),
            let view = nibInstance.first as? UIView {

            // Adds the view to the hierarchy
            addSubviewBindToEdges(view)

            // Sets the very important intrinsic content height
            intrinsicContentHeight = view.bounds.size.height
            invalidateIntrinsicContentSize()
        }

        // Adds the tag gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)

        // We need to update the style before assignments due to the iconView:
        // setting tintColor after image is set doesn't work!
        setUpColors()

        setAccessibility()

        // Sets the image in template mode (to use the tint color from `.iconColor`
        iconImageView.image = UIImage(named: "TravelTimePanel.icon", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        // Finally
        updateText()
    }

    /// Sets up the default colors.
    private func setUpColors() {
        backgroundColor = .colorBackgroundLight
        timeLabel.textColor = timeLabelTextColor
        iconImageView.tintColor = iconColor
    }

    /// Updates the string displayed on the panel.
    private func updateText() {
        let dateTimeString = DateFormatter.localizedString(from: time, dateStyle: .short, timeStyle: .short)

        timeLabel.text = "\("msdkui_depart_at".localized) \(dateTimeString)"
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.TravelTimePanel"

        iconImageView.isAccessibilityElement = false
        timeLabel.accessibilityHint = "msdkui_hint_travel_time".localized
        timeLabel.accessibilityIdentifier = "MSDKUI.TravelTimePanel.timeLabel"
    }
}

// MARK: - TravelTimePickerDelegate

extension TravelTimePanel: TravelTimePickerDelegate {

    public func travelTimePicker(_ picker: TravelTimePicker, didSelect date: Date) {
        // Is there an update?
        guard date != time else {
            return
        }

        time = date
        delegate?.travelTimePanel(self, didUpdate: date)
    }
}
