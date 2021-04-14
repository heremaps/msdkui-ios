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

final class GuidanceStreetLabelTests: XCTestCase {
    /// The object under test.
    private var labelUnderTest: GuidanceStreetLabel?

    override func setUp() {
        super.setUp()

        labelUnderTest = GuidanceStreetLabel(frame: .zero)
    }

    // MARK: - Looking for position state

    /// Tests configuration of label's looking for position state.
    func testIsLookingForPosition() throws {
        let labelUnderTest = try require(self.labelUnderTest)

        // Not looking for position
        labelUnderTest.isLookingForPosition = false

        XCTAssertTrue(labelUnderTest.isHidden, "It is hidden")
        XCTAssertNil(labelUnderTest.text, "It has no text")
        XCTAssertEqual(labelUnderTest.backgroundColor, .colorPositive, "It has correct background color")

        // Looking for position
        var expectedLookingForPositionText = "Looking for position"
        labelUnderTest.lookingForPositionText = expectedLookingForPositionText

        labelUnderTest.isLookingForPosition = true

        XCTAssertFalse(labelUnderTest.isHidden, "It is visible")
        XCTAssertEqual(labelUnderTest.text, expectedLookingForPositionText, "It has correct text")
        XCTAssertEqual(labelUnderTest.backgroundColor, .colorForegroundSecondary, "It has correct background color")

        // Looking for position text update
        expectedLookingForPositionText = "Getting user position"
        labelUnderTest.lookingForPositionText = expectedLookingForPositionText
        XCTAssertEqual(labelUnderTest.text, expectedLookingForPositionText, "It has correct text")
    }

    // MARK: - Content insets

    /// Tests if the label has the correct default content insets.
    func testContentInsets() {
        XCTAssertEqual(
            labelUnderTest?.contentInsets, UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
            "It has the correct content insets"
        )
    }

    /// Tests inset of label's content.
    func testTextInset() throws {
        let labelUnderTest = try require(self.labelUnderTest)
        labelUnderTest.text = "Invalidenstraße"

        let firstInset = UIEdgeInsets(top: 40, left: 30, bottom: 20, right: 10)
        labelUnderTest.contentInsets = firstInset
        labelUnderTest.sizeToFit()
        let firstSize = labelUnderTest.frame.size

        let secondInset = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        labelUnderTest.contentInsets = secondInset
        labelUnderTest.sizeToFit()
        let secondSize = labelUnderTest.frame.size

        XCTAssertEqual(secondInset.size - firstInset.size, secondSize - firstSize, "It has same size difference")
    }

    // MARK: - Accent

    /// Tests change of label's background color on `isAccented` property change.
    func testAccentChange() throws {
        let labelUnderTest = try require(self.labelUnderTest)

        XCTAssertNotEqual(labelUnderTest.backgroundColor, .black, "It has different initial background color")
        labelUnderTest.backgroundColor = .black

        labelUnderTest.isAccented = true
        XCTAssertEqual(labelUnderTest.backgroundColor, .colorPositive, "It has correct background color")
        labelUnderTest.isAccented = false
        XCTAssertEqual(labelUnderTest.backgroundColor, .colorForegroundSecondary, "It has correct background color")
    }

    /// Tests changes of label's background color properties.
    func testBackgroundColorChange() throws {
        let labelUnderTest = try require(self.labelUnderTest)
        let expectedBackgroundColor = UIColor.white

        XCTAssertNotEqual(labelUnderTest.plainBackgroundColor, expectedBackgroundColor, "It is different before setting background color")
        labelUnderTest.plainBackgroundColor = expectedBackgroundColor
        XCTAssertEqual(labelUnderTest.plainBackgroundColor, expectedBackgroundColor, "It is the same after setting background color")

        XCTAssertNotEqual(labelUnderTest.accentBackgroundColor, expectedBackgroundColor, "It is different before setting background color")
        labelUnderTest.accentBackgroundColor = expectedBackgroundColor
        XCTAssertEqual(labelUnderTest.accentBackgroundColor, expectedBackgroundColor, "It is the same after setting background color")
    }

    // MARK: - Style

    /// Tests label's style for each initialization path.
    func testStyle() throws {
        var labelUnderTest = try require(self.labelUnderTest)
        assertStyleProperties(of: labelUnderTest)

        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        labelUnderTest = try require(GuidanceStreetLabel(coder: coder))
        assertStyleProperties(of: labelUnderTest)
    }

    // MARK: - Accessibility

    /// Tests label's accessibility for each initialization path.
    func testAccessibility() throws {
        var labelUnderTest = try require(self.labelUnderTest)
        assertAccessibility(of: labelUnderTest)

        let coder = try NSKeyedUnarchiver(forReadingFrom: NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false))
        labelUnderTest = try require(GuidanceStreetLabel(coder: coder))
        assertAccessibility(of: labelUnderTest)
    }

    // MARK: - Private

    private func assertAccessibility(of labelUnderTest: GuidanceStreetLabel) {
        XCTAssertEqual(
            labelUnderTest.accessibilityIdentifier, "MSDKUI.GuidanceStreetLabel",
            "It has correct accessibility identifier"
        )
    }

    private func assertStyleProperties(of labelUnderTest: GuidanceStreetLabel) {
        XCTAssertTrue(labelUnderTest.isAccented, "It has correct style state")
        XCTAssertEqual(labelUnderTest.backgroundColor, .colorPositive, "It has correct background color")
        XCTAssertEqual(labelUnderTest.font, .preferredFont(forTextStyle: .subheadline), "It has correct font")
        XCTAssertEqual(labelUnderTest.textColor, .colorForegroundLight, "It has correct text color")
        XCTAssertEqual(labelUnderTest.layer.cornerRadius, labelUnderTest.bounds.height / 2, "It has correct rounded corners radius")
        XCTAssertTrue(labelUnderTest.clipsToBounds, "It has rounded corners")
        XCTAssertEqual(labelUnderTest.textAlignment, .center, "It has correct text alignment")
        XCTAssertEqual(labelUnderTest.numberOfLines, 1, "It has correct text alignment")
        XCTAssertEqual(labelUnderTest.lineBreakMode, .byTruncatingTail, "It has correct text truncation mode")
    }
}

/// Extension of `UIEdgeInsets` for conversion to `CGSize`.
private extension UIEdgeInsets {
    /// `CGSize` of `UIEdgeInsets`
    var size: CGSize {
        CGSize(
            width: left + right,
            height: top + bottom
        )
    }
}

/// Extension of `CGSize` for subtraction operator.
private extension CGSize {
    /// Subtracts two `CGSize`. Result is a `CGSize` with componentwise subtraction.
    static func - (_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        CGSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }
}
