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

import MSDKUI
import XCTest

class ExtensionUIColorTests: XCTestCase {
    // Tests that the red, green, blue and alpha compnents are set
    // correctly with the UIColor(hex:alpha:) extension
    func testInitWithHex() {
        let color = UIColor(hex: 0xFFEEDD, alpha: 0.67)
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)

        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            XCTAssertEqual(red, 0xFF / 0xFF, "Not the expected red component!")
            XCTAssertEqual(green, 0xEE / 0xFF, "Not the expected green component!")
            XCTAssertEqual(blue, 0xDD / 0xFF, "Not the expected blue component!")
            XCTAssertEqual(alpha, 0.67, "Not the expected alpha component!")
        } else {
            XCTFail("Unable to get the RGBA components!")
        }
    }
}
