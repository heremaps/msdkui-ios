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

/// A set of methods for configuring a `WaypointViewController` object.
protocol WaypointViewControllerDelegate: AnyObject {
    func waypointViewController(_ viewController: WaypointViewController, entry: WaypointEntry)
}

class WaypointViewController: UIViewController {
    // MARK: - Types

    enum LocationState {
        case available
        case searching
    }

    // MARK: - Properties

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var exitButton: UIBarButtonItem!

    @IBOutlet private(set) var okButton: UIBarButtonItem!

    @IBOutlet private(set) var containerView: UIView!

    @IBOutlet private(set) var waypointLabel: UILabel!

    @IBOutlet private(set) var waypointIndicator: UIActivityIndicatorView!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    private(set) var locationState: LocationState = .searching {
        didSet {
            switch locationState {
            case .available:
                displayInfo()

            case .searching:
                displaySearchingLocation()
            }
        }
    }

    weak var delegate: WaypointViewControllerDelegate?

    var selectedEntry: WaypointEntry?

    var trafficEnabled = true

    var positioningManager = NMAPositioningManager.sharedInstance()

    var controllerTitle: String?

    var controllerInfoString: String?

    var exitButtonTitle: String?

    var performSegueAfterOK: String?

    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var appBecomeActiveObserver: NSObjectProtocol?

    var reverseGeocoder: NMAGeocoding = NMAGeocoder.sharedInstance()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var observers: [Notification.Name: NSObjectProtocol] = [:]

    private var marker: NMAMapMarker?

    private var blockID: NSInteger = 0

    private var toAddress: String?

    private var mapGeoCenter: NMAGeoCoordinates?

    private var mapZoomLevel: Float?

    // MARK: - Life cycle

    deinit {
        // Remove observers
        observers.forEach { notificationCenter.removeObserver($0.value) }
        observers.removeAll()

        cleanUpLocationAuthorizationObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show the hud until the mapView respond() block is called with NMAMapEvent.tiltChanged
        showHUD()

        localize()
        updateStyle()
        setAccessibility()

        // Initially there is nothing to OK
        okButton.isEnabled = false

        // Set the custom title & button name
        titleItem.title = controllerTitle
        exitButton.title = exitButtonTitle

        // Is there a selected entry?
        if let selectedEntry = self.selectedEntry {
            makeEntry(waypoint: selectedEntry.waypoint, name: selectedEntry.name)
        }

        configureMap()

        // When the map is close to being ready, hide the hud
        blockID = mapView.respond(to: .all) { event, _, _ in
            if event == .tiltChanged {
                self.hideHUD()
            }

            return true
        }

        setUpLocationAuthorizationObserver()
        updateLocationState()
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // When this view controller re-appears, i.e. a segue is specified, it should not
        // show the selected marker etc
        if performSegueAfterOK != nil {
            reset()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRouteOverview", let viewController = segue.destination as? RouteOverviewViewController {
            prepare(incoming: viewController)
        }
    }

    // MARK: - Public

    func makeEntry(from coordinates: NMAGeoCoordinates) {
        // Reverse geocoding takes time
        showHUD()

        // Reset
        toAddress = nil

        reverseGeocoder.reverseGeocode(coordinates: coordinates) { _, data, error in
            var name: String?

            // Succeeded?
            if error == nil {
                if let results = data as? [NMAReverseGeocodeResult], results.isEmpty == false {
                    name = results.first?.location?.address?.formattedAddress

                    // if we don't know the street name, use the name as is
                    if let street = results.first?.location?.address?.street {
                        if let houseNumber = results.first?.location?.address?.houseNumber {
                            self.toAddress = "\(street) \(houseNumber)"
                        } else {
                            self.toAddress = "\(street)"
                        }
                    } else {
                        self.toAddress = name
                    }
                }
            }

            // Hopefully the name is set: we can make the entry now even when it is not set
            self.makeEntry(waypoint: NMAWaypoint(geoCoordinates: coordinates), name: name, streetAddress: self.toAddress)

            // OK'ing is possible by now
            self.okButton.isEnabled = true

            // Done
            self.hideHUD()
        }
    }

    func updateLocationState() {
        guard isLocationMandatory else {
            locationState = .available
            return
        }

        if positioningManager.currentPosition == nil {
            setUpUpdatePositionObserver()
            locationState = .searching
        } else {
            locationState = .available
        }
    }

    // MARK: - Private

    private func prepare(incoming viewController: RouteOverviewViewController) {
        viewController.mapGeoCenter = mapView.geoCenter
        viewController.mapZoomLevel = mapView.zoomLevel
        viewController.toCoordinates = marker?.coordinates
        viewController.toAddress = toAddress
        viewController.trafficEnabled = trafficEnabled
    }

    private func localize() {
        okButton.title = "msdkui_app_ok".localized
    }

    private func updateStyle() {
        view.backgroundColor = .colorBackgroundDark

        exitButton.tintColor = .colorAccentLight
        exitButton.width = CGFloat(50.0) // Set the min button width
        okButton.tintColor = .colorAccentLight
        okButton.width = CGFloat(50.0) // Set the min button width

        containerView.backgroundColor = .colorBackgroundBrand
        waypointLabel.textColor = .colorForegroundLight
    }

