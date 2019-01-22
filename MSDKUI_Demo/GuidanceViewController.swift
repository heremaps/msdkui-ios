//
// Copyright (C) 2017-2019 HERE Europe B.V.
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

final class GuidanceViewController: UIViewController {

    // MARK: - Types

    private enum Constants {

        // MARK: - Properties

        static let mapViewZoomLevel = Float(18.40)

        static let mapViewTilt = Float(72.0)

        // Center the position indicator horizontally and put close to the bottom vertically
        static let mapViewTransformCenter = CGPoint(x: 0.5, y: 0.65)
    }

    enum DashboardState {
        case open
        case collapsed
    }

    // MARK: - Properties

    @IBOutlet private(set) var maneuverView: GuidanceManeuverView!

    /// The next maneuver view which is initially hidden.
    @IBOutlet private(set) var nextManeuverView: GuidanceNextManeuverView!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var mapOverlayView: UIView!

    /// The current street label view which is initially hidden.
    @IBOutlet private(set) var currentStreetLabel: GuidanceStreetLabel!

    @IBOutlet private(set) var currentSpeedView: GuidanceSpeedView!

    @IBOutlet private(set) var speedLimitView: GuidanceSpeedLimitView!

    @IBOutlet private(set) var dashboardVisibleHeightConstraint: NSLayoutConstraint!

    @IBOutlet private(set) var dashboardOverlayView: UIView!

    /// The map route created out of `route`.
    var mapRoute: NMAMapRoute? {
        didSet {
            // If there is a previous map route, remove it from the map
            if let oldValue = oldValue {
                mapRouteHandler.remove(oldValue, from: mapView)
            }

            // If there is a new map route, add it to the map with the `trafficEnabled` setting
            if let mapRoute = mapRoute {
                mapRoute.isTrafficEnabled = trafficEnabled
                mapRouteHandler.add(mapRoute, to: mapView)
            }
        }
    }

    var idleTimerDisabler: IdleTimerDisabling = UIApplication.shared

    private(set) var maneuverMonitor: GuidanceManeuverMonitor?

    private(set) var positionObservers: [NSObjectProtocol] = []

    var mapRouteHandler: MapRouteHandling = MapRouteHandler()

    let guidanceCurrentStreetNameMonitor = GuidanceCurrentStreetNameMonitor()

    let speedMonitor = GuidanceSpeedMonitor()

    private(set) var dashboardState: DashboardState = .collapsed {
        didSet {
            // Updates the visible height
            dashboardVisibleHeightConstraint.constant = dashboardState == .collapsed ? .dashboardCollapsedHeight : .dashboardOpenHeight

            // Animates the height and alpha changes
            viewAnimator(0.3) { [weak self] in
                self?.mapOverlayView.alpha = self?.dashboardState == .collapsed ? .dashboardCollapsedAlpha : .dashboardOpenAlpha
                self?.view.layoutIfNeeded()
            }
        }
    }

    /// UIView animator used to animate views.
    lazy var viewAnimator = UIView.animate(withDuration:animations:)

