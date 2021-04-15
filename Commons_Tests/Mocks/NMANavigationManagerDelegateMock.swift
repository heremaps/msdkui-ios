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

// swiftlint:disable discouraged_optional_collection discouraged_optional_boolean

final class NMANavigationManagerDelegateMock: NSObject {
    // Properties used for verifying expectations.
    private(set) var lastNavigationManager: NMANavigationManager?
    private(set) var lastCurrentManeuver: NMAManeuver?
    private(set) var lastError: NMARoutingError?
    private(set) var lastNextManeuver: NMAManeuver?
    private(set) var lastStopOver: NMAWaypoint?
    private(set) var lastRouteResult: NMARouteResult?
    private(set) var lastLaneInformations: [NMALaneInformation]?
    private(set) var lastRoadElement: NMARoadElement?
    private(set) var lastRealisticViews: [NSNumber: [String: NMAImage]]?
    private(set) var lastSpeedingStatus: Bool?
    private(set) var lastSpeed: Float?
    private(set) var lastSpeedLimit: Float?
    private(set) var lastTrafficEnabledRoutingState: NMATrafficEnabledRoutingState?
    private(set) var lastText: String?

    // Properties used for stubbing the mock object.
    private(set) var stubbedShouldPlayVoiceFeedback: Bool?
}

// swiftlint:enable discouraged_optional_collection discouraged_optional_boolean

// MARK: - Stubs

extension NMANavigationManagerDelegateMock {
    func stubNavigationManagerShouldPlayVoiceFeedback(andReturn boolean: Bool) {
        stubbedShouldPlayVoiceFeedback = boolean
    }
}

// MARK: - NMANavigationManagerDelegate

extension NMANavigationManagerDelegateMock: NMANavigationManagerDelegate {
    public func navigationManagerDidReachDestination(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateManeuvers currentManeuver: NMAManeuver?, _ nextManeuver: NMAManeuver?) {
        lastNavigationManager = navigationManager
        lastCurrentManeuver = currentManeuver
        lastNextManeuver = nextManeuver
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didReachStopover stopover: NMAWaypoint) {
        lastNavigationManager = navigationManager
        lastStopOver = stopover
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateRoute routeResult: NMARouteResult) {
        lastNavigationManager = navigationManager
        lastRouteResult = routeResult
    }

    public func navigationManager(
        _ navigationManager: NMANavigationManager,
        didUpdateLaneInformation laneInformations: [NMALaneInformation],
        roadElement: NMARoadElement?
    ) {
        lastNavigationManager = navigationManager
        lastLaneInformations = laneInformations
        lastRoadElement = roadElement
    }

    public func navigationManager(
        _ navigationManager: NMANavigationManager,
        didUpdateRealisticViewsForCurrentManeuver realisticViews: [NSNumber: [String: NMAImage]]
    ) {
        lastNavigationManager = navigationManager
        lastRealisticViews = realisticViews
    }

    public func navigationManager(
        _ navigationManager: NMANavigationManager,
        didUpdateRealisticViewsForNextManeuver realisticViews: [NSNumber: [String: NMAImage]]
    ) {
        lastNavigationManager = navigationManager
        lastRealisticViews = realisticViews
    }

    public func navigationManagerDidInvalidateRealisticViews(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManager(
        _ navigationManager: NMANavigationManager,
        didUpdateSpeedingStatus isSpeeding: Bool,
        forCurrentSpeed speed: Float,
        speedLimit: Float
    ) {
        lastNavigationManager = navigationManager
        lastSpeedingStatus = isSpeeding
        lastSpeed = speed
        lastSpeedLimit = speedLimit
    }

    public func navigationManagerDidLosePosition(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManagerDidFindPosition(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManagerWillReroute(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didRerouteWithError error: NMARoutingError) {
        lastNavigationManager = navigationManager
        lastError = error
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didFindAlternateRoute routeResult: NMARouteResult) {
        lastNavigationManager = navigationManager
        lastRouteResult = routeResult
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didChangeRoutingState state: NMATrafficEnabledRoutingState) {
        lastNavigationManager = navigationManager
        lastTrafficEnabledRoutingState = state
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, shouldPlayVoiceFeedback text: String?) -> Bool {
        lastNavigationManager = navigationManager
        lastText = text

        return stubbedShouldPlayVoiceFeedback ?? false
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, willPlayVoiceFeedback text: String?) {
        lastNavigationManager = navigationManager
        lastText = text
    }

    public func navigationManager(_ navigationManager: NMANavigationManager, didPlayVoiceFeedback text: String?) {
        lastNavigationManager = navigationManager
        lastText = text
    }

    public func navigationManagerDidSuspendDueToInsufficientMapData(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }

    public func navigationManagerDidResumeDueToMapDataAvailability(_ navigationManager: NMANavigationManager) {
        lastNavigationManager = navigationManager
    }
}
