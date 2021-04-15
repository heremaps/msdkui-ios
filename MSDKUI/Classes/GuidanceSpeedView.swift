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

/// View for displaying the current speed information.
@IBDesignable open class GuidanceSpeedView: UIView {

    // MARK: - Properties

    /// Label for the speed value.
    @IBOutlet private(set) var speedValueLabel: UILabel!

    /// Label for the speed unit.
    @IBOutlet private(set) var speedUnitLabel: UILabel!

    /// The speed used to populate the view.
    /// The default value is `nil`.
    public var speed: Measurement<UnitSpeed>? = nil {
        didSet { updateLabels() }
    }

    /// Sets the text color of the speed value information.
    /// The default value is `UIColor.colorForeground`.
    public var speedValueTextColor: UIColor = .colorForeground {
        didSet { updateLabels() }
    }

    /// Sets the text color of the speed unit information.
    /// The default value is `UIColor.colorForegroundSecondary`.
    public var speedUnitTextColor: UIColor = .colorForegroundSecondary {
        didSet { updateLabels() }
    }

    /// Sets the speed unit used by the view.
    ///
    /// The default value depends on the locale.
    /// - It uses .kilometersPerHour if current locale uses metric system for speed,
    /// - It uses .milesPerHour otherwise.
    public var unit: UnitSpeed = Locale.current.usesKilometersPerHour ? .kilometersPerHour : .milesPerHour {
        didSet { updateLabels() }
    }

    /// Sets the text alignment of all textual information.
    /// The default value is `NSTextAlignment.left`.
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            speedValueLabel.textAlignment = textAlignment
            speedUnitLabel.textAlignment = textAlignment
        }
    }

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
        setUpView()
        setUpLabels()
        setUpViewAccessibility()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
        setUpView()
        setUpLabels()
        setUpViewAccessibility()
    }

    // MARK: - Private

    /// Sets up the view after initialization.
    private func setUpView() {
        backgroundColor = .white
    }

    /// Sets up labels after view initialization.
    private func setUpLabels() {
        updateLabels()

        // Uses monospaced digits for labels.
        speedValueLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        speedUnitLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    }

    /// Sets up accessibility after view initialization.
    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityIdentifier = "MSDKUI.GuidanceSpeedView"
        accessibilityLabel = "msdkui_speed".localized
    }

    /// Updates the labels whenever the viewModel, colors or unit changes.
    private func updateLabels() {
        // Converts the speed to the appropriate unit.
        let convertedSpeed = speed?.converted(to: unit)
        let speedValue = convertedSpeed.flatMap { NSNumber(value: $0.value) }

        // Sets the labels information.
        speedValueLabel.text = speedValue.flatMap(NumberFormatter.roundHalfUpFormatter.string) ?? .missingValue
        speedUnitLabel.text = speed != nil ? MeasurementFormatter.shortSpeedFormatter.string(from: unit) : nil

        // Sets the labels colors.
        speedValueLabel.textColor = speedValueTextColor
        speedUnitLabel.textColor = speedUnitTextColor

        // Updates the view accessibility hint when the labels' content change.
        accessibilityHint = convertedSpeed.flatMap(MeasurementFormatter.longSpeedFormatter.string)
    }
}
