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

import Foundation
@testable import MSDKUI
import UIKit

class Utils { // swiftlint:disable:this convenience_type
    private static let moduleName = "MSDKUI"
    private static var bundleInstance: Bundle?

    static func getBundle() -> Bundle? {
        if bundleInstance == nil {
            bundleInstance = loadBundle()
        }
        return bundleInstance
    }

    // Loads the framework's Bundle instance and returns it
    private static func loadBundle() -> Bundle? {
        let podBundle = Bundle(for: Utils.self)
        if let bundleURL = podBundle.url(forResource: moduleName, withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            } else {
                assertionFailure("Could not load the bundle.")
            }
        } else {
            assertionFailure("Could not create a path to the bundle.")
        }
        return nil
    }
}

extension String {
    var frameworkLocalized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Utils.getBundle()!, value: "", comment: "")
    }
}

extension UIView {
    func subview(withAccessibilityIdentifier identifier: String) -> UIView? {
        for view in subviews {
            if view.accessibilityIdentifier == identifier {
                return view
            } else if let child = view.subview(withAccessibilityIdentifier: identifier) {
                return child
            }
        }
        return nil
    }
}
