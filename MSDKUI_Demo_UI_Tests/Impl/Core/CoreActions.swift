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

import EarlGrey
import Foundation
@testable import MSDKUI
@testable import MSDKUI_Demo
import XCTest

/// Helps to use the EarlGrey framework.
enum CoreActions {
    static let scrollAmount: CGFloat = 50

    enum Gestures {
        case tap
        case longPress
    }

    /// Used for resetting for the UI tests.
    ///
    /// - Important: It is expected that this method is called in the setUp()
    ///              of each UI tests.
    static func reset(card: LandingView.Cards) {
        GREYAssertTrue(NSClassFromString("EarlGreyImpl") != nil, reason: "No EarlGrey!")

        // Set the kGREYConfigKeyArtifactsDirLocation dir
        if let dir = ProcessInfo.processInfo.environment["EARL_GREY_ARTIFACTS"] {
            GREYConfiguration.sharedInstance().setValue(dir, forConfigKey: kGREYConfigKeyArtifactsDirLocation)
        }

        LandingActions.tapCard(card)

        // Reset based upon the tapped card
        switch card {
        case .routingPlanner:
            ActionbarActions.reset()

        case .driveNav:
            break
        }
    }

    /// Used for taking a screenshot of the application.
    ///
    /// - Parameter name: The name of the file. Note that ".png" is suffixed.
    /// - Returns: true if it succeeds and false otherwise.
    /// - Important: For the time being this method works only on simulators. So, on
    ///              actual devices it does nothing.
    /// - Important: The files are saved into the MSDKUI-iOS/MSDKUI_Demo_UI_Tests/EarlGreyArtifacts
    ///              directory.
    @discardableResult static func saveScreenshot(_ name: String) -> Bool {
        #if arch(i386) || arch(x86_64)
            // The device is a simulator: save the screenshot
            let image = GREYScreenshotUtil.takeScreenshot()
            let file = name + ".png"
            let dir = GREYConfiguration.sharedInstance().stringValue(forConfigKey: kGREYConfigKeyArtifactsDirLocation)

            GREYScreenshotUtil.saveImage(asPNG: image, toFile: file, inDirectory: dir)

            print("Saved screenshot \(file)...")

            return true
        #else
            // The device is not a simulator: do nothing
            return false
        #endif
    }

    /// Performs the tap action on the specified element.
    ///
    /// - Parameter accessibilityIdentifier: The accessibility identifier of the targeted element.
    /// - Important: Note that when selecting element in case it is not found, EarlGrey throws an
    ///              exception, namely NoMatchingElementException, with the reason "Cannot find UI element."
    static func tapElement(_ accessibilityIdentifier: String) {
        print("Tapping \(accessibilityIdentifier)...")
        EarlGrey.selectElement(with: grey_accessibilityID(accessibilityIdentifier))
            .perform(grey_tap())
    }

    /// Taps the specified element.
    ///
    /// - Parameter element: element to tap on
    static func tap(element: GREYMatcher) {
        print("Tapping \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())
    }

    /// Types text to element.
    ///
    /// - Parameter element: element to type text into
    /// - Parameter text: text string to type into element
    static func typeText(element: GREYMatcher, text: String) {
        print("Typing \(String(text)) to \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .perform(grey_typeText(text))
    }

    /// Swipes up on element(scroll down).
    ///
    /// - Parameter element: element to swipe
    static func swipeUpOn(element: GREYMatcher) {
        print("Swiping up on \(String(element.description))...")
        EarlGrey.selectElement(with: element).perform(grey_swipeFastInDirection(GREYDirection.up))
    }

    /// Swipes down on element(scroll up).
    ///
    /// - Parameter element: element to swipe
    static func swipeDownOn(element: GREYMatcher) {
        print("Swiping down on \(String(element.description))...")
        EarlGrey.selectElement(with: element).perform(grey_swipeFastInDirection(GREYDirection.down))
    }

    /// Swipes down to find element.
    ///
    /// - Parameter element: element to find
    static func scrollUpTo(element: GREYMatcher) {
        print("Scrolling up to \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .usingSearch(grey_scrollInDirection(GREYDirection.down, scrollAmount), onElementWith: element)
    }

    /// Swipes up to find element.
    ///
    /// - Parameter element: element to find
    static func scrollDownTo(element: GREYMatcher) {
        print("Scrolling down to \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .usingSearch(grey_scrollInDirection(GREYDirection.up, scrollAmount), onElementWith: element)
    }

    /// Swipes up to find element and taps on it.
    ///
    /// - Parameter element: element to find
    static func srollDownAndTap(element: GREYMatcher) {
        print("Scrolling down to and taping \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .usingSearch(grey_scrollInDirection(GREYDirection.down, scrollAmount), onElementWith: element)
            .perform(grey_tap())
    }

    /// Swipes down to find element and taps on it.
    ///
    /// - Parameter element: element to find
    static func srollUpAndTap(element: GREYMatcher) {
        print("Scrolling up to and taping \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .usingSearch(grey_scrollInDirection(GREYDirection.up, scrollAmount), onElementWith: element)
            .perform(grey_tap())
    }

    /// Taps at a point on screen
    ///
    /// - Parameter element: Element to be tapped upon
    /// - Parameter point: Coordinates of the point - CGPoint(x: coordinateX,y: coordinateY)
    static func tap(element: GREYMatcher, point: CGPoint) {
        print("Taping at point {\(point)}...")
        EarlGrey.selectElement(with: element)
            .perform(grey_tapAtPoint(point))
    }

    /// Long taps at a point on screen
    ///
    /// - Parameter element: Element to be tapped upon
    /// - Parameter point: Coordinates of the point - CGPoint(x: coordinateX,y: coordinateY)
    static func longPress(element: GREYMatcher, point: CGPoint) {
        print("Taping at point \(point)...")
        EarlGrey.selectElement(with: element)
            .perform(grey_longPressAtPointWithDuration(point, Constans.longPressDuration))
    }

    /// Dismisses alert if displayed on top.
    ///
    /// - Parameter element: alert to be dismissed.
    static func dismissAlert(element: GREYMatcher) {
        Utils.waitFor(element: element)

        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "dismissAlert") { element, errorOrNil -> Bool in
                // Check error
                guard errorOrNil != nil else {
                    return false
                }

                // Make sure we have view here
                guard let alertView = element as? UIView else {
                    return false
                }

                // Make sure this is alert controller view
                guard let alert = alertView.viewController as? UIAlertController else {
                    return false
                }

                // Dismiss alert
                alert.dismiss(animated: false)

                return true
            }
        )
    }
}
