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
@testable import MSDKUI
import NMAKit

final class CurrentPositionProviderMock {
    private(set) var stubbedCurrentPosition: NMAGeoPosition?
    private(set) var stubbedCurrentRoadElement: NMARoadElement?
}

// MARK: - CurrentPositionProviding

extension CurrentPositionProviderMock: CurrentPositionProviding {
    var currentPosition: NMAGeoPosition? {
        stubbedCurrentPosition
    }

    func currentRoadElement() -> NMARoadElement? {
        stubbedCurrentRoadElement
    }
}

// MARK: - Stub

extension CurrentPositionProviderMock {
    func stubCurrentPosition(toReturn value: NMAGeoPosition?) {
        stubbedCurrentPosition = value
    }

    func stubRoadElement(toReturn value: NMARoadElement?) {
        stubbedCurrentRoadElement = value
    }
}
