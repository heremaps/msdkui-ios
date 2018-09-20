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

/// View for displaying the next maneuver data including maneuver icon, distance and street name.
@IBDesignable open class GuidanceNextManeuverView: UIView {

    // MARK: - Public types

    /// The view model used to populate the next maneuver view.
    public struct ViewModel {
        var maneuverIcon: UIImage?
        var distance: Measurement<UnitLength>
        var streetName: String?
        var distanceFormatter: MeasurementFormatter

        /// Creates and returns a `GuidanceNextManeuverView.ViewModel`.
        ///
        /// - Parameters:
        ///   - maneuverIcon: The icon of next maneuver to be displayed.
        ///   - distance: The travel distance of the next destination to be displayed.
        ///   - streetName: The name of the next maneuver street to be displayed.
        ///   - distanceFormatter: The `MeasurementFormatter` used to format the distance information.
        ///     Default value: Uses `MeasurementFormatter.currentMediumUnitFormatter`.
        public init(maneuverIcon: UIImage?,
                    distance: Measurement<UnitLength>,
                    streetName: String?,
                    distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter) {
            self.maneuverIcon = maneuverIcon
            self.distance = distance
            self.streetName = streetName
            self.distanceFormatter = distanceFormatter
        }
    }

    // MARK: - Outlets

    /// Image view for the icon of the next manuever.
    @IBOutlet private(set) weak var maneuverImageView: UIImageView!

    /// Label for the travel distance of the next manuever.
    @IBOutlet private(set) weak var distanceLabel: UILabel!

    /// Label for the duration/distance separator.
    @IBOutlet private(set) weak var separatorLabel: UILabel!

    /// Label for the street name of the next manuever.
    @IBOutlet private(set) weak var streetNameLabel: UILabel!

    // MARK: - Public properties

    /// Sets the view's foreground color, i.e. the color for the maneuver icon, distance etc.
    /// The default foreground color is colorForegroundSecondaryLight.
    public var foregroundColor: UIColor = .colorForegroundSecondaryLight {
        didSet {
            // Note the next maneuver icon is tinted in GuidanceNextManeuverView.configure(with:)
            distanceLabel.textColor = foregroundColor
            separatorLabel.textColor = foregroundColor
            streetNameLabel.textColor = foregroundColor
        }
    }

    /// Sets the text alignment of all textual information.
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            distanceLabel.textAlignment = textAlignment
            streetNameLabel.textAlignment = textAlignment
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

    // MARK: - Public

    /// Configures the labels' content.
    ///
    /// - Parameter model: The model used to configure the view.
    public func configure(with model: ViewModel) {
        maneuverImageView.image = model.maneuverIcon
        maneuverImageView.tintColor = foregroundColor
        distanceLabel.text = model.distanceFormatter.string(from: model.distance)
        distanceLabel.sizeToFit()

        // When ViewModel.streetName is nil, the dot & street name labels should be hidden
        if let streetName = model.streetName {
            streetNameLabel.text = streetName
            separatorLabel.isHidden = false
            streetNameLabel.isHidden = false
        } else {
            streetNameLabel.text = nil
            separatorLabel.isHidden = true
            streetNameLabel.isHidden = true
        }

        // Update the view accessibility hint when the labels' content change
        updateViewAccessibilityHint()
    }

    // MARK: - Private

    /// Sets up the view.
    private func setUpView() {
        loadFromNib()
        setUpLabels()
        setUpViewAccessibility()

        // Sets the default colors
        backgroundColor = .colorBackgroundViewDark
        foregroundColor = .colorForegroundSecondaryLight
    }

    /// Sets up labels after view initialization.
    private func setUpLabels() {
        // Sets the initial state of labels to nil (empty model)
        [distanceLabel, streetNameLabel].forEach { $0.text = nil }

        // Uses bold system fonts for labels
        [distanceLabel, separatorLabel, streetNameLabel].forEach { $0.font = .boldSystemFont(ofSize: 15) }
    }

    /// Sets up accessibility after view initialization.
    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitStaticText
        accessibilityIdentifier = "MSDKUI.GuidanceNextManeuverView"
        accessibilityLabel = "msdkui_next_maneuver".localized
    }

    /// Updates the view accessibility hint to match the labels' content.
    private func updateViewAccessibilityHint() {
        let hint = [distanceLabel, streetNameLabel]
            .flatMap { $0?.text }
            .joined(separator: ", ")

        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
