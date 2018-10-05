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

import UIKit

/// View for displaying the estimated arrival information, which includes
/// estimated time of arrival (ETA), time to arrival (TTA), and travel distance
/// to destination.
@IBDesignable open class GuidanceEstimatedArrivalView: UIView {

    // MARK: - Public types

    /// The view model used to populate the arrival view.
    public struct ViewModel {

        var estimatedTimeOfArrival: Date?
        var duration: Measurement<UnitDuration>?
        var distance: Measurement<UnitLength>?
        var estimatedTimeOfArrivalFormatter: DateFormatter
        var durationFormatter: MeasurementFormatter
        var distanceFormatter: MeasurementFormatter

        /// Creates and returns a `GuidanceEstimatedArrivalView.ViewModel`.
        ///
        /// - Parameters:
        ///   - estimatedTimeOfArrival: The estimated time of arrival to be displayed.
        ///   - duration: The travel time duration to be displayed.
        ///   - distance: The travel distance to destination to be displayed.
        ///   - estimatedTimeOfArrivalFormatter: The `DateFormatter` used to format the ETA information.
        ///     Default value: `DateFormatter.currentShortTimeFormatter`.
        ///   - durationFormatter: The `MeasurementFormatter` used to format the duration information.
        ///     Default value: `MeasurementFormatter.currentMediumUnitFormatter`.
        ///   - distanceFormatter: The `MeasurementFormatter` used to format the distance information.
        ///     Default value: Uses `MeasurementFormatter.currentMediumUnitFormatter`.
        public init(estimatedTimeOfArrival: Date? = nil,
                    duration: Measurement<UnitDuration>? = nil,
                    distance: Measurement<UnitLength>? = nil,
                    estimatedTimeOfArrivalFormatter: DateFormatter = .currentShortTimeFormatter,
                    durationFormatter: MeasurementFormatter = .currentMediumUnitFormatter,
                    distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter) {
            self.estimatedTimeOfArrival = estimatedTimeOfArrival
            self.duration = duration
            self.distance = distance
            self.estimatedTimeOfArrivalFormatter = estimatedTimeOfArrivalFormatter
            self.durationFormatter = durationFormatter
            self.distanceFormatter = distanceFormatter
        }

        /// A Boolean value indicating whether the model is complete.
        public var isComplete: Bool {
            return estimatedTimeOfArrival != nil && duration != nil && distance != nil
        }
    }

    // MARK: - Outlets

    /// Label for the estimated time of arrival (ETA).
    @IBOutlet private(set) weak var estimatedTimeOfArrivalLabel: UILabel!

    /// Label for the duration.
    @IBOutlet private(set) weak var durationLabel: UILabel!

    /// Label for the remaining distance.
    @IBOutlet private(set) weak var distanceLabel: UILabel!

    /// Label for the duration/distance separator.
    @IBOutlet private(set) weak var separatorLabel: UILabel!

    // MARK: - Public properties

    /// Sets the text color of the estimated time of arrival information.
    public var primaryInfoTextColor: UIColor = .colorForeground {
        didSet {
            estimatedTimeOfArrivalLabel.textColor = primaryInfoTextColor
        }
    }

    /// Sets the text color of duration and distance information.
    public var secondaryInfoTextColor: UIColor = .colorForegroundSecondary {
        didSet {
            durationLabel.textColor = secondaryInfoTextColor
            distanceLabel.textColor = secondaryInfoTextColor
            separatorLabel.textColor = secondaryInfoTextColor
        }
    }

    /// Sets the text alignment of all textual information.
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            estimatedTimeOfArrivalLabel.textAlignment = textAlignment
            durationLabel.textAlignment = textAlignment
            distanceLabel.textAlignment = textAlignment
        }
    }

    // MARK: - Life cycle

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

    // MARK: - Public

    /// Configures the labels' content.
    ///
    /// - Parameter model: The model used to configure the view (and labels).
    public func configure(with model: ViewModel) {
        let eta = model.estimatedTimeOfArrival.map(model.estimatedTimeOfArrivalFormatter.string)
        let duration = model.duration.map(model.durationFormatter.string)
        let distance = model.distance.map(model.distanceFormatter.string)
        let missingInformation = "msdkui_value_not_available".nonlocalizable

        estimatedTimeOfArrivalLabel.text = eta ?? missingInformation
        durationLabel.text = duration ?? missingInformation
        distanceLabel.text = distance ?? missingInformation

        // Update the view accessibility hint when the model changes
        updateViewAccessibilityHint(with: [eta, duration, distance])
    }

    // MARK: - Private

    /// Sets up labels after view initialization.
    private func setUpLabels() {
        // Sets the initial state of labels to nil (empty model)
        configure(with: ViewModel())

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

    /// Updates the view accessibility hint to match the labels' content.
    private func updateViewAccessibilityHint(with information: [String?]) {
        let hint = information.compactMap { $0 }.joined(separator: ", ")
        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
