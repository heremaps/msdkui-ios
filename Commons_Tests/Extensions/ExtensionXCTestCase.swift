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

import XCTest

extension XCTestCase {
    enum RequireError: Error {
        case failedToUnwrapOptional
    }

    /// Unwraps an optional.
    ///
    /// - Parameter expression: The optional to unwrap.
    /// - Returns: The unwrapped optional.
    /// - Throws: RequireError.failedToUnwrapOptional if failed to unwrap the optional.
    func require<T>(_ expression: @autoclosure () -> T?, file: StaticString = #file, line: UInt = #line) throws -> T {
        guard let value = expression() else {
            XCTFail("Failed to Unwrap Optional", file: file, line: line)
            throw RequireError.failedToUnwrapOptional
        }

        return value
    }

    /// Asserts that the string is localized.
    ///
    /// - Parameters:
    ///   - string: The string to be tested.
    ///   - key: The key of the string to be tested.
    ///   - bundle: The bundle where the string is defined. If not specified, it will use the main bundle.
    ///   - message: An optional description of the failure.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
    func XCTAssertLocalized(
        _ string: String?,
        key: String,
        bundle: Bundle? = .main,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let bundle = bundle else {
            XCTFail("Invalid bundle", file: file, line: line)
            return
        }

        // Checks if the string isn't equal to the localized key (is the string translated?)
        XCTAssertNotEqual(string, key, message, file: file, line: line)

        // Checks if the string matches the localized string
        XCTAssertEqual(string, NSLocalizedString(key, bundle: bundle, comment: ""), message, file: file, line: line)
    }

    /// Asserts that the string is nonlocalizable.
    ///
    /// - Parameters:
    ///   - string: The string to be tested.
    ///   - key: The key of the string to be tested.
    ///   - bundle: The bundle where the string is defined. If not specified, it will use the main bundle.
    ///   - message: An optional description of the failure.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
    func XCTAssertNonlocalizable(
        _ string: String?,
        key: String,
        bundle: Bundle? = .main,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let bundle = bundle else {
            XCTFail("Invalid bundle", file: file, line: line)
            return
        }

        // Checks if the string isn't equal to the nonlocalized key (is the string different?)
        XCTAssertNotEqual(string, key, message, file: file, line: line)

        // Checks if the string matches the nonlocalized string
        XCTAssertEqual(string, NSLocalizedString(key, tableName: "Nonlocalizable", bundle: bundle, comment: ""), message, file: file, line: line)
    }

    // swiftlint:disable line_length

    /// Asserts that the formatted string is localized.
    ///
    /// - Parameters:
    ///   - string: The string to be tested.
    ///   - formatKey: The key of the format used to build the string.
    ///   - arguments: The parameters used to build the string using the format.
    ///   - bundle: The bundle where the string is defined. If not specified, it will use the main bundle.
    ///   - message: An optional description of the failure.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
    func XCTAssertLocalized(_ string: String?, formatKey: String, arguments: CVarArg..., bundle: Bundle? = .main, message: String = "", file: StaticString = #file, line: UInt = #line) {
        guard let bundle = bundle else {
            XCTFail("Invalid bundle", file: file, line: line)
            return
        }

        let localizedFormatKey = NSLocalizedString(formatKey, bundle: bundle, comment: "")
        let localizedString = String(format: localizedFormatKey, arguments: arguments)

        // Checks if the string isn't equal to the localized key (is the string translated?)
        XCTAssertNotEqual(string, localizedFormatKey, message, file: file, line: line)

        // Checks if the string matches the localized string
        XCTAssertEqual(string, localizedString, message, file: file, line: line)
    }

    // swiftlint:enable line_length
}
