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

final class ExtensionDateFormatterTests: XCTestCase {
    /// Tests `DateFormatter.currentShortTimeFormatter`.
    func testCurrentShortTimeFormatter() {
        let formatter = DateFormatter.currentShortTimeFormatter

        XCTAssertEqual(formatter.dateStyle, .none, "It doesn't show the date")
        XCTAssertEqual(formatter.timeStyle, .short, "It shows the time with short style")
        XCTAssertEqual(formatter.locale, .current, "It uses the current locale to format the time")
    }
}
