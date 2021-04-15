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

/// This protocol is introduced to make testing router handing code possible.
protocol NMACoreRouting {
    /// Indicate the dynamic penalty that should be applied to route calculations.
    /// Penalties can be applied in the form of restricting roads, areas and setting different traffic modes.
    var dynamicPenalty: NMADynamicPenalty? { get set }

    /// This determines whether route is calculated online or offline.
    var connectivity: NMACoreRouterConnectivity { get set }

    /// Starts a route calculation with the given stop list and `NMARoutingMode`.
    func calculateRoute(withStops: [Any], routingMode: NMARoutingMode, _ completion: NMACalculateResultBlock?) -> Progress?
}

extension NMACoreRouter: NMACoreRouting {}
