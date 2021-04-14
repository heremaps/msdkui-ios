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

import UIKit

extension UIStoryboard {
    /// All the storyboards of the Demo application.
    enum StoryboardName: String {
        case about = "About"
        case driveNavigation = "DriveNavigation"
        case main = "Main"
        case routePlanner = "RoutePlanner"
    }

    /// Instantiate View Controllers from the given storyboard. It expects the View Controller
    /// identifier to match the name of the View Controller class.
    ///
    /// - Parameter storyboardName: The storyboard to instantiate the view controller.
    /// - Returns: The View Controller.
    static func instantiateFromStoryboard<T: UIViewController>(named storyboardName: StoryboardName) -> T {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        let identifier = String(describing: T.self)

        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Failed to instantiate \(identifier) from Main Storyboard")
        }

        return controller
    }
}
