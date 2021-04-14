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

final class ExtensionLocaleTests: XCTestCase {
    /// Tests the `.usesKilometersPerHour` behavior for Germany.
    func testUsesKilometersPerHourForGermany() {
        XCTAssertTrue(Locale(identifier: "de_DE").usesKilometersPerHour, "It uses km/h for speed.")
    }

    /// Tests the `.usesKilometersPerHour` behavior for the US.
    func testUsesKilometersPerHourForUS() {
        XCTAssertFalse(Locale(identifier: "en_US").usesKilometersPerHour, "It doesn't use km/h for speed.")
    }

    /// Tests the `.usesKilometersPerHour` behavior for UK.
    func testUsesKilometersPerHourForUK() {
        XCTAssertFalse(Locale(identifier: "en_GB").usesKilometersPerHour, "It doesn't use km/h for speed.")
    }

    /// Tests the `.usesKilometersPerHour` behavior for Brazil.
    func testUsesKilometersPerHourForBrazil() {
        XCTAssertTrue(Locale(identifier: "pt_BR").usesKilometersPerHour, "It uses km/h for speed.")
    }

    /// Tests the `.usesKilometersPerHour` behavior for an invalid Locale.
    func testUsesKilometersPerHourForInvalidLocale() {
        XCTAssertTrue(Locale(identifier: "BADBEEF").usesKilometersPerHour, "It uses km/h for speed.")
    }
}
