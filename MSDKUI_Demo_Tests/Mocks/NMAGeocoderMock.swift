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
@testable import MSDKUI_Demo
import NMAKit

final class NMAGeocoderMock {
    private(set) var didCallReverseGeocode = false
    private(set) var lastCoordinates: NMAGeoCoordinates?
    private(set) var lastCompletionBlock: NMARequestCompletionBlock?
}

// MARK: - NMAGeocoding

extension NMAGeocoderMock: NMAGeocoding {
    func reverseGeocode(coordinates: NMAGeoCoordinates, completionBlock: @escaping NMARequestCompletionBlock) {
        didCallReverseGeocode = true
        lastCoordinates = coordinates
        lastCompletionBlock = completionBlock
    }
}
