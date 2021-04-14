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

final class SingleChoiceOptionItemTests: XCTestCase {
    /// The object under test.
    private var item = SingleChoiceOptionItem()

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

    /// Select an item, make sure change protocol function is called and when the item selected again,
    /// it isn't called.
    func testSettingSelectedItem() {
        // Select the 2nd option
        item.selectedItemIndex = 2

        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate method only once")

        // Select the 2nd option again
        item.selectedItemIndex = 2

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It doesn't call the delegate method again")
    }

    /// When an outside range item is selected, the last valid selection is kept and the change
    /// protocol function isn't called.
    func testSettingSelectedItemOutsideRange() {
        // Select the 2nd option
        item.selectedItemIndex = 2

        XCTAssertTrue(mockDelegate.didCallDidChange, "It tells the delegate the item changed")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate method only once")

        // Select the 76th option which is outside the range
        item.selectedItemIndex = 76

        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It doesn't call the delegate method again")
        XCTAssertEqual(item.selectedItemIndex, 2, "Not the expected selected item 2 state!")
    }
}
