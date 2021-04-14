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

class Positioning {

    // MARK: - Properties

    private weak var lastlDataSource: NMAPositionDataSource?

    static let shared = Positioning()

    // MARK: - Private

    private init() {}

    // MARK: - Public

    func start() {
        lastlDataSource = NMAPositioningManager.sharedInstance().dataSource
        NMAPositioningManager.sharedInstance().dataSource = PositionDataSource()
        NMAPositioningManager.sharedInstance().startPositioning()
    }

    func stop() {
        NMAPositioningManager.sharedInstance().stopPositioning()
        NMAPositioningManager.sharedInstance().dataSource = lastlDataSource
    }
}
