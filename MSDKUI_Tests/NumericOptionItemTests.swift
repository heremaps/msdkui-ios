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

class NumericOptionItemTests: XCTestCase {
    /// The NumericOptionItem object to be tested.
    var itemUnterTest = NumericOptionItem()

    override func setUp() {
        super.setUp()

        // Set up the item
        itemUnterTest.label = "Test"
    }

    /// Tests that the default values are the expected ones.
    func testDefaultValues() {
        XCTAssertLocalized(itemUnterTest.getButtonTitle(),
                           key: "msdkui_set",
                           bundle: .MSDKUI,
                           "Not the expected value button title 'Set'!")
    }

    /// Tests that the text values are set correctly.
    func testTextValues() throws {
        // Set the input helper
        itemUnterTest.inputHelper = NumericOptionItemInputHelper(title: "Title", message: "Message", placeholder: "Placeholder") { _ in false }

        // Set the presenter
        itemUnterTest.presenter = UIApplication.shared.keyWindow?.rootViewController

        // Simulate tapping the value button to launch the alert controller
        itemUnterTest.onButton(UIButton())

        let alertController = try require(itemUnterTest.presenter?.presentedViewController as? UIAlertController)

        XCTAssertEqual(alertController.title, itemUnterTest.inputHelper?.title, "The title is OK")
        XCTAssertEqual(alertController.message, itemUnterTest.inputHelper?.message, "The message is OK")
        XCTAssertEqual(alertController.textFields?[0].placeholder, itemUnterTest.inputHelper?.placeholder, "The placeholder is OK")

        // Dismiss the alert controller
        alertController.dismiss(animated: false, completion: nil)
    }

    /// Tests that the validator method is called.
    func testValidatorMethod() {
        // Set the input helper
        itemUnterTest.inputHelper = NumericOptionItemInputHelper(title: "Title",
                                                                 message: "Message",
                                                                 placeholder: "Placeholder",
                                                                 validator: validate)
        // Set the value property
        itemUnterTest.value = NSNumber(value: 3)

        // Run the OK handler programmatically with a non-numeric value
        itemUnterTest.okHandler(userInput: "None-numeric value")

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "3", "The value is OK")

        // Run the OK handler programmatically with a numeric value
        itemUnterTest.okHandler(userInput: "7")

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "7", "The value is OK")
    }

    /// Tests that whenever the value is updated, the button title is updated and the change callback
    /// is called.
    func testCallbackWhenValueChanges() {
        var callbackOptionItem: OptionItem?

        itemUnterTest.onChanged = { optionItem in
            callbackOptionItem = optionItem
        }

        // Set the value property
        itemUnterTest.value = NSNumber(value: 3)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "3", "The value is OK")

        // Is the change callback called?
        XCTAssertTrue(self.itemUnterTest === callbackOptionItem, "The callback is called")
    }

    /// Tests that whenever the value is set, but not updated, the button title is not updated and the
    /// change callback is not called.
    func testCallbackWhenValueDoesntChange() {
        // Set the value property
        itemUnterTest.value = NSNumber(value: 5)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "5", "The value is OK")

        var callbackOptionItem: OptionItem?

        itemUnterTest.onChanged = { optionItem in
            callbackOptionItem = optionItem
        }

        // Set the value property with the same number
        itemUnterTest.value = NSNumber(value: 5)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "5", "The value is OK")

        // Is the change callback not called?
        XCTAssertNil(callbackOptionItem, "The callback is not called")
    }

    // MARK: Private

    // Validate the input
    private func validate(_ stringValue: String) -> Bool {
        let numericValue = NumberFormatter().number(from: stringValue)

        return (numericValue != nil ? true : false)
    }
}
