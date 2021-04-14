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
@testable import MSDKUI_Demo
import NMAKit

final class NMACoreRouterMock {
    private(set) var didCallCalculateRouteWithStopsRoutingMode = false
    private(set) var didCallCalculateRouteWithStopsRoutingModeCount = 0

    private(set) var lastStops: [Any]? // swiftlint:disable:this discouraged_optional_collection
    private(set) var lastRoutingMode: NMARoutingMode?
    private(set) var lastCompletion: NMACalculateResultBlock?

    var dynamicPenalty: NMADynamicPenalty?
    var connectivity: NMACoreRouterConnectivity = .default
}

// MARK: - NMACoreRouting

extension NMACoreRouterMock: NMACoreRouting {
    func calculateRoute(withStops stops: [Any], routingMode mode: NMARoutingMode, _ completion: NMACalculateResultBlock?) -> Progress? {
        didCallCalculateRouteWithStopsRoutingMode = true
        didCallCalculateRouteWithStopsRoutingModeCount += 1

        lastStops = stops
        lastRoutingMode = mode
        lastCompletion = completion

        return nil
    }
}
