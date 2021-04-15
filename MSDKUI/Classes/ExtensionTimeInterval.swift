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

extension TimeInterval {

    // Creates a string out of the self.
    var stringize: String {
        // There are 24 * 60 * 60 = 86400 seconds in a day
        // There are 60 * 60 = 3600 seconds in an hour
        // There are 60 seconds in a minute
        // Note that the value is copied first and decreased
        // as we go!
        // We want to show seconds as a last resort, so .toNearestOrAwayFromZero
        // is used for minute calculation. .toNearestOrAwayFromZero documentation:
        // "Round to the closest allowed value; if two values are equally
        //  close, the one with greater magnitude is chosen."
        // See: https://developer.apple.com/documentation/swift/floatingpointroundingrule
        //
        var duration = self
        let days = (duration / 86400).rounded(.towardZero)
        duration -= days * 86400
        let hours = (duration / 3600).rounded(.towardZero)
        duration -= hours * 3600
        let minutes = (duration / 60).rounded(.toNearestOrAwayFromZero)
        let seconds = duration - (minutes * 60)

        switch (days, hours, minutes, seconds) {
        case let (day, hour, _, _) where day > 0 && hour > 0:
            return String(format: "msdkui_days_hours".localized, Int(day), Int(hour))

        case let (day, _, _, _) where day > 0:
            return String(format: "msdkui_days".localized, Int(day))

        case let (_, hour, minute, _) where hour > 0 && minute > 0:
            return String(format: "msdkui_hours_minutes".localized, Int(hour), Int(minute))

        case let (_, hour, _, _) where hour > 0:
            return String(format: "msdkui_hours".localized, Int(hour))

        case let (_, _, minute, _) where minute > 0:
            return String(format: "msdkui_minutes".localized, Int(minute))

        default:
            return String(format: "msdkui_seconds".localized, Int(seconds))
        }
    }
}
