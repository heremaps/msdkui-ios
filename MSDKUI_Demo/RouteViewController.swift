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

protocol RouteViewControllerDelegate: AnyObject {
    func refreshRoute(_ viewController: UIViewController)
}

class RouteViewController: UIViewController {
    @IBOutlet private(set) var routeStackView: UIStackView!

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var routeDescriptionItem: RouteDescriptionItem!

    @IBOutlet private(set) var mapView: NMAMapView!

    @IBOutlet private(set) var maneuverList: ManeuverDescriptionList!

    @IBOutlet private(set) var hudView: UIView!

    @IBOutlet private(set) var activityIndicator: UIActivityIndicatorView!

    weak var delegate: RouteViewControllerDelegate?

    var route: NMARoute?

    var routingMode: NMARoutingMode?

    var mapRoute: NMAMapRoute?

    var maneuverBoundingBox: NMAGeoBoundingBox?

    var trafficEnabled = true

    var blockID: NSInteger = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Show the hud until the mapView respond() block is called with NMAMapEvent.tiltChanged
        showHUD()

        // Show the route on the map
        guard let route = route, let mapRoute = NMAMapRoute(route) else {
            return
        }

        self.mapRoute = mapRoute
        mapView.add(mapObject: mapRoute)

        // Should show the traffic on the map?
        mapView.isTrafficVisible = trafficEnabled

        // Prepare the components: note that we don't show the bar on the routeDescriptionItem
        routeDescriptionItem.trafficEnabled = trafficEnabled
        routeDescriptionItem.route = route
        maneuverList.route = route
        maneuverList.listDelegate = self

        // Add a tap gesture recognizer to the routeDescriptionItem:
        // When a maneuver is tapped, the map is zoomed to it and we
        // want to the map reset to the route when the RouteDescriptionItem
        // view is tapped
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        routeDescriptionItem.addGestureRecognizer(tapGestureRecognizer)

        // Are the start and end coordinates OK?
        if let startCoordinates = route.start?.originalPosition, let endCoordinates = route.destination?.originalPosition {
            // Make the route start/end markers
            mapView.addMarker(with: "Route.start", at: startCoordinates)
            mapView.addMarker(with: "Route.end", at: endCoordinates)
        }

        // When the map is close to being ready, hide the hud
        blockID = mapView.respond(to: .all) { event, _, _ in
            if event == .tiltChanged {
                self.hideHUD()
            }

            return true
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Hide the route views in the landscape orientation and zoom to a
        // maneuver or the whole route
        routeStackView.isHidden = isLandscape()
        maneuverBoundingBox == nil ? showRoute() : showManeuver()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Hide the route views in the landscape orientation
        routeStackView.isHidden = isLandscape()

        // What to do after transition: zoom to a maneuver or the whole route?
        coordinator.animate(alongsideTransition: nil) { _ in
            self.maneuverBoundingBox == nil ? self.showRoute() : self.showManeuver()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction private func onBack(_: UIBarButtonItem) {
        // Has any delegate?
        delegate?.refreshRoute(self)

        dismiss(animated: true, completion: nil)
    }

    // The tap handler method
    @objc func handleTap(_: UITapGestureRecognizer) {
        showRoute()
    }

    func localize() {
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_route_preview_title".localized
    }

    func updateStyle() {
        backButton.tintColor = .colorAccentLight
    }

    func showRoute() {
        guard let mapRoute = mapRoute else {
            return
        }

        // Try to contain the start marker
        if let routeBoundingBox = mapRoute.route.boundingBox {
            let frame = CGRect(x: mapView.frame.minX,
                               y: mapView.frame.minY + 50,
                               width: mapView.frame.width,
                               height: mapView.frame.height - 50)
            mapView.set(boundingBox: routeBoundingBox, inside: frame, animation: NMAMapAnimation.none)

            // There is no maneuver bounding box now other than the route
            maneuverBoundingBox = nil
        }
    }

    func showManeuver() {
        // Zoom to the maneuver
        mapView.set(boundingBox: maneuverBoundingBox!, animation: NMAMapAnimation.bow)
    }

    // We want to learn the orientation as soon as possible
    func isLandscape() -> Bool {
        return UIApplication.shared.statusBarOrientation != .portrait
    }

    func showHUD() {
        hudView.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideHUD() {
        // We no longer need the event block handler
        mapView.removeEventBlock(blockIdentifier: blockID)

        activityIndicator.stopAnimating()
        hudView.isHidden = true
    }

    private func setAccessibility() {
        backButton.accessibilityIdentifier = "RouteViewController.back"

        mapView.isAccessibilityElement = true
        mapView.accessibilityTraits = UIAccessibilityTraitNone
        mapView.accessibilityLabel = "msdkui_app_map_view".localized
        mapView.accessibilityHint = "msdkui_app_hint_route_map_view".localized
        mapView.accessibilityIdentifier = "RouteViewController.mapView"

        routeStackView.accessibilityIdentifier = "RouteViewController.routeStackView"
    }
}

// MARK: ManeuverDescriptionListDelegate

extension RouteViewController: ManeuverDescriptionListDelegate {
    func maneuverSelected(_: ManeuverDescriptionList, index _: Int, maneuver: NMAManeuver) {
        // Zoom to the tapped maneuver
        if let maneuverBoundingBox = NMAGeoBoundingBox(coordinates: maneuver.maneuverGeometry) {
            // Save the maneuver bounding box and show it
            self.maneuverBoundingBox = maneuverBoundingBox
            showManeuver()
        }
    }
}
