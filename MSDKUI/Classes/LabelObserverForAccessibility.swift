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

/// This class lets a view to monitor a `UILabel` and update its accessibility label
/// whenever the label's `text` is updated. Note that the label is ignored for accessibility
/// and the view which is usually the one containing the label takes its place.
class LabelObserverForAccessibility: NSObject {
    /// The label being observed.
    var label: UILabel

    /// The view which will get the label's text as its `accessibilityLabel`.
    var view: UIView

    private var observation: NSKeyValueObservation?

    /// The init method accepts a `UILabel` object and observe its `text` property to update
    /// the view's `accessibilityLabel` property continuously.
    ///
    /// - Parameter label: The `UILabel` object to be observed.
    /// - Parameter view: The `UIView` object which will get the label `text` as its `accessibilityLabel` property.
    init(_ label: UILabel, view: UIView) {
        self.label = label
        self.view = view

        // Ignore the label for accessibility
        self.view.isAccessibilityElement = true
        self.label.isAccessibilityElement = false

        super.init()

        // Whenever the label text is updated, we should be informed
        observation = observe(\.label.text, options: [.new]) { [weak self] _, change in
            // Updates the view's `accessibilityLabel` whenever the label `text` is updated.
            self?.view.accessibilityLabel = change.newValue as? String
        }
    }
}
