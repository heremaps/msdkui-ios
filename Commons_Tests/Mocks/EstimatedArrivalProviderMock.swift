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
@testable import MSDKUI
import NMAKit

final class EstimatedArrivalProviderMock {
    private(set) var stubbedDistanceToDestination: NMAUint64?
    private(set) var stubbedTimeToArrival: [NMATrafficPenaltyMode: TimeInterval] = [:]
}

// MARK: - EstimatedArrivalProviding

extension EstimatedArrivalProviderMock: EstimatedArrivalProviding {
    var distanceToDestination: NMAUint64 {
        guard let value = stubbedDistanceToDestination else {
            fatalError("Stub this value before accessing it")
        }

        return value
    }

    func timeToArrival(withTraffic trafficeMode: NMATrafficPenaltyMode, wholeRoute: Bool) -> TimeInterval {
        guard let value = stubbedTimeToArrival[trafficeMode] else {
            fatalError("Stub this value before accessing it")
        }

        return value
    }
}

// MARK: - Stub

extension EstimatedArrivalProviderMock {
    func stubDistanceToDestination(toReturn value: NMAUint64) {
        stubbedDistanceToDestination = value
    }

    func stubTimeToArrival(forTrafficModel trafficeMode: NMATrafficPenaltyMode, toReturn value: TimeInterval) {
        stubbedTimeToArrival[trafficeMode] = value
    }
}
