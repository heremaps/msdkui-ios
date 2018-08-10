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

class TravelTimePanelTests: XCTestCase {
    // The panel
    private var panel = TravelTimePanel()

    // Is the panel changed?
    private var isPanelChanged = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        panel.onTimeChanged = onTimeChanged
    }

    // Tests the panel
    func testPanel() {
        panelTests()
    }

    func panelTests() {
        let now = Date()

        // Has the panel intrinsicContentHeight set?
        XCTAssertGreaterThan(panel.intrinsicContentHeight, 0, "The panel has no intrinsicContentHeight!")

        // Assume the time type is updated
        panel.onTimePicked(now)

        // Is the panel change detected?
        XCTAssertTrue(isPanelChanged, "The panel change is not detected!")

        // Set the same time & type again
        isPanelChanged = false
        panel.onTimePicked(now)

        // Is the panel change not detected?
        XCTAssertFalse(isPanelChanged, "The panel change is detected!")
    }

    // MARK: - Private methods

    // For testing the changes
    func onTimeChanged(_ time: Date) {
        print("onTimeChanged: time: \(time.description)")

        // Are the values equal?
        XCTAssertEqual(time, panel.time, "The values should be equal!")

        isPanelChanged = true
    }
}
