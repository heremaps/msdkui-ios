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
    // The NumericOptionItem object to be tested
    var item = NumericOptionItem()

    // Is a change occurred?
    var changed = false

    // The real `rootViewController` is replaced with a view controller
    let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController

    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()

        // Set up the item
        item.label = "Test"
        item.onChanged = onChanged

        // Create the view controller which will present the NumericOptionItem input box
        let viewController = UIViewController()
        viewController.loadViewIfNeeded()
        viewController.view.addSubview(item)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

    // This method is called after the invocation of each test method in the class
    override func tearDown() {
        // Restore the root view controller
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController

        super.tearDown()
    }

    // Tests that the default values are the expected ones
    func testDefaultValues() {
        // Check the button title
        XCTAssertLocalized(item.getButtonTitle(), key: "msdkui_set", bundle: .MSDKUI,
                           "Not the expected value button title 'Set'!")
    }

    // Tests that whenever the value is updated, the button title state is updated & the change callback is called,
    // plus a no change update should not generate change callback
    func testChangingValuePropertyDirectly() {
        // Set the value property
        item.value = NSNumber(value: 3)

        // Check the button title
        XCTAssertEqual(item.getButtonTitle(), "3", "Not the expected value button title 3!")

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Reset
        changed = false

        // Set the value property with the same number
        item.value = NSNumber(value: 3)

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")
    }

    // Tests that whenever the button is tapped and a new value is submitted via the input box, the value is
    // updated, the button title state is updated & the change callback is called, plus a no change update should not
    // generate change callback
    func testChangingValuePropertyViaInputBox() {
        // Set the input helper
        item.inputHelper = NumericOptionItemInputHelper(validator: validate, title: "Vehicle axles", message: "Update the value?", placeholder: "9")

        // Let the view controller become the first responder: it will present the
        // alert controller
        item.viewController?.becomeFirstResponder()

        // Simulate touch inside the value button
        item.onButton(UIButton())

        guard let alertController = item.viewController?.presentedViewController as? InputBox else {
            XCTFail("No alertController!")
            return
        }

        // Directly call InputBox.viewWillAppear() as it setup the strings
        alertController.viewWillAppear(false)

        XCTAssertEqual(alertController.titleLabel.text, item.inputHelper.title, "Not the expected alert controller title")
        XCTAssertEqual(alertController.messageLabel.text, item.inputHelper.message, "Not the expected alert controller message")
        XCTAssertEqual(alertController.textField.placeholder, item.inputHelper.placeholder, "Not the expected alert controller placeholder")

        // Dismiss the alert controller
        item.viewController?.dismiss(animated: false, completion: nil)

        // Run the OK handler programmatically
        item.okHandler(userInput: "7")

        // Check the button title
        XCTAssertEqual(item.getButtonTitle(), "7", "Not the expected value button title!")

        // Has the change callback called?
        XCTAssertTrue(changed, "Not the expected changed true value!")

        // Reset
        changed = false

        // Call the okHandler with the same number
        item.okHandler(userInput: "7")

        // Has the change callback not called?
        XCTAssertFalse(changed, "Not the expected changed false value!")
    }

    // MARK: Private

    // Validate the input
    private func validate(_ stringValue: String) -> Bool {
        let numericValue = NumberFormatter().number(from: stringValue)

        return (numericValue != nil ? true : false)
    }

    // Callback for the updates
    private func onChanged(_: OptionItem) {
        changed = true
    }
}
