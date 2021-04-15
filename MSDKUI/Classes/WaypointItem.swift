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

/// This protocol provides the interaction which a `WaypointItem`
/// object needs with its parent table object.
protocol WaypointItemDelegate: AnyObject {

    /// Removes the item.
    ///
    /// - Parameter item: The object to be removed.
    func removeItem(_ item: WaypointItem)

    /// Selects the item.
    ///
    /// - Parameter item: The object to be selected.
    func selectItem(_ item: WaypointItem)
}

/// Represents a row in a `WaypointList`.
@IBDesignable class WaypointItem: UIView {

    // MARK: - Types

    /// Defines type of the waypoint.
    enum ItemType {

        /// Route's start point.
        case startPoint

        /// Route's destination.
        case endPoint

        /// Route's waypoint.
        case waypoint
    }

    // MARK: - Properties

    /// The label of the item.
    @IBOutlet private(set) var label: UILabel!

    /// The remove button for removing the item.
    ///
    /// - Note: This button has no assigned action and works through the hit test.
    @IBOutlet private(set) var removeButton: UIButton!

    /// This constraint helps us to set a leading inset.
    @IBOutlet private(set) var labelLeadingConstraint: NSLayoutConstraint!

    /// The entry object assigned to this item object.
    var entry: WaypointEntry! {
        didSet {
            // Reflects the update
            removeButton.isHidden = !(entry?.removable ?? false)
            label.text = name
        }
    }

    /// Waypoint's item type.
    /// The default value is '.waypoint'.
    var type: ItemType = .waypoint {
        didSet {
            // Updates only when entry is already set
            guard entry != nil else {
                return
            }

            label.text = name
        }
    }

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    weak var delegate: WaypointItemDelegate?

    /// Name of the waypoint displayed in UI
    private var name: String {
        if entry.isValid() {
            return entry.name
        } else {
            switch type {
            case .startPoint:
                return String(format: "msdkui_rp_from".localized, entry.name)

            case .endPoint:
                return String(format: "msdkui_rp_to".localized, entry.name)

            case .waypoint:
                return entry.name
            }
        }
    }

    // MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Are there both a view and an event?
        if let hitView = super.hitTest(point, with: event), let event = event {
            // If there is no touch, ignore the event
            // If the hit view is a UIButton remove the item: there is only one UIButton!
            // Else, select the item
            // Note:
            //   - For all the operations, we should be careful to
            //     avoid multiple handling!
            //   - We support both UITableView and stand-alone use cases
            // Note that we inform the remove and select actions via the delegate object
            let touchCount = event.allTouches?.count ?? 0
            if let button = hitView as? UIButton {
                // Removes button
                if touchCount == 1 {
                    delegate?.removeItem(self)
                    return button
                }
            } else {
                // Label
                if touchCount == 1 {
                    delegate?.selectItem(self)
                    return hitView
                }
            }
        }

        return nil
    }

    // MARK: - Private

    /// Initialises the contents of this view.
    private func setUp() {
        // Instantiates view
        if
            case let nibInstance = UINib(nibName: String(describing: WaypointItem.self), bundle: .MSDKUI).instantiate(withOwner: self),
            let view = nibInstance.first as? UIView {

            // Uses the view's bounds
            bounds = view.bounds

            // Adds the view to the hierarchy
            addSubviewBindToEdges(view)
        }

        // Sets the button image: it should be in template rendering mode
        let image = UIImage(named: "Icon.remove", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        removeButton.setImage(image, for: .normal)

        setAccessibility()
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        removeButton.accessibilityLabel = "msdkui_remove_waypoint".localized
        removeButton.accessibilityHint = nil
        removeButton.accessibilityIdentifier = "MSDKUI.WaypointItem.removeButton"

        label.accessibilityIdentifier = "MSDKUI.WaypointItem.label"
    }
}
