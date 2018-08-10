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

// This view controller is orientation sensitive: the `GuidanceManeuverPanel`
// monitors the device rotations. For the portrait and landscape orientations,
// it has different layouts.
class GuidanceViewController: UIViewController {
    enum Constants {
        static let mapViewZoomLevel = Float(18.40)

        static let mapViewTilt = Float(72.0)

        // Position the indicator centered at the bottom of screen
        static let mapViewTransformCenter = CGPoint(x: 0.5, y: 0.85)
    }

    @IBOutlet private(set) var panel: GuidanceManeuverPanel!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var stopNavigationButton: UIButton!

    var route: NMARoute?

    var mapRoute: NMAMapRoute?

    /// Flag specifies if simulation should be started.
    var shouldStartSimulation = false

    var trafficEnabled = true

    var presenter: GuidanceManeuverPanelPresenter?

    private var positionObservers: [NSObjectProtocol] = []

    // LocationBasedViewController
    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var appBecomeActiveObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateStyle()
        setAccessibility()

        guard let route = route else {
            return
        }

        // Create and register the self to the presenter
        presenter = GuidanceManeuverPanelPresenter(route: route)
        presenter?.delegate = self

        // Registers itself as a NavigationManagerDelegateDispatcher delegate
        NavigationManagerDelegateDispatcher.shared.add(delegate: self)

        configureMap()
        configureNavManager()
        setUpNotifications()
        setUpLocationAuthorizationObserver()

        startGuidance()

        // Start the guidance
        NMANavigationManager.sharedInstance().startTurnByTurnNavigation(route)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkLocationAuthorizationStatus()
    }

    deinit {
        // Remove observers
        positionObservers.forEach { notificationCenter.removeObserver($0) }
        positionObservers.removeAll()

        cleanUpLocationAuthorizationObserver()
    }

    func updateStyle() {
        applyCancelStyle(to: stopNavigationButton)
    }

    private func applyCancelStyle(to button: UIButton) {
        button.backgroundColor = .colorSignificantLight
        button.layer.cornerRadius = 2
        button.tintColor = .colorSignificant

        // Image
        let image = UIImage(named: "Clear")
        image?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)

        // Insets
        func equalInsets(around size: CGSize, in container: CGSize) -> UIEdgeInsets {
            let horizontalInsetHalf = size.width < container.width ?
                (container.width - size.width) / 2 : 0
            let verticalInsetHalf = size.height < container.height ?
                (container.height - size.height) / 2 : 0
            return UIEdgeInsets(top: verticalInsetHalf, left: horizontalInsetHalf, bottom: verticalInsetHalf, right: horizontalInsetHalf)
        }

        func imageEdgeInsets(sideLength: CGFloat, frame: CGRect) -> UIEdgeInsets {
            // Note: Design specifies button size of 48pt and image size of 24pt
            let imageSize = CGSize(width: sideLength, height: sideLength)
            let imageInsets = equalInsets(around: imageSize, in: frame.size)
            return imageInsets
        }

        button.imageEdgeInsets = imageEdgeInsets(sideLength: 24, frame: button.frame)
    }

    override var prefersStatusBarHidden: Bool {
        // We want to show the status bar always, i.e. even in the landscape orientation
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction private func stopNavigationButtonTapped(_ sender: UIButton) {
        stopSimulation()
        performSegue(withIdentifier: "LandingViewUnwind", sender: sender)
    }

    func configureMap() {
        guard let route = route, let mapRoute = NMAMapRoute(route) else {
            return
        }

        mapRoute.isTrafficEnabled = trafficEnabled

        // Add the route to the map
        mapView.add(mapObject: mapRoute)
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
    }

    func configureNavManager() {
        NMANavigationManager.sharedInstance().map = mapView
        NMANavigationManager.sharedInstance().mapTrackingTilt = .tiltCustom
        NMANavigationManager.sharedInstance().voicePackageMeasurementSystem = .metric
        NMANavigationManager.sharedInstance().mapTrackingEnabled = true
        NMANavigationManager.sharedInstance().realisticViewMode = .day
    }

    private func setAccessibility() {
        mapView.accessibilityIdentifier = "GuidanceViewController.mapView"

        stopNavigationButton.accessibilityIdentifier = "GuidanceViewController.stopNavigationButton"
        stopNavigationButton.accessibilityLabel = "msdkui_app_stop_navigation".localized
    }

    private func setUpNotifications() {
        // Need to update screen when position is updated or lost
        for notificationName: Notification.Name in [.NMAPositioningManagerDidUpdatePosition, .NMAPositioningManagerDidLosePosition] {
            let observer = notificationCenter.addObserver(forName: notificationName, object: nil, queue: nil) { [weak self] _ in
                    self?.updatePositionInfo()
            }
            positionObservers.append(observer)
        }
    }

    func startGuidance() {
        guard let route = route else {
            return
        }

        NMAPositioningManager.sharedInstance().stopPositioning()

        if shouldStartSimulation {
            let routeSource = NMARoutePositionSource(route: route)
            routeSource.updateInterval = 0.1 // second
            routeSource.movementSpeed = 12.0 // m/s
            NMAPositioningManager.sharedInstance().dataSource = routeSource
        }

        NMAPositioningManager.sharedInstance().startPositioning()
    }

    func stopSimulation() {
        NMANavigationManager.sharedInstance().stop()
        NMAPositioningManager.sharedInstance().stopPositioning()
        NMAPositioningManager.sharedInstance().dataSource = nil
        NMAPositioningManager.sharedInstance().startPositioning()
    }

    private func updatePositionInfo() {
        // TODO: MSDKUI-782 - implement replacing street name with no position info when needed
    }
}

// MARK: GuidanceManeuverPanelPresenterDelegate

extension GuidanceViewController: GuidanceManeuverPanelPresenterDelegate {
    public func guidanceManeuverPanelPresenter(_ presenter: GuidanceManeuverPanelPresenter, didUpdateData data: GuidanceManeuverData) {
        print("data: \(String(describing: data))")

        panel.data = data
    }

    public func guidanceManeuverPanelPresenterDidReachDestination(_ presenter: GuidanceManeuverPanelPresenter) {
        print("Reached to the destination!")

        panel.highlightManeuver(textColor: Styles.shared.guidanceManeuverArrivalTextColor)
    }
}

// MARK: NMANavigationManagerDelegate

extension GuidanceViewController: NMANavigationManagerDelegate {
    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateRoute routeResult: NMARouteResult) {
        guard let newRoute = routeResult.routes?.first,
            let newMapRoute = NMAMapRoute(newRoute) else {
            // Route calculation failed
            return
        }

        newMapRoute.isTrafficEnabled = trafficEnabled

        // Remove the current map route if reroute succeeded
        if let currentMapRoute = mapRoute {
            mapView.remove(mapObject: currentMapRoute)
        }

        route = newRoute
        mapView.add(mapObject: newMapRoute)
        mapRoute = newMapRoute
    }
}

// MARK: LocationBasedViewController

extension GuidanceViewController: LocationBasedViewController {
    func noLocationAlertCanceledAction() {
        stopSimulation()
        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }
}
