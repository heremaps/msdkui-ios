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

class RouteOverviewViewController: UIViewController, GuidancePresentingViewController {
    // MARK: - Types

    /// Route calculation state.
    ///
    /// Used by the View Controller to know what to display.
    ///
    /// - calculating: When route calculation started but didn't finish yet.
    /// - hasRoute: When route calculation finished with route.
    /// - noRoute: When route calculation finished without route.
    /// - unknown: Unknown/Initial state.
    private enum RouteCalculationState {
        case calculating
        case hasRoute(route: NMARoute)
        case noRoute
        case unknown
    }

    // MARK: - Properties

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var dividerViews: [UIView]!

    @IBOutlet private(set) var containerView: UIView!

    @IBOutlet private(set) var panelView: UIView!

    @IBOutlet private(set) var destinationView: UIStackView!

    @IBOutlet private(set) var toLabel: UILabel!

    @IBOutlet private(set) var addressLabel: UILabel!

    @IBOutlet private(set) var routeDescriptionItem: RouteDescriptionItem!

    @IBOutlet private(set) var showManeuversButton: UIButton!

    @IBOutlet private(set) var startNavigationButton: UIButton!

    @IBOutlet private(set) var noRouteLabel: UILabel!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var appBecomeActiveObserver: NSObjectProtocol?

    let guidanceSegueID = "ShowGuidanceFromRoutes"

    var shouldStartSimulation = false

    var route: NMARoute? {
        guard case let .hasRoute(route) = routeCalculationState else {
            return nil
        }

        return route
    }

    var trafficEnabled = true

    lazy var router: NMACoreRouting = NMACoreRouter()

    // The current coordinates
    var fromCoordinates: NMAGeoCoordinates?

    // The destination coordinates
    var toCoordinates: NMAGeoCoordinates?

    // The destination address string
    var toAddress: String?

    var mapGeoCenter: NMAGeoCoordinates?

    var mapZoomLevel: Float?

    var mapRouteHandler: MapRouteHandling = MapRouteHandler()

    var mapViewportHandler: MapViewportHandling = MapViewportHandler()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var toMapMarker: NMAMapMarker?

    /// A Boolean value indicating whether the route is displayed on the map.
    private var isRouteDisplayed = false

