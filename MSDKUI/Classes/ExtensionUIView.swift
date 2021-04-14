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

/// Extension for `UIView`.
public extension UIView {

    /// Loads the view from the nib file from the specified bundle and adds it as subview.
    ///
    /// - Parameter bundle: The bundle containing nib file.
    func loadFromNib(bundle: Bundle) {
        let nibName = String(describing: type(of: self))

        guard
            let views = bundle.loadNibNamed(nibName, owner: self),
            let firstView = views.first as? UIView else {
                return
        }

        firstView.translatesAutoresizingMaskIntoConstraints = true
        firstView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        firstView.frame = bounds

        addSubview(firstView)
    }
}

extension UIView {

    /// Adds constraints to the view so that the view has the same leading, top, trailing and
    /// bottom constraints as the parent view.
    ///
    /// - Parameter view: The view to be added.
    func addSubviewBindToEdges(_ view: UIView, inset: UIEdgeInsets = .zero) {
        // We use autolayout
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        // The view constraints for the edges
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                                   toItem: self, attribute: .leading, multiplier: 1,
                                                   constant: inset.left)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                               toItem: self, attribute: .top, multiplier: 1,
                                               constant: inset.top)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing,
                                                    relatedBy: .equal, toItem: self,
                                                    attribute: .trailing, multiplier: 1, constant: inset.right)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                                  toItem: self, attribute: .bottom, multiplier: 1,
                                                  constant: inset.bottom)

        // Add the constraints
        addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
    }

    /// Loads the view from the nib file contained in the MSDKUI bundle and adds it as subview.
    func loadFromNib() {
        if let bundle = Bundle.MSDKUI {
            loadFromNib(bundle: bundle)
        }
    }
}
