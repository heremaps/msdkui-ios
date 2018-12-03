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

import MSDKUI
import UIKit

final class GuidanceEstimatedArrivalViewController: UIViewController {

    @IBOutlet private(set) var estimatedArrivalView: GuidanceEstimatedArrivalView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsViewController = segue.destination as? GuidanceEstimatedArrivalSettingsViewController

        settingsViewController?.didSelect = { [weak self] setting in
            self?.estimatedArrivalView.estimatedTimeOfArrival = setting.estimatedTimeOfArrival
            self?.estimatedArrivalView.estimatedTimeOfArrivalFormatter = setting.estimatedTimeOfArrivalFormatter
            self?.estimatedArrivalView.duration = setting.duration
            self?.estimatedArrivalView.durationFormatter = setting.durationFormatter
            self?.estimatedArrivalView.distance = setting.distance
            self?.estimatedArrivalView.distanceFormatter = setting.distanceFormatter
            self?.estimatedArrivalView.textAlignment = setting.textAligment
            self?.estimatedArrivalView.primaryInfoTextColor = setting.primaryInfoTextColor
            self?.estimatedArrivalView.secondaryInfoTextColor = setting.secondaryInfoTextColor
        }
    }
}
