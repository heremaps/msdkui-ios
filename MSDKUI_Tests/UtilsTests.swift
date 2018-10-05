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

class UtilsTests: XCTestCase {

    /// Tests that the MSDKUI.Utils.roundToSignificantDigits() works as expected.
    func testRoundToSignificantDigits() {
        let cases: [(originalNumber: Double, significantDigits: Int, expectedNumber: Double)] = [
            (1.6778, 2, 1.7),
            (1.6778, 3, 1.68),
            (1.6778, 4, 1.678),
            (1.67348, 4, 1.673),
            (95.4567, 4, 95.46),
            (95.4536, 4, 95.45),
            (175.456791234, 9, 175.456791)
        ]

        // Check each test case one-by-one
        cases.forEach {
            let roundedNumber: Double = MSDKUI.Utils.roundToSignificantDigits(number: $0.originalNumber, significantDigits: $0.significantDigits)
            XCTAssertEqual(roundedNumber, $0.expectedNumber, accuracy: Double($0.significantDigits), "It returns the correct rounded number")
        }
    }
}
