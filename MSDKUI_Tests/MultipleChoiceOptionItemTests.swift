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

final class MultipleChoiceOptionItemTests: XCTestCase {
    /// The object under test.
    private var item = MultipleChoiceOptionItem()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = OptionItemDelegateMock() // swiftlint:disable:this weak_delegate

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

        item.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests the behaviour when `MultipleChoiceOptionItem.selectedItemIndexes` are set.
    func testSettingSelectedItems() {
        // Select the [29, 32, 0, 3, 2] options
        item.selectedItemIndexes = [29, 32, 0, 3, 2]

        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate only once")
        XCTAssertEqual(mockDelegate.lastItem, item, "It calls the delegate with the correct item")

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

        // Select the [0, 3, 2] options again
        item.selectedItemIndexes = [0, 3, 2]

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It doesn't tell the delegate changed")

        // Select the [1, 4] options
        item.selectedItemIndexes = [1, 4]

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 2, "It calls the delegate again")
        XCTAssertEqual(mockDelegate.lastItem, item, "It calls the delegate with the correct item")
    }

    /// Tests the behaviour when `MultipleChoiceOptionItem.selectedItemIndexes` is set nil.
    func testClearingSelectedItems() {
        // Select the [0, 3, 2] options
        item.selectedItemIndexes = [0, 3, 2]

        // Clear it
        item.selectedItemIndexes = nil

        // Check the switch states one-by-one
        for index in 0 ..< item.labels.count {
            let state = item.optionSwitches[index].isOn

            XCTAssertFalse(state, "Not the expected none-selected switch state for switch \(index)!")
        }
    }

    /// When an outside range item is selected, the last valid selection is kept and the change
    /// protocol function isn't called.
    func testSettingSelectedItemOutsideRange() {
        // Select the [0, 3, 2] options
        item.selectedItemIndexes = [0, 3, 2]

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate method once")

        // Select the same indexes with several outside range ones
        item.selectedItemIndexes = [29, 32, 0, 3, 2]

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It doesn't call the delegate method again")
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
}
