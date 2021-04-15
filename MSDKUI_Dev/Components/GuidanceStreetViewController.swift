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

final class GuidanceStreetViewController: UIViewController {
    @IBOutlet private(set) var currentStreetLabel: GuidanceStreetLabel!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsViewController = segue.destination as? GuidanceStreetSettingsViewController

        settingsViewController?.didSelect = { [weak self] item in
            self?.title = item.title

            self?.currentStreetLabel.accentBackgroundColor = item.configuration.accentBackgroundColor
            self?.currentStreetLabel.plainBackgroundColor = item.configuration.plainBackgroundColor
            self?.currentStreetLabel.isAccented = item.configuration.isAccented
            self?.currentStreetLabel.text = item.configuration.text
            self?.currentStreetLabel.font = item.configuration.font
        }
    }
}
