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

/// The protocol describing the Navigation Manager Delegate Dispatcher.
protocol NavigationManagerDelegateDispatching {

    /// Returns the number of the delegates.
    var count: Int { get }

    /// A Boolean value indicating whether the delegates collection is empty.
    var isEmpty: Bool { get }

    /// Adds a delegate object.
    ///
    /// - Parameter delegate: An object conforming to the protocol.
    func add(delegate: NMANavigationManagerDelegate)

    /// Removes a delegate object.
    ///
    /// - Parameter delegate: An object conforming to the protocol.
    func remove(delegate: NMANavigationManagerDelegate)
}

/// The Dispatcher for `NMANavigationManager` delegate events.
///
/// When the shared instance of the NavigationManagerDelegateDispatcher is assigned as
/// NMANavigationManager delegate, it acts as a dispatcher for all the other instances
/// that conform to the NMANavigationManagerDelegate protocol.
open class NavigationManagerDelegateDispatcher: NSObject {

    // MARK: - Properties

    /// NavigationManagerDelegateDispatcher singleton instance.
    public static let shared = NavigationManagerDelegateDispatcher()

    /// The objects listening for `NMANavigationManagerDelegate` methods.
    private let delegates = MulticastDelegate<NMANavigationManagerDelegate>()

    /// The NMANavigationManager instance.
    private let sharedNavigationManager: NMANavigationManager

    // MARK: - Public

    init(sharedNavigationManager: NMANavigationManager = .sharedInstance()) {
        self.sharedNavigationManager = sharedNavigationManager
    }
}

// MARK: - NavigationManagerDelegateDispatching

extension NavigationManagerDelegateDispatcher: NavigationManagerDelegateDispatching {

    // MARK: - Public

    public var count: Int {
        delegates.count
    }

    public var isEmpty: Bool {
        delegates.isEmpty
    }

    public func add(delegate: NMANavigationManagerDelegate) {
        delegates.add(delegate)
        updateNavigationManagerDelegate()
    }

    public func remove(delegate: NMANavigationManagerDelegate) {
        delegates.remove(delegate)
        updateNavigationManagerDelegate()
    }

    // MARK: - Private

    /// Updates the Shared Navigation Manager delegate.
    private func updateNavigationManagerDelegate() {
        sharedNavigationManager.delegate = delegates.isEmpty ? nil : self
    }
}

// MARK: - NMANavigationManagerDelegate

extension NavigationManagerDelegateDispatcher: NMANavigationManagerDelegate {

    public func navigationManagerDidReachDestination(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidReachDestination?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateManeuvers currentManeuver: NMAManeuver?, _ nextManeuver: NMAManeuver?) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateManeuvers: currentManeuver, nextManeuver)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didReachStopover stopover: NMAWaypoint) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didReachStopover: stopover)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateRoute routeResult: NMARouteResult) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateRoute: routeResult)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateLaneInformation laneInformations: [NMALaneInformation],
                                  roadElement: NMARoadElement?) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateLaneInformation: laneInformations, roadElement: roadElement)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateRealisticViewsForCurrentManeuver realisticViews: [NSNumber: [String: NMAImage]]) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateRealisticViewsForCurrentManeuver: realisticViews)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateRealisticViewsForNextManeuver realisticViews: [NSNumber: [String: NMAImage]]) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateRealisticViewsForNextManeuver: realisticViews)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerDidInvalidateRealisticViews(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidInvalidateRealisticViews?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager,
                                  didUpdateSpeedingStatus isSpeeding: Bool,
                                  forCurrentSpeed speed: Float,
                                  speedLimit: Float) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didUpdateSpeedingStatus: isSpeeding, forCurrentSpeed: speed, speedLimit: speedLimit)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerDidLosePosition(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidLosePosition?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerDidFindPosition(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidFindPosition?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerWillReroute(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerWillReroute?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didRerouteWithError error: NMARoutingError) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didRerouteWithError: error)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didFindAlternateRoute routeResult: NMARouteResult) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didFindAlternateRoute: routeResult)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didChangeRoutingState state: NMATrafficEnabledRoutingState) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didChangeRoutingState: state)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, shouldPlayVoiceFeedback text: String?) -> Bool {
        var shouldPlayVoiceFeedback = false

        delegates.invoke {
            if let shouldPlay = $0.navigationManager?(navigationManager, shouldPlayVoiceFeedback: text) {
                shouldPlayVoiceFeedback = shouldPlayVoiceFeedback || shouldPlay
            }
        }

        updateNavigationManagerDelegate()

        return shouldPlayVoiceFeedback
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, willPlayVoiceFeedback text: String?) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, willPlayVoiceFeedback: text)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didPlayVoiceFeedback text: String?) {
        delegates.invoke {
            $0.navigationManager?(navigationManager, didPlayVoiceFeedback: text)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerDidSuspendDueToInsufficientMapData(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidSuspendDueToInsufficientMapData?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }

    public func navigationManagerDidResumeDueToMapDataAvailability(_ navigationManager: NMANavigationManager) {
        delegates.invoke {
            $0.navigationManagerDidResumeDueToMapDataAvailability?(navigationManager)
        }

        updateNavigationManagerDelegate()
    }
}
