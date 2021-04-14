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

final class GuidanceManeuverUtilTests: XCTestCase {
    /// This is the real `NMANavigationManager` method.
    private var realNavigationManagerMethod: Method!

    /// This is the method used for mocking the real `NMANavigationManager` method.
    private var mockNavigationManagerMethod: Method!

    // MARK: - Tests

    /// Tests `GuidanceManeuverUtil.getIndex()` method.
    func testGetIndexOfManeuver() {
        let coordinates0 = NMAGeoCoordinates(latitude: Double(1.0), longitude: Double(2.0))
        let maneuver0 = MockUtils.mockManeuver(coordinates0, with: NMAManeuverAction.junction)
        let coordinates1 = NMAGeoCoordinates(latitude: Double(3.0), longitude: Double(4.0))
        let maneuver1 = MockUtils.mockManeuver(coordinates1, with: NMAManeuverAction.changeLine)
        let coordinates2 = NMAGeoCoordinates(latitude: Double(5.0), longitude: Double(6.0))
        let maneuver2 = MockUtils.mockManeuver(coordinates2, with: NMAManeuverAction.changeLine)
        let maneuver3 = MockUtils.mockManeuver(coordinates2, with: NMAManeuverAction.junction)
        let maneuver4: NMAManeuver? = nil
        let maneuvers = [maneuver0, maneuver1, maneuver2]

        XCTAssertEqual(GuidanceManeuverUtil.getIndex(of: maneuver0, from: maneuvers), 0, "The index should be 0!")
        XCTAssertEqual(GuidanceManeuverUtil.getIndex(of: maneuver1, from: maneuvers), 1, "The index should be 1!")
        XCTAssertEqual(GuidanceManeuverUtil.getIndex(of: maneuver2, from: maneuvers), 2, "The index should be 2!")
        XCTAssertNil(GuidanceManeuverUtil.getIndex(of: maneuver3, from: maneuvers), "The index should be nil!")
        XCTAssertNil(GuidanceManeuverUtil.getIndex(of: maneuver4, from: maneuvers), "The index should be nil!")
    }

    /// Tests `GuidanceManeuverUtil.areManeuversEqual()` method.
    func testAreManeuversEqual() {
        let leftCoordinates = NMAGeoCoordinates(latitude: Double(1.0), longitude: Double(2.0))
        let leftManeuver = MockUtils.mockManeuver(leftCoordinates, with: NMAManeuverAction.junction)
        let rightCoordinates = NMAGeoCoordinates(latitude: Double(1.0), longitude: Double(2.0))
        let rightManeuver = MockUtils.mockManeuver(rightCoordinates, with: NMAManeuverAction.junction)

        XCTAssertTrue(GuidanceManeuverUtil.areManeuversEqual(leftManeuver, rightManeuver), "Maneuvers should be equal!")
        XCTAssertFalse(GuidanceManeuverUtil.areManeuversEqual(leftManeuver, nil), "Maneuvers should not be equal!")
        XCTAssertTrue(GuidanceManeuverUtil.areManeuversEqual(nil, nil), "Maneuvers should be equal!")
    }

    /// Tests `GuidanceManeuverUtil.combineStrings()` method.
    func testCombineStrings() {
        let signpostString = "Signpost"
        let name = "Invalidenstr."
        let number = "30"
        let coordinates = NMAGeoCoordinates(latitude: Double(1.0), longitude: Double(2.0))
        let maneuverLeaveHighway = MockUtils.mockManeuver(coordinates, with: NMAManeuverAction.leaveHighway, withSignpostString: signpostString)
        let maneuverNotLeaveHighway = MockUtils.mockManeuver(coordinates, with: NMAManeuverAction.changeLine)

        XCTAssertEqual(
            GuidanceManeuverUtil.combineStrings(maneuver: maneuverLeaveHighway, name: name, number: number), signpostString,
            "Not the expected string from the signpost!"
        )

        XCTAssertEqual(
            GuidanceManeuverUtil.combineStrings(maneuver: maneuverNotLeaveHighway, name: name, number: number), number + "/" + name,
            "Not the expected combined string!"
        )

        XCTAssertEqual(
            GuidanceManeuverUtil.combineStrings(maneuver: maneuverNotLeaveHighway, name: name, number: nil), name,
            "Not the expected combined string!"
        )

        XCTAssertEqual(
            GuidanceManeuverUtil.combineStrings(maneuver: maneuverNotLeaveHighway, name: nil, number: number), number,
            "Not the expected combined string!"
        )

        XCTAssertNil(
            GuidanceManeuverUtil.combineStrings(maneuver: maneuverNotLeaveHighway, name: nil, number: nil),
            "Not the expected combined string!"
        )
    }