    override var prefersStatusBarHidden: Bool {
        // We want to show the status bar always, i.e. even in the horizontal orientation
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var appBecomeActiveObserver: NSObjectProtocol?

    var shouldStartSimulation = false

    var route: NMARoute? {
        didSet {
            maneuverMonitor?.updateRoute(route)
            nextManeuverMonitor?.updateRoute(route)
        }
    }

    var trafficEnabled = true

    private var nextManeuverMonitor: GuidanceNextManeuverMonitor?

    private var positioningManager = NMAPositioningManager.sharedInstance()

    // MARK: - Life cycle

    deinit {
        cleanUpPositionNotificationsObservers()
        cleanUpLocationAuthorizationObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateStyle()
        setAccessibility()

        // Applies speed view style
        setUpCurrentSpeedView()

        // Applies speed limit style
        setUpSpeedLimitView()

        // Applies maneuver view style
        setUpManeuverView()

        // Applies next maneuver view style
        setUpNextManeuverView()

        guard let route = route else {
            return
        }

        // Creates and registers itself to the GuidanceManeuverMonitor delegate
        maneuverMonitor = GuidanceManeuverMonitor(route: route)
        maneuverMonitor?.delegate = self

        // Creates and registers itself as the GuidanceNextManeuverMonitor delegate
        nextManeuverMonitor = GuidanceNextManeuverMonitor(route: route)
        nextManeuverMonitor?.delegate = self

        // Registers itself as a delegate to current street name monitor
        guidanceCurrentStreetNameMonitor.delegate = self

        // Configure current street label
        currentStreetLabel.lookingForPositionText = "msdkui_app_userposition_search".localized

        // Registers itself as the GuidanceSpeedMonitor delegate
        speedMonitor.delegate = self

        // Registers itself as a NavigationManagerDelegateDispatcher delegate
        NavigationManagerDelegateDispatcher.shared.add(delegate: self)

        configureMap()
        configureNavManager()
        setUpLocationAuthorizationObserver()
        setUpPositionNotificationsObservers()
        updatePositionInfo()

        startNavigation()

        // Starts the guidance
        NMANavigationManager.sharedInstance().startTurnByTurnNavigation(route)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Sets up views when `UIUserInterfaceSizeClass` case changes from `.unspecified`
        setUpCurrentSpeedView(for: traitCollection)
        setUpManeuverView(for: traitCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkLocationAuthorizationStatus()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        // Sets up views based on new `UITraitCollection`
        setUpCurrentSpeedView(for: newCollection)
        setUpManeuverView(for: newCollection)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashboardSegue", let viewController = segue.destination as? GuidanceDashboardViewController {
            viewController.delegate = self
        }
    }

    // MARK: - Public

    func startNavigation() {
        guard let route = route else {
            return
        }

        // Disable the idle timer to prevent darkening the screen during guidance
        idleTimerDisabler.isIdleTimerDisabled = true

        positioningManager.stopPositioning()

        if shouldStartSimulation {
            let routeSource = NMARoutePositionSource(route: route)
            routeSource.updateInterval = 0.1 // second
            routeSource.movementSpeed = 12.0 // m/s
            positioningManager.dataSource = routeSource
        }

        positioningManager.startPositioning()
    }

    func stopNavigation() {
        // Enable the idle timer back
        idleTimerDisabler.isIdleTimerDisabled = false

        NMANavigationManager.sharedInstance().stop()
        positioningManager.stopPositioning()
        positioningManager.dataSource = nil
        positioningManager.startPositioning()

        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }

    /// Handles the tap on the map overlay view.
    ///
    /// - Parameter sender: The tap gesture recognizer.
    @IBAction func handleMapOverlayViewTap(_ sender: UITapGestureRecognizer) { // swiftlint:disable:this private_action
        guard sender.state == .ended else {
            return
        }

        dashboardState = .collapsed
    }

    // MARK: - Private

    private func updateStyle() {
        view.backgroundColor = .colorBackgroundDark
        dashboardOverlayView.backgroundColor = .colorBackgroundDark
    }

    private func configureMap() {
        guard let route = route, let mapRoute = mapRouteHandler.makeMapRoute(with: route) else {
            return
        }

        // Set the map route
        self.mapRoute = mapRoute

        // Mark the route end
        if let endCoordinates = route.destination?.originalPosition {
            mapView.addMarker(with: "Route.end", at: endCoordinates)
        }

        mapView.maximumTiltProfile = { zoom in
            let angle3DLowZoomLevel = Constants.mapViewZoomLevel - 4.0
            let angle3DHighZoomLevel = Constants.mapViewZoomLevel - 2.0
            let angle3DGuidance = Constants.mapViewTilt

            return angle3DGuidance * max(1, (zoom - angle3DLowZoomLevel) / (angle3DHighZoomLevel - angle3DLowZoomLevel))
        }

        mapView.set(zoomLevel: Constants.mapViewZoomLevel, animation: .none)
        mapView.tilt = mapView.maximumTilt(atZoomLevel: Constants.mapViewZoomLevel)
        mapView.landmarksVisible = true
        mapView.positionIndicator.isVisible = true
        mapView.positionIndicator.isAccuracyIndicatorVisible = true
        mapView.isTrafficVisible = trafficEnabled
        mapView.extrudedBuildingsVisible = true
        mapView.mapCenterFixedOnRotateZoom = true
        mapView.transformCenter = Constants.mapViewTransformCenter
        mapView.copyrightLogoPosition = .bottomLeft

        // Center the map with the current coordinates if known
        if let currentCoordinates = positioningManager.currentPosition?.coordinates {
            mapView.set(geoCenter: currentCoordinates, animation: .none)
        }
    }

    private func configureNavManager() {
        NMANavigationManager.sharedInstance().map = mapView
        NMANavigationManager.sharedInstance().mapTrackingTilt = .tiltCustom
        NMANavigationManager.sharedInstance().voicePackageMeasurementSystem = .metric
        NMANavigationManager.sharedInstance().mapTrackingEnabled = true
        NMANavigationManager.sharedInstance().realisticViewMode = .day
    }

    private func setAccessibility() {
        mapView.accessibilityIdentifier = "GuidanceViewController.mapView"
        currentStreetLabel.accessibilityIdentifier = "GuidanceViewController.currentStreetLabel"
    }

    /// Styles the current speed view.
    private func setUpCurrentSpeedView() {
        // Rounds the speed view
        currentSpeedView.layer.cornerRadius = currentSpeedView.bounds.height / 2

        // Centers the current speed view content
        currentSpeedView.textAlignment = .center

        // Sets the colors
        currentSpeedView.backgroundColor = .colorBackgroundBrand
        currentSpeedView.speedValueTextColor = .colorForegroundLight
        currentSpeedView.speedUnitTextColor = .colorForegroundLight
    }

    /// Styles the speed limit view.
    private func setUpSpeedLimitView() {
        // Rounds the speed limit view
        speedLimitView.layer.cornerRadius = speedLimitView.bounds.height / 2

        // Adds red border
        speedLimitView.layer.borderWidth = 4
        speedLimitView.layer.borderColor = UIColor.red.cgColor
    }

    /// Styles the next maneuver view.
    private func setUpNextManeuverView() {
        // Sets margins for view
        nextManeuverView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    }

    /// Styles the maneuver view.
    private func setUpManeuverView() {
        maneuverView.tintColor = .colorAccentLight
    }

    private func setUpPositionNotificationsObservers() {
        for notificationName: Notification.Name in [.NMAPositioningManagerDidUpdatePosition] {
            let observer = notificationCenter.addObserver(forName: notificationName, object: nil, queue: nil) { [weak self] _ in
                self?.updatePositionInfo()
            }
            positionObservers.append(observer)
        }
    }

    private func cleanUpPositionNotificationsObservers() {
        positionObservers.forEach(notificationCenter.removeObserver)
        positionObservers = []
    }

    private func updatePositionInfo() {
        if positioningManager.currentPosition == nil {
            currentStreetLabel.isLookingForPosition = true
        } else if currentStreetLabel.isLookingForPosition {
            currentStreetLabel.isLookingForPosition = false
            let currentStreetName = NMANavigationManager.sharedInstance().currentManeuver?.getCurrentStreet()
            guidanceCurrentStreetNameMonitor(guidanceCurrentStreetNameMonitor,
                                             didUpdateCurrentStreetName: currentStreetName)
        }
        // Ignore position updates when not looking for position
    }

    /// Sets up the current speed view for the given trait collection.
    ///
    /// - Parameter traitCollection: The trait collection used to set up the `currentSpeedView`.
    private func setUpCurrentSpeedView(for traitCollection: UITraitCollection) {
        switch traitCollection.verticalSizeClass {
        case .compact:
            currentSpeedView.isHidden = false

        default:
            currentSpeedView.isHidden = true
        }
    }

    /// Sets up the maneuver view for the given trait collection.
    ///
    /// - Parameter traitCollection: The trait collection used to set up the `maneuverView`.
    private func setUpManeuverView(for traitCollection: UITraitCollection) {
        switch traitCollection.verticalSizeClass {
        case .compact:
            maneuverView.axis = .vertical

        default:
            maneuverView.axis = .horizontal
        }
    }
}

// MARK: - GuidanceManeuverMonitorDelegate

extension GuidanceViewController: GuidanceManeuverMonitorDelegate {

