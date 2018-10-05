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

/// This protocol provides the interaction which a `WaypointListCell`
/// object needs with its parent table object.
@objc protocol WaypointListCellDelegate: AnyObject {

    /// Tells the delegate that dragging has started.
    ///
    /// - Parameter cell: A `WaypointListCell` object informing the delegate about the action.
    func dragStarted(_ cell: WaypointListCell)
}

/// This class let us to keep the `WaypointItem` as a `UIView` while enjoying
/// the UITableView drag support instead of custom drag support.
class WaypointListCell: UITableViewCell {

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    weak var delegate: WaypointListCellDelegate?

    /// The reorder image view tint color.
    var reorderImageViewTintColor: UIColor?

    /// The flag showing the drag status.
    private var isDragging = false

    /// This function let us to get the drag start notification.
    override func layoutSubviews() {
        super.layoutSubviews()

        // We are taking advantage of the fact that Apple reduces the alpha before dragging
        // restores it when dragging is done
        if alpha < 1.0 && !isDragging {
            isDragging = true

            // Has any delegate?
            delegate?.dragStarted(self)
        } else if alpha == 1.0 && isDragging {
            isDragging = false
        }
    }
}
