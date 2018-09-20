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

protocol WaypointViewControllerDelegate: AnyObject {
    func waypointViewController(_ viewController: WaypointViewController, entry: WaypointEntry)

    func waypointViewController(_ viewController: WaypointViewController,
                                didCenterMap geoCenter: NMAGeoCoordinates,
                                with zoomLevel: Float)
}

class WaypointViewController: UIViewController {
    // MARK: - LocationBasedViewController properties

    var notificationCenter: NotificationCenterObserving = NotificationCenter.default

    var isLocationMandatory = true

    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider = CLLocationManager.authorizationStatus

    var urlOpener: URLOpening = UIApplication.shared

    var noLocationAlert: UIAlertController?

    var appBecomeActiveObserver: NSObjectProtocol?

    // MARK: - Enums

    enum LocationState {
        case available
        case searching
    }

    // MARK: - Outlets

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var exitButton: UIBarButtonItem!

    @IBOutlet private(set) var okButton: UIBarButtonItem!

    @IBOutlet private(set) var containerView: UIView!

    @IBOutlet private(set) var waypointLabel: UILabel!

    @IBOutlet private(set) var waypointIndicator: UIActivityIndicatorView!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private properties

    private (set) var locationState: LocationState = .searching {
        didSet {
            switch locationState {
            case .available:
                displayInfo()
            case .searching:
                displaySearchingLocation()
            }
        }
    }

    private var observers: [Notification.Name: NSObjectProtocol] = [:]

    // MARK: - Internal properties

    weak var delegate: WaypointViewControllerDelegate?

    var selectedEntry: WaypointEntry?

    var marker: NMAMapMarker?

    var blockID: NSInteger = 0

    var trafficEnabled = true

    var positioningManager = NMAPositioningManager.sharedInstance()

    var toAddress: String?

    var controllerTitle: String?

    var controllerInfoString: String?

    var exitButtonTitle: String?

    var performSegueAfterOK: String?

    var mapGeoCenter: NMAGeoCoordinates?

    var mapZoomLevel: Float?

    // MARK: - Life cycle

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

        // Pass the updates if there is a delegate
        delegate?.waypointViewController(self, didCenterMap: mapView.geoCenter, with: mapView.zoomLevel)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // When this view controller re-appears, i.e. a segue is specified, it should not
        // show the selected marker etc
        if performSegueAfterOK != nil {
            reset()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ShowRouteOverview" {
            guard let viewController = segue.destination as? RouteOverviewViewController else {
                return
            }

            // Init the vc
            viewController.mapGeoCenter = mapView.geoCenter
            viewController.mapZoomLevel = mapView.zoomLevel
            viewController.toCoordinates = marker?.coordinates
            viewController.toAddress = toAddress
            viewController.trafficEnabled = trafficEnabled
        }
    }

    deinit {
        // Remove observers
        observers.forEach { notificationCenter.removeObserver($0.value) }
        observers.removeAll()

        cleanUpLocationAuthorizationObserver()
    }

    // MARK: - Actions

    @IBAction private func onExit(_: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction private func onOK(_: UIBarButtonItem) {
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

    // MARK: - Internal

    func makeEntry(from coordinates: NMAGeoCoordinates) {
        // Reverse geocoding takes time
        showHUD()

        print("Coordinates: '\(coordinates.latitude), \(coordinates.longitude)'")

        // Reset
        toAddress = nil

        // Try to get a localized name out of the coordinates via reverse geocoding
        let request = NMAGeocoder.sharedInstance().createReverseGeocodeRequest(coordinates: coordinates)

        request.languagePreference = Locale.preferredLanguages[0]
        request.collectionSize = 1
        request.start { (_: NMARequest, data: Any?, error: Error?) in
            var name: String?

            // Succeeded?
            if error == nil {
                if let results = data as? [NMAReverseGeocodeResult], results.isEmpty == false {
                    name = results[0].location?.address?.formattedAddress

                    print("Address: '\(name ?? "nil")'")

                    // if we don't know the street & house number, use the name as is
                    if let street = results[0].location?.address?.street, let houseNumber = results[0].location?.address?.houseNumber {
                        self.toAddress = "\(street) \(houseNumber)"
                    } else {
                        self.toAddress = name
                    }
                }
            }

            // Hopefully the name is set: we can make the entry now even when it is not set
            self.makeEntry(waypoint: NMAWaypoint(geoCoordinates: coordinates), name: name)

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

    private func localize() {
        okButton.title = "msdkui_app_ok".localized
    }

    private func updateStyle() {
        view.backgroundColor = .colorBackgroundBrand

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
        exitButton.accessibilityIdentifier = "WaypointViewController.exit"
        okButton.accessibilityIdentifier = "WaypointViewController.ok"

        waypointLabel.accessibilityIdentifier = "WaypointViewController.waypoint"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction // We want to get the exact tap location
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

    private func makeEntry(waypoint: NMAWaypoint, name: String?) {
        let entry: WaypointEntry
        if let name = name {
            entry = WaypointEntry(waypoint, name: name)
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

        print("Selected entry is '\(entry.name)'")

        selectedEntry = entry

        // Accessibility: focus on the waypoint label
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, waypointLabel)
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
}

// MARK: NMAMapGestureDelegate

extension WaypointViewController: NMAMapGestureDelegate {
    func mapView(_: NMAMapView, didReceiveTapAt location: CGPoint) {
        handleGesture(at: location)
    }

    func mapView(_: NMAMapView, didReceiveLongPressAt location: CGPoint) {
        handleGesture(at: location)
    }
}

// MARK: LocationBasedViewController

extension WaypointViewController: LocationBasedViewController {
    func noLocationAlertCanceledAction() {
        performSegue(withIdentifier: "LandingViewUnwind", sender: self)
    }
}
