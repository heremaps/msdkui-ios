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

class TravelTimePickerTests: XCTestCase {
    // The panel
    private var picker: TravelTimePicker!

    // 40 min later
    private var time = Date().addingTimeInterval(40.0 * 60.0)

    // Is the panel changed?
    private var isPickerChanged = false

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Load the nib file
        let nibFile = UINib(nibName: "TravelTimePicker", bundle: .MSDKUI)

        // Create the time picker
        picker = nibFile.instantiate(withOwner: nil, options: nil)[0] as! TravelTimePicker

        // Set up the picker
        picker.time = time
        picker.onTimePicked = onTimePicked
    }

    // Tests the panel
    func testPanel() {
        panelTests()
    }

    func panelTests() {
        let app = UIApplication.shared

        // Present the picker
        let presenter = (app.keyWindow?.rootViewController)!
        presenter.present(picker, animated: false)

        // Accept the time
        picker.okButton.sendActions(for: .touchUpInside)

        // Is the panel change detected?
        XCTAssertTrue(isPickerChanged, "The picker change is not detected!")
    }

    // For testing the changes
    func onTimePicked(_ time: Date) {
        print("onTimeChanged: time: \(time.description)")

        XCTAssertEqual(time, self.time, "Unexpected time!")

        isPickerChanged = true
    }
}
