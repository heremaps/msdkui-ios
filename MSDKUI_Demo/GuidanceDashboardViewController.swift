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

import MSDKUI
import UIKit

protocol GuidanceDashboardViewControllerDelegate: AnyObject {
    /// Notifies the delegate when the stop navigation button is tapped.
    ///
    /// - Parameter controller: The controller notifying the event.
    func guidanceDashboardViewControllerDidTapStopNavigation(_ controller: GuidanceDashboardViewController)

    /// Notifies the delegate when the view is tapped.
    ///
    /// - Parameter controller: The controller notifying the event.
    func guidanceDashboardViewControllerDidTapView(_ controller: GuidanceDashboardViewController)

    /// Notifies the delegate when a table view item is tapped.
    ///
    /// - Parameters:
    ///   - controller: The controller notifying the event.
    ///   - item: The selected item.
    func guidanceDashboardViewController(_ controller: GuidanceDashboardViewController, didSelectItem item: GuidanceDashboardTableViewDataSource.Item)
}

final class GuidanceDashboardViewController: UIViewController {

    // MARK: - Public properties

    /// The delegate that implements the `GuidanceDashboardViewControllerDelegate` protocol.
    weak var delegate: GuidanceDashboardViewControllerDelegate?

    /// The speed monitor, used to populate the current speed view.
    let speedMonitor = GuidanceSpeedMonitor()

    /// The estimated arrival monitor, used to populate the estimated arrival view.
    let estimatedArrivalMonitor = GuidanceEstimatedArrivalMonitor()

    /// The table view data source.
    let tableViewDataSource = GuidanceDashboardTableViewDataSource()

    // MARK: - Outlets

    /// The stop navigation button, which triggers the `GuidanceDashboardViewControllerDelegate` method to stop the navigation.
    @IBOutlet private(set) weak var stopNavigationButton: UIButton!

    /// The estimated arrival view.
    @IBOutlet private(set) weak var estimatedArrivalView: GuidanceEstimatedArrivalView!

    /// The current speed view.
    @IBOutlet private(set) weak var currentSpeedView: GuidanceSpeedView!

    /// The dashboard pull view (handle).
    @IBOutlet private(set) weak var pullView: UIView!

    /// The dashboard table view.
    @IBOutlet private(set) weak var tableView: UITableView!

    // The separator view.
    @IBOutlet private(set) weak var separatorView: UIView!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpStopNavigationButton()
        setUpCurrentSpeedView()
        setUpEstimatedArrivalView()
        setUpPullView()
        setUpTableView()
        setUpSeparatorView()
        setUpMonitors()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Sets up the view for the current trait collection
        setUpView(for: traitCollection)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        setUpView(for: newCollection)
    }

    // MARK: - Actions

    /// Triggers the action to stop the navigation.
    ///
    /// - Parameter sender: The button tapped.
    @IBAction private func stopNavigation(_ sender: UIButton) {
        delegate?.guidanceDashboardViewControllerDidTapStopNavigation(self)
    }

    /// Triggers the delegate method when the view is tapped.
    ///
    /// - Parameter sender: The tap gesture recognizer.
    @IBAction func handleViewTapGesture(_ sender: UITapGestureRecognizer) { // swiftlint:disable:this private_action
        guard sender.state == .ended else {
            return
        }

        delegate?.guidanceDashboardViewControllerDidTapView(self)
    }

    // MARK: - Private

    /// Sets up the view for the give trait collection.
    private func setUpView(for traitCollection: UITraitCollection) {
        switch traitCollection.verticalSizeClass {
        case .compact:
            estimatedArrivalView.textAlignment = .left
        default:
            estimatedArrivalView.textAlignment = .center
        }
    }

    /// Sets up the view controller's view.
    private func setUpView() {
        view.backgroundColor = .colorBackgroundViewLight

        // Adds rounded corners to the dashboard's view
        if #available(iOS 11.0, *) {
            view.layer.cornerRadius = 12.0
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }

        // Adds shadow to dashboard's view
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowColor = UIColor.colorDivider.cgColor
        view.layer.shadowOpacity = 0.4
    }

    /// Sets up the stop navigation button.
    private func setUpStopNavigationButton() {
        stopNavigationButton.accessibilityIdentifier = "GuidanceViewController.stopNavigationButton"
        stopNavigationButton.accessibilityLabel = "msdkui_app_stop_navigation".localized
        stopNavigationButton.backgroundColor = .colorSignificantLight
        stopNavigationButton.tintColor = .colorSignificant
    }

    /// Sets up the current speed view.
    private func setUpCurrentSpeedView() {
        currentSpeedView.backgroundColor = nil
        currentSpeedView.textAlignment = .left
        currentSpeedView.unit = Locale.current.usesMetricSystem ? .kilometersPerHour : .milesPerHour
    }

    /// Sets up the estimated arrival view.
    private func setUpEstimatedArrivalView() {
        estimatedArrivalView.backgroundColor = nil
    }

    /// Sets up the pull view.
    private func setUpPullView() {
        pullView.backgroundColor = .colorHint
    }

    /// Sets up the table view and reloads the data.
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
        tableView.reloadData()
    }

    /// Sets up the separator view.
    private func setUpSeparatorView() {
        separatorView.backgroundColor = .colorDivider
    }

    /// Sets up monitors.
    private func setUpMonitors() {
        speedMonitor.delegate = self
        estimatedArrivalMonitor.delegate = self
    }
}

// MARK: - GuidanceSpeedMonitorDelegate

extension GuidanceDashboardViewController: GuidanceSpeedMonitorDelegate {
    func guidanceSpeedMonitor(_ monitor: GuidanceSpeedMonitor,
                              didUpdateCurrentSpeed currentSpeed: Measurement<UnitSpeed>,
                              isSpeeding: Bool,
                              speedLimit: Measurement<UnitSpeed>?) {
        currentSpeedView.speed = currentSpeed
        currentSpeedView.speedValueTextColor = isSpeeding ? .colorNegative : .colorForeground
        currentSpeedView.speedUnitTextColor = isSpeeding ? .colorNegative : .colorForegroundSecondary
    }
}

// MARK: - GuidanceEstimatedArrivalMonitorDelegate

extension GuidanceDashboardViewController: GuidanceEstimatedArrivalMonitorDelegate {
    func guidanceEstimatedArrivalMonitor(_ monitor: GuidanceEstimatedArrivalMonitor,
                                         didChangeTimeOfArrival timeOfArrival: Date?,
                                         distance: Measurement<UnitLength>?,
                                         duration: Measurement<UnitDuration>?) {
        let viewModel = GuidanceEstimatedArrivalView.ViewModel(estimatedTimeOfArrival: timeOfArrival,
                                                               duration: duration,
                                                               distance: distance)
        estimatedArrivalView.configure(with: viewModel)
    }
}

// MARK: - UITableViewDelegate

extension GuidanceDashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = tableViewDataSource.item(at: indexPath) else {
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.guidanceDashboardViewController(self, didSelectItem: item)
    }
}
