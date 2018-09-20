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

@testable import MSDKUI
import XCTest

class TransportModePanelTests: XCTestCase {
    // The panel
    private var panel = TransportModePanel()

    /// Test the default transport modes.
    func testDefaultTransporModes() {
        XCTAssertEqual(panel.transportModes, [.car, .truck, .pedestrian, .bike, .scooter],
                       "It has the correct transport modes enabled by default.")
    }

    /// Test the panel intrinsic content size.
    func testIntrinsicContentSize() {
        // Find the last button
        let lastPanelButton = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
            .last

        XCTAssertEqual(panel.intrinsicContentSize.width, UIViewNoIntrinsicMetric,
                       "It doesn't constrain the width.")
        XCTAssertEqual(panel.intrinsicContentSize.height, lastPanelButton?.bounds.height,
                       "It constrains the height according to the last button added to the panel.")
    }

    /// Test the default transport mode images.
    func testDefaultTransporModeImages() {
        let images = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
            .compactMap { $0.image(for: .normal) }

        verifyButtonImage(images?[0], usingTemplateNamed: "TransportModePanel.car")
        verifyButtonImage(images?[1], usingTemplateNamed: "TransportModePanel.truck")
        verifyButtonImage(images?[2], usingTemplateNamed: "TransportModePanel.pedestrian")
        verifyButtonImage(images?[3], usingTemplateNamed: "TransportModePanel.bike")
        verifyButtonImage(images?[4], usingTemplateNamed: "TransportModePanel.scooter")
    }

    /// Test the default transport mode accessibility strings.
    func testDefaultTransporModeAccessibility() {
        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }

        verifyAccessibilityForButton(buttons?[0], type: "msdkui_car".localized, identifier: "MSDKUI.TransportModePanel.car")
        verifyAccessibilityForButton(buttons?[1], type: "msdkui_truck".localized, identifier: "MSDKUI.TransportModePanel.truck")
        verifyAccessibilityForButton(buttons?[2], type: "msdkui_pedestrian".localized, identifier: "MSDKUI.TransportModePanel.pedestrian")
        verifyAccessibilityForButton(buttons?[3], type: "msdkui_bike".localized, identifier: "MSDKUI.TransportModePanel.bike")
        verifyAccessibilityForButton(buttons?[4], type: "msdkui_scooter".localized, identifier: "MSDKUI.TransportModePanel.scooter")
    }

    /// Tests the panel with a single transport mode set.
    func testWhenTransportModesHasASingleMode() {
        panel.transportModes = [.car]

        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }

        XCTAssertEqual(buttons?.count, 1, "It returns the correct number of buttons.")

        verifyAccessibilityForButton(buttons?[0], type: "msdkui_car".localized, identifier: "MSDKUI.TransportModePanel.car")
    }

    /// Tests the panel with multiple transport modes set.
    func testWhenTransportModesHasMultipleModes() {
        panel.transportModes = [.car, .bike]

        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }

        XCTAssertEqual(buttons?.count, 2, "It returns the correct number of buttons.")

        verifyAccessibilityForButton(buttons?[0], type: "msdkui_car".localized, identifier: "MSDKUI.TransportModePanel.car")
        verifyAccessibilityForButton(buttons?[1], type: "msdkui_bike".localized, identifier: "MSDKUI.TransportModePanel.bike")
    }

    /// Tests the panel with unsupported transport modes.
    func testWhenTransportModesDoesntHaveSupportModes() {
        panel.transportModes = [.publicTransport, .urbanMobility]

        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }

        XCTAssertEqual(buttons?.count, 0, "It doesn't have buttons.")
    }

    /// Tests the action when the current transport mode is tapped.
    func testWhenCurrentTransportModeIsTapped() {
        var didCallOnModeChanged = false

        // Set the current transport mode (car)
        panel.transportMode = .car

        // Set the callback function to be called when the mode changes
        panel.onModeChanged = { _ in
            didCallOnModeChanged = true
        }

        // Find the first - and current - button (car)
        let carButton = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
            .first

        // Tap on the first button
        carButton?.sendActions(for: .touchUpInside)

        XCTAssertFalse(didCallOnModeChanged, "It doesn't call the callback function.")
        XCTAssertEqual(panel.transportMode, .car, "It doesn't change the transport mode.")
    }

    /// Tests the action when the current transport mode is tapped.
    func testWhenAnotherTransportModeIsTapped() {
        var didCallOnModeChanged = false
        var passedMode: NMATransportMode?

        // Set the current transport mode (car)
        panel.transportMode = .car

        // Set the callback function to be called when the mode changes
        panel.onModeChanged = { newMode in
            didCallOnModeChanged = true
            passedMode = newMode
        }

        // Find the last button (scooter)
        let scooterButton = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
            .last

        // Tap on the last button
        scooterButton?.sendActions(for: .touchUpInside)

        XCTAssertTrue(didCallOnModeChanged, "It calls teh callback function.")
        XCTAssertEqual(passedMode, .scooter, "It passes the new transport mode to the callback function.")
        XCTAssertEqual(panel.transportMode, .scooter, "It selects the correct transport mode.")
    }

    /// Tests the panel default colors.
    func testDefaultColors() {
        // Get buttons
        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
        XCTAssertNotNil(buttons, "It has buttons")

        // Check colors
        buttons?.forEach {
            XCTAssertEqual($0.backgroundColor, .colorBackgroundDark, "It has correct background color")
            XCTAssertEqual($0.imageView?.tintColor, .colorForegroundLight, "It has correct icon color")
        }

        let markerColor = panel.createSelectorView()?.viewWithTag(1000)?.backgroundColor
        XCTAssertEqual(markerColor, .colorAccent, "It has correct marker color")
    }

    /// Test the panel color updates.
    func testColorUpdates() {
        panel.panelBackgroundColor = .red
        panel.selectorColor = .green
        panel.iconColor = .blue

        // Get buttons
        let buttons = panel.subviews.first?.subviews
            .compactMap { $0 as? UIButton }
        XCTAssertNotNil(buttons, "It has buttons")

        // Check colors
        buttons?.forEach {
            XCTAssertEqual($0.backgroundColor, .red, "It has correct background color")
            XCTAssertEqual($0.imageView?.tintColor, .blue, "It has correct icon color")
        }

        let markerColor = panel.createSelectorView()?.viewWithTag(1000)?.backgroundColor
        XCTAssertEqual(markerColor, .green, "It has correct marker color")
    }

    // MARK: - Helpers

    private func verifyButtonImage(_ image: UIImage?,
                                   usingTemplateNamed name: String,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        XCTAssertEqual(image, UIImage(named: name, in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
                       "It matches the expected image.", file: file, line: line)
    }

    private func verifyAccessibilityForButton(_ button: UIButton?,
                                              type: String,
                                              identifier: String,
                                              file: StaticString = #file,
                                              line: UInt = #line) {
        XCTAssertLocalized(button?.accessibilityLabel,
                           formatKey: "msdkui_transport_mode",
                           arguments: type,
                           bundle: .MSDKUI,
                           message: "It has the correct accessibility label.", file: file, line: line)
        XCTAssertNil(button?.accessibilityHint,
                     "It has the correct accessibility hint.", file: file, line: line)
        XCTAssertEqual(button?.accessibilityIdentifier,
                       identifier, "It has the correct accessibility identifier.", file: file, line: line)
    }
}
