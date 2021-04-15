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
@testable import MSDKUI_Demo
import XCTest

/// Helps to use the EarlGrey framework.
enum CoreActions {

    // MARK: - Types

    enum Gestures {
        case tap
        case longPress
    }

    // MARK: - Properties

    private static let scrollAmount: CGFloat = 50

    // MARK: - Public

    /// Used for resetting for the UI tests.
    ///
    /// - Important: It is expected that this method is called in the setUp()
    ///              of each UI tests.
    static func reset(card: LandingMatchers.Cards) {
        GREYAssertTrue(NSClassFromString("EarlGreyImpl") != nil, reason: "No EarlGrey!")

        // Set the kGREYConfigKeyArtifactsDirLocation dir
        if let dir = ProcessInfo.processInfo.environment["EARL_GREY_ARTIFACTS"] {
            GREYConfiguration.sharedInstance().setValue(dir, forConfigKey: kGREYConfigKeyArtifactsDirLocation)
        }

        LandingActions.tapCard(card)

        // Reset based upon the tapped card
        switch card {
        case .routePlanner:
            RoutePlannerActions.reset()

        case .driveNavigation:
            break
        }
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
    /// - Parameter element: element to tap on.
    static func tap(element: GREYMatcher) {
        print("Tapping \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())
    }

    /// Types text to element.
    ///
    /// - Parameter element: element to type text into.
    /// - Parameter text: text string to type into element.
    static func typeText(element: GREYMatcher, text: String) {
        print("Typing \(String(text)) to \(String(element.description))...")
        EarlGrey.selectElement(with: element)
            .perform(grey_typeText(text))
    }

    /// Swipes up on element(scroll down).
    ///
    /// - Parameter element: element to swipe.
    static func swipeUpOn(element: GREYMatcher) {
        print("Swiping up on \(String(element.description))...")
        EarlGrey.selectElement(with: element).perform(grey_swipeFastInDirection(GREYDirection.up))
    }

    /// Swipes down on element(scroll up).
    ///
    /// - Parameter element: element to swipe.
    static func swipeDownOn(element: GREYMatcher) {
        print("Swiping down on \(String(element.description))...")
        EarlGrey.selectElement(with: element).perform(grey_swipeFastInDirection(GREYDirection.down))
    }

    /// Taps at a point on screen.
    ///
    /// - Parameter element: Element to be tapped upon.
    /// - Parameter point: Coordinates of the point - CGPoint(x: coordinateX,y: coordinateY).
    static func tap(element: GREYMatcher, point: CGPoint) {
        print("Tapping at point {\(point)}...")

        EarlGrey.selectElement(with: element)
            .perform(grey_tapAtPoint(point))
    }

    /// Long taps at a point on screen.
    ///
    /// - Parameter element: Element to be tapped upon.
    /// - Parameter point: Coordinates of the point - CGPoint(x: coordinateX,y: coordinateY).
    static func longPress(element: GREYMatcher, point: CGPoint) {
        print("Tapping at point \(point)...")

        EarlGrey.selectElement(with: element)
            .perform(grey_longPressAtPointWithDuration(point, Constants.longPressDuration))
    }

    /// Finds point in the middle of the UI element.
    ///
    /// - Parameter element: Element under examination.
    /// - Returns: A point in the middle of an observable element.
    static func centerOfElementBounds(element: GREYMatcher) -> CGPoint {
        var point = CGPoint(x: 0.0, y: 0.0)
        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "Get center point of an UI element") { element, errorOrNil in
                guard
                    errorOrNil != nil,
                    let element = element as? UIView else {
                        return false
                }
                let heightMiddle = element.bounds.height / 2
                let widthMiddle = element.bounds.width / 2
                point = CGPoint(x: widthMiddle, y: heightMiddle)
                return true
            }
        )
        return point
    }
}
