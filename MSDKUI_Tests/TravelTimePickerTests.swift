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
    /// The picker under test.
    private var picker: TravelTimePicker!

    /// 40 min later.
    private var futureDate = Calendar.current.date(byAdding: .minute, value: 40, to: Date())

    /// Is the panel changed?
    private var isPickerChanged = false

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Load the nib file
        let nibFile = UINib(nibName: "TravelTimePicker", bundle: .MSDKUI)

        // Create the time picker
        picker = nibFile.instantiate(withOwner: nil, options: nil)[0] as? TravelTimePicker

        // Set up the picker
        picker.time = futureDate
        picker.onTimePicked = onTimePicked
    }

    /// Tests the picker action.
    func testPickerAction() {
        let app = UIApplication.shared

        // Present the picker
        let presenter = (app.keyWindow?.rootViewController)!
        presenter.present(picker, animated: false)

        // Accept the time
        picker.okButton.sendActions(for: .touchUpInside)

        // Is the panel change detected?
        XCTAssertTrue(isPickerChanged, "The picker change is not detected!")
    }

    /// Tests the picker default colors.
    func testPickerDefaultColors() {
        XCTAssertEqual(picker.canvasView.backgroundColor, .colorForegroundLight, "It has the correct canvas background color")
        XCTAssertEqual(picker.titleView.backgroundColor, .colorBackgroundLight, "It has the correct title view background color")
        XCTAssertNil(picker.datePicker.backgroundColor, "It has a transparent date picker view")
        XCTAssertEqual(picker.titleLabel.textColor, .colorForeground, "It has the correct title label text color")
        XCTAssertEqual(picker.okButton.titleColor(for: .normal), .colorAccent, "It has the correct ok button title color")
        XCTAssertEqual(picker.cancelButton.titleColor(for: .normal), .colorAccent, "It has the correct cancel button title color")
    }

    /// For testing the changes.
    func onTimePicked(_ time: Date) {
        XCTAssertEqual(time, self.futureDate, "Unexpected time!")

        isPickerChanged = true
    }
}
