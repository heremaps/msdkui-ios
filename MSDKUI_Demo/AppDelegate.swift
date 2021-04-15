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

import MSDKUI
import NMAKit
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties

    var window: UIWindow?

    // MARK: - Public

    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Sets the NMA credentials, otherwise aborts execution
        guard NMAApplicationContext.setAppId(NMACredentials.appID, appCode: NMACredentials.appCode, licenseKey: NMACredentials.licenseKey) == .none else {
            return false
        }

        // We want to have custom navigation bars to be inline with the default components styling
        UINavigationBar.appearance().barTintColor = UIColor.colorBackgroundDark
        UINavigationBar.appearance().tintColor = UIColor.colorForegroundLight
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.colorForegroundLight]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()

        // We want to update the status bar color to be inline with the default components styling
        if #available(iOS 13.0, *) {} else {
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.colorBackgroundDark
        }

        // Set up map matching
        NMAPositioningManager.sharedInstance().mapMatchingEnabled = true

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Start the positioning manager if not started already
        if !NMAPositioningManager.sharedInstance().isActive {
            NMAPositioningManager.sharedInstance().startPositioning()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Stop the positioning manager
        NMAPositioningManager.sharedInstance().stopPositioning()
    }
}
