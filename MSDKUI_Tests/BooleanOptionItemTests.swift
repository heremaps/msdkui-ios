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

class BooleanOptionItemTests: XCTestCase {
    // The BooleanOptionItem object to be tested
    private var item = BooleanOptionItem()

    // Is a change occurred?
    private var changed = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        item.label = "Test"
        item.onChanged = onChanged
    }

    // Tests that whenever the checked value is updated, the switch state is updated & the change callback is called,
    // plus a no change update should not generate change callback
    func testChangingCheckedProperty() {
        // Toggle the checked property
        item.checked = !(item.checked)

        // Is the switch state in line with the checked property?
        XCTAssertEqual(item.optionSwitch.isOn, item.checked, "Not the expected switch state & checked property conformance!")

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Reset
        changed = false

        // Toggle the checked property
        item.checked = !(item.checked)

        // Is the switch state in line with the checked property?
        XCTAssertEqual(item.optionSwitch.isOn, item.checked, "Not the expected switch state & checked property conformance!")

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Reset
        changed = false

        // Assign the same value again
        item.checked = item.checked

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")
    }

    // Tests that whenever the switch state is updated, the checked property is updated & the change callback is called
    func testChangingSwitchSate() {
        // Toggle the switch state
        let state = item.optionSwitch.isOn
        item.optionSwitch.isOn = !state

        // Simulate user interaction: call the switch handler directly
        item.onSwitch(UISwitch())

        // Is the switch state in line with the checked property?
        XCTAssertEqual(item.checked, item.optionSwitch.isOn, "Not the expected checked property & switch state conformance!")

        // Has the change callback called?
        XCTAssertEqual(changed, true, "Not the expected changed true value!")
    }

    // Callback for the updates
    func onChanged(_: OptionItem) {
        changed = true
    }
}
