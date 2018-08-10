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

/// Provides additional methods to the UIView class.
public extension UIView {
    /// Adds constraints to the view so that the view has the same leading, top, trailing and
    /// bottom constraints as the parent view.
    ///
    /// - Parameter view: The view to be added.
    func addSubviewBindToEdges(_ view: UIView) {
        // We use autolayout
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        // The view constraints for the edges
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.leading, relatedBy: .equal,
                                                   toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1,
                                                   constant: 0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: .equal,
                                               toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1,
                                               constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.trailing,
                                                    relatedBy: .equal, toItem: self,
                                                    attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: .equal,
                                                  toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1,
                                                  constant: 0)

        // Add the constraints
        addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
    }

    /// Sets the `translatesAutoresizingMaskIntoConstraints` properties of all the subviews
    /// to `false`.
    func useAutoLayout() {
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
