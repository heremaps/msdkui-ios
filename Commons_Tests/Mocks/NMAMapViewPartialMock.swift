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
import NMAKit

/// Partial mock for NMAMapKit, used to test expectations.
/// As a partial mock, it forward calls to the super class.
final class NMAMapViewPartialMock: NMAMapView {
    private(set) var didCallAddMapObject = false
    private(set) var didCallSetBoundingBoxWithAnimation = false
    private(set) var didCallSetBoundingBoxInsideWithAnimation = false

    private(set) var lastMapObject: NMAMapObject?
    private(set) var lastBoundingBox: NMAGeoBoundingBox?
    private(set) var lastScreenRect: CGRect?
    private(set) var lastAnimationType: NMAMapAnimation?

    override func add(mapObject object: NMAMapObject) -> Bool {
        didCallAddMapObject = true
        lastMapObject = object

        return super.add(mapObject: object)
    }

    override func set(boundingBox: NMAGeoBoundingBox, animation animationType: NMAMapAnimation) {
        didCallSetBoundingBoxWithAnimation = true
        lastBoundingBox = boundingBox
        lastAnimationType = animationType

        super.set(boundingBox: boundingBox, animation: animationType)
    }

    override func set(boundingBox: NMAGeoBoundingBox, inside screenRect: CGRect, animation animationType: NMAMapAnimation) {
        didCallSetBoundingBoxInsideWithAnimation = true
        lastBoundingBox = boundingBox
        lastScreenRect = screenRect
        lastAnimationType = animationType

        super.set(boundingBox: boundingBox, inside: screenRect, animation: animationType)
    }
}
