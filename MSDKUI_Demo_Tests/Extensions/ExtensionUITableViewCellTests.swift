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

@testable import MSDKUI_Demo
import XCTest

final class ExtensionUITableViewCellTests: XCTestCase {
    /// Tests `.selectedBackgroundColor` when called with color.
    func testSelectedBackgroundColorWithValue() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        // Sets the selected background color
        cell.selectedBackgroundColor = .purple

        XCTAssertEqual(cell.selectedBackgroundView?.backgroundColor, .purple, "It has a selected background view with correct color")
        XCTAssertEqual(cell.selectedBackgroundColor, .purple, "It has a selected background color")
    }

    /// Tests `.selectedBackgroundColor` when called with nil.
    func testSelectedBackgroundColorWithNil() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        // Nils out the selected background color
        cell.selectedBackgroundColor = nil

        XCTAssertNil(cell.selectedBackgroundView?.backgroundColor, "It doesn't have a selected background view with color")
        XCTAssertNil(cell.selectedBackgroundColor, "It doesn't have a selected background color (via getter)")
    }
}
