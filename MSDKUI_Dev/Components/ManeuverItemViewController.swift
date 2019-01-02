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

final class ManeuverItemViewController: UIViewController {

    @IBOutlet private(set) var maneuverView: ManeuverItemView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsViewController = segue.destination as? ManeuverItemSettingsViewController

        settingsViewController?.didSelect = { [weak self] item in
            self?.title = item.title

            self?.maneuverView.iconImageView.image = item.configuration.iconImageViewImage
            self?.maneuverView?.instructionLabel.text = item.configuration.instructionLabelText
            self?.maneuverView?.instructionLabel.textColor = item.configuration.instructionLabelTextColor
            self?.maneuverView.addressLabel.text = item.configuration.addressLabelText
            self?.maneuverView.addressLabel.textColor = item.configuration.addressLabelTextColor
            self?.maneuverView.distanceLabel.text = item.configuration.distanceLabelText
            self?.maneuverView.distanceLabel.textColor = item.configuration.distanceLabelTextColor
            self?.maneuverView.visibleSections = item.configuration.visibleSections
        }
    }
}
