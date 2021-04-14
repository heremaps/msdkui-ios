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

import Foundation
import NMAKit

/// The protocol used to notify the delegate about changes on the estimated arrival at the destination.
public protocol GuidanceNextManeuverMonitorDelegate: AnyObject {

    /// Notifies the delegate about the updates in the next maneuver.
    ///
    /// - Parameters:
    ///   - monitor: The monitor announcing the changes.
    ///   - maneuverIcon: The maneuver icon of the next maneuver.
    ///   - distance: The distance to the next maneuver.
    ///   - streetName: The name of the next steet.
    func guidanceNextManeuverMonitor(_ monitor: GuidanceNextManeuverMonitor,
                                     didReceiveIcon maneuverIcon: UIImage?,
                                     distance: Measurement<UnitLength>,
                                     streetName: String?)

    /// Notifies the delegate when bad data is received. For example, there may be no next manuever
    /// available or the distance between the current and next maneuver may be greater than 1 km.
    ///
    /// - Parameter monitor: The monitor announcing the bad data.
    func guidanceNextManeuverMonitorDidReceiveError(_ monitor: GuidanceNextManeuverMonitor)
}

/// Monitors and notifies the delegate about changes on the estimated arrival at the destination.
open class GuidanceNextManeuverMonitor: NSObject {

    // MARK: - Properties

    /// The delegate object which will receive the next manuever updates.
    public weak var delegate: GuidanceNextManeuverMonitorDelegate?

    private(set) var  route: NMARoute?

    /// The distance between current and next maneuvers for displaying the next maneuver.
    private static let distanceThresholdMeter = 1000

    private let navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatching

    // MARK: - Public

    /// Creates and returns a new instance of the next maneuver monitor.
    ///
    /// - Parameter route: The route to be used.
    public convenience init(route: NMARoute) {
        self.init(route: route, navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatcher.shared)
    }

    init(route: NMARoute, navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatching) {
        self.route = route
        self.navigationManagerDelegateDispatcher = navigationManagerDelegateDispatcher

        super.init()

        self.navigationManagerDelegateDispatcher.add(delegate: self)
    }

    deinit {
        navigationManagerDelegateDispatcher.remove(delegate: self)
    }

    /// In case of rerouting, it is under user responsibility to update the route.
    ///
    /// - Parameter route: The updated route.
    public func updateRoute(_ route: NMARoute?) {
        self.route = route
    }

    // MARK: - Private

    /// Publishes the extracted data from the passed maneuver to the delegate.
    ///
    /// - Parameter nextManeuver: The next maneuver to be queried.
    private func publishData(from nextManeuver: NMAManeuver?) {
        // If there is no next maneuver or the distance from the previous maneuver is greater
        // than `GuidanceNextManeuverMonitor.distanceThresholdMeter`, consider them as error cases.
        guard let nextManeuver = nextManeuver,
            nextManeuver.distanceFromPreviousManeuver < GuidanceNextManeuverMonitor.distanceThresholdMeter else {
                delegate?.guidanceNextManeuverMonitorDidReceiveError(self)
                return
        }

        var maneuverIcon: UIImage?

        if let iconFileName = nextManeuver.getIconFileName() {
            maneuverIcon = UIImage(named: iconFileName,
                                   in: .MSDKUI,
                                   compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }

        delegate?.guidanceNextManeuverMonitor(self,
                                              didReceiveIcon: maneuverIcon,
                                              distance: Measurement<UnitLength>(value: Double(nextManeuver.distanceFromPreviousManeuver), unit: .meters),
                                              streetName: nextManeuver.getNextStreet(fallback: route))
    }
}

// MARK: - NMANavigationManagerDelegate

extension GuidanceNextManeuverMonitor: NMANavigationManagerDelegate {

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateManeuvers currentManeuver: NMAManeuver?,
                                  _ nextManeuver: NMAManeuver?) {
        // See documentation for `NMANavigationManagerDelegate`: The `currentManeuver` is the
        // upcoming maneuver to be taken, `nextManeuver` is the maneuver to be taken after the
        // current maneuver.
        publishData(from: nextManeuver)
    }
}
