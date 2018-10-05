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

import Foundation
import NMAKit

/// This protocol lets the implementer monitor the maneuvers during gudiance.
public protocol GuidanceManeuverPanelPresenterDelegate: AnyObject {

    /// This method is called whenever a new maneuver can be shown.
    ///
    /// - Parameter presenter: The presenter which is handling the guidance.
    /// - Parameter data: The data for the maneuver. This can be nil in case
    ///   there is no data available.
    func guidanceManeuverPanelPresenter(_ presenter: GuidanceManeuverPanelPresenter, didUpdateData data: GuidanceManeuverData?)

    /// This method is called whenever the destination is reached.
    ///
    /// - Parameter presenter: The presenter which is handling the guidance.
    func guidanceManeuverPanelPresenterDidReachDestination(_ presenter: GuidanceManeuverPanelPresenter)
}

/// This class is responsible for monitoring HERE Maps SDK guidance maneuver events provided by `NMANavigationManager`.
open class GuidanceManeuverPanelPresenter: NSObject {

    // MARK: - Public properties

    /// The delegate object that conforms to the `GuidanceManeuverPanelPresenterDelegate` protocol.
    public weak var delegate: GuidanceManeuverPanelPresenterDelegate?

    /// Determines whether to enable navigation voice.
    public var isVoiceEnabled = true

    // MARK: - Private properties

    /// The route used for navigation.
    private var route: NMARoute?

    /// The notification dispatch mechanism used to receive information.
    private let notificationCenter: NotificationCenterObserving

    /// Reference to the 'NMAPositioningManagerDidUpdatePosition' observer.
    private var positionUpdateObserver: NSObjectProtocol?

    // MARK: - Life cycle

    /// Creates and returns a `GuidanceManeuverPanelPresenter` object.
    ///
    /// - Parameter route: The route to be used.
    public convenience init(route: NMARoute) {
        self.init(route: route, notificationCenter: NotificationCenter.default)
    }

    /// Creates and returns a `GuidanceManeuverPanelPresenter` object.
    ///
    /// - Parameters:
    ///   - route: The route to be used.
    ///   - notificationCenter: The notification center for observing position updates.
    init(route: NMARoute, notificationCenter: NotificationCenterObserving) {
        self.route = route
        self.notificationCenter = notificationCenter
        super.init()

        // Registers itself as a NavigationManagerDelegateDispatcher delegate
        NavigationManagerDelegateDispatcher.shared.add(delegate: self)

        setUpObservable()
    }

    deinit {
        // Removes the observer
        positionUpdateObserver.flatMap(notificationCenter.removeObserver)

        // Removes itself as a NavigationManagerDelegateDispatcher delegate
        NavigationManagerDelegateDispatcher.shared.remove(delegate: self)
    }

    /// In case of rerouting, it is under user responsibility to update the route.
    ///
    /// - Parameter route: The updated route.
    public func updateRoute(_ route: NMARoute?) {
        self.route = route
    }

    // MARK: - Private

    private func setUpObservable() {
        positionUpdateObserver = notificationCenter.addObserver(forName: .NMAPositioningManagerDidUpdatePosition, object: nil, queue: nil) { [weak self] _ in
            guard let currentManeuver = NMANavigationManager.sharedInstance().currentManeuver else {
                return
            }

            self?.publishData(from: currentManeuver)
        }
    }

    /// Publishes the extracted data from the passed maneuver to the delegate.
    ///
    /// - Parameter maneuver: The maneuver to be queried.
    fileprivate func publishData(from maneuver: NMAManeuver) {
        var data = GuidanceManeuverData()

        // Try to set the distance
        if NMAPositioningManager.sharedInstance().currentPosition != nil {
            let distance = NMANavigationManager.sharedInstance().distanceToCurrentManeuver

            if distance != NMANavigationManagerInvalidValue {
                data.distance = Utils.formatDistance(Int(distance))
            }
        }

        // Try to set the info1 and info2 strings
        // Trick: As the exit number string is an optional number and when it
        //        is available the street name should appear below it, we assign
        //        it to info1, not to info2! Note that info1 is optional and
        //        when it is not available, it is hidden
        data.info1 = maneuver.getSignpostExitNumber()
        data.info2 = maneuver.getNextStreet(fallback: route)

        // Set the icon
        data.maneuverIcon = maneuver.getIconFileName()

        // Set the next road icon for this maneuver
        data.nextRoadIcon = maneuver.nextRoadIcon?.uiImage()

        // Inform the delegate
        delegate?.guidanceManeuverPanelPresenter(self, didUpdateData: data)
    }
}

// MARK: - NMANavigationManagerDelegate

extension GuidanceManeuverPanelPresenter: NMANavigationManagerDelegate {

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateManeuvers currentManeuver: NMAManeuver?,
                                  _ nextManeuver: NMAManeuver?) {
        // See documentation for `NMANavigationManagerDelegate`: The `currentManeuver` is the
        // upcoming maneuver to be taken, `nextManeuver` is the maneuver to be taken after the
        // current maneuver
        guard let currentManeuver = currentManeuver else {
            return
        }

        publishData(from: currentManeuver)
    }

    public func navigationManagerDidReachDestination(_: NMANavigationManager) {
        delegate?.guidanceManeuverPanelPresenterDidReachDestination(self)
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, shouldPlayVoiceFeedback text: String?) -> Bool {
        return isVoiceEnabled
    }

    public func navigationManagerWillReroute(_ navigationManager: NMANavigationManager) {
        delegate?.guidanceManeuverPanelPresenter(self, didUpdateData: nil)
    }
}
