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

/// Matches element with text and returns the matched element
///
/// - Parameter text: text to be matched on the view
func viewContainingText(text: String) -> GREYMatcher {
    return GREYElementMatcherBlock(matchesBlock: {
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
