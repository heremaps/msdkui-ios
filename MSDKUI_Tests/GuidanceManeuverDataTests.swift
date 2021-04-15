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

@testable import MSDKUI
import XCTest

final class GuidanceManeuverDataTests: XCTestCase {
    private let maneuverIcon = UIImage()
    private let distance = Measurement(value: 300, unit: UnitLength.meters)
    private let info1 = "Exit 30"
    private let info2 = "Invalidenstr."
    private let nextRoadIcon = UIImage()

    // MARK: - Tests

    /// Tests that the data object has the expected data.
    func testData() {
        let dataObject = GuidanceManeuverData(maneuverIcon: maneuverIcon, distance: distance, info1: info1, info2: info2, nextRoadIcon: nil)

        XCTAssertEqual(dataObject.maneuverIcon, maneuverIcon, "Wrong maneuverIcon!")
        XCTAssertEqual(dataObject.distance, distance, "Wrong distance!")
        XCTAssertEqual(dataObject.info1, info1, "Wrong info1!")
        XCTAssertEqual(dataObject.info2, info2, "Wrong info2!")
    }

    /// Tests that the equality works as expected (without images).
    func testEqualityWithoutImages() {
        let dataObject = GuidanceManeuverData(maneuverIcon: nil, distance: distance, info1: info1, info2: info2, nextRoadIcon: nil)
        let objectWithSameData = GuidanceManeuverData(maneuverIcon: nil, distance: distance, info1: info1, info2: info2, nextRoadIcon: nil)

        XCTAssertEqual(objectWithSameData, dataObject, "Wrong equality!")
    }

    /// Tests that the equality works as expected (with images).
    func testEqualityWithImages() {
        let dataObject = GuidanceManeuverData(maneuverIcon: maneuverIcon, distance: distance, info1: info1, info2: info2, nextRoadIcon: nextRoadIcon)
        let objectWithSameData = GuidanceManeuverData(maneuverIcon: maneuverIcon, distance: distance, info1: info1, info2: info2, nextRoadIcon: nextRoadIcon)

        XCTAssertEqual(objectWithSameData, dataObject, "Wrong equality!")
    }
}
