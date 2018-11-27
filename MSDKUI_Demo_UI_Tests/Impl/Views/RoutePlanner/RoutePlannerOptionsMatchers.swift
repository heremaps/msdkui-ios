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

enum RoutePlannerOptionMatchers {
    static var optionRouteOptions: GREYMatcher {
        return  grey_accessibilityLabel("Route options")
    }

    static var optionAvoidTraffic: GREYMatcher {
        return  grey_accessibilityLabel("Avoid traffic")
    }

    static var optionRouteType: GREYMatcher {
        return grey_accessibilityLabel("Route type")
    }

    static var truckOptionTunnelsAllowed: GREYMatcher {
        return grey_accessibilityLabel("Tunnels allowed")
    }

    static var truckOptionHazardousMaterials: GREYMatcher {
        return grey_accessibilityLabel("Hazardous materials")
    }

    static var truckOptionTruckOptions: GREYMatcher {
        return grey_accessibilityLabel("Truck options")
    }
}