    private func configureMap() {
        mapView.landmarksVisible = true
        mapView.positionIndicator.isVisible = true
        mapView.positionIndicator.isAccuracyIndicatorVisible = true
        mapView.extrudedBuildingsVisible = true
        mapView.copyrightLogoPosition = .bottomCenter
        mapView.gestureDelegate = self

        // Is a zoom level specified?
        if let mapZoomLevel = mapZoomLevel {
            mapView.zoomLevel = mapZoomLevel
        }

        // Center the map with the decreasing priorities:
        // 1 - Marker coordinates if specified
        // 2 - Specified map geo center if specified
        // 3 - Current coordinates if known
        if let selectedEntry = selectedEntry, selectedEntry.isValid() {
            mapView.set(geoCenter: selectedEntry.waypoint.originalPosition, animation: .none)
        } else if let mapGeoCenter = mapGeoCenter {
            mapView.set(geoCenter: mapGeoCenter, animation: .none)
        } else if let currentCoordinates = positioningManager.currentPosition?.coordinates {
            mapView.set(geoCenter: currentCoordinates, animation: .none)
        }
    }

    private func showHUD() {
        hudView.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideHUD() {
        // We no longer need the event block handler
        mapView.removeEventBlock(blockIdentifier: blockID)

        activityIndicator.stopAnimating()
        hudView.isHidden = true
    }

    private func setAccessibility() {
        exitButton.accessibilityIdentifier = "WaypointViewController.exitButton"
        okButton.accessibilityIdentifier = "WaypointViewController.okButton"

        waypointLabel.accessibilityIdentifier = "WaypointViewController.waypointLabel"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = .allowsDirectInteraction // We want to get the exact tap location
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_waypoint_map_view".localized
        mapView.accessibilityIdentifier = "WaypointViewController.mapView"

        hudView.accessibilityIdentifier = "WaypointViewController.hudView"
    }

    private func warnForInvalidWaypoint() {
        let alertController = UIAlertController(title: nil, message: "msdkui_app_waypoint_not_valid".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "msdkui_app_ok".localized, style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func makeEntry(waypoint: NMAWaypoint, name: String?, streetAddress: String? = nil) {
        let entry: WaypointEntry
        if let name = name {
            entry = WaypointEntry(waypoint, name: name, streetAddress: streetAddress)
        } else {
            entry = WaypointEntry(waypoint)
        }

        // Is the entry is valid, i.e. it has coordinates?
        guard entry.isValid() else {
            return
        }

        let waypointOriginalPosition = entry.waypoint.originalPosition
        if let marker = marker {
            marker.coordinates = waypointOriginalPosition
        } else {
            marker = mapView.addMarker(with: "Waypoint.add", at: waypointOriginalPosition)
        }

        waypointLabel.text = entry.name
        containerView.backgroundColor = UIColor.colorAccent

        selectedEntry = entry

        // Accessibility: focus on the waypoint label
        UIAccessibility.post(notification: .layoutChanged, argument: waypointLabel)
    }

    private func handleGesture(at location: CGPoint) {
        // Waypoint selection is only possible when info is displayed
        if locationState != .available {
            return
        }

        // Make sure there's a valid coordinate
        guard let coordinates = mapView.geoCoordinates(from: location) else {
            // Otherwise show a warning
            warnForInvalidWaypoint()
            return
        }

        // Make the entry: the OK button will be enabled after making the entry
        makeEntry(from: coordinates)
    }

    private func reset() {
        okButton.isEnabled = false
        containerView.backgroundColor = .colorBackgroundBrand
        waypointLabel.text = controllerInfoString
        if let marker = marker {
            mapView.remove(mapObject: marker)
        }
        selectedEntry = nil
        marker = nil

        configureMap()
    }

    private func setUpUpdatePositionObserver() {
        let positionObserver = notificationCenter.addObserver(forName: .NMAPositioningManagerDidUpdatePosition, object: nil, queue: nil) { [weak self] _ in
            // Get coordinates if available
            guard let coordinates = self?.positioningManager.currentPosition?.coordinates else {
                return
            }

            // Remove notification observer
            if let observer = self?.observers[.NMAPositioningManagerDidUpdatePosition] {
                self?.notificationCenter.removeObserver(observer)
            }

            self?.observers.removeValue(forKey: .NMAPositioningManagerDidUpdatePosition)

            // Update state
            self?.locationState = .available

            // Move map to current position
            self?.mapView.set(geoCenter: coordinates, animation: .bow)
        }

        observers[.NMAPositioningManagerDidUpdatePosition] = positionObserver
    }

    private func displayInfo() {
        waypointLabel.text = controllerInfoString
        waypointIndicator.stopAnimating()
        waypointIndicator.isHidden = true
    }

    private func displaySearchingLocation() {
        waypointLabel.text = "msdkui_app_userposition_search".localized
        waypointIndicator.isHidden = false
        waypointIndicator.startAnimating()
    }

    @IBAction private func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction private func selectEntry(_ sender: UIBarButtonItem) {
        // If there is any selected entry, pass it to the delegate if any
        if let selectedEntry = selectedEntry {
            delegate?.waypointViewController(self, entry: selectedEntry)
        }

        // If there is a segue specified, perform it and otherwise simply dismiss
        if let segue = performSegueAfterOK {
            performSegue(withIdentifier: segue, sender: self)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - NMAMapGestureDelegate

extension WaypointViewController: NMAMapGestureDelegate {
    func mapView(_ mapView: NMAMapView, didReceiveTapAt location: CGPoint) {
        handleGesture(at: location)
    }

    func mapView(_ mapView: NMAMapView, didReceiveLongPressAt location: CGPoint) {
        handleGesture(at: location)
    }
}

// MARK: - LocationBasedViewController

extension WaypointViewController: LocationBasedViewController {
    func noLocationAlertCanceledAction() {
        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }
}
