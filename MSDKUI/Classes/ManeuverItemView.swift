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

import Foundation
import NMAKit

/// The maneuver item view.
@IBDesignable open class ManeuverItemView: UIView {

    // MARK: - Properties

    /// The label for displaying the maneuver icon.
    @IBOutlet private(set) var iconImageView: UIImageView!

    /// The label for displaying the maneuver instruction.
    @IBOutlet private(set) var instructionLabel: UILabel!

    /// The label for displaying the address info.
    @IBOutlet private(set) var addressLabel: UILabel!

    /// The label for displaying the distance info.
    @IBOutlet private(set) var distanceLabel: UILabel!

    /// The stack view which contains the address and the distance labels.
    @IBOutlet private(set) var addressDistanceStackView: UIStackView!

    /// The maneuver icon image.
    public var icon: UIImage? {
        didSet {
            iconImageView.image = icon
            iconImageView.isHidden = icon == nil
        }
    }

    /// The maneuver icon image tint color. The default value is `UIColor.colorForeground`.
    public var iconTintColor: UIColor? {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }

    /// The maneuver instructions.
    public var instructions: String? {
        didSet {
            instructionLabel.text = instructions
            instructionLabel.isHidden = instructions == nil

            updateAccessibility()
        }
    }

    /// The maneuver instructions text color. The default value is `UIColor.colorForeground`.
    public var instructionsTextColor: UIColor? {
        didSet {
            instructionLabel.textColor = instructionsTextColor
        }
    }

    /// The maneuver address.
    public var address: String? {
        didSet {
            addressLabel.text = address
            addressLabel.isHidden = address == nil
            addressDistanceStackView.isHidden = addressLabel.isHidden && distanceLabel.isHidden

            updateAccessibility()
        }
    }

    /// The maneuver address text color. The default value is `UIColor.colorForegroundSecondary`.
    public var addressTextColor: UIColor? {
        didSet {
            addressLabel.textColor = addressTextColor
        }
    }

    /// The maneuver distance.
    public var distance: Measurement<UnitLength>? {
        didSet { updateDistance() }
    }

    /// The maneuver distance text color. The default value is `UIColor.colorForegroundSecondary`.
    public var distanceTextColor: UIColor? {
        didSet {
            distanceLabel.textColor = distanceTextColor
        }
    }

    /// The distance formatter. The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter {
        didSet { updateDistance() }
    }

    /// The accessibility distance formatter. The default value is `MeasurementFormatter.currentLongUnitFormatter`.
    public var accessibilityDistanceFormatter: MeasurementFormatter = .currentLongUnitFormatter {
        didSet { updateDistance() }
    }

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    // MARK: - Private

    private func setUp() {
        loadFromNib()

        setUpColors()
        setUpViewAccessibility()

        // Sets initial values
        icon = nil
        instructions = nil
        address = nil
        distance = nil
    }

    private func setUpColors() {
        backgroundColor = .colorForegroundLight

        iconTintColor = .colorForeground
        instructionsTextColor = .colorForeground
        addressTextColor = .colorForegroundSecondary
        distanceTextColor = .colorForegroundSecondary
    }

    private func setUpViewAccessibility() {
        iconImageView.isAccessibilityElement = false
        instructionLabel.isAccessibilityElement = false
        addressLabel.isAccessibilityElement = false
        distanceLabel.isAccessibilityElement = false

        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityLabel = "msdkui_maneuver".localized
        accessibilityIdentifier = "MSDKUI.ManeuverItemView"
    }

    private func updateAccessibility() {
        let formattedDistance = distance.map(accessibilityDistanceFormatter.string)
        let hint = [instructions, address, formattedDistance].compactMap { $0 }
        accessibilityHint = hint.isEmpty ? nil : hint.joined(separator: ", ")
    }

    public func updateDistance() {
        distanceLabel.text = distance.map(distanceFormatter.string)
        distanceLabel.isHidden = distance == nil
        addressDistanceStackView.isHidden = addressLabel.isHidden && distanceLabel.isHidden

        updateAccessibility()
    }
}
