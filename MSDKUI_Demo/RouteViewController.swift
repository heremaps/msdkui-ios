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

/// A set of methods for communicating interactions with the route.
protocol RouteViewControllerDelegate: AnyObject {
    func refreshRoute(_ viewController: UIViewController)
}

class RouteViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var routeDescriptionItem: RouteDescriptionItem!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var topSeparatorView: UIView!

    @IBOutlet private(set) var bottomSeparatorView: UIView!

    @IBOutlet private(set) var sourceLabel: UILabel!

    @IBOutlet private(set) var sourceToDestinationImage: UIImageView!

    @IBOutlet private(set) var destinationLabel: UILabel!

    @IBOutlet private(set) var maneuverTableView: ManeuverTableView!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private(set) var tableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private(set) var showButtonSeparatorView: UIView!

    @IBOutlet private(set) var showButton: UIButton!

    weak var delegate: RouteViewControllerDelegate?

    var routingMode: NMARoutingMode?

    var route: NMARoute?

    var mapRouteHandler: MapRouteHandling = MapRouteHandler()

    var mapViewportHandler: MapViewportHandling = MapViewportHandler()

    var reverseGeocoder: NMAGeocoding = NMAGeocoder.sharedInstance()

    var trafficEnabled = true

    var sourceAddress: String?

    var destinationAddress: String?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var mapRoute: NMAMapRoute?

    private var startMarker: NMAMapMarker?

    private var endMarker: NMAMapMarker?

    private var blockID: NSInteger = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Show the route on the map
        guard let route = route, let mapRoute = mapRouteHandler.makeMapRoute(with: route) else {
            return
        }

        self.mapRoute = mapRoute
        mapRouteHandler.add(mapRoute, to: mapView)

        // Should show the traffic on the map?
        mapView.isTrafficVisible = trafficEnabled
        mapView.isUserInteractionEnabled = false

        // Prepare the components: note that we don't show the bar on the routeDescriptionItem
        routeDescriptionItem.trafficEnabled = trafficEnabled
        routeDescriptionItem.route = route
        routeDescriptionItem.trailingInset = -16
        routeDescriptionItem.leadingInset = 19
        routeDescriptionItem.setSectionVisible(.icon, false)
        maneuverTableView.route = route

        updateShowButtonText()
        updateMapViewAccessibility()

        // Are the start and end coordinates OK?
        if let startCoordinates = route.start?.originalPosition, let endCoordinates = route.destination?.originalPosition {
            // Make the route start/end markers
            startMarker = mapView.addMarker(with: "Route.start", at: startCoordinates)
            endMarker = mapView.addMarker(with: "Route.end", at: endCoordinates)
        }

        // Perform initial operations (make sure map is loaded, collect source/destination names etc.)
        performInitialOperations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        showRoute()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // What to do after transition: zoom to a maneuver or the whole route?
        coordinator.animate(alongsideTransition: nil) { _ in
            self.showRoute()
        }
    }

    // MARK: - Private

    private func localize() {
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_route_preview_title".localized
    }

    private func performInitialOperations() {
        // Before all operations display HUD
        showHUD()

        let initialOperationsGroup = DispatchGroup()

        // Collect source location name if not set
        if let sourceAddress = sourceAddress {
            sourceLabel.text = sourceAddress
        } else {
            sourceLabel.text = nil
            if let startCoordinates = route?.start?.originalPosition {
                initialOperationsGroup.enter()
                reverseGeocode(coordinates: startCoordinates) { name, _ in
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.sourceLabel.text = name
                    }

                    initialOperationsGroup.leave()
                }
            }
        }

        // Collect destination location name if not set
        if let destinationAddress = destinationAddress {
            destinationLabel.text = destinationAddress
        } else {
            destinationLabel.text = nil
            if let endCoordinates = route?.destination?.originalPosition {
                initialOperationsGroup.enter()
                reverseGeocode(coordinates: endCoordinates) { name, _ in
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.destinationLabel.text = name
                    }

                    initialOperationsGroup.leave()
                }
            }
        }

        // Make sure map is loaded
        initialOperationsGroup.enter()
        blockID = mapView.respond(to: .all) { event, _, _ in
            if event == .tiltChanged {
                initialOperationsGroup.leave()
            }

            return true
        }

        // After all above are solved, hide HUD
        initialOperationsGroup.notify(queue: DispatchQueue.main) {
            self.hideHUD()
        }
    }

    private func updateStyle() {
        // Hides unused rows
        maneuverTableView.tableFooterView = UIView(frame: .zero)

        backButton.tintColor = .colorAccentLight

        sourceLabel.textColor = .colorForegroundSecondary
        destinationLabel.textColor = .colorForegroundSecondary
        sourceToDestinationImage.tintColor = .colorForegroundSecondary

        topSeparatorView.backgroundColor = .colorDivider
        bottomSeparatorView.backgroundColor = .colorDivider
        showButtonSeparatorView.backgroundColor = .colorDivider

        applyForegroundLightStyle(to: showButton)
    }

    private func applyForegroundLightStyle(to button: UIButton) {
        // Colors
        button.backgroundColor = .colorForegroundLight
        button.setTitleColor(.colorAccent, for: .normal)

        // Border
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.colorAccent.cgColor

        applyStyle(to: button)
    }

    private func applyStyle(to button: UIButton) {
        // Settings
        button.layer.cornerRadius = 2
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.titleLabel?.lineBreakMode = .byTruncatingTail

        // Insets
        let sideEdgePadding: CGFloat = 16
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: sideEdgePadding, bottom: 0, right: sideEdgePadding)
    }

    private func updateShowButtonText() {
        let title = tableViewHeightConstraint.isActive ? "msdkui_app_guidance_button_showmaneuvers".localized : "msdkui_app_guidance_button_showmap".localized
        showButton.setTitle(title, for: .normal)
    }

    private func updateMapViewAccessibility() {
        // Map view is available to accessibility only when visible
        mapView.isAccessibilityElement = tableViewHeightConstraint.isActive
    }

    private func showRoute() {
        guard let mapRoute = mapRoute else {
            return
        }

        mapViewportHandler.setViewport(of: mapView, on: [mapRoute.route], with: [startMarker, endMarker], animation: .bow)
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
        backButton.accessibilityIdentifier = "RouteViewController.backButton"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = .none
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_route_map_view".localized
        mapView.accessibilityIdentifier = "RouteViewController.mapView"

        hudView.accessibilityIdentifier = "RouteViewController.hudView"

        showButton.accessibilityIdentifier = "RouteViewController.showButton"
    }

    private func reverseGeocode(coordinates: NMAGeoCoordinates, completionHandler: @escaping (_ name: String?, _ error: Error?) -> Void) {
        reverseGeocoder.reverseGeocode(coordinates: coordinates) { _, data, error in
            var name: String?

            // Succeeded?
            if error == nil {
                if let results = data as? [NMAReverseGeocodeResult], results.isEmpty == false {
                    if let street = results.first?.location?.address?.street {
                        if let houseNumber = results.first?.location?.address?.houseNumber {
                            name = "\(street) \(houseNumber)"
                        } else {
                            name = "\(street)"
                        }
                    } else {
                        name = results.first?.location?.address?.formattedAddress
                    }
                }
            }

            completionHandler(name, error)
        }
    }

    @IBAction private func goBack(_ sender: UIBarButtonItem) {
        delegate?.refreshRoute(self)

        dismiss(animated: true)
    }

    @IBAction private func toggleTableViewVisibility(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.tableViewHeightConstraint.isActive.toggle()
            self.updateShowButtonText()
            self.updateMapViewAccessibility()

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Accessibility: focus on the back bar button when maneuver table view is toggled
            UIAccessibility.post(notification: .layoutChanged, argument: self.backButton)
        })
    }
}
