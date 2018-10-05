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

import NMAKit

public extension NMAManeuver { // swiftlint:disable:this missing_docs

    /// Gets the current street. In case the current street is not found, the current signpost is used.
    ///
    /// - Returns: The current street name or nil when it is not available.
    @objc func getCurrentStreet() -> String? {
        return GuidanceManeuverUtil.getCurrentStreet(from: self)
    }

    /// Gets the next street name. In case the next street is not found, the next maneuvers
    /// coming after are checked and when the next street is still not found, as a fallback,
    /// the maneuvers in the route are checked.
    ///
    /// - Parameter route: The route whose maneuvers will be checked as a fallback or nil when is not available.
    /// - Returns: The next street name or nil when it is not available.
    @objc func getNextStreet(fallback route: NMARoute?) -> String? {
        var nextStreet = GuidanceManeuverUtil.combineStrings(maneuver: self,
                                                             name: nextRoadName as String?,
                                                             number: nextRoadNumber as String?)

        if nextStreet.hasContent == false {
            nextStreet = GuidanceManeuverUtil.getNextStreet(from: self, fallback: route)
        }

        if nextStreet.hasContent == false {
            nextStreet = GuidanceManeuverUtil.combineStrings(maneuver: self,
                                                             name: roadName as String?,
                                                             number: roadNumber as String?)
        }

        if nextStreet.hasContent == false {
            if let signpost = signpost, signpost.exitText.hasContent == true {
                nextStreet = signpost.exitText
            }
        }

        return nextStreet
    }

    /// Gets the signpost exit number.
    ///
    /// - Returns: The exit number string from the signpost or nil when it is not available.
    @objc func getSignpostExitNumber() -> String? {
        if let signpost = signpost, signpost.exitNumber.hasContent == true {
            return String(format: "msdkui_maneuver_exit".localized, signpost.exitNumber!)
        }

        return nil
    }

    /// Returns a string from the maneuver's signpost.
    ///
    /// - Returns: The string from the maneuver signpost or nil when it is not available.
    @objc func getStringFromSignpost() -> String? {
        if let signpost = signpost {
            if signpost.exitDirections.isEmpty == false && signpost.exitDirections[0].text.hasContent == true {
                return signpost.exitDirections[0].text
            }

            // Try the signpost exit text
            if signpost.exitText.hasContent == true {
                return signpost.exitText
            }
        }

        return nil
    }

    /// Gets the internal resource icon file name.
    ///
    /// - Returns: The icon name.
    @objc func getIconFileName() -> String {
        return "maneuver_icon_\(icon.rawValue)"
    }
}
