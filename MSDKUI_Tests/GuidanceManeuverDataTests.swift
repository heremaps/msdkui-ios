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

@testable import MSDKUI
import XCTest

class GuidanceManeuverDataTests: XCTestCase {
    // The maneuverIcon string
    private static let maneuverIcon = "maneuver_icon_4"

    // The distance string
    private static let distance = "300 m"

    // The info1 string
    private static let info1 = "Exit 30"

    // The info2 string
    private static let info2 = "Invalidenstr."

    // Tests that the data object has the expected data
    func testData() {
        let dataObject = GuidanceManeuverData(maneuverIcon: GuidanceManeuverDataTests.maneuverIcon,
                                              distance: GuidanceManeuverDataTests.distance,
                                              info1: GuidanceManeuverDataTests.info1,
                                              info2: GuidanceManeuverDataTests.info2)

        XCTAssertEqual(dataObject.maneuverIcon, GuidanceManeuverDataTests.maneuverIcon, "Wrong maneuverIcon!")
        XCTAssertEqual(dataObject.distance, GuidanceManeuverDataTests.distance, "Wrong distance!")
        XCTAssertEqual(dataObject.info1, GuidanceManeuverDataTests.info1, "Wrong info1!")
        XCTAssertEqual(dataObject.info2, GuidanceManeuverDataTests.info2, "Wrong info2!")
    }

    // Tests that the equality works as expected
    func testEquality() {
        let dataObject = GuidanceManeuverData(maneuverIcon: GuidanceManeuverDataTests.maneuverIcon,
                                              distance: GuidanceManeuverDataTests.distance,
                                              info1: GuidanceManeuverDataTests.info1,
                                              info2: GuidanceManeuverDataTests.info2)
        let objectWithSameData = GuidanceManeuverData(maneuverIcon: GuidanceManeuverDataTests.maneuverIcon,
                                                      distance: GuidanceManeuverDataTests.distance,
                                                      info1: GuidanceManeuverDataTests.info1,
                                                      info2: GuidanceManeuverDataTests.info2)

        XCTAssertEqual(objectWithSameData, dataObject, "Wrong equality!")
    }

    // Tests that the string description works as expected
    func testDescription() {
        let dataObject = GuidanceManeuverData(maneuverIcon: GuidanceManeuverDataTests.maneuverIcon,
                                              distance: GuidanceManeuverDataTests.distance,
                                              info1: nil,
                                              info2: GuidanceManeuverDataTests.info2)

        let description = String(describing: dataObject)
        let expectedDescription = "maneuverIcon: \(GuidanceManeuverDataTests.maneuverIcon), " +
            "distance: \(GuidanceManeuverDataTests.distance), " +
            "info1: nil, info2: \(GuidanceManeuverDataTests.info2)"

        XCTAssertEqual(description, expectedDescription, "Wrong description!")
    }
}
