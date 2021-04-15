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
@testable import MSDKUI

enum DriveNavigationMatchers {
    static var driveNavView: GREYMatcher {
        grey_accessibilityID("LandingViewController.driveNavView")
    }

    static var driveNavMapView: GREYMatcher {
        grey_anyOf([grey_accessibilityID("GuidanceViewController.mapView"),
                           grey_accessibilityID("RouteOverviewViewController.mapView")]
        )
    }

    static var currentStreetLabel: GREYMatcher {
        grey_accessibilityID("GuidanceViewController.currentStreetLabel")
    }

    static var stopNavigationButton: GREYMatcher {
        grey_accessibilityID("GuidanceDashboardViewController.stopNavigationButton")
    }

    static var maneuverView: GREYMatcher {
        grey_kindOfClass(GuidanceManeuverView.self)
    }

    static var nextManeuverView: GREYMatcher {
        grey_allOf([grey_accessibilityID("MSDKUI.GuidanceNextManeuverView"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var maneuverViewText: GREYMatcher {
        grey_allOf([grey_accessibilityTrait(.staticText),
                           grey_ancestor(grey_kindOfClass(GuidanceManeuverView.self))]
        )
    }

    static var currentSpeed: GREYMatcher {
        grey_allOf([grey_accessibilityID("MSDKUI.GuidanceSpeedView"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var arrivalTime: GREYMatcher {
        grey_allOf([grey_accessibilityID("MSDKUI.GuidanceEstimatedArrivalView"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var dashboardSettings: GREYMatcher {
        grey_allOf([grey_accessibilityLabel("Settings"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var dashboardAbout: GREYMatcher {
        grey_allOf([grey_accessibilityLabel("About"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var routeDescription: GREYMatcher {
        grey_allOf([grey_accessibilityID("MSDKUI.RouteDescriptionItem"),
                           grey_accessibilityLabel("Route"),
                           grey_accessibilityTrait(.staticText)]
        )
    }

    static var speedLimit: GREYMatcher {
        grey_accessibilityID("MSDKUI.GuidanceSpeedLimitView")
    }
}

extension GREYMatcher {

    func andSufficientlyVisible() -> GREYMatcher {
        grey_allOf([self, grey_sufficientlyVisible()])
    }
}
