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

@testable import MSDKUI
@testable import MSDKUI_Demo
import UIKit
import XCTest

final class GuidanceDashboardViewControllerTests: XCTestCase {
    /// The object under test.
    private var dashboardViewController: GuidanceDashboardViewController?

    /// The mock delegate used to verify expectations.
    private let mockDelegate = GuidanceDashboardViewControllerDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        dashboardViewController = UIStoryboard.instantiateFromStoryboard(named: .driveNavigation) as GuidanceDashboardViewController
        _ = dashboardViewController?.view

        dashboardViewController?.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests if the view controller exists.
    func testExists() {
        XCTAssertNotNil(dashboardViewController, "It exists")
    }

    /// Tests if the view has the correct color.
    func testViewBackgroundColor() {
        XCTAssertEqual(dashboardViewController?.view.backgroundColor, .colorBackgroundViewLight, "It has the correct background color")
    }

    /// Tests if the view has rounded corners.
    func testViewRoundedCorners() {
        if #available(iOS 11.0, *) {
            XCTAssertEqual(dashboardViewController?.view.layer.cornerRadius, 12.0, "It has the correct corner radius")
            XCTAssertEqual(
                dashboardViewController?.view.layer.maskedCorners, [.layerMaxXMinYCorner, .layerMinXMinYCorner],
                "It has the correct corners rounded"
            )
        }
    }

    /// Tests if the view has shadow.
    func testViewShadow() {
        XCTAssertEqual(dashboardViewController?.view.layer.shadowRadius, 1, "It has a shadow with correct radius")
        XCTAssertEqual(dashboardViewController?.view.layer.shadowOffset, CGSize(width: 0, height: -1), "It has a shadow with correct offset")
        XCTAssertEqual(dashboardViewController?.view.layer.shadowColor, UIColor.colorDivider.cgColor, "It has a shadow with correct color")
        XCTAssertEqual(dashboardViewController?.view.layer.shadowOpacity, 0.4, "It has a shadow with correct opacity")
    }

    /// Checks if the Speed Monitor exists.
    func testSpeedMonitor() {
        XCTAssertNotNil(dashboardViewController?.speedMonitor, "It has the speed monitor")
        XCTAssert(dashboardViewController?.speedMonitor.delegate === dashboardViewController, "It is the monitor delegate")
    }

    /// Checks if the Estimated Arrival Monitor exists.
    func testEstimatedArrivalMonitor() {
        XCTAssertNotNil(dashboardViewController?.estimatedArrivalMonitor, "It has the estimated arrival monitor")
        XCTAssert(dashboardViewController?.estimatedArrivalMonitor.delegate === dashboardViewController, "It is the monitor delegate")
    }

    /// Tests if the Table View Data Source exists.
    func testTableViewDataSource() {
        XCTAssertNotNil(dashboardViewController?.tableViewDataSource, "It has the table view data source")
    }

    /// Checks if the stop navigation button exists.
    func testStopNavigationButton() throws {
        XCTAssertNotNil(dashboardViewController?.stopNavigationButton, "It has the stop navigation button")

        XCTAssertEqual(
            dashboardViewController?.stopNavigationButton.accessibilityIdentifier, "GuidanceDashboardViewController.stopNavigationButton",
            "It has the correct correct accessibility identifier"
        )

        XCTAssertLocalized(
            dashboardViewController?.stopNavigationButton.accessibilityLabel, key: "msdkui_app_stop_navigation",
            "It has the correct accessibility label"
        )

        XCTAssertNil(dashboardViewController?.stopNavigationButton.currentTitle, "It doens't have a title")

        XCTAssertEqual(
            dashboardViewController?.stopNavigationButton.backgroundColor, .colorSignificantLight,
            "It has the correct background color"
        )

        XCTAssertEqual(
            dashboardViewController?.stopNavigationButton.tintColor, .colorSignificant,
            "It has the correct tint color"
        )

        // TODO: MSDKUI-2161
        // let expectedImage = try require(UIImage(named: "Clear", in: Bundle(for: GuidanceViewController.self), compatibleWith: nil))
        // XCTAssertEqual(dashboardViewController?.stopNavigationButton.currentImage, expectedImage,
        //               "It has the correct image")
    }

    /// Checks if the Estimated Arrival View exists.
    func testEstimatedArrivalView() throws {
        XCTAssertNotNil(dashboardViewController?.estimatedArrivalView, "It has the estimated arrival view")
        XCTAssertNil(dashboardViewController?.estimatedArrivalView.backgroundColor, "It has the estimated arrival view without background color")
        XCTAssertFalse(try require(dashboardViewController?.estimatedArrivalView.isHidden), "It has the estimated arrival view visible by default")
        XCTAssertEqual(dashboardViewController?.estimatedArrivalView.gestureRecognizers?.count, 1, "It has a gesture recognizer")
    }

    /// Checks if the Current Speed View exists.
    func testCurrentSpeedView() {
        XCTAssertNotNil(dashboardViewController?.currentSpeedView, "It has the speed view")
        XCTAssertNil(dashboardViewController?.currentSpeedView.backgroundColor, "It has the speed view without background color")
        XCTAssertEqual(dashboardViewController?.currentSpeedView.textAlignment, .left, "It has a speed view with centered content")
        XCTAssertEqual(dashboardViewController?.currentSpeedView.gestureRecognizers?.count, 1, "It has a gesture recognizer")
    }

    /// Checks if the Pull View (aka Handle) exists.
    func testPullView() {
        XCTAssertNotNil(dashboardViewController?.pullView, "It has the pull view")
        XCTAssertEqual(dashboardViewController?.pullView.layer.cornerRadius, 2, "It has the pull view with correct corner radius")
        XCTAssertEqual(dashboardViewController?.pullView.backgroundColor, .colorDivider, "It has the pull view with correct color")
        XCTAssertEqual(dashboardViewController?.pullView.gestureRecognizers?.count, 1, "It has a gesture recognizer")
    }

    /// Checks if the Table View exists.
    func testTableView() throws {
        XCTAssertNotNil(dashboardViewController?.tableView, "It has the table view")
        XCTAssertEqual(dashboardViewController?.tableView.rowHeight, 56.0, "It has the correct row height")
        XCTAssertFalse(try require(dashboardViewController?.tableView.isScrollEnabled), "It has scrolling disabled")
        XCTAssert(dashboardViewController?.tableView.dataSource === dashboardViewController?.tableViewDataSource, "It has the correct data source")
        XCTAssert(dashboardViewController?.tableView.delegate === dashboardViewController, "It has the correct delegate")
        XCTAssertEqual(dashboardViewController?.tableView.separatorStyle, UITableViewCell.SeparatorStyle.none, "It doesn't have cell separators")
    }

    /// Tests if the Separator View exists.
    func testSeparatorView() {
        XCTAssertNotNil(dashboardViewController?.separatorView, "It has the separator view")
        XCTAssertEqual(dashboardViewController?.separatorView.backgroundColor, .colorDivider, "It has the separator view with correct background color")
        XCTAssertEqual(dashboardViewController?.separatorView.bounds.height, 1, "It has the separator view with correct height")
    }

    /// Tests the behavior when the navigation button is tapped.
    func testWhenStopNavigationButtonIsTapped() {
        dashboardViewController?.stopNavigationButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(mockDelegate.didCallDidTapStopNavigation, "It calls the delegate method to stop the navigation")
        XCTAssertEqual(mockDelegate.lastController, dashboardViewController, "It calls the delegate method with the correct view controller")
    }

    /// Tests the behavior when the tap gesture is triggered (gesture began).
    func testWhenTapGestureBeings() {
        let mockTapGesture = MockUtils.mockTapGestureRecognizer(with: .began)

        dashboardViewController?.handleViewTapGesture(mockTapGesture)

        XCTAssertFalse(mockDelegate.didCallDidTapView, "It doesn't call the delegate")
    }

    /// Tests the behavior when the tap gesture is triggered (gesture ended).
    func testWhenTapGestureEnds() {
        let mockTapGesture = MockUtils.mockTapGestureRecognizer(with: .ended)

        dashboardViewController?.handleViewTapGesture(mockTapGesture)

        XCTAssertTrue(mockDelegate.didCallDidTapView, "It tells the delegate the view was tapped")
        XCTAssertEqual(mockDelegate.lastController, dashboardViewController, "It calls the delegate method with the correct view controller")
    }

    /// Tests the estimated arrival view when the device orientation changes.
    func testEstimatedArrivalViewWhenDeviceOrientationChanges() throws {
        // Add the Dashboard View Controller as another View Controller child (to be able to inject trait collections)
        let dashboardViewController = try require(self.dashboardViewController)
        let navigationController = UINavigationController(rootViewController: dashboardViewController)

        // Inject the regular trait collection
        let regularTraitCollection = UITraitCollection(verticalSizeClass: .regular)
        navigationController.setOverrideTraitCollection(regularTraitCollection, forChild: dashboardViewController)

        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.primaryInfoTextColor, .colorForeground,
            "It has the correct primary text color"
        )
        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.secondaryInfoTextColor, .colorForegroundSecondary,
            "It has the correct secondary text color"
        )
        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.textAlignment, .center,
            "It has the correct text alignment"
        )

        // Inject the compact trait collection
        let compactTrait = UITraitCollection(verticalSizeClass: .compact)
        navigationController.setOverrideTraitCollection(compactTrait, forChild: dashboardViewController)

        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.primaryInfoTextColor, .colorForeground,
            "It has the correct primary text color"
        )
        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.secondaryInfoTextColor, .colorForegroundSecondary,
            "It has the correct secondary text color"
        )
        XCTAssertEqual(
            dashboardViewController.estimatedArrivalView.textAlignment, .left,
            "It has the correct text alignment"
        )
    }

    // MARK: - GuidanceEstimatedArrivalMonitorDelegate

    /// Tests when `.guidanceEstimatedArrivalMonitor(_:didChangeTimeOfArrival:distance:duration:)` is triggered with complete model.
    func testWhenGuidanceEstimatedArrivalMonitorDidChangeTimeOfArrivalDistanceDurationIsTriggeredWithCompleteModel() throws {
        let monitor = try require(dashboardViewController?.estimatedArrivalMonitor)

        let arrivalTime = Date.distantFuture
        let distance = Measurement<UnitLength>(value: 100, unit: .meters)
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)

        // Triggers the delegate method
        dashboardViewController?.guidanceEstimatedArrivalMonitor(monitor, didChangeTimeOfArrival: arrivalTime, distance: distance, duration: duration)

        XCTAssertFalse(
            try require(dashboardViewController?.estimatedArrivalView.isHidden),
            "It shows the estimated arrival view"
        )

        XCTAssertEqual(
            dashboardViewController?.estimatedArrivalView.estimatedTimeOfArrivalLabel.text,
            DateFormatter.currentShortTimeFormatter.string(from: arrivalTime),
            "It configures the arrival view with the correct ETA"
        )

        XCTAssertEqual(
            dashboardViewController?.estimatedArrivalView.distanceLabel.text,
            MeasurementFormatter.currentMediumUnitFormatter.string(from: distance),
            "It configures the arrival view with the correct distance"
        )

        XCTAssertEqual(
            dashboardViewController?.estimatedArrivalView.durationLabel.text,
            MeasurementFormatter.currentMediumUnitFormatter.string(from: duration),
            "It configures the arrival view with the correct duration"
        )
    }

    /// Tests when `.guidanceEstimatedArrivalMonitor(_:didChangeTimeOfArrival:distance:duration:)` is triggered with incomplete model.
    func testWhenGuidanceEstimatedArrivalMonitorDidChangeTimeOfArrivalDistanceDurationIsTriggeredWithIncompleteModel() throws {
        let monitor = try require(dashboardViewController?.estimatedArrivalMonitor)

        let arrivalTime = Date.distantFuture
        let duration = Measurement<UnitDuration>(value: 10, unit: .seconds)

        // Triggers the delegate method
        dashboardViewController?.guidanceEstimatedArrivalMonitor(monitor, didChangeTimeOfArrival: arrivalTime, distance: nil, duration: duration)

        XCTAssertEqual(
            dashboardViewController?.estimatedArrivalView.estimatedTimeOfArrivalLabel.text,
            DateFormatter.currentShortTimeFormatter.string(from: arrivalTime),
            "It configures the arrival view with the correct ETA"
        )

        XCTAssertNonlocalizable(
            dashboardViewController?.estimatedArrivalView.distanceLabel.text, key: "msdkui_value_not_available", bundle: .MSDKUI,
            "It configures the arrival view with dashes"
        )

        XCTAssertEqual(
            dashboardViewController?.estimatedArrivalView.durationLabel.text,
            MeasurementFormatter.currentMediumUnitFormatter.string(from: duration),
            "It configures the arrival view with the correct duration"
        )
    }

    // MARK: - GuidanceSpeedMonitorDelegate

    /// Tests when `.guidanceSpeedMonitor(_:didUpdateCurrentSpeed:isSpeeding:speedLimit:)` is triggered with valid speed.
    func testWhenGuidanceSpeedMonitorDidUpdateCurrentSpeedIsSpeedingSpeedLimitIsTriggeredWithValidSpeed() throws {
        let monitor = try require(dashboardViewController?.speedMonitor)
        let speed = Measurement<UnitSpeed>(value: 10, unit: .metersPerSecond)
        let speedLimit = Measurement<UnitSpeed>(value: 20, unit: .metersPerSecond)

        dashboardViewController?.guidanceSpeedMonitor(monitor, didUpdateCurrentSpeed: speed, isSpeeding: false, speedLimit: speedLimit)

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speed, speed,
            "It shows a view configured with the correct speed"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedValueTextColor, .colorForeground,
            "It shows the speed view with correct speed value color"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedUnitTextColor, .colorForegroundSecondary,
            "It shows the speed view with correct speed unit color"
        )
    }

    /// Tests when `.guidanceSpeedMonitor(_:didUpdateCurrentSpeed:isSpeeding:speedLimit:)` is triggered with speeding speed.
    func testWhenGuidanceSpeedMonitorDidUpdateCurrentSpeedIsSpeedingSpeedLimitIsTriggeredWithSpeedingSpeed() throws {
        let monitor = try require(dashboardViewController?.speedMonitor)
        let speed = Measurement<UnitSpeed>(value: 20, unit: .metersPerSecond)
        let speedLimit = Measurement<UnitSpeed>(value: 10, unit: .metersPerSecond)

        dashboardViewController?.guidanceSpeedMonitor(monitor, didUpdateCurrentSpeed: speed, isSpeeding: true, speedLimit: speedLimit)

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speed, speed,
            "It shows a view configured with the correct speed"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedValueTextColor, .colorNegative,
            "It shows the speed view with correct speed value color"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedUnitTextColor, .colorNegative,
            "It shows the speed view with correct speed unit color"
        )
    }

    /// Tests when `.guidanceSpeedMonitor(_:didUpdateCurrentSpeed:isSpeeding:speedLimit:)` is triggered without speed limit.
    func testWhenGuidanceSpeedMonitorDidUpdateCurrentSpeedWithoutSpeedLimit() throws {
        let monitor = try require(dashboardViewController?.speedMonitor)
        let speed = Measurement<UnitSpeed>(value: 10, unit: .metersPerSecond)

        dashboardViewController?.guidanceSpeedMonitor(monitor, didUpdateCurrentSpeed: speed, isSpeeding: false, speedLimit: nil)

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speed, speed,
            "It shows a view configured with the correct speed"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedValueTextColor, .colorForeground,
            "It shows the speed view with correct speed value color"
        )

        XCTAssertEqual(
            dashboardViewController?.currentSpeedView.speedUnitTextColor, .colorForegroundSecondary,
            "It shows the speed view with correct speed unit color"
        )
    }

    // MARK: - UITableViewDelegate

    /// Tests when `.tableView(_:didSelectRowAt:)` is triggered.
    func testTableViewDidSelectRowAtRow0() throws {
        dashboardViewController?.tableView(try require(dashboardViewController?.tableView), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertTrue(mockDelegate.didCallDidSelectItem, "It tells the delegate the item was selected")
        XCTAssertEqual(mockDelegate.lastItem, .settings, "It tells the delegate the corrent item was selected")
    }

    /// Tests when `.tableView(_:didSelectRowAt:)` is triggered.
    func testTableViewDidSelectRowAtRow1() throws {
        dashboardViewController?.tableView(try require(dashboardViewController?.tableView), didSelectRowAt: IndexPath(row: 1, section: 0))

        XCTAssertTrue(mockDelegate.didCallDidSelectItem, "It tells the delegate the item was selected")
        XCTAssertEqual(mockDelegate.lastItem, .about, "It tells the delegate the corrent item was selected")
    }
}
