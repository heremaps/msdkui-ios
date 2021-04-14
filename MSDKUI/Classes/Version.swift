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

import Foundation

/// This class is responsible for providing all the version data.
public class Version: NSObject {

    /// Returns the MSDKUI framework version string. Note that it is set by the podspec file.
    ///
    /// - Returns: The version string or a question mark if it is not possible to retrieve the version string.
    public static func getString() -> String {
        guard
            let plistURL = Bundle.MSDKUI?.url(forResource: "Info", withExtension: "plist"),
            let plistData = try? Data(contentsOf: plistURL),
            let result = ((try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]) as [String: Any]??),
            let version = result?["CFBundleShortVersionString"] as? String else { return "?" }

        return version
    }
}
