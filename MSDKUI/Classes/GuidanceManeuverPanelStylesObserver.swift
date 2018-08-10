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

/// This class lets a `GuidanceManeuverPanel` object to monitor style updates.
class GuidanceManeuverPanelStylesObserver: NSObject {
    /// The `GuidanceManeuverPanel` object wanting to monitor the style updates.
    private var panel: GuidanceManeuverPanel

    private var observations = [NSKeyValueObservation]()

    /// The init method accepts a `GuidanceManeuverPanel` object and observe the related `Styles` properties to update
    /// its styling continuously.
    ///
    /// - Parameter panel: The `GuidanceManeuverPanel` object which will receive the style updates.
    init(_ panel: GuidanceManeuverPanel) {
        self.panel = panel

        super.init()

        // Whenever the GuidanceManeuverPanel related styles are updated, we should be informed
        observations = [
            panelStyleUpdate(observedNew: \.guidanceManeuverPanelBackgroundColor),
            panelStyleUpdate(observedNew: \.guidanceManeuverIconAndTextColor)
        ]
    }

    /// Updates the panel's styling whenever the related style properties are updated.
    private func panelStyleUpdate<Value>(observedNew keyPath: KeyPath<Styles, Value>) -> NSKeyValueObservation {
        return Styles.shared.observe(keyPath, options: [.new]) { [weak self] _, _ in
            self?.panel.updateStyle()
        }
    }
}
