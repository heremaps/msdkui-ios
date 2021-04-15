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

import MSDKUI
@testable import MSDKUI_Demo
import XCTest

final class OptionPanelViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: OptionPanelViewController?

    /// The mock delegate used to check expectations.
    private var mockDelegate = OptionsDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Initialize the view from the Storyboard
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as OptionPanelViewController

        // Sets the panel
        viewControllerUnderTest?.panel = TruckOptionsPanel()

        // Sets the panel title
        viewControllerUnderTest?.panelTitle = "Mocked Title"

        // Set the delegate
        viewControllerUnderTest?.delegate = mockDelegate

        // Load the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()
    }

    // MARK: - Tests

    /// Tests if the View Controller has the correct title.
    func testTitle() {
        XCTAssertEqual(
            viewControllerUnderTest?.titleItem.title, "Mocked Title",
            "It should have the correct title"
        )
    }

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(
            viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
            "It should have the correct status bar style"
        )
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertNotNil(
            viewControllerUnderTest?.backButton,
            "The back button should exist"
        )

        XCTAssertNotEqual(
            viewControllerUnderTest?.backButton.title, "msdkui_app_back",
            "The back button title should be localized"
        )

        XCTAssertLocalized(
            viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
            "The back button should have the correct title"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
            "The back button should have the correct tint color"
        )
    }

    /// Tests the accessibility identifiers.
    func testAccessibilityIdentifiers() {
        XCTAssertEqual(
            viewControllerUnderTest?.backButton.accessibilityIdentifier, "OptionPanelViewController.backButton",
            "The back button should have the correct accessibility identifier"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.scrollView.accessibilityIdentifier, "OptionPanelViewController.scrollView",
            "The scroll view should have the correct accessibility identifier"
        )
    }

    /// Tests the back button action before option changes.
    func testBackButtonTapBeforeOptionChange() {
        // Triggers the back button action
        viewControllerUnderTest?.backButton.tap()

        XCTAssertFalse(
            mockDelegate.didCallOptionsUpdated,
            "It doesn't call the delegate method"
        )
    }

    /// Tests the back button action after option changes.
    func testBackButtonTapAfterOptionChange() throws {
        let optionsPanel = try require(viewControllerUnderTest?.panel)

        // Triggers the option change action
        viewControllerUnderTest?.optionsPanel(optionsPanel, didChangeTo: OptionItem())

        // Triggers the back button action
        viewControllerUnderTest?.backButton.tap()

        XCTAssertTrue(
            mockDelegate.didCallOptionsUpdated,
            "It calls the delegate method"
        )
        XCTAssertEqual(
            mockDelegate.lastViewController, viewControllerUnderTest,
            "It passed the correct view controller instance to the delegate"
        )
    }

    /// Tests the conformance to the `PickerViewDelegate` protocol.
    func testMakeLabel() {
        let mockPickerView = UIPickerView()
        let label = viewControllerUnderTest?.makeLabel(mockPickerView, text: "Mock Text")

        XCTAssertEqual(
            label?.attributedText?.string, "Mock Text",
            "It creates a label with the correct text"
        )

        XCTAssertEqual(
            label?.textAlignment, .center,
            "It creates a label with the correct text alignment"
        )
    }

    /// Tests the view life cycle when panel is of type RouteTypeOptionsPanel.
    func testViewDidLoadWithRouteTypeOptionsPanel() {
        let panel = RouteTypeOptionsPanel()

        // Sets the panel
        viewControllerUnderTest?.panel = panel

        // Load the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(
            panel.pickerDelegate === viewControllerUnderTest,
            "It sets the view controller as the panel delegate"
        )
    }

    /// Tests the view life cycle when panel is of type TrafficOptionsPanel.
    func testViewDidLoadWithTrafficOptionsPanel() {
        let panel = TrafficOptionsPanel()

        // Sets the panel
        viewControllerUnderTest?.panel = panel

        // Load the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(
            panel.pickerDelegate === viewControllerUnderTest,
            "It sets the view controller as the panel delegate"
        )
    }

    /// Tests the view life cycle when panel is of type TruckOptionsPanel.
    func testViewDidLoadWithTruckOptionsPanel() {
        let panel = TruckOptionsPanel()

        // Sets the panel
        viewControllerUnderTest?.panel = panel

        // Load the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(
            panel.pickerDelegate === viewControllerUnderTest,
            "It sets the view controller as the panel delegate"
        )
    }

    /// Tests the view life cycle when panel is of type TunnelOptionsPanel.
    func testViewDidLoadWithTunnelOptionsPanel() {
        let panel = TunnelOptionsPanel()

        // Sets the panel
        viewControllerUnderTest?.panel = panel

        // Load the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        XCTAssertTrue(
            panel.pickerDelegate === viewControllerUnderTest,
            "It sets the view controller as the panel delegate"
        )
    }
}
