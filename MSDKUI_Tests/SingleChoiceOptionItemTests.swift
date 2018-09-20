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

class SingleChoiceOptionItemTests: XCTestCase {
    // The SingleChoiceOptionItem object to be tested
    private var item = SingleChoiceOptionItem()

    // Is a change occurred?
    private var changed = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        item.labels = [
            "Public transportation only",
            "Shortest route only",
            "Good weather only",
            "No toll cost",
            "Avoid tunnels",
            "Avoid parks"
        ]
        item.onChanged = onChanged
    }

    // Select an item, make sure change callback runs and when the item selected again, the change
    // callback doesn't run
    func testSettingSelectedItem() {
        // Select the 2nd option
        item.selectedItemIndex = 2

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Reset
        changed = false

        // Select the 2nd option again
        item.selectedItemIndex = 2

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")
    }

    // When an outside range item is selected, the last valid selection is kept and the change
    // callback doesn't run
    func testSettingSelectedItemOutsideRange() {
        // Select the 2nd option
        item.selectedItemIndex = 2

        // Reset
        changed = false

        // Select the 76th option which is outside the range
        item.selectedItemIndex = 76

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")

        // Has there been no update?
        XCTAssertEqual(item.selectedItemIndex, 2, "Not the expected selected item 2 state!")
    }

    // Callback for the updates
    func onChanged(_: OptionItem) {
        changed = true
    }
}