    /// Tests `GuidanceManeuverUtil.getNextStreet()` method: the current maneuver should provide
    /// the return string.
    func testGetNextStreetWithCurrentManeuver() {
        // We need to swizzle the navigation manager for this test as GuidanceManeuverUtil.getNextManeuver() uses it
        swizzleNavigationManager()

        let nextStreet = GuidanceManeuverUtil.getNextStreet(from: MockUtils.mockNavigationManager().currentManeuver, fallback: MockUtils.mockRoute())

        // Restore the navigation manager
        deswizzleNavigationManager()

        XCTAssertEqual(nextStreet, "58/Chausseestr.", "Not the expected next string!")
    }

    /// Tests `GuidanceManeuverUtil.getNextStreet()` method: the route should provide the return string.
    func testGetNextStreetWithRoute() throws {
        // We need to swizzle the navigation manager for this test as GuidanceManeuverUtil.getNextManeuver() uses it
        swizzleNavigationManagerWithoutNextManeuver()

        // Note that we should get the next street via the route maneuvers
        let firstManeuver = try require(MockUtils.mockRoute().maneuvers?.first)
        let nextStreet = GuidanceManeuverUtil.getNextStreet(from: firstManeuver, fallback: MockUtils.mockRoute())

        // Restore the navigation manager
        deswizzleNavigationManager()

        XCTAssertEqual(nextStreet, "116/Invalidenstr.", "Not the expected next string!")
    }

    // MARK: - Private

    private func swizzleNavigationManager() {
        let realNavigationManagerInstance = NMANavigationManager.sharedInstance()
        let realNavigationManagerClass: AnyClass! = object_getClass(realNavigationManagerInstance)
        realNavigationManagerMethod = class_getClassMethod(realNavigationManagerClass, #selector(NMANavigationManager.sharedInstance))

        let mockNavigationManagerInstance = MockUtils()
        let mockNavigationManagerClass: AnyClass! = object_getClass(mockNavigationManagerInstance)
        mockNavigationManagerMethod = class_getClassMethod(mockNavigationManagerClass, #selector(MockUtils.mockNavigationManager))

        if let realNavigationManagerMethod = realNavigationManagerMethod {
            method_exchangeImplementations(realNavigationManagerMethod, mockNavigationManagerMethod)
        } else {
            XCTFail("swizzleNavigationManager failed!")
        }
    }

    private func swizzleNavigationManagerWithoutNextManeuver() {
        let realNavigationManagerInstance = NMANavigationManager.sharedInstance()
        let realNavigationManagerClass: AnyClass! = object_getClass(realNavigationManagerInstance)
        realNavigationManagerMethod = class_getClassMethod(realNavigationManagerClass, #selector(NMANavigationManager.sharedInstance))

        let mockNavigationManagerInstance = MockUtils()
        let mockNavigationManagerClass: AnyClass! = object_getClass(mockNavigationManagerInstance)
        mockNavigationManagerMethod = class_getClassMethod(mockNavigationManagerClass, #selector(MockUtils.mockNavigationManagerWithoutNextManeuver))

        if let realNavigationManagerMethod = realNavigationManagerMethod {
            method_exchangeImplementations(realNavigationManagerMethod, mockNavigationManagerMethod)
        } else {
            XCTFail("swizzleNavigationManagerWithoutNextManeuver failed!")
        }
    }

    private func deswizzleNavigationManager() {
        if let mockNavigationManagerMethod = mockNavigationManagerMethod, let realNavigationManagerMethod = realNavigationManagerMethod {
            method_exchangeImplementations(mockNavigationManagerMethod, realNavigationManagerMethod)
        } else {
            XCTFail("deswizzleNavigationManager failed!")
        }
    }
}
