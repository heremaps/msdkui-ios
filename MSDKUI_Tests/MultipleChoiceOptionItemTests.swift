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

class MultipleChoiceOptionItemTests: XCTestCase {
    // The MultipleChoiceOptionItem object to be tested
    private var item = MultipleChoiceOptionItem()

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

    func testSettingSelectedItems() {
        // Select the [29, 32, 0, 3, 2] options
        item.selectedItemIndexes = [29, 32, 0, 3, 2]

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Check the switch states one-by-one
        for index in 0 ..< item.labels.count {
            let state = item.optionSwitches[index].isOn

            switch index {
            case 0, 2, 3:
                XCTAssertTrue(state, "Not the expected selected switch \(index) state!")

            default:
                XCTAssertFalse(state, "Not the expected none-selected switch state for switch \(index)!")
            }
        }

        // Reset
        changed = false

        // Select the [0, 3, 2] options again
        item.selectedItemIndexes = [0, 3, 2]

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")

        // Select the [1, 4] options
        item.selectedItemIndexes = [1, 4]

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")
    }

    func testClearingSelectedItems() {
        // Select the [0, 3, 2] options
        item.selectedItemIndexes = [0, 3, 2]

        // Reset
        changed = false

        // Clear it
        item.selectedItemIndexes = nil

        // Check the switch states one-by-one
        for index in 0 ..< item.labels.count {
            let state = item.optionSwitches[index].isOn

            XCTAssertFalse(state, "Not the expected none-selected switch state for switch \(index)!")
        }
    }

    // When an outside range item is selected, the last valid selection is kept and the change
    // callback doesn't run
    func testSettingSelectedItemOutsideRange() {
        // Select the [0, 3, 2] options
        item.selectedItemIndexes = [0, 3, 2]

        // Reset
        changed = false

        // Select the same indexes with several outside range ones
        item.selectedItemIndexes = [29, 32, 0, 3, 2]

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")

        // Has there been no update?
        XCTAssertEqual(item.selectedItemIndexes, [0, 3, 2], "Not the expected selected switches [0, 3, 2]!")

        // Check the switch states one-by-one
        for index in 0 ..< item.labels.count {
            let state = item.optionSwitches[index].isOn

            switch index {
            case 0, 2, 3:
                XCTAssertTrue(state, "Not the expected selected switch \(index) state!")

            default:
                XCTAssertFalse(state, "Not the expected none-selected switch state for switch \(index)!")
            }
        }
    }

    // Callback for the updates
    func onChanged(_: OptionItem) {
        changed = true
    }
}
