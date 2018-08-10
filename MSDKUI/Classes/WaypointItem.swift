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

/// This protocol provides the interaction which a `WaypointItem`
/// object needs with its parent table object.
@objc protocol WaypointItemDelegate: AnyObject {
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
    /// Defines type of the waypoint.
    enum ItemType {

        /// Route start point.
        case startPoint

        /// Route destination.
        case endPoint

        /// Route waypoint.
        case waypoint
    }

    /// The label of the item.
    @IBOutlet private(set) var label: UILabel!

    /// The callback which is fired when the remove button is tapped.
    var onRemoveClicked: ((WaypointEntry) -> Void)?

    /// The callback which is fired when dragging the item is started.
    var onDragStarted: ((WaypointEntry) -> Void)?

    /// The entry object assigned to this item object.
    var entry: WaypointEntry! {
        didSet {
            // Reflect the update
            removeButton.isHidden = !(entry!.removable)
            label.text = name
        }
    }

    /// Waypoint item type.
    /// Default value is '.waypoint'.
    var type: ItemType = .waypoint {
        didSet {
            // Update only when entry is already set
            guard entry != nil else {
                return
            }

            label.text = name
        }
    }

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

    /// The remove button for removing the item.
    ///
    /// - Important: This button has no assigned action and works through the hit test.
    @IBOutlet private(set) var removeButton: UIButton!

    /// This constraint helps us to set a leading inset.
    @IBOutlet private(set) var labelLeadingConstraint: NSLayoutConstraint!

    /// This view holds the related XIB file contents.
    @IBOutlet private(set) var view: UIView!

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    weak var delegate: WaypointItemDelegate?

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
            // Note that:
            //   - For all the operations, we should be careful to
            //     avoid multiple handling!
            //   - We support both UITableView and stand-alone use cases
            // Note that we inform the remove and select actions in two ways:
            //   1 - If there are callbacks set, we call them
            //   2 - If there is a delegate, we inform it

            let touchCount = event.allTouches?.count ?? 0
            if let button = hitView as? UIButton {
                // Remove button
                if touchCount == 1 {
                    onRemoveClicked?(entry!)
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

    /// Flashes item color and then executes the completion code.
    func flash(completion: @escaping () -> Swift.Void) {
        UIView.animate(withDuration: TimeInterval(Styles.shared.waypointListFlashDurationSeconds),
                       animations: {
                           self.view.backgroundColor = Styles.shared.waypointListFlashColor
                       },
                       completion: { _ in
                           self.view.backgroundColor = Styles.shared.waypointListCellBackgroundColor
                           completion()
        })
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        view.backgroundColor = Styles.shared.waypointListCellBackgroundColor

        label.textColor = Styles.shared.waypointListCellTextColor
        labelLeadingConstraint.constant = Styles.shared.waypointListCellLabelLeadingInset

        removeButton.backgroundColor = Styles.shared.waypointListCellButtonBackgroundColor
        removeButton.tintColor = Styles.shared.waypointListCellButtonTintColor
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Load the view nib file
        let nibFile = UINib(nibName: String(describing: WaypointItem.self), bundle: .MSDKUI)
        view = nibFile.instantiate(withOwner: self, options: nil)[0] as! UIView

        // Use the view's bounds
        bounds = view.bounds

        // Set the button image: it should be in template rendering mode
        let image = UIImage(named: "Icon.remove", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        removeButton.setImage(image, for: .normal)

        updateStyle()
        addSubviewBindToEdges(view)
        setAccessibility()
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        removeButton.accessibilityLabel = "msdkui_remove_waypoint".localized
        removeButton.accessibilityHint = nil
        removeButton.accessibilityIdentifier = "MSDKUI.WaypointItem.remove"

        label.accessibilityIdentifier = "MSDKUI.WaypointItem.label"
    }
}

// MARK: WaypointListCellDelegate

extension WaypointItem: WaypointListCellDelegate {
    func dragStarted(_: WaypointListCell) {
        onDragStarted?(entry!)
    }
}
