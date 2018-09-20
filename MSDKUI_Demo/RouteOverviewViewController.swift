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

class RouteOverviewViewController: UIViewController, GuidancePresentingViewController {
    // MARK: - LocationBasedViewController properties

    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var appBecomeActiveObserver: NSObjectProtocol?

    // MARK: - GuidancePresentingViewController properties

    var guidanceSegueID: String? = "ShowGuidanceFromRoutes"

    var shouldStartSimulation = false

    var route: NMARoute?

    var trafficEnabled = true

    // MARK: - Outlets

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

    // MARK: - Internal properties

    let router = NMACoreRouter()

    // The current coordinates
    var fromCoordinates: NMAGeoCoordinates?

    // The destination coordinates
    var toCoordinates: NMAGeoCoordinates?

    // The destination address string
    var toAddress: String?

    var mapGeoCenter: NMAGeoCoordinates?

    var mapZoomLevel: Float?

    var blockID = NSInteger(0)

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

        // Show the hud until the route is calculated
        showHUD()

        // TODO: MSDKUI-1150 - [iOS] Check RouteDescriptionItem padding properties
        // We don't want any leading/trailing padding
        routeDescriptionItem.leadingConstraint.constant = 0
        routeDescriptionItem.trailingConstraint.constant = 0

        // Hopefully we have the to address
        addressLabel.text = toAddress

        localize()
        updateStyle()
        setAccessibility()
        setUpLocationAuthorizationObserver()

