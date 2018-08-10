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

import UIKit

extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    /// Taps an UIAlertController button, triggering its action.
    ///
    /// - Parameter index: The index of the button to be tapped.
    func tapButton(at index: Int) {
        guard
            let block = actions[index].value(forKey: "handler"),
            case let blockPointer = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque()),
            case let handler = unsafeBitCast(blockPointer, to: AlertHandler.self) else {
                return
        }

        handler(actions[index])
    }
}
