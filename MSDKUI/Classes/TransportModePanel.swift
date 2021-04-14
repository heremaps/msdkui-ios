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

/// The delegate of a `TransportModePanel` object must adopt the `TransportModePanelDelegate`
/// protocol to get notified on updates.
public protocol TransportModePanelDelegate: AnyObject {

    /// Tells the delegate a new transport mode is selected.
    ///
    /// - Parameters:
    ///   - panel: The panel notifying a new transport mode is selected.
    ///   - mode: The transport mode selected.
    func transportModePanel(_ panel: TransportModePanel, didChangeTo mode: NMATransportMode)
}

/// A panel displaying all the possible transport modes.
@IBDesignable open class TransportModePanel: UIView {

    // MARK: - Properties

    override open var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// The visible transport modes.
    ///
    /// - Note: NMATransportMode.urbanMobility and NMATransportMode.publicTransport are not supported.
    /// - Note: The buttons are listed in the order of this array.
    public var transportModes: [NMATransportMode] = [.car, .truck, .pedestrian, .bike, .scooter] {
        didSet {
            resetPanel()
            makePanel()
            reflectTransportMode()
        }
    }

    /// The selected transport mode. It sets the initially selected transport mode, too.
    ///
    /// - Note: It should be within the `transportModes` array. Otherwise, no transport mode is selected.
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

    /// Selector color.
    public var selectorColor: UIColor = .colorAccent {
        didSet {
            selectorImage = nil
            resetPanel()
            makePanel()
            reflectTransportMode()
        }
    }

    /// Panel background color.
    public var panelBackgroundColor: UIColor = .colorBackgroundDark {
        didSet {
            resetPanel()
            makePanel()
            reflectTransportMode()
        }
    }

    /// Icon color.
    public var iconColor: UIColor = .colorForegroundLight {
        didSet {
            resetPanel()
            makePanel()
            reflectTransportMode()
        }
    }

    /// The object which acts as the delegate of the transport mode panel.
    public weak var delegate: TransportModePanelDelegate?

    // All the button images
    private static let buttonImages: [NMATransportMode: UIImage?] = [
        // Creates the images in the template mode for customization as the backgroundColor and tintColor
        // properties works well with layered images
        .car: UIImage(named: "TransportModePanel.car", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .pedestrian: UIImage(named: "TransportModePanel.pedestrian", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .truck: UIImage(named: "TransportModePanel.truck", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .bike: UIImage(named: "TransportModePanel.bike", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        .scooter: UIImage(named: "TransportModePanel.scooter", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    ]

    private var selectorImage: UIImage?

    /// The image which shows the selected option visually.
    private var selector: UIImage? {
        if
            selectorImage == nil,
            let selectorView = createSelectorView(),
            let image = UIImage(view: selectorView) {
            selectorImage = image
        }

        return selectorImage
    }

    /// Stores the partnership between the transport modes and buttons on the panel.
    private var modesToButtons: [NMATransportMode: UIButton] = [:]

    /// The intrinsic content height is important for setting the `intrinsicContentSize`.
    private var intrinsicContentHeight: CGFloat = 0.0

    /// This horizontal stackview holds all the buttons.
    private let stackView = UIStackView()

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    /// Creates the view that will be displayed as selector marker in panel.
    ///
    /// - Returns: Created view, or nil if cannot create.
    func createSelectorView() -> UIView? {
        // Load view
        let selectorView = UINib(nibName: String(describing: TransportModePanel.self),
                                 bundle: .MSDKUI).instantiate(withOwner: nil).dropFirst().first as? UIView

        // Applies the style
        selectorView?.viewWithTag(1000)?.backgroundColor = selectorColor

        return selectorView
    }

    // MARK: - Private

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

        // Loads the nib file
        let nibFile = UINib(nibName: String(describing: TransportModePanel.self), bundle: .MSDKUI)

        // Stores the height of the last button added
        var lastButtonHeight = CGFloat(0)

        // One-by-one create buttons
        for mode in transportModes {
            guard
                supportedTransportModes.contains(mode),
                let buttonImage = TransportModePanel.buttonImages[mode],
                let button = nibFile.instantiate(withOwner: nil).first as? UIButton else {
                    continue
            }

            button.setImage(buttonImage, for: .normal)
            button.addTarget(self, action: #selector(onButton), for: .touchUpInside)
            setAccessibility(button, mode)

            updateStyle(button)
            stackView.addArrangedSubview(button)
            setAccessibility()

            // Inserts the new key/value pair
            modesToButtons[mode] = button

            // Stores the height of the button
            lastButtonHeight = button.bounds.size.height
        }

        // Sets the very important intrinsic content height out of the last button
        intrinsicContentHeight = lastButtonHeight
        invalidateIntrinsicContentSize()

        // Adds the stackview to the view
        addSubviewBindToEdges(stackView)

        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }

    /// Updates the style for the visuals.
    private func updateStyle(_ button: UIButton) {
        button.backgroundColor = panelBackgroundColor
        button.imageView?.tintColor = iconColor
    }

    /// Sets the selected button on the panel based on the `transportMode`.
    private func reflectTransportMode() {
        modesToButtons[transportMode]?.setBackgroundImage(selector, for: .normal)
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
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.carButton"

        case .truck:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_truck".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.truckButton"

        case .pedestrian:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_pedestrian".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.pedestrianButton"

        case .bike:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_bike".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.bikeButton"

        case .scooter:
            button.accessibilityLabel = String(format: "msdkui_transport_mode".localized, arguments: ["msdkui_scooter".localized])
            button.accessibilityHint = nil
            button.accessibilityIdentifier = "MSDKUI.TransportModePanel.scooterButton"

        default:
            assertionFailure("Unsupported mode!")
        }
    }

    /// The button handler method.
    ///
    /// - Parameter sender: The button which is tapped.
    @objc private func onButton(_ sender: UIButton) {
        // Gets the new transport mode and checks if there's an update
        guard
            let newTransportMode = modesToButtons.first(where: { $0.value === sender })?.key,
            transportMode != newTransportMode else {
                return
        }

        // Clears the previously selected button and select the new one
        modesToButtons[transportMode]?.setBackgroundImage(nil, for: .normal)
        sender.setBackgroundImage(selector, for: .normal)

        // Updates the transport mode
        transportMode = newTransportMode

        // Notifies the delegate
        delegate?.transportModePanel(self, didChangeTo: transportMode)
    }
}
