//
// Copyright (C) 2017-2020 HERE Europe B.V.
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

/// A view for displaying the maneuvers during guidance.
@IBDesignable open class GuidanceManeuverView: UIView {

    // MARK: - Types

    /// All the supported guidance maneuver view states.
    ///
    /// - noData: State where the view does not have maneuver data (e.g. initial state).
    /// - updating: State where the view awaits maneuver data.
    /// - data: State where the view contains maneuver data.
    public enum State: Equatable {
        case noData
        case updating
        case data(_ data: GuidanceManeuverData)
    }

    // MARK: - Properties

    /// The content stack view.
    @IBOutlet private(set) var contentStackView: UIStackView!

    /// The labels stack view (distance, info1, info2, separator, and message).
    @IBOutlet private(set) var labelsStackView: UIStackView!

    /// The activity indicator.
    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    /// The maneuver icon image view.
    @IBOutlet private(set) var maneuverIconImageView: UIImageView!

    /// The next road icon image view.
    @IBOutlet private(set) var nextRoadIconImageView: UIImageView!

    /// The distance label.
    @IBOutlet private(set) var distanceLabel: UILabel!

    /// The info1 label.
    @IBOutlet private(set) var info1Label: UILabel!

    /// The info2 label.
    @IBOutlet private(set) var info2Label: UILabel!

    /// The message separator view, adding additional vertical space before the message label.
    @IBOutlet private(set) var messageSeparatorView: UIView!

    /// The message label.
    @IBOutlet private(set) var messageLabel: UILabel!

    /// The view state. The default value is `.noData`.
    public var state: State = .noData {
        didSet {
            switch state {
            case .noData:
                displayNoData()

            case .updating:
                displayBusyState()

            case .data(let maneuverData):
                displayData(maneuverData)
            }

            updateSeparator()
        }
    }

    /// The axis along which the arranged views are laid out.
    /// The default value is `NSLayoutConstraint.Axis.horizontal`.
    public var axis: NSLayoutConstraint.Axis {
        get { contentStackView.axis }
        set {
            contentStackView.axis = newValue

            switch newValue {
            case .horizontal:
                contentStackView.alignment = .top
                contentStackView.spacing = 16

            case .vertical:
                contentStackView.alignment = .leading
                contentStackView.spacing = 12

            @unknown default:
                fatalError("Unknown axis")
            }

            updateSeparator()
        }
    }

    /// The distance measurement formatter.
    /// The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter {
        didSet {
            guard case let .data(maneuverData) = state else {
                return
            }

            displayData(maneuverData)
        }
    }

    /// Sets the view's foreground color, i.e. the color for the icons,
    /// text and activity indicators. The default value is `UIColor.colorForegroundLight`.
    public var foregroundColor: UIColor? {
        didSet {
            distanceLabel.textColor = foregroundColor
            info1Label.textColor = foregroundColor
            info2Label.textColor = highlightManeuver ? tintColor : foregroundColor
            messageLabel.textColor = foregroundColor

            maneuverIconImageView.tintColor = foregroundColor
            nextRoadIconImageView.tintColor = foregroundColor
            activityIndicator.color = foregroundColor
        }
    }

    /// A Boolean value that determines whether the maneuver should be highlighted.
    /// If `true`, sets the maneuver text color to the view's `.tintColor`.
    /// If `false`, sets the maneuver text color to `.foregroundColor`.
    /// The default value is `false`.
    public var highlightManeuver: Bool = false {
        didSet {
            info2Label.textColor = highlightManeuver ? tintColor : foregroundColor
        }
    }

    // MARK: - Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }

    // MARK: - Private

    private func setUpView() {
        // Loads the xib
        loadFromNib()

        // Sets the default colors
        backgroundColor = .colorBackgroundDark
        foregroundColor = .colorForegroundLight

        // Uses monospaced font to have fixed distances between digits
        distanceLabel.font = .monospacedDigitSystemFont(ofSize: 34, weight: .regular)

        // Sets the initial state
        state = .noData
    }

    /// Displays the no data state.
    private func displayNoData() {
        // Shows the instruction icon
        maneuverIconImageView.image = UIImage(named: "car_position_marker", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        maneuverIconImageView.isHidden = false

        // Sets the corrent message label text
        messageLabel.text = "msdkui_maneuverpanel_nodata".localized
        messageLabel.isHidden = false

        // Stops the activity indicator animation, automatically hidding it
        activityIndicator.stopAnimating()

        // Hides all the other views
        nextRoadIconImageView.image = nil
        [distanceLabel, info1Label, info2Label].forEach { $0?.text = nil }
        [nextRoadIconImageView, distanceLabel, info1Label, info2Label].forEach { $0.isHidden = true }
    }

    /// Displays the busy state.
    private func displayBusyState() {
        // Animates the activity indicator
        activityIndicator.startAnimating()

        // Sets the corrent message label text
        messageLabel.text = "msdkui_maneuverpanel_updating".localized
        messageLabel.isHidden = false

        // Hides all the other views
        [maneuverIconImageView, nextRoadIconImageView].forEach { $0?.image = nil }
        [distanceLabel, info1Label, info2Label].forEach { $0?.text = nil }
        [maneuverIconImageView, nextRoadIconImageView, distanceLabel, info1Label, info2Label].forEach { $0.isHidden = true }
    }

    /// Displays the maneuver data state.
    private func displayData(_ data: GuidanceManeuverData) {
        // Stops the activity indicator animation, automatically hidding it
        activityIndicator.stopAnimating()

        // Sets the maneuver icon if valid, otherwise hides the view
        maneuverIconImageView.image = data.maneuverIcon
        maneuverIconImageView.isHidden = data.maneuverIcon == nil

        // Sets the next road icon if valid, otherwise hides the view
        nextRoadIconImageView.image = data.nextRoadIcon
        nextRoadIconImageView.isHidden = data.nextRoadIcon == nil

        // Sets the distance text if valid, otherwise hides the label
        distanceLabel.text = data.distance.map(distanceFormatter.string)
        distanceLabel.isHidden = data.distance == nil

        // Sets the info1 text if valid, otherwise hides the label
        info1Label.text = data.info1
        info1Label.isHidden = data.info1 == nil

        // Sets the info2 text if valid, otherwise hides the label
        info2Label.text = data.info2
        info2Label.isHidden = data.info2 == nil

        // Resets the text label and hides it
        messageLabel.text = nil
        messageLabel.isHidden = true
    }

    /// Show or hide the message separator view depending on the axis and state.
    private func updateSeparator() {
        switch (axis, state) {
        case (.horizontal, .noData), (.horizontal, .updating):
            messageSeparatorView.isHidden = false

        default:
            messageSeparatorView.isHidden = true
        }
    }
}
