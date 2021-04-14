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

final class ExtensionNumberFormatterTests: XCTestCase {
    /// Tests `NumberFormatter.roundHalfUpFormatter`.
    func testRoundHalfUpFormatter() {
        let formatter = NumberFormatter.roundHalfUpFormatter

        XCTAssertEqual(formatter.string(from: NSNumber(value: 6.0)), "6", "It returns the correct rounded up string")
        XCTAssertEqual(formatter.string(from: NSNumber(value: 6.1)), "6", "It returns the correct rounded up string")
        XCTAssertEqual(formatter.string(from: NSNumber(value: 6.5)), "7", "It returns the correct rounded up string")
        XCTAssertEqual(formatter.string(from: NSNumber(value: 6.9)), "7", "It returns the correct rounded up string")
        XCTAssertEqual(formatter.string(from: NSNumber(value: 7.0)), "7", "It returns the correct rounded up string")
    }
}
