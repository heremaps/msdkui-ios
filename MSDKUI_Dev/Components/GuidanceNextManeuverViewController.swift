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

import MSDKUI
import UIKit

final class GuidanceNextManeuverViewController: UIViewController {
    @IBOutlet private(set) var nextManeuverView: GuidanceNextManeuverView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsViewController = segue.destination as? GuidanceNextManeuverSettingsViewController

        settingsViewController?.didSelect = { [weak self] item in
            self?.title = item.title

            self?.nextManeuverView.foregroundColor = item.configuration.foregroundColor

            let model = GuidanceNextManeuverView.ViewModel(
                maneuverIcon: item.configuration.maneuverIcon,
                distance: item.configuration.distance,
                streetName: item.configuration.streetName,
                distanceFormatter: item.configuration.distanceFormatter
            )
            self?.nextManeuverView.configure(with: model)
        }
    }
}