    /// The route calculation state. It updates the UI when set.
    private var routeCalculationState: RouteCalculationState = .unknown {
        didSet {
            switch routeCalculationState {
            case .calculating:
                showHUD()

            case let .hasRoute(route):
                routeDescriptionItem.route = route
                hideHUD()
                hideNoRouteFound()
                mapView.setNeedsDisplay()

            case .noRoute:
                hideHUD()
                showNoRouteFound()

            case .unknown:
                break
            }
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set position to current or last known if available
        if let currentPosition = NMAPositioningManager.sharedInstance().currentPosition {
            fromCoordinates = currentPosition.coordinates
        } else if let recentLocation = CLLocationManager().location {
            // Try to set last known position
            fromCoordinates = NMAGeoCoordinates(latitude: recentLocation.coordinate.latitude, longitude: recentLocation.coordinate.longitude)
        }

        // Prepare the 'routeDescriptionItem'
        routeDescriptionItem.trafficEnabled = trafficEnabled
        routeDescriptionItem.trailingInset = 0
        routeDescriptionItem.leadingInset = 0

        // Hopefully we have the to address
        addressLabel.text = toAddress

        localize()

        setUpStyle()
        setAccessibility()
        setUpLocationAuthorizationObserver()
        setUpMapView()
        setUpRouter()

        // Sets up the view when based on `toAddress`
        setUpDestinationView()

        // Trigger route calculation as soon as possible
        calculateRoute()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Restore
        mapView.isTrafficVisible = trafficEnabled

        // Sets up the view when `UIUserInterfaceSizeClass` case changes from `.unspecified`
        setUpDestinationView(for: traitCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkLocationAuthorizationStatus()
        updateViewport(of: mapView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // From the NMAMapView trafficVisible property documentation:
        // "Traffic can only be displayed on one map at a time. It is recommended that you turn off
        //  traffic display on other maps before enabling traffic display on a new map otherwise the
        //  results may be unpredictable."
        mapView.isTrafficVisible = false
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)

        // Sets up the view based on new `UITraitCollection`
        setUpDestinationView(for: newCollection)

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            if let `self` = self {
                self.updateViewport(of: self.mapView)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == guidanceSegueID, let viewController = segue.destination as? GuidanceViewController {
            prepare(incoming: viewController)
        } else if segue.identifier == "ShowManeuvers", let viewController = segue.destination as? ManeuversOverviewViewController {
            prepare(incoming: viewController)
        }
    }

    deinit {
        cleanUpLocationAuthorizationObserver()
    }

    // MARK: - Private

    private func prepare(incoming viewController: ManeuversOverviewViewController) {
        viewController.route = route
        viewController.toAddress = toAddress
    }

    private func localize() {
        toLabel.text = "msdkui_app_routeoverview_to".localized
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_route_preview_title".localized
        noRouteLabel.text = "msdkui_app_routeresults_error".localized

        showManeuversButton.setTitle("msdkui_app_guidance_button_showmaneuvers".localized, for: .normal)
        startNavigationButton.setTitle("msdkui_app_guidance_button_start".localized, for: .normal)
    }

    private func setUpStyle() {
        activityIndicator.color = .colorAccent

        dividerViews.forEach { $0.backgroundColor = .colorDivider }
        panelView.backgroundColor = UIColor.colorBackgroundViewLight
        backButton.tintColor = .colorAccentLight
        toLabel.textColor = .colorForegroundSecondary
        addressLabel.textColor = .colorForegroundSecondary
        noRouteLabel.backgroundColor = .colorBackgroundViewLight
        noRouteLabel.textColor = .colorNegative
        containerView.backgroundColor = .colorBackgroundViewLight

        applyForegroundLightStyle(to: showManeuversButton)
        applyAccentStyle(to: startNavigationButton)
    }

    private func setUpMapView() {
        mapView.landmarksVisible = true
        mapView.positionIndicator.isVisible = true
        mapView.positionIndicator.isAccuracyIndicatorVisible = true
        mapView.extrudedBuildingsVisible = true
        mapView.copyrightLogoPosition = .bottomCenter

        // Is a zoom level specified?
        if let mapZoomLevel = mapZoomLevel {
            mapView.zoomLevel = mapZoomLevel
        }

        // Is a map center specified?
        if let mapGeoCenter = mapGeoCenter {
            mapView.set(geoCenter: mapGeoCenter, animation: .none)
        }
    }

    private func setUpRouter() {
        router.dynamicPenalty = NMADynamicPenalty()
        router.dynamicPenalty?.trafficPenaltyMode = .optimal // We want to display delays
        router.connectivity = .online
    }

    private func calculateRoute() {
        // Abort if 'from' and 'to' coordinates aint available
        guard let fromCoordinates = fromCoordinates, let toCoordinates = toCoordinates else {
            routeCalculationState = .noRoute
            return
        }

        // Add the route end marker
        toMapMarker = mapView.addMarker(with: "Route.end", at: toCoordinates)

        // Calculate the route
        let routingMode = NMARoutingMode()
        routingMode.transportMode = .car
        routingMode.resultLimit = 1

        let waypoints: [NMAWaypoint] = [
            NMAWaypoint(geoCoordinates: fromCoordinates, waypointType: .stopWaypoint),
            NMAWaypoint(geoCoordinates: toCoordinates, waypointType: .stopWaypoint)
        ]

        // Mark the state as loading
        routeCalculationState = .calculating

        _ = router.calculateRoute(withStops: waypoints, routingMode: routingMode) { result, error in
            // Update route if available without error or with restrictions
            if error == .none || error == .violatesOptions, let route = result?.routes?.first {
                // Set the data
                self.routeCalculationState = .hasRoute(route: route)
                self.showRoute()
            } else {
                self.routeCalculationState = .noRoute
            }
        }
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

    private func updateViewport(of mapView: NMAMapView) {
        // Abort if route isn't on the map
        guard isRouteDisplayed else {
            return
        }

        let mapMarkers = [toMapMarker, mapView.currentPositionIndicatorMarker]
        mapViewportHandler.setViewport(of: mapView, on: [route], with: mapMarkers, animation: .bow)
    }

    private func showHUD() {
        containerView.isHidden = true
        activityIndicator.startAnimating()
    }

    private func hideHUD() {
        activityIndicator.stopAnimating()
        containerView.isHidden = false
    }

    private func hideNoRouteFound() {
        panelView.isHidden = false
        noRouteLabel.isHidden = true
    }

    private func showNoRouteFound() {
        panelView.isHidden = true
        noRouteLabel.isHidden = false
    }

    private func showRoute() {
        guard
            isRouteDisplayed == false,
            case let .hasRoute(route) = routeCalculationState,
            let mapRoute = mapRouteHandler.makeMapRoute(with: route) else {
            return
        }

        // Draws the route on map
        mapRouteHandler.add(mapRoute, to: mapView)

        // Remember so it doesn't redraw the route
        isRouteDisplayed = true

        // In case of success, try to contain the markers and otherwise inform the user
        updateViewport(of: mapView)
    }

    private func setAccessibility() {
        backButton.accessibilityIdentifier = "RouteOverviewViewController.backButton"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = .none
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_route_map_view".localized
        mapView.accessibilityIdentifier = "RouteOverviewViewController.mapView"

        containerView.accessibilityIdentifier = "RouteOverviewViewController.containerView"

        showManeuversButton.accessibilityIdentifier = "RouteOverviewViewController.showManeuversButton"
        startNavigationButton.accessibilityIdentifier = "RouteOverviewViewController.startNavigationButton"
    }

    @IBAction private func goBack() {
        dismiss(animated: true)
    }

    @IBAction private func showManeuvers() {
        performSegue(withIdentifier: "ShowManeuvers", sender: self)
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

// MARK: - LocationBasedViewController

extension RouteOverviewViewController: LocationBasedViewController {
    func noLocationAlertCanceledAction() {
        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }
}
