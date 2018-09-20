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

import UIKit
import NMAKit
import MSDKUI

/// Shows usage of GuidanceManeuverPanel and how to fed maneuver data into it while running
/// guidance simulation.
class GuidanceViewController: UIViewController, GuidanceManeuverPanelPresenterDelegate {

    @IBOutlet weak var guidanceManeuverPanel: GuidanceManeuverPanel!
    @IBOutlet weak var mapView: NMAMapView!

    var guidanceManeuverPanelPresenter: GuidanceManeuverPanelPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let route = RouteHelper.sharedInstance.selectedRoute else {
            print("No valid route yet.")
            return
        }

        guidanceManeuverPanelPresenter = GuidanceManeuverPanelPresenter(route: route)
        guidanceManeuverPanelPresenter.delegate = self

        guidanceManeuverPanel.foregroundColor = UIColor(red: 1.0, green: 0.77, blue: 0.11, alpha: 1.0)

        startGuidanceSimulation(route: route)
    }

    func guidanceManeuverPanelPresenter(_ presenter: GuidanceManeuverPanelPresenter,
                                        didUpdateData data: GuidanceManeuverData?) {
        print("data changed: \(String(describing: data))")
        guidanceManeuverPanel.data = data
    }

    func guidanceManeuverPanelPresenterDidReachDestination(_ presenter: GuidanceManeuverPanelPresenter) {
        print("Destination reached.")
        guidanceManeuverPanel.highlightManeuver(textColor: .colorAccentLight)
    }

    func startGuidanceSimulation(route: NMARoute) {
        GuidanceHelper.sharedInstance.startGuidanceSimulation(route: route, mapView: mapView)
    }

    @IBAction func onStopGuidanceButtonClicked(_ sender: UIButton) {
        GuidanceHelper.sharedInstance.stopGuidance()
    }
}
