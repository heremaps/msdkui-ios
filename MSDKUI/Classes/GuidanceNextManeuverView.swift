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

/// View for displaying the next maneuver data including maneuver icon, distance and street name.
@IBDesignable open class GuidanceNextManeuverView: UIView {

    // MARK: - Types

    /// The view model used to populate the next maneuver view.
    public struct ViewModel {

        // MARK: - Properties

        var maneuverIcon: UIImage?
        var distance: Measurement<UnitLength>?
        var streetName: String?
        var distanceFormatter: MeasurementFormatter
        var accessibilityDistanceFormatter: MeasurementFormatter

        // MARK: - Public

        /// Creates and returns a `GuidanceNextManeuverView.ViewModel`.
        ///
        /// - Parameters:
        ///   - maneuverIcon: The icon of the next maneuver to be displayed.
        ///   - distance: The travel distance of the next destination to be displayed.
        ///   - streetName: The name of the next maneuver street to be displayed.
        ///   - distanceFormatter: The `MeasurementFormatter` used to format the distance information.
        ///     The default value: Uses `MeasurementFormatter.currentMediumUnitFormatter`.
        ///   - accessibilityDistanceFormatter: The `MeasurementFormatter` used to format
        ///                                     the distance information for accessibility VoiceOver.
        ///     The default value: Uses `MeasurementFormatter.currentLongUnitFormatter`.
        public init(maneuverIcon: UIImage? = nil,
                    distance: Measurement<UnitLength>? = nil,
                    streetName: String? = nil,
                    distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter,
                    accessibilityDistanceFormatter: MeasurementFormatter = .currentLongUnitFormatter) {
            self.maneuverIcon = maneuverIcon
            self.distance = distance
            self.streetName = streetName
            self.distanceFormatter = distanceFormatter
            self.accessibilityDistanceFormatter = accessibilityDistanceFormatter
        }
    }

    // MARK: - Properties

    /// Image view for the icon of the next manuever.
    @IBOutlet private(set) var maneuverImageView: UIImageView!

    /// Label for the travel distance of the next manuever.
    @IBOutlet private(set) var distanceLabel: UILabel!

    /// Label for the duration/distance separator.
    @IBOutlet private(set) var separatorLabel: UILabel!

    /// Label for the street name of the next manuever.
    @IBOutlet private(set) var streetNameLabel: UILabel!

    /// Sets the view's foreground color, i.e. the color for the maneuver icon, distance etc.
    /// The default value is `UIColor.colorForegroundSecondaryLight`.
    public var foregroundColor: UIColor = .colorForegroundSecondaryLight {
        didSet {
            maneuverImageView.tintColor = foregroundColor
            distanceLabel.textColor = foregroundColor
            separatorLabel.textColor = foregroundColor
            streetNameLabel.textColor = foregroundColor
        }
    }

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }

    /// Configures the label's content.
    ///
    /// - Parameter model: The model used to configure the view.
    public func configure(with model: ViewModel) {
        maneuverImageView.image = model.maneuverIcon
        maneuverImageView.isHidden = model.maneuverIcon == nil

        distanceLabel.text = model.distance.flatMap(model.distanceFormatter.string)
        distanceLabel.isHidden = model.distance == nil

        distanceLabel.accessibilityLabel = model.distance.flatMap(model.accessibilityDistanceFormatter.string)
        distanceLabel.sizeToFit()

        streetNameLabel.text = model.streetName
        streetNameLabel.isHidden = model.streetName == nil

        separatorLabel.isHidden = distanceLabel.isHidden || streetNameLabel.isHidden

        updateViewAccessibilityHint()
    }

    // MARK: - Private

    private func setUpView() {
        layoutMargins = .zero

        loadFromNib()
        setUpLabels()
        setUpViewAccessibility()

        // Sets the default colors
        backgroundColor = .colorBackgroundViewDark
        foregroundColor = .colorForegroundSecondaryLight

        // Sets the initial state
        configure(with: ViewModel())
    }

    private func setUpLabels() {
        [distanceLabel, separatorLabel, streetNameLabel].forEach { $0.font = .boldSystemFont(ofSize: 15) }
    }

    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityIdentifier = "MSDKUI.GuidanceNextManeuverView"
        accessibilityLabel = "msdkui_next_maneuver".localized
    }

    private func updateViewAccessibilityHint() {
        let hint = [distanceLabel, streetNameLabel]
            .compactMap { $0?.text }
            .joined(separator: ", ")

        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
