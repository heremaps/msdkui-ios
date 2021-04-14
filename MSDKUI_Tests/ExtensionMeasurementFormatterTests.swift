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

final class ExtensionMeasurementFormatterTests: XCTestCase {
    /// Tests `MeasurementFormatter.currentMediumUnitFormatter`.
    func testCurrentMediumUnitFormatter() {
        let formatter = MeasurementFormatter.currentMediumUnitFormatter

        XCTAssertEqual(formatter.unitOptions, .naturalScale, "It chooses the preferred unit to format for the measurement based on the formatter's locale")
        XCTAssertEqual(formatter.unitStyle, .medium, "It uses the medium style to format the unit")
        XCTAssertEqual(formatter.locale, .current, "It uses the current locale to format the unit")
        XCTAssertEqual(formatter.numberFormatter.maximumFractionDigits, 0, "It doesn't show digits after the decimal separator")
    }

    /// Tests `MeasurementFormatter.shortSpeedFormatter`.
    func testShortSpeedFormatter() {
        let formatter = MeasurementFormatter.shortSpeedFormatter

        XCTAssertEqual(formatter.unitOptions, .providedUnit, "It uses the unit provided for the measurement")
        XCTAssertEqual(formatter.unitStyle, .short, "It uses the short style to format the unit")
        XCTAssertEqual(formatter.locale, .current, "It uses the current locale to format the unit")
        XCTAssertEqual(formatter.numberFormatter.maximumFractionDigits, 0, "It doesn't show digits after the decimal separator")
    }

    /// Tests `MeasurementFormatter.longSpeedFormatter`.
    func testLongSpeedFormatter() {
        let formatter = MeasurementFormatter.longSpeedFormatter

        XCTAssertEqual(formatter.unitOptions, .providedUnit, "It uses the unit provided for the measurement")
        XCTAssertEqual(formatter.unitStyle, .long, "It uses the long style to format the unit")
        XCTAssertEqual(formatter.locale, .current, "It uses the current locale to format the unit")
        XCTAssertEqual(formatter.numberFormatter.maximumFractionDigits, 0, "It doesn't show digits after the decimal separator")
    }
}
