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
import NMAKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var exitButton: UIBarButtonItem!

    // This button has two tasks: either expands the waypoint list or collapses it
    // Note that the waypoint list is hidden after the routes are calculated
    @IBOutlet private(set) var rightButton: UIBarButtonItem!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var waypointList: WaypointList!

    @IBOutlet private(set) var waypointListStackView: UIStackView!

    @IBOutlet private(set) var optionsButton: IconButton!

    @IBOutlet private(set) var transportModePanel: TransportModePanel!

    @IBOutlet private(set) var travelTimePanel: TravelTimePanel!

    @IBOutlet private(set) var routesList: RouteDescriptionList!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    // We need routing support
    var router = NMACoreRouter()

    // For panel testing
    var routingMode = NMARoutingMode()
    var selectedRouteIndex: Int?

    // Shows the mapView & hides waypoint list & routes list, and vice versa.
    var showMapView = true {
        didSet {
            mapView.isHidden = !showMapView
            waypointListStackView.isHidden = !showMapView
            routesList.isHidden = showMapView

            // If the map view is hidden, i.e. there are routes, show
            // the right button with the expand image and otherwise hide it:
            // as UIBarButtonItem has no isHidden property, we play with its
            // tintColor property and disable it
            if mapView.isHidden == true {
                rightButton.tintColor = UIColor.colorAccentLight
                rightButton.isEnabled = true
                rightButton.image = UIImage(named: "IconButton.expand")
                titleItem.title = RouteDescriptionList.name
            } else {
                rightButton.tintColor = UIColor.colorBackgroundDark
                rightButton.isEnabled = false
            }

            // Reflect the right button's current function
            updateAccessibility()
        }
    }

    var trafficEnabled = true {
        didSet {
            mapView.isTrafficVisible = trafficEnabled
            routesList.trafficEnabled = trafficEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Set some basic values for the map view
        mapView.copyrightLogoPosition = .bottomCenter
        mapView.zoomLevel = 14.0
        mapView.tilt = 0.0
        mapView.landmarksVisible = true
        mapView.extrudedBuildingsVisible = true
        mapView.positionIndicator.isVisible = false
        mapView.positionIndicator.isAccuracyIndicatorVisible = false
        mapView.isTrafficVisible = trafficEnabled

        // Reflect the right button's initial function
        updateAccessibility()

        // Set up the NMAKit objects
        router.dynamicPenalty = NMADynamicPenalty()
        router.dynamicPenalty!.trafficPenaltyMode = .optimal // We want to display delays
        router.connectivity = .online

        routingMode.resultLimit = 5 // We want at most five routes

        // Initiate the objects
        waypointList.listDelegate = self

        transportModePanel.onModeChanged = onModeChanged

        travelTimePanel.onTimeChanged = onTimeChanged
        updateTime()

        routesList.listDelegate = self
        routesList.trafficEnabled = trafficEnabled

        showMapView = true

        clearRouteList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // From the NMAMapView trafficVisible property documentation:
        // "Traffic can only be displayed on one map at a time. It is recommended that you turn off
        //  traffic display on other maps before enabling traffic display on a new map otherwise the
        //  results may be unpredictable."
        mapView.isTrafficVisible = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Restore
        mapView.isTrafficVisible = trafficEnabled
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ShowWaypoint" {
            guard let viewController = segue.destination as? WaypointViewController else {
                return
            }

            // Init the vc and set its delegate
            // Is there a selected row? If so, pass it
            viewController.controllerTitle = "msdkui_app_waypoint_select_location".localized
            viewController.controllerInfoString = "msdkui_app_rp_waypoint_subtitle".localized
            viewController.exitButtonTitle = "msdkui_app_cancel".localized
            viewController.trafficEnabled = trafficEnabled
            viewController.mapGeoCenter = mapView.geoCenter
            viewController.mapZoomLevel = mapView.zoomLevel
            viewController.delegate = self
            viewController.isLocationMandatory = false
            if let selectedRowIndex = waypointList.indexPathForSelectedRow?.row,
                waypointList.waypointEntries.indices.contains(selectedRowIndex),
                case let selectedEntry = waypointList.waypointEntries[selectedRowIndex] {
                viewController.selectedEntry = selectedEntry
            }
        } else if segue.identifier == "ShowOptions" {
            guard let viewController = segue.destination as? OptionsViewController else {
                return
            }

            // Init the vc and enable it to trigger route calculation
            viewController.delegate = self
            viewController.routingMode = routingMode
            viewController.dynamicPenalty = router.dynamicPenalty
            viewController.transportMode = transportModePanel.transportMode
        } else if segue.identifier == "ShowRoute" {
            guard let viewController = segue.destination as? RouteViewController else {
                return
            }

            // Init the vc and enable it to trigger route calculation
            viewController.delegate = self
            viewController.route = routesList.routes[selectedRouteIndex!]
            viewController.routingMode = routingMode
            viewController.trafficEnabled = trafficEnabled
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction private func onSwap(_: IconButton) {
        waypointList.reverse()

        // Action
        calculateRoute()
    }

    @IBAction private func onAdd(_: IconButton) {
        // Make sure that no row is selected
        if let indexPathForSelectedRow = waypointList.indexPathForSelectedRow {
            waypointList.deselectRow(at: indexPathForSelectedRow, animated: false)
        }

        // Switch to waypoint picker
        performSegue(withIdentifier: "ShowWaypoint", sender: self)
    }

    @IBAction private func onOptions(_: IconButton) {
        performSegue(withIdentifier: "ShowOptions", sender: self)
    }

    @IBAction private func onExit(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onRight(_: UIBarButtonItem) {
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

    func localize() {
        exitButton.title = "msdkui_app_exit".localized
        titleItem.title = "msdkui_app_rp_teaser_title".localized
    }

    func updateStyle() {
        exitButton.tintColor = .colorAccentLight

        // The options button requires custom handling as it stands next to the white travelTimePanel
        optionsButton.backgroundColor = .colorBackgroundLight
        optionsButton.tintColor = .colorForegroundSecondary
    }

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

            // Make sure to hide the map view, i.e. show the route list
            self.showMapView = false

            // In case of accessibility, let the route list be focused
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.routesList)

            // Done
            self.hideHUD()
        }
    }

    func clearRouteList() {
        selectedRouteIndex = nil
    }

    func updateTime() {
        routingMode.departureTime = travelTimePanel.time
    }

    func showHUD() {
        hudView.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideHUD() {
        activityIndicator.stopAnimating()
        hudView.isHidden = true
    }

    private func setAccessibility() {
        exitButton.accessibilityIdentifier = "ViewController.exit"

        rightButton.accessibilityIdentifier = "ViewController.right"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = UIAccessibilityTraitNone
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_helper_map_view".localized
        mapView.accessibilityIdentifier = "ViewController.mapView"
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

    // MARK: TransportModePanel

    func onModeChanged(_ mode: NMATransportMode) {
        print("onModeChanged called: new mode: \(mode.rawValue)")

        // Reflect the update
        routingMode.transportMode = mode

        // Action
        calculateRoute()
    }

    // MARK: TravelTimePanel

    func onTimeChanged(_ time: Date) {
        print("onTimeChanged: time: \(time.description)")

        updateTime()

        // Action
        calculateRoute()
    }
}

// MARK: RouteViewControllerDelegate

extension ViewController: RouteViewControllerDelegate {
    // In some cases the traffic data appears late, it is better to refresh the routes
    func refreshRoute(_: UIViewController) {
        // Simply re-assign the routes to force a refresh
        let routes = routesList.routes
        routesList.routes = routes
    }
}

// MARK: WaypointViewControllerDelegate

extension ViewController: WaypointViewControllerDelegate {
    func waypointViewController(_: WaypointViewController, entry: WaypointEntry) {
        // Is there a selected entry?
        if let indexPathForSelectedRow = waypointList.indexPathForSelectedRow {
            let selectedEntry = waypointList.waypointEntries[indexPathForSelectedRow.row]

            // Is it updated?
            if selectedEntry.waypoint.originalPosition.latitude != entry.waypoint.originalPosition.latitude ||
                selectedEntry.waypoint.originalPosition.longitude != entry.waypoint.originalPosition.longitude {
                waypointList.updateEntry(entry, at: waypointList.indexPathForSelectedRow!.row)
            }
        } else {
            // Add a new entry
            waypointList.addEntry(entry)
        }
    }

    func waypointViewController(_: WaypointViewController,
                                didCenterMap geoCenter: NMAGeoCoordinates,
                                with zoomLevel: Float) {
        mapView.geoCenter = geoCenter
        mapView.zoomLevel = zoomLevel
    }
}

// MARK: OptionsDelegate

extension ViewController: OptionsDelegate {
    func optionsUpdated(_: UIViewController) {
        print("Calculating route with the updated options...")

        // In case the traffic penalty mode is not optimal, don't ask for the traffic data
        trafficEnabled = router.dynamicPenalty!.trafficPenaltyMode == .optimal

        // Recalculate the route with the updated options
        calculateRoute()
    }
}

// MARK: WaypointListDelegate

extension ViewController: WaypointListDelegate {
    func entryAdded(_: WaypointList, index: Int, entry: WaypointEntry) {
        print("Added entry \(index) having '\(entry.name)' name")

        // Action
        calculateRoute()
    }

    func entrySelected(_: WaypointList, index: Int, entry: WaypointEntry) {
        print("Selected entry \(index) having '\(entry.name)' name")

        // Action
        performSegue(withIdentifier: "ShowWaypoint", sender: self)
    }

    func entryRemoved(_: WaypointList, index: Int, entry: WaypointEntry) {
        print("Removed entry \(index) having '\(entry.name)' name")

        // Action
        calculateRoute()
    }

    func entryDragged(_: WaypointList, from: Int, to: Int) {
        print("Dragged entry from \(from) to \(to)!")

        // Action
        calculateRoute()
    }

    func entryUpdated(_: WaypointList, index: Int, entry: WaypointEntry) {
        print("Updated entry \(index): now it has '\(entry.name)' name")

        // Action
        calculateRoute()
    }
}

// MARK: RouteDescriptionListDelegate

extension ViewController: RouteDescriptionListDelegate {
    func routeDescriptionList(_ list: RouteDescriptionList, didSelect route: NMARoute, at index: Int) {
        print("Route \(index) tapped")

        // Update the selected route index
        selectedRouteIndex = index

        // Action
        performSegue(withIdentifier: "ShowRoute", sender: self)
    }
}
