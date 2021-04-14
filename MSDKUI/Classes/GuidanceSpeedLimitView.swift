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

/// View for displaying the speed limit information.
@IBDesignable open class GuidanceSpeedLimitView: UIView {

    // MARK: - Properties

    /// Image View for the background image.
    @IBOutlet public private(set) var backgroundImageView: UIImageView!

    /// Label for the speed limit.
    @IBOutlet private(set) var speedLimitLabel: UILabel!

    /// The speed limit used to populate the view.
    public var speedLimit: Measurement<UnitSpeed>? = nil {
        didSet { updateContent() }
    }

    /// Sets the speed limit unit used by the view.
    ///
    /// The default value depends on the locale.
    /// - It uses .kilometersPerHour if current locale uses metric system for speed,
    /// - It uses .milesPerHour otherwise.
    public var unit: UnitSpeed = Locale.current.usesKilometersPerHour ? .kilometersPerHour : .milesPerHour {
        didSet { updateContent() }
    }

    /// Sets the text color of the speed limit information.
    /// The default value is `UIColor.colorForeground`.
    public var speedLimitTextColor: UIColor = .colorForeground {
        didSet { updateContent() }
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
        updateContent()

        // Uses monospaced digits for labels
        speedLimitLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
    }

    /// Sets up accessibility after view initialization.
    private func setUpViewAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityIdentifier = String(reflecting: GuidanceSpeedLimitView.self)
        accessibilityLabel = "msdkui_speed_limit".localized
    }

    /// Updates label and accessibility hint.
    private func updateContent() {
        let convertedSpeed = speedLimit?.converted(to: unit)
        let speedValue = convertedSpeed.map { NSNumber(value: $0.value) }

        speedLimitLabel.text = speedValue.flatMap(NumberFormatter.roundHalfUpFormatter.string)
        speedLimitLabel.textColor = speedLimitTextColor

        accessibilityHint = convertedSpeed.map(MeasurementFormatter.longSpeedFormatter.string)
    }
}
