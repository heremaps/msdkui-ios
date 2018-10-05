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

import EarlGrey
@testable import MSDKUI

enum GuidanceView {
    static var mapView: GREYMatcher {
        return grey_accessibilityID("GuidanceViewController.mapView")
    }

    static var stopNavigationButton: GREYMatcher {
        return grey_accessibilityID("GuidanceDashboardViewController.stopNavigationButton")
    }

    static var maneuverPanel: GREYMatcher {
        return grey_kindOfClass(GuidanceManeuverPanel.self)
    }

    static var maneuverPanelText: GREYMatcher {
        return grey_allOf([grey_accessibilityTrait(.staticText),
                           grey_ancestor(grey_kindOfClass(GuidanceManeuverPanel.self))
            ])
    }

    static var currentSpeed: GREYMatcher {
        return grey_accessibilityID("MSDKUI.GuidanceSpeedView")
    }
}
