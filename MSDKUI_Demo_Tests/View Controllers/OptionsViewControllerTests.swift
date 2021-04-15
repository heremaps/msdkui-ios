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
import NMAKit
import XCTest

final class OptionsViewControllerTests: XCTestCase {
    /// The object under test.
    private var viewControllerUnderTest: OptionsViewController?

    /// The mock delegate used to check expectations.
    private var mockDelegate = OptionsDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Initializes the view from the Storyboard
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as OptionsViewController

        // Loads the view hierarchy
        viewControllerUnderTest?.loadViewIfNeeded()

        // Sets the routing mode
        viewControllerUnderTest?.routingMode = NMARoutingMode(routingType: .fastest, transportMode: .car, routingOptions: .avoidTollRoad)

        // Sets the dynamic penalty
        viewControllerUnderTest?.dynamicPenalty = NMADynamicPenalty()

        // Sets the transport mode
        viewControllerUnderTest?.transportMode = .car

        // Sets the delegate
        viewControllerUnderTest?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the View Controller has the correct status bar style.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(
            viewControllerUnderTest?.preferredStatusBarStyle, .lightContent,
            "It has the correct status bar style"
        )
    }

    /// Tests the table view setup.
    func testTableView() {
        XCTAssertEqual(
            viewControllerUnderTest?.tableView.tableFooterView?.bounds.height, 0,
            "It hides unused table view cells"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.tableView.accessibilityIdentifier, "OptionsViewController.tableView",
            "It has the table view accessibility identifier"
        )
    }

    /// Tests the back button.
    func testBackButton() {
        XCTAssertLocalized(
            viewControllerUnderTest?.backButton.title, key: "msdkui_app_back",
            "It has the correct back button title"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.backButton.tintColor, .colorAccentLight,
            "It has the correct back button tint color"
        )

        XCTAssertEqual(
            viewControllerUnderTest?.backButton.accessibilityIdentifier, "OptionsViewController.backButton",
            "It has the correct back button accessibility identifier"
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
    func testBackButtonTapAfterOptionChange() {
        // Triggers the option change action
        viewControllerUnderTest?.optionsUpdated(UIViewController())

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

    /// Tests the view life cycle when transport mode is car.
    func testViewDidLoadWithTransportModeCar() throws {
        try verifyTableViewFor(transportMode: .car, expecting: [RouteTypeOptionsPanel.name, TrafficOptionsPanel.name, RoutingOptionsPanel.name])
    }

    /// Tests the view life cycle when transport mode is bike.
    func testViewDidLoadWithTransportModeBike() throws {
        try verifyTableViewFor(transportMode: .bike, expecting: [RoutingOptionsPanel.name])
    }

    /// Tests the view life cycle when transport mode is pedestrian.
    func testViewDidLoadWithTransportModePedestrian() throws {
        try verifyTableViewFor(transportMode: .pedestrian, expecting: [RoutingOptionsPanel.name])
    }

    /// Tests the view life cycle when transport mode is truck.
    func testViewDidLoadWithTransportModeTruck() throws {
        let expectedNames = [
            TrafficOptionsPanel.name,
            RoutingOptionsPanel.name,
            TunnelOptionsPanel.name,
            HazardousMaterialsOptionsPanel.name,
            TruckOptionsPanel.name
        ]

        try verifyTableViewFor(transportMode: .truck, expecting: expectedNames)
    }

    /// Tests the view life cycle when transport mode is scooter.
    func testViewDidLoadWithTransportModeScooter() throws {
        try verifyTableViewFor(transportMode: .scooter, expecting: [TrafficOptionsPanel.name, RoutingOptionsPanel.name])
    }

    /// Tests if the correct view controller is presented when the car/route type cell is selected.
    func testSelectTableViewRowForCarAndRow0() throws {
        try selectTableViewCellFor(transportMode: .car, at: IndexPath(row: 0, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RouteTypeOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RouteTypeOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RouteTypeOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the car/traffic cell is selected.
    func testSelectTableViewRowForCarAndRow1() throws {
        try selectTableViewCellFor(transportMode: .car, at: IndexPath(row: 1, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is TrafficOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? TrafficOptionsPanel)?.dynamicPenalty === viewControllerUnderTest?.dynamicPenalty,
                "It presents the Options Panel View Controller with the correct panel dynamic penalty"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, TrafficOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the car/routing cell is selected.
    func testSelectTableViewRowForCarAndRow2() throws {
        try selectTableViewCellFor(transportMode: .car, at: IndexPath(row: 2, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RoutingOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RoutingOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RoutingOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the bike/routing cell is selected.
    func testSelectTableViewRowForBikeAndRow0() throws {
        try selectTableViewCellFor(transportMode: .bike, at: IndexPath(row: 0, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RoutingOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RoutingOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RoutingOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the pedestrian/routing cell is selected.
    func testSelectTableViewRowForPedestrianAndRow0() throws {
        try selectTableViewCellFor(transportMode: .pedestrian, at: IndexPath(row: 0, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RoutingOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RoutingOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RoutingOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the truck/traffic cell is selected.
    func testSelectTableViewRowForTruckAndRow0() throws {
        try selectTableViewCellFor(transportMode: .truck, at: IndexPath(row: 0, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is TrafficOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? TrafficOptionsPanel)?.dynamicPenalty === viewControllerUnderTest?.dynamicPenalty,
                "It presents the Options Panel View Controller with the correct panel dynamic penalty"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, TrafficOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the truck/routing cell is selected.
    func testSelectTableViewRowForTruckAndRow1() throws {
        try selectTableViewCellFor(transportMode: .truck, at: IndexPath(row: 1, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RoutingOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RoutingOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RoutingOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the truck/tunnel cell is selected.
    func testSelectTableViewRowForTruckAndRow2() throws {
        try selectTableViewCellFor(transportMode: .truck, at: IndexPath(row: 2, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is TunnelOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? TunnelOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, TunnelOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the truck/hazardous materials cell is selected.
    func testSelectTableViewRowForTruckAndRow3() throws {
        try selectTableViewCellFor(transportMode: .truck, at: IndexPath(row: 3, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is HazardousMaterialsOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? HazardousMaterialsOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, HazardousMaterialsOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the truck/truck cell is selected.
    func testSelectTableViewRowForTruckAndRow4() throws {
        try selectTableViewCellFor(transportMode: .truck, at: IndexPath(row: 4, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is TruckOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? TruckOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, TruckOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the scooter/traffic cell is selected.
    func testSelectTableViewRowForScooterAndRow0() throws {
        try selectTableViewCellFor(transportMode: .scooter, at: IndexPath(row: 0, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is TrafficOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? TrafficOptionsPanel)?.dynamicPenalty === viewControllerUnderTest?.dynamicPenalty,
                "It presents the Options Panel View Controller with the correct panel dynamic penalty"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, TrafficOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    /// Tests if the correct view controller is presented when the scooter/routing cell is selected.
    func testSelectTableViewRowForScooterAndRow1() throws {
        try selectTableViewCellFor(transportMode: .scooter, at: IndexPath(row: 1, section: 0)) { presentedViewController in
            XCTAssertTrue(
                presentedViewController.panel is RoutingOptionsPanel,
                "It presents the Options Panel View Controller with the correct panel"
            )

            XCTAssertTrue(
                (presentedViewController.panel as? RoutingOptionsPanel)?.routingMode === viewControllerUnderTest?.routingMode,
                "It presents the Options Panel View Controller with the correct panel routing mode"
            )

            XCTAssertEqual(
                presentedViewController.panelTitle, RoutingOptionsPanel.name,
                "It presents the Options Panel View Controller with the correct panel title"
            )

            XCTAssertTrue(
                presentedViewController.delegate === viewControllerUnderTest,
                "It sets the option view controller as the option panel view controller delegate"
            )
        }
    }

    // MARK: - Private

    private func verifyTableViewFor(
        transportMode: NMATransportMode,
        expecting expectedTitles: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        // Sets the transport mode
        viewControllerUnderTest?.transportMode = transportMode

        // Loads the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        let tableView = try require(viewControllerUnderTest?.tableView)

        XCTAssertEqual(
            viewControllerUnderTest?.tableView(tableView, numberOfRowsInSection: 0), expectedTitles.count,
            "It has the correct number of table view cells",
            file: file,
            line: line
        )

        // Retrieves the text from all the table view cells
        let rowTitles = tableView
            .indexPaths()
            .compactMap { viewControllerUnderTest?.tableView(tableView, cellForRowAt: $0).textLabel?.text }

        XCTAssertEqual(
            rowTitles, expectedTitles,
            "It returns the correct table view cells",
            file: file,
            line: line
        )
    }

    private func selectTableViewCellFor(
        transportMode: NMATransportMode,
        at indexPath: IndexPath,
        completion: (_ presentedViewController: OptionPanelViewController) -> Void
    ) throws {
        // Sets the transport mode
        viewControllerUnderTest?.transportMode = transportMode

        // Loads the view hierarchy
        viewControllerUnderTest?.viewDidLoad()

        // The real `rootViewController` is replaced with `viewControllerUnderTest`
        let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

        // Attaches the view controller to the window before selecting a row
        UIApplication.shared.keyWindow?.rootViewController = viewControllerUnderTest

        let tableView = try require(viewControllerUnderTest?.tableView)

        // Selects the cell and triggers the table view delegate method
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        viewControllerUnderTest?.tableView(tableView, didSelectRowAt: indexPath)

        XCTAssertTrue(
            viewControllerUnderTest?.presentedViewController is OptionPanelViewController,
            "It presents the Option Panel View Controller"
        )

        // Calls the completion with the presented view controller
        completion(try require(viewControllerUnderTest?.presentedViewController as? OptionPanelViewController))

        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController
    }
}
