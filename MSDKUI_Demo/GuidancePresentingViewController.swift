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

import NMAKit
import UIKit

protocol GuidancePresentingViewController: AnyObject {
    var route: NMARoute? { get set }

    var guidanceSegueID: String? { get set }

    var shouldStartSimulation: Bool { get set }

    var trafficEnabled: Bool { get set }

    func showSimulationAlert()

    func showGuidance(withSimulation: Bool)
}

extension GuidancePresentingViewController where Self: UIViewController {
    func showSimulationAlert() {
        let alert = UIAlertController(title: "msdkui_app_guidance_start_simulation".localized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "msdkui_app_cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "msdkui_app_ok".localized, style: .default) { _ in
            self.showGuidance(withSimulation: true)
        })

        present(alert, animated: true)
    }

    func showGuidance(withSimulation: Bool) {
        shouldStartSimulation = withSimulation

        if let guidanceSegueID = guidanceSegueID {
            performSegue(withIdentifier: guidanceSegueID, sender: self)
        }
    }

    func prepare(viewController: GuidanceViewController) {
        viewController.route = route
        viewController.shouldStartSimulation = shouldStartSimulation
        viewController.trafficEnabled = trafficEnabled
    }

    func applyAccentStyle(to button: UIButton) {
        // Colors
        button.backgroundColor = .colorAccent
        button.setTitleColor(.colorForegroundLight, for: .normal)

        applyStyle(to: button)
    }

    func applyForegroundLightStyle(to button: UIButton) {
        // Colors
        button.backgroundColor = .colorForegroundLight
        button.setTitleColor(.colorAccent, for: .normal)

        // Border
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.colorAccent.cgColor

        applyStyle(to: button)
    }

    private func applyStyle(to button: UIButton) {
        // Settings
        button.layer.cornerRadius = 2
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.titleLabel?.lineBreakMode = .byTruncatingTail

        // Insets
        let sideEdgePadding: CGFloat = 16
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: sideEdgePadding, bottom: 0, right: sideEdgePadding)
    }
}
