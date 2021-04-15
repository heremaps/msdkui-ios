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

class ManeuverResource {
    var icon: UIImage?
    var instructions: String?
    var address: String?
    var distance: Measurement<UnitLength>?

    init(maneuvers: [NMAManeuver], at index: Int) {
        let maneuverResources = ManeuverResources(maneuvers: maneuvers)

        icon = maneuverResources.getIconFileName(for: index).flatMap {
            UIImage(named: $0, in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }

        instructions = maneuverResources.getInstruction(for: index)
        address = maneuverResources.getRoadName(for: index)

        let distanceValue = maneuverResources.getDistance(for: index)
        let distanceMeasurement = Measurement(value: Double(distanceValue), unit: UnitLength.meters)
        distance = distanceValue <= 0 ? nil : distanceMeasurement
    }
}
