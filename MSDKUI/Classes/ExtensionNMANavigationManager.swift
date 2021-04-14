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

/// This helper protocol is introduced to make testing with `NMANavigationManager` easier.
protocol EstimatedArrivalProviding {

    /// Returns the distance from current position to the end of route in meters,
    /// or NMANavigationManagerInvalidValue on error.
    var distanceToDestination: NMAUint64 { get }

    /// Returns the Time To Arrival (TTA) in seconds or -DBL_MAX (see float.h) on error.
    /// This method returns -DBL_MAX if access to this operation is denied.
    ///
    /// - Parameters:
    ///   - withTraffic: The NMATrafficPenaltyMode used for calculation.
    ///   - wholeRoute: `true` to return the TTA for the whole route, `false` to return the TTA.
    /// - Returns: The Time To Arrival (TTA) in seconds.
    func timeToArrival(withTraffic: NMATrafficPenaltyMode, wholeRoute: Bool) -> TimeInterval
}

extension NMANavigationManager: EstimatedArrivalProviding {}
