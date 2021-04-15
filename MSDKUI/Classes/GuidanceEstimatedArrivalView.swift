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

/// View for displaying the estimated arrival information, which includes
/// estimated time of arrival (ETA), time to arrival (TTA), and travel distance
/// to destination.
@IBDesignable open class GuidanceEstimatedArrivalView: UIView {

    // MARK: - Properties

    /// Label for the estimated time of arrival (ETA).
    @IBOutlet private(set) var estimatedTimeOfArrivalLabel: UILabel!

    /// Label for the duration.
    @IBOutlet private(set) var durationLabel: UILabel!

    /// Label for the remaining distance.
    @IBOutlet private(set) var distanceLabel: UILabel!

    /// Label for the duration/distance separator.
    @IBOutlet private(set) var separatorLabel: UILabel!

    /// Sets the text color of the estimated time of arrival information.
    /// The default value is `UIColor.colorForeground`.
    public var primaryInfoTextColor: UIColor = .colorForeground {
        didSet {
            estimatedTimeOfArrivalLabel.textColor = primaryInfoTextColor
        }
    }

    /// Sets the text color of duration and distance information.
    /// The default value is `UIColor.colorForegroundSecondary`.
    public var secondaryInfoTextColor: UIColor = .colorForegroundSecondary {
        didSet {
            durationLabel.textColor = secondaryInfoTextColor
            distanceLabel.textColor = secondaryInfoTextColor
            separatorLabel.textColor = secondaryInfoTextColor
        }
    }

    /// Sets the text alignment of all textual information.
    /// The default value is `NSTextAlignment.center`.
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            estimatedTimeOfArrivalLabel.textAlignment = textAlignment
            durationLabel.textAlignment = textAlignment
            distanceLabel.textAlignment = textAlignment
        }
    }

    /// The estimated time of arrival to be displayed.
    public var estimatedTimeOfArrival: Date? {
        didSet {
            updateEstimatedTimeOfArrivalLabel()
            updateViewAccessibilityHint()
        }
    }

    /// The travel time duration to be displayed.
    public var duration: Measurement<UnitDuration>? {
        didSet {
            updateDurationLabel()
            updateViewAccessibilityHint()
        }
    }

    /// The travel distance to destination to be displayed.
    public var distance: Measurement<UnitLength>? {
        didSet {
            updateDistanceLabel()
            updateViewAccessibilityHint()
        }
    }

    /// The `DateFormatter` used to format the ETA information.
    /// The default value is `DateFormatter.currentShortTimeFormatter`.
    public var estimatedTimeOfArrivalFormatter: DateFormatter = .currentShortTimeFormatter {
        didSet {
            updateEstimatedTimeOfArrivalLabel()
            updateViewAccessibilityHint()
        }
    }

    /// The `MeasurementFormatter` used to format the duration information.
    /// The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var durationFormatter: MeasurementFormatter = .currentMediumUnitFormatter {
        didSet {
            updateDurationLabel()
            updateViewAccessibilityHint()
        }
    }

    /// The `MeasurementFormatter` used to format the distance information.
    /// The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter {
        didSet {
            updateDistanceLabel()
            updateViewAccessibilityHint()
        }
    }

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
        setUpLabels()
        setUpViewAccessibility()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
        setUpLabels()
        setUpViewAccessibility()
    }

    // MARK: - Private

    /// Sets up labels after view initialization.
    private func setUpLabels() {
        // Sets the initial state of labels to nil (empty model)
        estimatedTimeOfArrival = nil
        duration = nil
        distance = nil

        // Uses monospaced digits for labels
        estimatedTimeOfArrivalLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        [durationLabel, distanceLabel].forEach { $0.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular) }

        // Sets the default colors
        primaryInfoTextColor = .colorForeground
        secondaryInfoTextColor = .colorForegroundSecondary
    }

    /// Sets up accessibility after view initialization.
    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityIdentifier = "MSDKUI.GuidanceEstimatedArrivalView"
        accessibilityLabel = "msdkui_estimated_arrival".localized
    }

    /// Updates the estimated time of arrival label.
    private func updateEstimatedTimeOfArrivalLabel() {
        let etaString = estimatedTimeOfArrival.map(estimatedTimeOfArrivalFormatter.string)
        estimatedTimeOfArrivalLabel.text = etaString ?? .missingValue
    }

    /// Updates the duration label.
    private func updateDurationLabel() {
        let durationString = duration.map(durationFormatter.string)
        durationLabel.text = durationString ?? .missingValue
    }

    /// Updates the distance label.
    private func updateDistanceLabel() {
        let distanceString = distance.map(distanceFormatter.string)
        distanceLabel.text = distanceString ?? .missingValue
    }

    /// Updates the view accessibility hint to match the properties' content.
    private func updateViewAccessibilityHint() {
        let etaString = estimatedTimeOfArrival.map(estimatedTimeOfArrivalFormatter.string)
        let durationString = duration.map(durationFormatter.string)
        let distanceString = distance.map(distanceFormatter.string)

        let hint = [etaString, durationString, distanceString].compactMap { $0 }.joined(separator: ", ")
        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
