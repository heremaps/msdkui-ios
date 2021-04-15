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

final class BooleanOptionItemTests: XCTestCase {
    /// The object under test.
    private var item = BooleanOptionItem()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = OptionItemDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Set up the item
        item.label = "Test"
        item.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests that whenever the checked value is updated, the switch state is updated & the
    /// change protocol function is called, plus a no change update should not generate a
    /// call to this function.
    func testChangingCheckedProperty() {
        // Toggle the checked property
        item.checked.toggle()

        XCTAssertEqual(item.optionSwitch.isOn, item.checked, "Not the expected switch state & checked property conformance!")
        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate only once")

        // Toggle the checked property
        item.checked.toggle()

        XCTAssertEqual(item.optionSwitch.isOn, item.checked, "Not the expected switch state & checked property conformance!")
        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 2, "It calls the delegate again")

        // Assign the same value again
        item.checked = item.checked

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 2, "It doesn't call the delegate again")
    }

    /// Tests that whenever the switch state is updated, the checked property is updated & the change
    /// protocol function is called.
    func testChangingSwitchSate() {
        // Toggle the switch state
        let state = item.optionSwitch.isOn
        item.optionSwitch.isOn = !state

        // Simulate user interaction: call the switch handler directly
        item.onSwitch(UISwitch())

        XCTAssertEqual(item.checked, item.optionSwitch.isOn, "Not the expected checked property & switch state conformance!")
        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
    }
}