    func guidanceManeuverMonitor(_ monitor: GuidanceManeuverMonitor, didUpdateData data: GuidanceManeuverData?) {
        if let maneuverData = data {
            maneuverView.state = .data(maneuverData)
        } else {
            maneuverView.state = .updating
        }
    }

    func guidanceManeuverMonitorDidReachDestination(_ monitor: GuidanceManeuverMonitor) {
        // Enable the idle timer back
        idleTimerDisabler.isIdleTimerDisabled = false
        maneuverView.highlightManeuver = true
    }
}

// MARK: - NMANavigationManagerDelegate

extension GuidanceViewController: NMANavigationManagerDelegate {

    func navigationManager(_ navigationManager: NMANavigationManager, didUpdateRoute routeResult: NMARouteResult) {
        guard let newRoute = routeResult.routes?.first,
            let newMapRoute = mapRouteHandler.makeMapRoute(with: newRoute) else {
                // Route calculation failed
                return
        }

        // Refresh the route and map route
        route = newRoute
        mapRoute = newMapRoute
    }
}

// MARK: - LocationBasedViewController

extension GuidanceViewController: LocationBasedViewController {

    func noLocationAlertCanceledAction() {
        stopNavigation()
    }
}

// MARK: - GuidanceNextManeuverMonitorDelegate

extension GuidanceViewController: GuidanceNextManeuverMonitorDelegate {

