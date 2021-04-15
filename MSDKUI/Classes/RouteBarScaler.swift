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
import NMAKit

/// Handles the scaling necessary for the route bars on the `RouteDescriptionItem` objects.
class RouteBarScaler {

    // MARK: - Properties

    /// The parent `RouteDescriptionList` object.
    private let parent: RouteDescriptionList!

    /// Sets the max value for scaling purposes.
    ///
    /// - Important: Depending on the sort type, it is either the longest duration
    ///              or length.
    private var maxValue = Double(0)

    // MARK: - Public

    /// Creates a new `RouteBarScaler` object with the specified parent.
    ///
    /// - Parameter parent: The parent `RouteDescriptionList` object.
    init(parent: RouteDescriptionList) {
        self.parent = parent
    }

    /// Prepares the scaler by finding the max value out of the parent's routes.
    func refresh() {
        maxValue = 0

        // Is there any route?
        if parent.routes.isEmpty == false {
            // Find the max value for scaling the bar based on the sort type
            switch parent.sortType {
            case .length:
                maxValue = parent.routes.map { Double($0.length) }.max() ?? 0

            case .duration:
                maxValue = parent.routes.map { $0.durationWithTraffic() }.max() ?? 0
            }
        }
    }

    /// Sets the scaling for the specified cell.
    ///
    /// - Parameter item: The item which has its scaling value to be set.
    func setScale(for item: RouteDescriptionItem) {
        // If there is no max value, ignore the scaling request
        if maxValue == 0 {
            item.scale = 1
        } else {
            // Sets the scale based on the sort type
            switch parent.sortType {
            case .length:
                item.scale = Double(item.route?.length ?? 0) / maxValue

            case .duration:
                item.scale = Double(item.route?.durationWithTraffic() ?? 0) / maxValue
            }
        }
    }
}
