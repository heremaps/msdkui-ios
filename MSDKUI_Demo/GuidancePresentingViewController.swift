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

import NMAKit
import UIKit

/// This protocol is intended for view controllers presenting a guidance
/// maneuver view and support guidance simulation.
protocol GuidancePresentingViewController: AnyObject {
    /// The route set for guidance.
    var route: NMARoute? { get }

    /// The segue identifier for presenting the guidance maneuver view.
    var guidanceSegueID: String { get }

    /// The simulation start flag.
    var shouldStartSimulation: Bool { get set }

    /// A Boolean value that determines whether traffic enabled.
    var trafficEnabled: Bool { get }

    /// Shows an alert box for guidance simulation confirmation.
    func showSimulationAlert()

    /// Starts the guidance with or without simulation.
    ///
    /// - Parameter withSimulation: Sets the simulation state.
    func showGuidance(withSimulation: Bool)
}

// MARK: - UIViewController

extension GuidancePresentingViewController where Self: UIViewController {
    func showSimulationAlert() {
        let alert = UIAlertController(title: "msdkui_app_guidance_start_simulation".localized, message: nil, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "GuidancePresentingViewController.AlertController.showSimulationView"
        alert.addAction(UIAlertAction(title: "msdkui_app_cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "msdkui_app_ok".localized, style: .default) { _ in
            self.showGuidance(withSimulation: true)
        })

        present(alert, animated: true)
    }

    func showGuidance(withSimulation: Bool) {
        shouldStartSimulation = withSimulation

        performSegue(withIdentifier: guidanceSegueID, sender: self)
    }

    func prepare(incoming viewController: GuidanceViewController) {
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

    // MARK: - Private

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
