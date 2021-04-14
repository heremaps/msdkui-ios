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

@testable import MSDKUI_Demo
import XCTest

final class IconButtonTests: XCTestCase {
    // Is the button tapped?
    private var isTapped = false

    // MARK: - Tests

    // Tests that there is a default type value and it is the expected value
    func testDefaultValues() {
        let button = IconButton(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))

        // Is the default type expected value?
        XCTAssertEqual(button.type, .add, "Not the expected type .add!")

        // Is the image set?
        XCTAssertNotNil(button.image(for: .normal), "No image is set!")
    }

    // Tests that it is possible to set the type to a custom value
    func testCustomType() {
        let button = IconButton(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))

        // Set a custom type
        button.type = .options

        // Is the type expected value?
        XCTAssertEqual(button.type, .options, "Not the expected type .options!")

        // Is the image set?
        XCTAssertNotNil(button.image(for: .normal), "No image is set!")
    }

    // Tests that the button tap handler works as expected
    func testTapHandler() {
        let button = IconButton(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))

        // Set the button tap handler method
        button.addTarget(self, action: #selector(tapHandler(sender:)), for: .touchUpInside)

        // Simulate touch
        button.sendActions(for: .touchUpInside)

        // Is the tap detected?
        XCTAssertTrue(isTapped, "The tap wasn't detected!")
    }

    // MARK: - Private

    @objc private func tapHandler(sender _: UIButton) {
        isTapped = true
    }
}
