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

class TitleItemTests: XCTestCase {
    // The test object
    private var item = TitleItem()

    /// Tests the item default colors.
    func testDefaultColors() {
        XCTAssertEqual(item.view.backgroundColor, .colorForegroundLight, "It has correct background color")
        XCTAssertEqual(item.lineView.backgroundColor, .colorDivider, "It has corrct line color")
        XCTAssertEqual(item.label.textColor, .colorForeground, "It has correct text color")
    }

    /// Test the item color updates.
    func testColorUpdates() {
        item.backgroundColor = .black
        item.lineColor = .white
        item.textColor = .red

        XCTAssertEqual(item.view.backgroundColor, .black, "It has correct background color")
        XCTAssertEqual(item.lineView.backgroundColor, .white, "It has corrct line color")
        XCTAssertEqual(item.label.textColor, .red, "It has correct text color")
    }
}
