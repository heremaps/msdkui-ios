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
@testable import MSDKUI
import NMAKit

/// Class containing helper utility methods.
class Utils {
    private init() {}
    private static var configured = false

    static func configure() {
        if !configured {
            speedupAnimations()
            configured = true
        }
        GREYConfiguration.sharedInstance().reset()
        configureEarlGreyScreenshotPath()
    }

    static func configureEarlGreyScreenshotPath() {
        if let screenshotPath = ProcessInfo.processInfo.environment["SCREENSHOT_PATH"] {
            GREYConfiguration.sharedInstance().setValue(screenshotPath, forConfigKey: kGREYConfigKeyArtifactsDirLocation)
        }
    }

    static func speedupAnimations() {
        UIApplication.shared.keyWindow?.layer.speed = 100
    }

    /// The root part of the screenshot names.
    private static var testName: String?

    /// The current sequence number. Note that it is reset via initTest(name: ).
    private static var sequence: Int?

    /// Enables or disables the specified `NMAMapView` rendering.
    ///
    /// - Parameter accessibilityIdentifier: The targeted element as GREYMatcher.
    /// - param status: true to enable and false to disable map view rendering.
    static func allowMapViewRendering(_ element: GREYMatcher, _ status: Bool) {
        EarlGrey.selectElement(with: element).perform(
            GREYActionBlock.action(withName: "allowMapViewRendering") { element, errorOrNil in
                guard errorOrNil != nil else {
                    return false
                }

                let mapView = element as! NMAMapView
                mapView.isRenderAllowed = status

                return true
            }
        )
    }

    /// First expands the waypoint list and then saves a screenshot.
    ///
    /// - Parameter name: The name of the screenshot file.
    static func saveWaypointsScreenshot(name: String) {
        CoreActions.tapElement("ViewController.right")
        CoreActions.saveScreenshot(name)
    }

    /// Initiates the specified test.
    ///
    /// - Parameter name: The name of the test.
    /// - Important: The screenshots that will be saved by saveScreenshot()
    ///              method would be named like "name_0", "name_1", etc. That is,
    ///              the file name starts from zero and is updated sequentially.
    static func initTest(name: String) {
        // If the name has "()" at the end, delete them
        if name.hasSuffix("()") {
            testName = String(name.dropLast(2))
        } else {
            testName = name
        }

        // Reset
        sequence = 0
    }

    /// Saves a screenshot sequentially named if the `testName` is set.
    /// Otherwise, this method does nothing.
    static func saveScreenshot() {
        // Is the test name set?
        guard testName != nil else {
            return
        }

        CoreActions.saveScreenshot("\(testName!)_\(sequence!)")

        // Update the sequence number for the next run
        sequence! += 1
    }

    /// First expands the waypoint list and then saves a screenshot sequentially named
    /// if the `testName` is set. Otherwise, this method does nothing.
    static func saveWaypointsScreenshot() {
        // Is the test name set?
        guard testName != nil else {
            return
        }

        Utils.saveWaypointsScreenshot(name: "\(testName!)_\(sequence!)")

        // Update the sequence number for the next run
        sequence! += 1
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

    /// Waits for the specified number of seconds.
    ///
    /// - Parameter element: Element to wait for.
    /// - Parameter timeout: The timeout period in seconds.
    static func waitFor(element: GREYMatcher, timeout seconds: Double = Constans.mediumWait) {
        _ = GREYCondition(name: "waiting for an update") {
            var error: NSError?
            EarlGrey.selectElement(with: element)
                .assert(grey_sufficientlyVisible(), error: &error)
            return error == nil
        }.wait(withTimeout: TimeInterval(seconds), pollInterval: Constans.smallPollInterval)
    }
}
