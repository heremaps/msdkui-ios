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
import NMAKit
import UIKit

final class ManeuversOverviewViewController: UIViewController, GuidancePresentingViewController {
    // MARK: - Properties

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var destinationView: UIStackView!

    @IBOutlet private(set) var toLabel: UILabel!

    @IBOutlet private(set) var addressLabel: UILabel!

    @IBOutlet private(set) var routeDescriptionItem: RouteDescriptionItem!

    @IBOutlet private(set) var maneuverTableView: ManeuverTableView!

    @IBOutlet private(set) var dividerViews: [UIView]!

    @IBOutlet private(set) var showMapButton: UIButton!

    @IBOutlet private(set) var startNavigationButton: UIButton!

    let guidanceSegueID = "ShowGuidanceFromManeuvers"

    var shouldStartSimulation = false

    var route: NMARoute?

    var trafficEnabled = true

    // The destination address string
    var toAddress: String?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Hopefully we have the to address
        addressLabel.text = toAddress

        // Prepare the components: note that we don't show the bar on the routeDescriptionItem
        routeDescriptionItem.trafficEnabled = trafficEnabled
        routeDescriptionItem.route = route
        routeDescriptionItem.trailingInset = 0
        routeDescriptionItem.leadingInset = 0
        maneuverTableView.route = route

        // Sets up the view when based on `toAddress`
        setUpDestinationView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Sets up the view when `UIUserInterfaceSizeClass` case changes from `.unspecified`
        setUpDestinationView(for: traitCollection)
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)

        // Sets up the view based on new `UITraitCollection`
        setUpDestinationView(for: newCollection)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == guidanceSegueID, let viewController = segue.destination as? GuidanceViewController {
            prepare(incoming: viewController)
        }
    }

    // MARK: - Private

    private func localize() {
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_route_preview_title".localized

        toLabel.text = "msdkui_app_routeoverview_to".localized

        showMapButton.setTitle("msdkui_app_guidance_button_showmap".localized, for: .normal)
        startNavigationButton.setTitle("msdkui_app_guidance_button_start".localized, for: .normal)
    }

    private func updateStyle() {
        // Hides unused rows
        maneuverTableView.tableFooterView = UIView(frame: .zero)

        backButton.tintColor = .colorAccentLight
        dividerViews.forEach { $0.backgroundColor = .colorDivider }

        toLabel.textColor = .colorForegroundSecondary
        addressLabel.textColor = .colorForegroundSecondary

        applyForegroundLightStyle(to: showMapButton)
        applyAccentStyle(to: startNavigationButton)
    }

    private func setAccessibility() {
        routeDescriptionItem.accessibilityIdentifier = "ManeuversOverviewViewController.routeDescriptionItem"
        maneuverTableView.accessibilityIdentifier = "ManeuversOverviewViewController.maneuverTableView"

        backButton.accessibilityIdentifier = "ManeuversOverviewViewController.backButton"
        showMapButton.accessibilityIdentifier = "ManeuversOverviewViewController.showMapButton"
        startNavigationButton.accessibilityIdentifier = "ManeuversOverviewViewController.startNavigationButton"
    }

    /// Sets up the destination view for the given trait collection and `toAddress` member.
    /// Shows the view only when `toAddress` hasContent and `verticalSizeClass` is `.regular`.
    ///
    /// - Parameter traitCollection: The trait collection used to set up the `destinationView`,
    ///                              when it is not provided, i.e. nil, it has no effect on the result.
    private func setUpDestinationView(for traitCollection: UITraitCollection? = nil) {
        // Hide it when neither destination address nor regular vertical size class are set
        destinationView.isHidden = !toAddress.hasContent || traitCollection?.verticalSizeClass != .regular
    }

    @IBAction private func goBack() {
        dismiss(animated: true)
    }

    @IBAction private func showMap() {
        dismiss(animated: false)
    }

    @IBAction private func startNavigation() {
        showGuidance(withSimulation: false)
    }

    @IBAction private func startSimulation(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            showSimulationAlert()
        }
    }
}
