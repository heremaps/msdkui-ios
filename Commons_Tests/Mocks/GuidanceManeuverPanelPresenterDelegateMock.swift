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

import Foundation
import MSDKUI

final class GuidanceManeuverPanelPresenterDelegateMock {
    private(set) var didCallDidUpdateData = false
    private(set) var didCallDidReachDestination = false

    private(set) var lastPresenter: GuidanceManeuverPanelPresenter?
    private(set) var lastData: GuidanceManeuverData?
}

// MARK: - GuidanceManeuverPanelPresenterDelegate

extension GuidanceManeuverPanelPresenterDelegateMock: GuidanceManeuverPanelPresenterDelegate {
    func guidanceManeuverPanelPresenter(_ presenter: GuidanceManeuverPanelPresenter, didUpdateData data: GuidanceManeuverData?) {
        didCallDidUpdateData = true
        lastPresenter = presenter
        lastData = data
    }

    func guidanceManeuverPanelPresenterDidReachDestination(_ presenter: GuidanceManeuverPanelPresenter) {
        didCallDidReachDestination = true
        lastPresenter = presenter
    }
}
