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

class ViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var exitButton: UIBarButtonItem!

    // This button has two tasks: either expands the waypoint list or collapses it
    // Note that the waypoint list is hidden after the routes are calculated
    @IBOutlet private(set) var rightButton: UIBarButtonItem!

    @IBOutlet private(set) var waypointList: WaypointList!

    @IBOutlet private(set) var waypointListStackView: UIStackView!

    @IBOutlet private(set) var optionsButton: IconButton!

    @IBOutlet private(set) var transportModePanel: TransportModePanel!

    @IBOutlet private(set) var travelTimePanel: TravelTimePanel!

    @IBOutlet private(set) var helperScrollView: UIScrollView!

    @IBOutlet private(set) var emptyView: EmptyView!

    @IBOutlet private(set) var routesList: RouteDescriptionList!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    // We need routing support
    lazy var router: NMACoreRouting = NMACoreRouter()

    // For panel testing
    private(set) var routingMode = NMARoutingMode()

    // Shows the `helperScrollView` & hides waypoint list & routes list, and vice versa.
    private(set) var showHelperScrollView = true {
        didSet {
            helperScrollView.isHidden = !showHelperScrollView
            waypointListStackView.isHidden = !showHelperScrollView
            routesList.isHidden = showHelperScrollView

            // When the `helperScrollView` is hidden, i.e. there are routes, show
            // the right button with the expand image and otherwise hide it:
            // as UIBarButtonItem has no isHidden property, we play with its
            // tintColor property and disable it
            if helperScrollView.isHidden == true {
                rightButton.tintColor = .colorAccentLight
                rightButton.isEnabled = true
                rightButton.image = UIImage(named: "IconButton.expand")
                titleItem.title = RouteDescriptionList.name
            } else {
                rightButton.tintColor = .colorBackgroundDark
                rightButton.isEnabled = false
            }

            // Reflect the right button's current function
            updateAccessibility()
        }
    }

    var trafficEnabled = true {
        didSet {
            routesList.trafficEnabled = trafficEnabled
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var selectedRouteIndex: Int?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Reflect the right button's initial function
        updateAccessibility()

        // Set up the NMAKit objects
        let dynamicPenalty = NMADynamicPenalty()
        dynamicPenalty.trafficPenaltyMode = .optimal // We want to display delays
        router.dynamicPenalty = dynamicPenalty
        router.connectivity = .online

        routingMode.resultLimit = 5 // We want at most five routes

        // Initiate the objects
        waypointList.listDelegate = self

        transportModePanel.delegate = self

        travelTimePanel.delegate = self
        updateTime()

        routesList.listDelegate = self
        routesList.trafficEnabled = trafficEnabled

        clearRouteList()

        setUpHelperScrollView()

        showHelperScrollView = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isBeingPresented {
            // Set the initial `helperScrollView.contentSize`
            helperScrollView.contentSize = emptyView.frame.size
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update `helperScrollView.contentSize` after transition
        coordinator.animate(alongsideTransition: nil) { _ in
            self.helperScrollView.contentSize = self.emptyView.frame.size
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWaypoint", let viewController = segue.destination as? WaypointViewController {
            prepare(incoming: viewController)
        } else if segue.identifier == "ShowOptions", let viewController = segue.destination as? OptionsViewController {
            prepare(incoming: viewController)
        } else if segue.identifier == "ShowRoute", let viewController = segue.destination as? RouteViewController {
            prepare(incoming: viewController)
        }
    }

    // MARK: - Public

    func calculateRoute() {
        clearRouteList()

        guard waypointList.isRoutingPossible else {
            return
        }

        // We will be busy
        showHUD()

        _ = router.calculateRoute(withStops: waypointList.waypoints, routingMode: routingMode) { result, error in
            // In case of problems, keep the empty array as the routes
            var routes: [NMARoute] = []
            if error == .none || error == .violatesOptions {
                if let result = result, let resultRoutes = result.routes {
                    routes = resultRoutes
                }
            } else {
                // Print to the Console the reason why it might have failed to calculate the route
                print(error)
            }

            // Get the routes
            self.routesList.routes = routes

            // Make sure to hide the `helperScrollView`, i.e. show the route list
            self.showHelperScrollView = false

            // In case of accessibility, let the route list be focused
            UIAccessibility.post(notification: .layoutChanged, argument: self.routesList)

            // Done
            self.hideHUD()
        }
    }

    // MARK: - Private

    private func prepare(incoming viewController: WaypointViewController) {
        viewController.controllerTitle = "msdkui_app_waypoint_select_location".localized
        viewController.controllerInfoString = "msdkui_app_rp_waypoint_subtitle".localized
        viewController.exitButtonTitle = "msdkui_app_cancel".localized
        viewController.trafficEnabled = trafficEnabled
        viewController.delegate = self
        viewController.isLocationMandatory = false

        // Is there a selected route?
        if let selectedRowIndex = waypointList.indexPathForSelectedRow?.row,
            waypointList.waypointEntries.indices.contains(selectedRowIndex),
            case let selectedEntry = waypointList.waypointEntries[selectedRowIndex] {
            viewController.selectedEntry = selectedEntry
        }
    }

    private func prepare(incoming viewController: OptionsViewController) {
        viewController.delegate = self
        viewController.routingMode = routingMode
        viewController.dynamicPenalty = router.dynamicPenalty
        viewController.transportMode = transportModePanel.transportMode
    }

    private func prepare(incoming viewController: RouteViewController) {
        viewController.delegate = self
        viewController.routingMode = routingMode
        viewController.trafficEnabled = trafficEnabled
        viewController.sourceAddress = waypointList.waypointEntries.first?.streetAddress
        viewController.destinationAddress = waypointList.waypointEntries.last?.streetAddress
        if let selectedRouteIndex = selectedRouteIndex {
            viewController.route = routesList.routes[selectedRouteIndex]
        }
    }

    private func localize() {
        exitButton.title = "msdkui_app_exit".localized
        titleItem.title = "msdkui_app_rp_teaser_title".localized
    }

    private func updateStyle() {
        exitButton.tintColor = .colorAccentLight

        // The options button requires custom handling as it stands next to the white travelTimePanel
        optionsButton.backgroundColor = .colorBackgroundLight
        optionsButton.tintColor = .colorForegroundSecondary
    }

    private func clearRouteList() {
        selectedRouteIndex = nil
    }

    private func updateTime() {
        routingMode.departureTime = travelTimePanel.time
    }

    private func showHUD() {
        hudView.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideHUD() {
        activityIndicator.stopAnimating()
        hudView.isHidden = true
    }

    private func setAccessibility() {
        exitButton.accessibilityIdentifier = "ViewController.exitButton"
        rightButton.accessibilityIdentifier = "ViewController.rightButton"
        helperScrollView.accessibilityIdentifier = "ViewController.helperScrollView"
    }

    private func updateAccessibility() {
        // The right button is multi-functional and we must update its accessibilty
        // strings whenever we update its function
        if waypointListStackView.isHidden == true {
            rightButton.accessibilityLabel = "msdkui_app_expand".localized
            rightButton.accessibilityHint = "msdkui_app_hint_expand".localized
        } else {
            rightButton.accessibilityLabel = "msdkui_app_collapse".localized
            rightButton.accessibilityHint = "msdkui_app_hint_collapse".localized
        }
    }

    private func setUpHelperScrollView() {
        let viewModel = EmptyView.ViewModel(
            image: UIImage(named: "RoutingHelper"),
            title: "msdkui_app_routeplanner_getdirections".localized,
            subtitle: "msdkui_app_routeplanner_startchoosingwaypoint".localized
        )

        emptyView.configure(with: viewModel)
    }

    @IBAction private func reverseItems(_ sender: IconButton) {
        waypointList.reverse()

        calculateRoute()
    }

    @IBAction private func addWaypoint(_ sender: IconButton) {
        // Make sure that no row is selected
        if let indexPathForSelectedRow = waypointList.indexPathForSelectedRow {
            waypointList.deselectRow(at: indexPathForSelectedRow, animated: false)
        }

        // Switch to waypoint picker
        performSegue(withIdentifier: "ShowWaypoint", sender: self)
    }

    @IBAction private func showOptions(_ sender: IconButton) {
        performSegue(withIdentifier: "ShowOptions", sender: self)
    }

    @IBAction private func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction private func toggleWaypointsVisibility(_ sender: UIBarButtonItem) {
        if waypointListStackView.isHidden == true {
            // Show the waypoint list and show the collapse image
            waypointListStackView.isHidden = false
            rightButton.image = UIImage(named: "IconButton.collapse")
        } else {
            // Hide the waypoint list and show the expand image
            waypointListStackView.isHidden = true
            rightButton.image = UIImage(named: "IconButton.expand")
        }

        // Reflect the right button's current function
        updateAccessibility()
    }
}

// MARK: - RouteViewControllerDelegate

extension ViewController: RouteViewControllerDelegate {
    // In some cases the traffic data appears late, it is better to refresh the routes
    func refreshRoute(_ viewController: UIViewController) {
        // Simply re-assign the routes to force a refresh
        let routes = routesList.routes
        routesList.routes = routes
    }
}

// MARK: - WaypointViewControllerDelegate

extension ViewController: WaypointViewControllerDelegate {
    func waypointViewController(_ viewController: WaypointViewController, entry: WaypointEntry) {
        // Is there a selected entry?
        if let indexPathForSelectedRow = waypointList.indexPathForSelectedRow {
            let selectedEntry = waypointList.waypointEntries[indexPathForSelectedRow.row]

            // Is it updated?
            if selectedEntry.waypoint.originalPosition.latitude != entry.waypoint.originalPosition.latitude ||
                selectedEntry.waypoint.originalPosition.longitude != entry.waypoint.originalPosition.longitude {
                waypointList.updateEntry(entry, at: indexPathForSelectedRow.row)
            }
        } else {
            // Add a new entry
            waypointList.addEntry(entry)
        }
    }
}

// MARK: - OptionsDelegate

extension ViewController: OptionsDelegate {
    func optionsUpdated(_ viewController: UIViewController) {
        // In case the traffic penalty mode is not optimal, don't ask for the traffic data
        trafficEnabled = router.dynamicPenalty?.trafficPenaltyMode == .optimal

        // Recalculate the route with the updated options
        calculateRoute()
    }
}

// MARK: - WaypointListDelegate

extension ViewController: WaypointListDelegate {
    func waypointList(_ list: WaypointList, didAdd entry: WaypointEntry, at index: Int) {
        calculateRoute()
    }

    func waypointList(_ list: WaypointList, didSelect entry: WaypointEntry, at index: Int) {
        performSegue(withIdentifier: "ShowWaypoint", sender: self)
    }

    func waypointList(_ list: WaypointList, didRemove entry: WaypointEntry, at index: Int) {
        calculateRoute()
    }

    func waypointList(_ list: WaypointList, didDragFrom from: Int, to: Int) {
        calculateRoute()
    }

    func waypointList(_ list: WaypointList, didUpdate entry: WaypointEntry, at index: Int) {
        calculateRoute()
    }
}

// MARK: - RouteDescriptionListDelegate

extension ViewController: RouteDescriptionListDelegate {
    func routeDescriptionList(_ list: RouteDescriptionList, didSelect route: NMARoute, at index: Int) {
        // Update the selected route index
        selectedRouteIndex = index

        performSegue(withIdentifier: "ShowRoute", sender: self)
    }
}

// MARK: - TravelTimePanelDelegate

extension ViewController: TravelTimePanelDelegate {
    func travelTimePanel(_ panel: TravelTimePanel, didUpdate date: Date) {
        updateTime()
        calculateRoute()
    }
}

// MARK: - TransportModePanelDelegate

extension ViewController: TransportModePanelDelegate {
    func transportModePanel(_ panel: TransportModePanel, didChangeTo mode: NMATransportMode) {
        routingMode.transportMode = mode
        calculateRoute()
    }
}