        configureMap()
        configureRouter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Restore
        mapView.isTrafficVisible = trafficEnabled
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkLocationAuthorizationStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // From the NMAMapView trafficVisible property documentation:
        // "Traffic can only be displayed on one map at a time. It is recommended that you turn off
        //  traffic display on other maps before enabling traffic display on a new map otherwise the
        //  results may be unpredictable."
        mapView.isTrafficVisible = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Zoom to the whole route & markers after transition
        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateView()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == guidanceSegueID, let viewController = segue.destination as? GuidanceViewController {
            prepare(viewController: viewController)
        } else if segue.identifier == "ShowManeuvers", let viewController = segue.destination as? ManeuversOverviewViewController {
            viewController.route = route
            viewController.toAddress = toAddress
        }
    }

    deinit {
        cleanUpLocationAuthorizationObserver()
    }

    // MARK: - Actions

    @IBAction private func goBack() {
        dismiss(animated: true)
    }

    @IBAction private func showManeuvers() {
        performSegue(withIdentifier: "ShowManeuvers", sender: self)
    }

    @IBAction private func startNavigation() {
        showGuidance(withSimulation: false)
    }

    @IBAction private func handleNavigationLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            showSimulationAlert()
        }
    }

    // MARK: - Private

    private func localize() {
        toLabel.text = "msdkui_app_routeoverview_to".localized
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_route_preview_title".localized
        noRouteLabel.text = "msdkui_app_routeresults_error".localized

        showManeuversButton.setTitle("msdkui_app_guidance_button_showmaneuvers".localized, for: .normal)
        startNavigationButton.setTitle("msdkui_app_guidance_button_start".localized, for: .normal)
    }

    private func updateStyle() {
        activityIndicator.color = UIColor.colorAccent

        dividerViews.forEach { $0.backgroundColor = .colorDivider }
        panelView.backgroundColor = UIColor.colorBackgroundViewLight
        backButton.tintColor = UIColor.colorAccentLight
        toLabel.textColor = UIColor.colorForegroundSecondary
        addressLabel.textColor = UIColor.colorForegroundSecondary
        noRouteLabel.backgroundColor = UIColor.colorBackgroundViewLight
        noRouteLabel.textColor = UIColor.colorNegative
        containerView.backgroundColor = .colorBackgroundViewLight

        applyForegroundLightStyle(to: showManeuversButton)
        applyAccentStyle(to: startNavigationButton)
    }

    private func configureMap() {
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

        // When the map is close to being ready, calculate the road
        blockID = mapView.respond(to: .all) { event, _, _ in
            if event == .tiltChanged {
                self.calculateRoute()
            }

            return true
        }
    }

    private func configureRouter() {
        router.dynamicPenalty = NMADynamicPenalty()
        router.dynamicPenalty!.trafficPenaltyMode = .optimal // We want to display delays
        router.connectivity = .online
    }

    private func calculateRoute() {
        // If we don't know the from & to coordinates, inform the user
        guard let fromCoordinates = fromCoordinates, let toCoordinates = toCoordinates else {
            noRouteFound()
            return
        }

        // Add the route end marker
        mapView.addMarker(with: "Route.end", at: toCoordinates)

        // Calculate the route
        let routingMode = NMARoutingMode()
        routingMode.transportMode = .car
        routingMode.resultLimit = 1

        let waypoints: [NMAWaypoint] = [
            NMAWaypoint(geoCoordinates: fromCoordinates, waypointType: .stopWaypoint),
            NMAWaypoint(geoCoordinates: toCoordinates, waypointType: .stopWaypoint)
        ]

        _ = router.calculateRoute(withStops: waypoints, routingMode: routingMode) { result, error in
            if error == .none || error == .violatesOptions {
                if let result = result, let resultRoutes = result.routes,
                    resultRoutes.count == 1, let route = resultRoutes.first {
                    // Set the data
                    self.route = route
                    self.routeDescriptionItem.trafficEnabled = self.mapView.isTrafficVisible
                    self.routeDescriptionItem.route = self.route

                    // Try to show the route on the map
                    if let mapRoute = NMAMapRoute(route) {
                        self.mapView.add(mapObject: mapRoute)
                    }
                }
            }

            // Ready for use
            self.hideHUD()

            // In case of success, try to contain the markers and otherwise inform the user
            self.updateView()
        }
    }

    private func updateView() {
        // If we don't know the destination address or in landscape orientation, hide it
        destinationView.isHidden = toAddress == nil || UIDevice.current.isLandscape

        // If the route is not calculated yet, do nothing
        guard activityIndicator.isHidden else {
            return
        }

        // Do we have a route? If not, inform the user
        guard let route = route else {
            noRouteFound()
            return
        }

        // Do we know the route boundig box?
        // Do we know the start & end coordinates?
        // Do we know the start & end marker bounding boxes and the intersection bounding box?
        // If not, do nothing
        guard let routeBoundingBox = route.boundingBox,
            case let fromCoordinates = fromCoordinates,
            case let toCoordinates = toCoordinates,
            let startMarkerBoundingBox = mapView.markerBoundingBox(at: fromCoordinates),
            let endMarkerBoundingBox = mapView.markerBoundingBox(at: toCoordinates),
            let intersectionBoundingBox = NMAGeoBoundingBox(boundingBoxes: [routeBoundingBox, startMarkerBoundingBox, endMarkerBoundingBox]) else {
                return
        }

        // Zoom to the route and markers thanks to the intersectionBoundingBox
        mapView.set(boundingBox: intersectionBoundingBox, animation: .bow)
    }

    private func showHUD() {
        containerView.isHidden = true
        activityIndicator.startAnimating()
    }

    private func hideHUD() {
        // We no longer need the event block handler
        mapView.removeEventBlock(blockIdentifier: blockID)

        activityIndicator.stopAnimating()
        containerView.isHidden = false
    }

    private func noRouteFound() {
        hideHUD()
        panelView.isHidden = true
        noRouteLabel.isHidden = false
    }

    private func setAccessibility() {
        backButton.accessibilityIdentifier = "RouteOverviewViewController.backButton"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = UIAccessibilityTraitNone
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_route_map_view".localized
        mapView.accessibilityIdentifier = "RouteOverviewViewController.mapView"

        containerView.accessibilityIdentifier = "RouteOverviewViewController.containerView"

        showManeuversButton.accessibilityIdentifier = "RouteOverviewViewController.showManeuversButton"
        startNavigationButton.accessibilityIdentifier = "RouteOverviewViewController.startNavigationButton"
    }
}

// MARK: LocationBasedViewController

extension RouteOverviewViewController: LocationBasedViewController {
    func noLocationAlertCanceledAction() {
        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }
}
