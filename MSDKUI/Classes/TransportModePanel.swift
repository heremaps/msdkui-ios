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

import Foundation
import NMAKit

/// A panel displaying all the possible transport modes.
@IBDesignable open class TransportModePanel: UIView {
    /// The visible transport modes.
    ///
    /// - Important: NMATransportMode.urbanMobility and NMATransportMode.publicTransport are not supported.
    /// - Important: The buttons are listed in the order of this array.
    public var transportModes: [NMATransportMode] = [.car, .truck, .pedestrian, .bike, .scooter] {
        didSet {
            resetPanel()
            makePanel()
            reflectTransportMode()
        }
    }

    /// The selected transport mode. It sets the initially selected transport mode, too.
    ///
    /// - Important: It should be within the `transportModes` array. Otherwise, no transport mode is selected.
    public var transportMode: NMATransportMode = .car {
        willSet {
            // Any update?
            if transportMode != newValue {
                // Clear the existing one
                modesToButtons[transportMode]?.setBackgroundImage(nil, for: .normal)
            }
        }
        didSet {
            // Any update?
            if transportMode != oldValue {
                reflectTransportMode()
            }
        }
    }

    /// The callback which is fired when a transport mode selected.
    public var onModeChanged: ((NMATransportMode) -> Void)?

    // All the button images
    private static let buttonImages: [NMATransportMode: UIImage?] = [
        // Create the images in the template mode for customization as the backgroundColor and tintColor
        // properties works well with layered images
        .car: UIImage(named: "TransportModePanel.car", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .pedestrian: UIImage(named: "TransportModePanel.pedestrian", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .truck: UIImage(named: "TransportModePanel.truck", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .bike: UIImage(named: "TransportModePanel.bike", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .scooter: UIImage(named: "TransportModePanel.scooter", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    ]

    /// The image which shows the selected option visually.
    private static var selector: UIImage? = {
        // Load the nib file and create the selector view
        guard
            case let nibFile = UINib(nibName: String(describing: TransportModePanel.self), bundle: .MSDKUI),
            let selectorView = nibFile.instantiate(withOwner: nil, options: nil)[1] as? UIView else {
            return nil
        }

        // Apply the style
        selectorView.viewWithTag(1000)?.backgroundColor = Styles.shared.transportModePanelSelectorColor

        return UIImage(view: selectorView)
    }()

    /// Stores the partnership between the transport modes and buttons on the panel.
    private var modesToButtons: [NMATransportMode: UIButton] = [:]

    /// The intrinsic content height is important for supporting the scroll views.
    private var intrinsicContentHeight: CGFloat = 0.0

    /// This horizontal stackview holds all the buttons.
    private let stackView = UIStackView()

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
        // Customise the view settings
        isMultipleTouchEnabled = false
        isUserInteractionEnabled = true

        // Stackview settings
        stackView.spacing = 0.0
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Finally
        makePanel()

        // Set the selected button
        reflectTransportMode()
    }

    /// Creates the buttons.
    private func makePanel() {
        // Only the transport modes in this array are supported
        let supportedTransportModes: [NMATransportMode] = [.car, .pedestrian, .truck, .bike, .scooter]

        // Load the nib file
        let nibFile = UINib(nibName: String(describing: TransportModePanel.self), bundle: .MSDKUI)

        // Store the height of the last button added
        var lastButtonHeight = CGFloat(0)

        // One-by-one create buttons
        for mode in transportModes {
            guard
                supportedTransportModes.contains(mode),
                let buttonImage = TransportModePanel.buttonImages[mode],
                let button = nibFile.instantiate(withOwner: nil, options: nil).first as? UIButton else {
                continue
            }

            button.setImage(buttonImage, for: .normal)
            button.addTarget(self, action: #selector(onButton), for: .touchUpInside)
            setAccessibility(button, mode)

            updateStyle(button)
            stackView.addArrangedSubview(button)
            setAccessibility()

            // Insert the new key/value pair
            modesToButtons[mode] = button

            // Store the height of the button
            lastButtonHeight = button.bounds.size.height
        }

        // Set the very important intrinsic content height out of the last button
        intrinsicContentHeight = lastButtonHeight
        invalidateIntrinsicContentSize()

        // Add the stackview to the view
        addSubviewBindToEdges(stackView)

        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }

    /// Updates the style for the visuals.
    private func updateStyle(_ button: UIButton) {
        button.backgroundColor = Styles.shared.transportModePanelBackgroundColor
        button.imageView?.tintColor = Styles.shared.transportModePanelIconColor
    }

    /// Sets the selected button on the panel based on the `transportMode`.
    private func reflectTransportMode() {
        modesToButtons[transportMode]?.setBackgroundImage(TransportModePanel.selector, for: .normal)
    }

    /// The button handler method.
    ///
    /// - Parameter sender: The button which is tapped.
    @objc private func onButton(_ sender: UIButton) {
        // Get the new transport mode and checks if there's an update
        guard
            let newTransportMode = modesToButtons.first(where: { $0.value === sender })?.key,
            transportMode != newTransportMode else {
            return
        }

        // Clear the previously selected button and select the new one
        modesToButtons[transportMode]?.setBackgroundImage(nil, for: .normal)
        sender.setBackgroundImage(TransportModePanel.selector, for: .normal)

        // Update the transport mode
        transportMode = newTransportMode

        // Has any callback set?
        onModeChanged?(transportMode)
    }

    /// Resets the panel, i.e. clears all the existing artefacts.
    private func resetPanel() {
        // Clear the existing partnerships
        modesToButtons.removeAll()

        // Clear the stackview
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // Reset
        intrinsicContentHeight = 0.0
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.TransportModePanel"
    }

    /// Sets the accessibility strings for the given button and mode.
    ///
    /// - Parameter button: The button to be updated.
    /// - Parameter mode: The mode for which the accessibility strings are requested.
    private func setAccessibility(_ button: UIButton, _ mode: NMATransportMode) {
        switch mode {
        case .car:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_car".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.car"

        case .truck:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_truck".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.truck"

        case .pedestrian:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_pedestrian".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.pedestrian"

        case .bike:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_bike".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.bike"

        case .scooter:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_scooter".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.scooter"

        default:
            assertionFailure("Unsupported mode!")
        }
    }
}
