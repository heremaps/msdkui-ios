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

import EarlGrey

enum RouteOverviewMatchers {
    static var maneuverTableView: GREYMatcher {
        grey_anyOf([grey_accessibilityID("MSDKUI.ManeuverTableView"),
                           grey_accessibilityID("ManeuversOverviewViewController.maneuverTableView")])
    }

    static func maneuverTableViewCell(cellNr: Int) -> GREYMatcher {
        grey_accessibilityID("MSDKUI.ManeuverTableView.cell_\(cellNr)")
    }

    static var routeDescriptionItem: GREYMatcher {
        grey_accessibilityID("MSDKUI.RouteDescriptionItem")
    }

    static var startNavigationButton: GREYMatcher {
        grey_anyOf([grey_accessibilityID("RouteOverviewViewController.startNavigationButton"),
                           grey_accessibilityID("ManeuversOverviewViewController.startNavigationButton")]
        )
    }

    static var maneuversShowMapButton: GREYMatcher {
        grey_anyOf([grey_accessibilityID("ManeuversOverviewViewController.showMapButton"),
                           grey_accessibilityID("RouteViewController.showButton")])
    }
}
