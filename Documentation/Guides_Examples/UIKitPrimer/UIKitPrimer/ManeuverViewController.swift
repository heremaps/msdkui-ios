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

/// Shows a RouteDescriptionList where a user can select a route and sees the belonging maneuvers
/// in a ManeuverDescriptionList.
class ManeuverViewController: UIViewController, RouteDescriptionListDelegate, ManeuverDescriptionListDelegate {

    @IBOutlet weak var routeDescriptionList: RouteDescriptionList!
    @IBOutlet weak var maneuverDescriptionList: ManeuverDescriptionList!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard RouteHelper.sharedInstance.lastCalculatedRoutes != nil else {
            print("No valid routes yet.")
            routeDescriptionList.routes = []
            return
        }

        // select first route by default
        RouteHelper.sharedInstance.selectedRoute = RouteHelper.sharedInstance.lastCalculatedRoutes?.first

        routeDescriptionList.routes = RouteHelper.sharedInstance.lastCalculatedRoutes!
        routeDescriptionList.listDelegate = self
        routeDescriptionList.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)

        maneuverDescriptionList.route = RouteHelper.sharedInstance.selectedRoute
        maneuverDescriptionList.listDelegate = self
    }

    // MARK: - RouteDescriptionListDelegate

    func routeDescriptionList(_ list: RouteDescriptionList, didSelect route: NMARoute, at index: Int) {
        print("Selected route at index: \(index)")
        maneuverDescriptionList.route = route
        RouteHelper.sharedInstance.selectedRoute = route
    }

    func routeDescriptionList(_ list: RouteDescriptionList, willDisplay item: RouteDescriptionItem) {
        item.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    }

    // MARK: - ManeuverDescriptionListDelegate

    func maneuverDescriptionList(_ list: ManeuverDescriptionList, didSelect maneuver: NMAManeuver, at index: Int) {
        print("Selected maneuver \(maneuver.description)")
    }

    func maneuverDescriptionList(_ list: ManeuverDescriptionList, willDisplay item: ManeuverDescriptionItem) {
        item.iconImageView.tintColor = UIColor(red: 1.0, green: 0.77, blue: 0.11, alpha: 1.0)
    }
}
