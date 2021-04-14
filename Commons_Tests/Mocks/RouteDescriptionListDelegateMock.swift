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

import Foundation
import MSDKUI
import NMAKit

final class RouteDescriptionListDelegateMock {
    private(set) var didCallRouteSelected = false
    private(set) var didCallWillDisplayItem = false

    private(set) var lastList: RouteDescriptionList?
    private(set) var lastIndex: Int?
    private(set) var lastRoute: NMARoute?
    private(set) var lastRouteItem: RouteDescriptionItem?
}

// MARK: - RouteDescriptionListDelegate

extension RouteDescriptionListDelegateMock: RouteDescriptionListDelegate {
    func routeDescriptionList(_ list: RouteDescriptionList, didSelect route: NMARoute, at index: Int) {
        didCallRouteSelected = true
        lastList = list
        lastIndex = index
        lastRoute = route
    }

    func routeDescriptionList(_ list: RouteDescriptionList, willDisplay item: RouteDescriptionItem) {
        didCallWillDisplayItem = true
        lastList = list
        lastRouteItem = item
    }
}
