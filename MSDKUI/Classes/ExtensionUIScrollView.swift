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

/// Provides additional methods to the UIScrollView class.
public extension UIScrollView {
    /// This method simplifies adding views into the scroll view. Each subview will have
    /// the scroll view width and vertically chained in the given order via a stackview.
    ///
    /// For more information, see [Working with Scroll Views](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html)
    func addSubviewsWithVerticalScrolling(_ views: [UIView]) {
        let stackView = UIStackView()

        // Stackview settings
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.axis = .vertical

        // One-by-one add the views to the stackview
        for view in views {
            stackView.addArrangedSubview(view)
        }

        addSubviewBindToEdges(stackView)

        // We are after vertical scrolling
        let widthConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.width, relatedBy: .equal,
                                                 toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1,
                                                 constant: 0)
        addConstraint(widthConstraint)
    }
}
