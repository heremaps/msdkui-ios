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

    /// The panel under test.
    private var panel = TravelTimePanel()

    /// The mock delegate used to validate expectations.
    private var mockDelegate = TravelTimePanelDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Sets the mock delegate
        panel.delegate = mockDelegate
    }

    /// Tests the panel height.
    func testPanelHeight() {
        XCTAssertGreaterThan(panel.intrinsicContentHeight, 0, "It has intrinsic content height")
    }

    /// Tests the panel's default colors.
    func testDefaultColors() {
        XCTAssertEqual(panel.backgroundColor, .colorBackgroundLight, "It has the correct background color")
        XCTAssertEqual(panel.timeLabel.textColor, .colorForegroundSecondary, "It has the correct time label text color")
        XCTAssertEqual(panel.iconImageView.tintColor, .colorForegroundSecondary, "It has the correct icon image view tint color")
    }

    /// Tests the behavior when new colors are set.
    func testWhenColorsChange() {
        panel.iconColor = .red
        panel.timeLabelTextColor = .green

        XCTAssertEqual(panel.iconImageView.tintColor, .red, "It has the correct icon image view tint color")
        XCTAssertEqual(panel.timeLabel.textColor, .green, "It has the correct time label text color")
    }

    /// Tests the behavior when time changes.
    func testWhenTimeChanges() {
        let now = Date()
        let later = Date.distantFuture
        var passedTime: Date?

        // Sets the callback
        panel.onTimeChanged = { time in
            passedTime = time
        }

        // Sets the current time as baseline
        panel.onTimePicked(now)

        // Sets the new time
        panel.onTimePicked(later)

        XCTAssertNotEqual(passedTime, now, "It doesn't call the callback function with the old time")
        XCTAssertEqual(passedTime, later, "It calls the callback function with the new time")
        XCTAssertEqual(panel.time, later, "It updates the panel to the new time")
    }

    /// Tests the behavior when the panel is tapped.
    func testWhenPanelIsTapped() {
        // Adds the panel to a view controller
        let viewController = UIViewController()
        viewController.view.addSubview(panel)

        // Triggeres the tap gesture
        panel.handleTap(MockUtils.mockTapGestureRecognizer(with: .began))

        XCTAssertTrue(mockDelegate.didCallWillDisplayPicker, "It tells the delegate the picker view controller is about to be presented")
        XCTAssert(mockDelegate.lastPanel === panel, "It calls the delegate with the correct panel")
        XCTAssertNotNil(mockDelegate.lastPickerViewController, "It calls the delegate with a valid picker view controller")
    }
}
