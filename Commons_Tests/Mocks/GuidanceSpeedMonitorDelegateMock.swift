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
import MSDKUI

final class GuidanceSpeedMonitorDelegateMock {
    private(set) var didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit = false
    private(set) var didUpdateCurrentSpeedIsSpeedingSpeedLimitCount = 0

    private(set) var lastSpeedMonitor: GuidanceSpeedMonitor?
    private(set) var lastCurrentSpeed: Measurement<UnitSpeed>?
    private(set) var lastIsSpeeding: Bool? // swiftlint:disable:this discouraged_optional_boolean
    private(set) var lastSpeedLimit: Measurement<UnitSpeed>?
}

// MARK: - GuidanceSpeedMonitorDelegate

extension GuidanceSpeedMonitorDelegateMock: GuidanceSpeedMonitorDelegate {
    func guidanceSpeedMonitor(
        _ monitor: GuidanceSpeedMonitor,
        didUpdateCurrentSpeed currentSpeed: Measurement<UnitSpeed>?,
        isSpeeding: Bool,
        speedLimit: Measurement<UnitSpeed>?
    ) {
        didCallDidUpdateCurrentSpeedIsSpeedingSpeedLimit = true
        didUpdateCurrentSpeedIsSpeedingSpeedLimitCount += 1
        lastSpeedMonitor = monitor
        lastCurrentSpeed = currentSpeed
        lastIsSpeeding = isSpeeding
        lastSpeedLimit = speedLimit
    }
}
