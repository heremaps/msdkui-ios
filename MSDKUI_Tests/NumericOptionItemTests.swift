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

final class NumericOptionItemTests: XCTestCase {
    /// The object under test.
    private var itemUnterTest = NumericOptionItem()

    /// The mock delegate used to verify expectations.
    private var mockDelegate = OptionItemDelegateMock() // swiftlint:disable:this weak_delegate

    override func setUp() {
        super.setUp()

        // Set up the item
        itemUnterTest.label = "Test"
        itemUnterTest.delegate = mockDelegate
    }

    // MARK: - Tests

    /// Tests that the default values are the expected ones.
    func testDefaultValues() {
        XCTAssertLocalized(
            itemUnterTest.getButtonTitle(),
            key: "msdkui_set",
            bundle: .MSDKUI,
            "Not the expected value button title 'Set'!"
        )
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
        XCTAssertEqual(alertController.textFields?.first?.placeholder, itemUnterTest.inputHelper?.placeholder, "The placeholder is OK")

        // Dismiss the alert controller
        alertController.dismiss(animated: false)
    }

    /// Tests that the validator method is called.
    func testValidatorMethod() {
        // Set the input helper
        itemUnterTest.inputHelper = NumericOptionItemInputHelper(
            title: "Title",
            message: "Message",
            placeholder: "Placeholder",
            validator: validate
        )
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

    /// Tests that whenever the value is updated, the button title is updated and the change
    /// protocol function is called.
    func testChangeProtocolFunctionWhenValueChanges() {
        // Set the value property
        itemUnterTest.value = NSNumber(value: 3)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "3", "The value is OK")

        // Check the Delegate
        XCTAssertTrue(mockDelegate.didCallDidChange, "It calls the delegate method")
        XCTAssert(mockDelegate.lastItem === itemUnterTest, "The delegate method is called with the correct item")
    }

    /// Tests that whenever the value is set, but not updated, the button title is not updated and the
    /// change protocol function is not called.
    func testChangeProtocolFunctionWhenValueDoesntChange() {
        // Set the value property
        itemUnterTest.value = NSNumber(value: 5)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "5", "The value is OK")

        XCTAssertTrue(mockDelegate.didCallDidChange, "It calls the delegate method")
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It calls the delegate method once")

        // Set the value property with the same number
        itemUnterTest.value = NSNumber(value: 5)

        // Check the button title
        XCTAssertEqual(itemUnterTest.getButtonTitle(), "5", "The value is OK")

        // It doesn't call the delegate method again
        XCTAssertEqual(mockDelegate.didCallDidChangeCount, 1, "It doesn't call the delegate method again")
    }

    // MARK: - Private

    private func validate(_ stringValue: String) -> Bool {
        let numericValue = NumberFormatter().number(from: stringValue)

        return (numericValue != nil ? true : false)
    }
}