    func guidanceNextManeuverMonitor(_ monitor: GuidanceNextManeuverMonitor,
                                     didReveiveData maneuverIcon: UIImage?,
                                     distance: Measurement<UnitLength>,
                                     streetName: String?) {
        let viewModel = GuidanceNextManeuverView.ViewModel(maneuverIcon: maneuverIcon, distance: distance, streetName: streetName)
        nextManeuverView.configure(with: viewModel)
        nextManeuverView.isHidden = false
    }

    func guidanceNextManeuverMonitorDidReceiveError(_ monitor: GuidanceNextManeuverMonitor) {
        nextManeuverView.isHidden = true
    }
}

// MARK: - GuidanceCurrentStreetNameMonitorDelegate

extension GuidanceViewController: GuidanceCurrentStreetNameMonitorDelegate {

    func guidanceCurrentStreetNameMonitor(_ monitor: GuidanceCurrentStreetNameMonitor, didUpdateCurrentStreetName currentStreetName: String?) {
        currentStreetLabel.text = currentStreetName
        currentStreetLabel.isAccented = true
        currentStreetLabel.isHidden = currentStreetLabel.text.hasContent ? false : true
    }
}

// MARK: - GuidanceSpeedMonitorDelegate

extension GuidanceViewController: GuidanceSpeedMonitorDelegate {

    func guidanceSpeedMonitor(_ monitor: GuidanceSpeedMonitor,
                              didUpdateCurrentSpeed currentSpeed: Measurement<UnitSpeed>,
                              isSpeeding: Bool,
                              speedLimit: Measurement<UnitSpeed>?) {
        // Updates the current speed view
        currentSpeedView.speed = currentSpeed
        currentSpeedView.backgroundColor = isSpeeding ? .colorNegative : .colorBackgroundBrand

        // Updates the speed limit view
        speedLimitView.speedLimit = speedLimit
        speedLimitView.isHidden = speedLimit == nil
    }
}

// MARK: - GuidanceDashboardViewControllerDelegate

extension GuidanceViewController: GuidanceDashboardViewControllerDelegate {

    func guidanceDashboardViewController(_ controller: GuidanceDashboardViewController, didSelectItem item: GuidanceDashboardTableViewDataSource.Item) {
        guard item == .about else {
            return
        }

        performSegue(withIdentifier: "AboutSegue", sender: self)
    }

    func guidanceDashboardViewControllerDidTapView(_ controller: GuidanceDashboardViewController) {
        dashboardState = dashboardState == .open ? .collapsed : .open
    }

    func guidanceDashboardViewControllerDidTapStopNavigation(_ controller: GuidanceDashboardViewController) {
        stopNavigation()
    }
}

// MARK: - Dashboard Constants

private extension CGFloat {

    /// The dashboard alpha when collapsed.
    static let dashboardCollapsedAlpha = CGFloat(0.0)

    /// The dashboard height when collapsed.
    static let dashboardCollapsedHeight = CGFloat(84)

    /// The dashboard alpha when open.
    static let dashboardOpenAlpha = CGFloat(0.5)

    /// The dashboard height when open.
    static let dashboardOpenHeight = CGFloat(197)
}
