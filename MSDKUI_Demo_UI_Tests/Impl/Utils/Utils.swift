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

import EarlGrey
@testable import MSDKUI
import NMAKit

/// Class containing helper utility methods.
enum Utils {

    /// Enables or disables the specified `NMAMapView` rendering.
    ///
    /// - Parameter accessibilityIdentifier: The targeted element as GREYMatcher.
    /// - param status: true to enable and false to disable map view rendering.
    static func allowMapViewRendering(_ element: GREYMatcher, _ status: Bool) {
        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "allowMapViewRendering") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let mapView = element as? NMAMapView else {
                        return false
                }

                mapView.isRenderAllowed = status

                return true
            }
        )
    }

    /// Stringizes the specified rows like "0, 1, 2, ..." .
    ///
    /// - Parameter indexPaths: The array of row index paths.
    /// - Returns: A comma separated string of rows.
    static func stringizeRows(_ indexPaths: [IndexPath]) -> String {
        var rows = ""

        for indexPath in indexPaths {
            rows += String(indexPath.row)
            rows += ", "
        }

        // Delete the last comma & blank char
        rows = String(rows.dropLast(2))

        print("Rows: \(rows)")

        return rows
    }

    /// Waits until the specified element becomes visible.
    ///
    /// - Parameters:
    ///   - GREYMatcher: Matcher of the element to wait for.
    ///   - timeout: The timeout period in seconds.
    ///   - pollInterval: The polling interval period in seconds
    static func waitUntil(visible element: GREYMatcher,
                          timeout: Double = Constants.mediumWait,
                          pollInterval: Double = Constants.smallPollInterval) {
        // From the GREYMatchers::matcherForSufficientlyVisible() documentation:
        //    "EarlGrey considers elements that are more than kElementSufficientlyVisiblePercentage (75 %)
        //     visible areawise to be sufficiently visible."
        let condition = GREYCondition(name: "Sufficiently visible") {
            var error: NSError?
            EarlGrey.selectElement(with: element)
                .assert(grey_sufficientlyVisible(), error: &error)
            return error == nil
        }.wait(withTimeout: timeout, pollInterval: pollInterval)

        GREYAssertTrue(condition, reason: "Element was not visible after \(timeout) seconds")
    }

    /// Waits until the specified element becomes hidden.
    ///
    /// - Parameters:
    ///   - accessibilityIdentifier: The `accessibilityIdentifier` of the element to wait for.
    ///   - timeout: The timeout period in seconds.
    ///   - pollInterval: The polling interval period in seconds.
    static func waitUntil(hidden accessibilityIdentifier: String,
                          timeout: Double = Constants.mediumWait,
                          pollInterval: Double = Constants.smallPollInterval) {
        let element = grey_accessibilityID(accessibilityIdentifier)
        let condition = GREYCondition(name: "Hidden") {
            var error: NSError?
            EarlGrey.selectElement(with: element).assert(grey_notVisible(), error: &error)
            return error == nil
        }.wait(withTimeout: timeout, pollInterval: pollInterval)

        GREYAssertTrue(condition, reason: "Element is not hidden after \(timeout) seconds")
    }

    /// Matches element with text and returns the matched element.
    ///
    /// - Parameter text: The text to be matched on the view.
    /// - Returns: The `GREYMatcher` object containing the given text.
    static func viewContainingText(_ text: String) -> GREYMatcher {

        GREYElementMatcherBlock(matchesBlock: {
            guard
                case let element = $0 as AnyObject,
                case let selector = #selector(getter: UILabel.text),
                element.responds(to: selector),
                let viewText = element.perform(selector)?.takeUnretainedValue() as? String else {
                    return false
            }

            return viewText.contains(text)
        }, descriptionBlock: { _ = $0.appendText("containsText(\"\(text)\")") })
    }

    /// Waits until the specified element passes a condition.
    ///
    /// Waits until condition block returns true, or the specified timeout has expired.
    /// The condition is polled at specified intervals.
    ///
    /// - Parameters:
    ///   - elementMatcher: matcher of the element to wait for.
    ///   - timeout: the timeout period in seconds.
    ///   - pollInterval: the polling interval period in seconds.
    ///   - conditionBlock: the condition block to wait upon.
    static func waitUntil<T>(element elementMatcher: GREYMatcher,
                             timeout: TimeInterval = Constants.longWait,
                             pollInterval: TimeInterval = Constants.longPollInterval,
                             conditionBlock: @escaping ((T) -> Bool)) {
        var isMatched: Bool = false
        GREYCondition(name: "Wait for matcher") {
            EarlGrey.selectElement(with: elementMatcher).perform(GREYActionBlock.action(withName: "Wait for element") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let matchedObject = element as? T else {
                        return false
                }

                isMatched = conditionBlock(matchedObject)
                return true
            })
            return isMatched
        }.wait(withTimeout: timeout, pollInterval: pollInterval)
        GREYAssert(isMatched, reason: "No element was matched")
    }

    /// Matches option element with specified label and returns UISwitch that belongs to this option view.
    ///
    /// - Parameter text: Text that option label should contain.
    /// - Returns: UISwith element for option item.
    static func optionSwitchForLabelContainingText(_ text: String) -> GREYMatcher {
        GREYElementMatcherBlock(matchesBlock: { element in

            // Find option switch, switch must have parent
            guard let view = element as? UISwitch,
                view.accessibilityIdentifier == "Label+SwitchOption.switch",
                let superview = view.superview else {
                    return false
            }

            // Check if parent of found switch have UILabel that contains searched text
            return superview.subviews.contains { view -> Bool in
                guard let label = view as? UILabel, let labelText = label.text else {
                    return false
                }
                return labelText.contains(text)
            }
        }, descriptionBlock: { _ = $0.appendText("optionSwitchWithLabelContainText(\"\(text)\")") })
    }
}
