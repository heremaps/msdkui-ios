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

/// This protocol provides the methods which a `WaypointList` object
/// needs after user interactions to inform its delegate object.
@objc public protocol WaypointListDelegate: AnyObject {
    /// Tells the delegate that a `WaypointEntry` object is added.
    ///
    /// - Parameters:
    ///   - list: A `WaypointList` object informing the delegate about the action.
    ///   - entry: The `WaypointEntry` object added to list.
    ///   - index: The index of the entry object.
    @objc optional func waypointList(_ list: WaypointList, didAdd entry: WaypointEntry, at index: Int)

    /// Tells the delegate that a `WaypointEntry` object is selected.
    ///
    /// - Parameters:
    ///   - list: A `WaypointList` object informing the delegate about the action.
    ///   - entry: The `WaypointEntry` object selected.
    ///   - index: The index of the entry object.
    @objc optional func waypointList(_ list: WaypointList, didSelect entry: WaypointEntry, at index: Int)

    /// Tells the delegate that a `WaypointEntry` object is removed.
    ///
    /// - Parameters:
    ///   - list: A `WaypointList` object informing the delegate about the action.
    ///   - entry: The `WaypointEntry` object removed.
    ///   - index: The index of the entry object.
    @objc optional func waypointList(_ list: WaypointList, didRemove entry: WaypointEntry, at index: Int)

    /// Tells the delegate that two `WaypointEntry` objects are dragged.
    ///
    /// - Parameters:
    ///   - list: A `WaypointList` object informing the delegate about the action.
    ///   - from: The previous index of the dragged `WaypointEntry` object.
    ///   - to: The new index of its destination position.
    @objc optional func waypointList(_ list: WaypointList, didDragFrom from: Int, to: Int)

    /// Tells the delegate that a `WaypointEntry` object is updated.
    ///
    /// - Parameters:
    ///   - list: A `WaypointList` object informing the delegate about the action.
    ///   - entry: The `WaypointEntry` object updated.
    ///   - index: The index of the entry object.
    @objc optional func waypointList(_ list: WaypointList, didUpdate entry: WaypointEntry, at index: Int)
}

/// Displays a list of scrollable `WaypointItem` objects containing a `WaypointEntry`
/// and provides the `WaypointListDelegate` protocol to get notified in case of user interaction.
/// It allows users drag items via a drag button and delete items via a delete button. By default, a
/// newly created `WaypointList` object has two empty `WaypointEntry` objects. Here, empty means
/// the `WaypointEntry` object has no coordinates and has a default name. In order to launch a
/// `WaypointList` object with a list of entries, its `waypointEntries` property may be set like
/// this:
/// ````
/// waypointList.waypointEntries = [
///    WaypointEntry(...),
///    WaypointEntry(...),
///    WaypointEntry(...)
/// ]
/// ````
@IBDesignable open class WaypointList: UITableView {
    // MARK: - Properties

    /// A string representation of the list which is useful for debugging.
    override open var description: String {
        // Stringize the waypoint entries
        var stringizedEntries = ""
        for waypointEntry in waypointEntries {
            stringizedEntries += "\n" + waypointEntry.description + ","
        }

        // In order to fix the compiler error below the return clause separated into two parts:
        // "Expression was too complex to be solved in reasonable time; consider breaking up the
        // expression into distinct sub-expressions"
        // Note that the last ',' dropped from the stringizedEntries variable
        let description = "; minWaypointItems: \(minWaypointItems)"
            + "; maxWaypointItems: \(maxWaypointItems)"
            + "; maxVisibleItems: \(maxVisibleItems)"
            + "; entryCount: \(entryCount)"
            + "; entries: [ \(stringizedEntries.dropLast())\n]>"

        // The super's description minus the final '>' char and the description string
        return super.description.dropLast() + description
    }

    /// Creates and returns a natural content size based on the related view properties.
    override open var intrinsicContentSize: CGSize {
        if entryCount <= 0 {
            return CGSize.zero
        }

        let rowHeight = contentSize.height / CGFloat(entryCount)
        let minimumHeight = rowHeight * CGFloat(minWaypointItems)
        let maximumHeight = rowHeight * CGFloat(maxVisibleItems)

        var height = contentSize.height
        if height < minimumHeight {
            height = minimumHeight
        } else if height > maximumHeight {
            height = maximumHeight
        }

        return CGSize(width: bounds.width, height: height)
    }

    /// The minimum number of waypoints required for a route.
    /// When this value is set to a number lower than 2 or greater than entryCount, it will be reverted to its previous value.
    @IBInspectable public var minWaypointItems: Int = 2 {
        didSet {
            if minWaypointItems < 2
                || minWaypointItems > entryCount {
                minWaypointItems = oldValue
            }
        }
    }

    /// The maximum number of waypoints.
    /// When this value is set to a number lower than minWaypointItems or maxVisibleItems or entryCount, it will be reverted to its previous value.
    @IBInspectable public var maxWaypointItems: Int = 16 {
        didSet {
            if maxWaypointItems < minWaypointItems
                || maxWaypointItems < maxVisibleItems
                || maxWaypointItems < entryCount {
                maxWaypointItems = oldValue
            }
        }
    }

    /// The maximum number of waypoints this list should show at once.
    /// Any item above this number will be visible via scrolling.
    /// When this value is set to a number lower than the minWaypointItems or greater than maxWaypointItems, it will be reverted to its previous value.
    @IBInspectable public var maxVisibleItems: Int = 4 {
        didSet {
            if maxVisibleItems < minWaypointItems
                || maxVisibleItems > maxWaypointItems {
                maxVisibleItems = oldValue
            }
        }
    }

    /// Number of `WaypointEntry` objects in the list.
    public var entryCount: Int {
        waypointEntries.count
    }

    /// A Boolean value indicating if it is possible to calculate a route. True, if the entries are valid and
    /// the minimum number of entries is available, false otherwise.
    public var isRoutingPossible: Bool {
        entryCount >= minWaypointItems && !waypointEntries.contains { $0.isValid() == false }
    }

    /// Array of `WaypointEntry` objects found in the list.
    ///
    /// - Note: The array is initalized with minWaypointItems `WaypointEntry` objects having no coordinates.
    /// - Note: When set to an array with less entries than minWaypointItems, it will be reverted to the old value.
    /// - Note: When set to an array with more entries than maxWaypointItems, it will be reverted to the old value.
    public var waypointEntries: [WaypointEntry] = [WaypointEntry]() {
        didSet {
            if waypointEntries.count < minWaypointItems
                || waypointEntries.count > maxWaypointItems {
                waypointEntries = oldValue
                return
            }

            toggleRemoveButtons()

            // After any update, force a table update
            reloadData()

            // Flashing the scroll indicators help the user to scroll for more
            if entryCount > maxVisibleItems {
                flashScrollIndicators()
            }
        }
    }

    /// The array of all the `NMAWaypoint` objects.
    public var waypoints: [NMAWaypoint] {
        var waypoints: [NMAWaypoint] = []

        // One-by-one add the NMAWaypoint objects
        for waypointEntry in waypointEntries {
            waypoints.append(waypointEntry.waypoint)
        }

        return waypoints
    }

    /// The item color when selected. The default value is `UIColor.colorBackgroundDark`.
    public var itemFlashColor = UIColor.colorBackgroundDark {
        didSet { reloadData() }
    }

    /// The duration, in seconds, the item stays selected before running its action. The default value is 0.015.
    public var itemFlashDuration = TimeInterval(0.015) {
        didSet { reloadData() }
    }

    /// The item background color. The default value is `UIColor.colorBackgroundDark`.
    public var itemBackgroundColor = UIColor.colorBackgroundDark {
        didSet { reloadData() }
    }

    /// The item text color when address is available. The default value is `UIColor.colorForegroundLight`.
    public var itemTextColor = UIColor.colorForegroundLight {
        didSet { reloadData() }
    }

    /// The item placeholder color. The default value is `UIColor.colorHintLight`.
    public var itemPlaceholderColor = UIColor.colorHintLight {
        didSet { reloadData() }
    }

    /// The item text leading inset, which sets the spacing between the 'remove' button and the label.
    /// When the remove button is not displayed, increasing this inset may prove to be useful.
    /// The default value is 5.0.
    public var itemTextLeadingInset = CGFloat(5.0) {
        didSet { reloadData() }
    }

    /// The item 'remove' button's background color. The default value is `nil`.
    public var itemButtonBackgroundColor: UIColor? {
        didSet { reloadData() }
    }

    /// The item buttons' - remove and reorder - tint color. The default value is `UIColor.colorForegroundLight`.
    public var itemButtonsTintColor = UIColor.colorForegroundLight {
        didSet { reloadData() }
    }

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    public weak var listDelegate: WaypointListDelegate?

    /// The cell reuse identifier.
    private let reuseIdentifier = "WaypointListCell"

    // MARK: - Public

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    /// Removes all the existing entries and restores the default state.
    public func reset() {
        waypointEntries = makeDefaultWaypoints()
        waypointEntriesChanged(at: 0)

        // Make sure to scroll to the top: in the landscape orientation
        // waypointEntriesChanged(at:) may fail to scroll to the top!
        setContentOffset(CGPoint.zero, animated: false)
    }

    /// Reverses the order of the waypoint entries of this list. For example, if there are
    /// four entries, then 1, 2, 3, 4 will be reversed to 4, 3, 2, 1.
    public func reverse() {
        waypointEntries = waypointEntries.reversed()

        // Accessibility: if the voice over is active, we want to make an announcement
        // We are using UIAccessibilityScreenChangedNotification which resets the focus, so
        // we need to restore the focus. Note that UIAccessibilityAnnouncementNotification
        // does not work reliably!
        if UIAccessibility.isVoiceOverRunning {
            let focusedView = UIAccessibility.focusedElement(using: .notificationVoiceOver)
            UIAccessibility.post(notification: .screenChanged, argument: "msdkui_reversed_waypoints".localized)
            UIAccessibility.post(notification: .screenChanged, argument: focusedView) // Restore the focus
        }
    }

    /// Swaps the specified entries.
    public func swap(firstIndex: Int, secondIndex: Int) {
        let sourceEntry = waypointEntries[firstIndex]

        waypointEntries[firstIndex] = waypointEntries[secondIndex]
        waypointEntries[secondIndex] = sourceEntry
    }

    /// Inserts a new `WaypointEntry` object to the end of the list if it is valid.
    ///
    /// - Parameter entry: `WaypointEntry` object to be added to list.
    /// - Note: If the entry is not valid, nothing is done.
    /// - Note: If the list already has the maxWaypointItems, nothing is done.
    /// - Note: If the entry is valid, scrolls to the row.
    /// - Note: If there is a delegate, its `.waypointList(_:didAdd:at:)` method is called.
    public func addEntry(_ entry: WaypointEntry) {
        if entryCount >= maxWaypointItems {
            return
        }

        waypointEntries.append(entry)
        waypointEntriesChanged(at: entryCount - 1)

        // Has any delegate?
        listDelegate?.waypointList?(self, didAdd: entry, at: entryCount - 1)
    }

    /// Inserts a new `WaypointEntry` object at the specified position to the list if it
    /// is valid.
    ///
    /// - Parameter entry: `WaypointEntry` object to be added to list.
    /// - Parameter index: The position at which to insert the new entry. It must be a valid
    ///                    index within the list or equal to the list's entryCount property.
    /// - Note: If the entry is not valid, nothing is done.
    /// - Note: If the list already reached the maxWaypointItems, nothing is done.
    /// - Note: If the entry is valid, scrolls to the row.
    /// - Note: If there is a delegate, its `.waypointList(_:didAdd:at:)` method is called.
    public func insertEntry(_ entry: WaypointEntry, at index: Int) {
        if entryCount >= maxWaypointItems {
            return
        }

        if isIndexValid(at: index) || index == waypointEntries.count {
            waypointEntries.insert(entry, at: index)
            waypointEntriesChanged(at: index)

            // Has any delegate?
            listDelegate?.waypointList?(self, didAdd: entry, at: index)
        }
    }

    /// Updates the `WaypointEntry` object found at the specified position if it is valid.
    ///
    /// - Parameter entry: `WaypointEntry` object to be added to the list.
    /// - Parameter index: The position of the entry to update. `index` must be a valid
    ///                    index within the list.
    /// - Note: If the entry is not valid, nothing is done.
    /// - Note: If the entry is valid, scrolls to the row.
    /// - Note: If there is a delegate, its `.waypointList(_:didUpdate:at:)` method is called.
    public func updateEntry(_ entry: WaypointEntry, at index: Int) {
        if isIndexValid(at: index) {
            waypointEntries[index] = entry
            waypointEntriesChanged(at: index)

            // Has any delegate?
            listDelegate?.waypointList?(self, didUpdate: entry, at: index)
        }
    }

    /// Adds a `WaypointEntry` object with an empty `NMAWaypoint` object using default values (latitude
    /// and longititude are zero and a default name) at the end of the list.
    ///
    /// - Note: If there is a delegate, its `.waypointList(_:didAdd:at:)` method is called.
    public func addEmptyEntry() {
        addEntry(WaypointEntry(NMAWaypoint(), name: "msdkui_waypoint_select_location".localized))
    }

    /// Inserts a WaypointEntry` object with an empty `NMAWaypoint` object using default values (latitude
    /// and longititude are zero and a default name) at the specified position of the list.
    ///
    /// - Parameter index: The position at which to insert the new entry. It must be a valid index within
    ///                    the list or equal to the list's entryCount property.
    /// - Note: If the entry is not valid, nothing is done.
    /// - Note: If there is a delegate, its `.waypointList(_:didAdd:at:)` method is called.
    public func insertEmptyEntry(at index: Int) {
        insertEntry(WaypointEntry(NMAWaypoint(), name: "msdkui_waypoint_select_location".localized), at: index)
    }

    /// Removes and returns the entry at the specified position.
    ///
    /// - Parameter index: The position of the entry to remove. `index` must be a valid index
    ///                    within the list.
    /// - Returns: The entry at the specified index or nil if the index is not valid.
    /// - Note: If the list contains only the minWaypointItems, nothing is done.
    /// - Note: If there is a delegate, its `.waypointList(_:didRemove:at:)` method is called.
    /// - Note: If the entry is deleted, scrolls to the previous row.
    @discardableResult public func removeEntry(at index: Int) -> WaypointEntry? {
        if entryCount > minWaypointItems
            && isIndexValid(at: index) {
            beginUpdates()
            let entry = waypointEntries.remove(at: index)
            deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            endUpdates()

            waypointEntriesChanged(at: min(entryCount - 1, index))

            // Has any delegate?
            listDelegate?.waypointList?(self, didRemove: entry, at: index)

            return entry
        }

        return nil
    }

    // MARK: - Private

    /// Sets the accessibility contents.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.WaypointList"
    }

    /// Sets the accessibility contents for a cell.
    ///
    /// - Parameter cell: The cell to be updated.
    /// - Parameter row: The row of the passed cell.
    private func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
        // The reorder button needs this label to construct its label in a better way,
        // e.g. "Reorder, Button" vs "Reorder Waypoint 3, Button"
        cell.accessibilityIdentifier = "MSDKUI.WaypointList.cell_\(row)"

        if let view = cell.contentView.viewWithTag(1000) as? WaypointItem {
            view.tag = 0 // Done
            view.label.isAccessibilityElement = false
            view.removeButton.isAccessibilityElement = true

            // For accessibility, always use "From" and "To"
            switch view.type {
            case .startPoint:
                let waypointName = String(format: "msdkui_rp_from".localized, view.entry.name)
                cell.accessibilityLabel = waypointName
                view.removeButton.accessibilityLabel = "msdkui_remove".localized + ": " + waypointName

            case .endPoint:
                let waypointName = String(format: "msdkui_rp_to".localized, view.entry.name)
                cell.accessibilityLabel = waypointName
                view.removeButton.accessibilityLabel = "msdkui_remove".localized + ": " + waypointName

            case .waypoint:
                cell.accessibilityLabel = String(format: "msdkui_waypoint_in_list".localized, arguments: [row]) +
                    ": " + view.entry.name
                view.removeButton.accessibilityLabel = String(format: "msdkui_remove_waypoint_in_list".localized, arguments: [row]) +
                    ": " + view.entry.name
            }
        }

        // If there is a delegate, consider it a button and otherwise text
        if listDelegate == nil {
            cell.accessibilityTraits = .staticText
            cell.accessibilityHint = nil
        } else {
            cell.accessibilityTraits = .button
            cell.accessibilityHint = "msdkui_hint_waypoint".localized
        }
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Applies default style
        setUpStyle()

        // Tableview settings
        delegate = self
        dataSource = self

        // Sets the table row height out of the view used for the content view
        let view = WaypointItem()
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = view.bounds.size.height

        // Registers cells
        register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        setAccessibility()

        // Initiates waypointEntries to be a default of waypoints.
        waypointEntries = makeDefaultWaypoints()
    }

    /// Sets up default style.
    private func setUpStyle() {
        bounces = true
        allowsMultipleSelection = false
        allowsSelection = true
        allowsSelectionDuringEditing = true
        isScrollEnabled = true
        isEditing = true
        canCancelContentTouches = true
        alwaysBounceVertical = false
        separatorStyle = .singleLine
        separatorInset = .zero
        backgroundColor = .colorBackgroundDark
        separatorColor = .colorDividerLight
    }

    /// Checks the given index. To be valid, it must be within the [0..Count of entries)
    /// range.
    ///
    /// - Parameter index: The position within the list to check.
    /// - Returns: True, if the index is valid and false otherwise.
    private func isIndexValid(at index: Int) -> Bool {
        (index >= 0 && index < waypointEntries.count)
    }

    /// CreateS initial list of empty entries containing as many entries as the minimum number of waypoints
    private func makeDefaultWaypoints() -> [WaypointEntry] {
        [WaypointEntry](
            cloneValue: WaypointEntry(
                NMAWaypoint(),
                name: "msdkui_waypoint_select_location".localized
            ),
            count: minWaypointItems
        )
    }

    /// Invalidates the view’s intrinsic content size.
    /// Triggers a layout update for the superview.
    private func updateContentSize() {
        invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
    }

    /// Shows remove buttons when there are more than minNumberOfWaypoints
    /// otherwise hide them
    private func toggleRemoveButtons() {
        let isRemovable = entryCount > minWaypointItems
        for entry in waypointEntries {
            entry.removable = isRemovable
        }
    }

    /// Shows/Hides remove waypoint buttons, updates layout and scrolls to indexPath
    private func waypointEntriesChanged(at index: Int) {
        toggleRemoveButtons()
        updateContentSize()
        scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
    }
}

// MARK: - WaypointItemDelegate

extension WaypointList: WaypointItemDelegate {
    func removeItem(_ item: WaypointItem) {
        // If we get the index path, remove the cell
        for cell in visibleCells where cell.contentView == item.superview {
            if let indexPath = indexPath(for: cell) {
                tableView(self, commit: .delete, forRowAt: indexPath)

                // done
                return
            }
        }
    }

    /// Note that flashes the selected cell has a visual feedback.
    func selectItem(_ item: WaypointItem) {
        // If we get the index path, select the cell
        for cell in visibleCells where cell.contentView == item.superview {
            if let indexPath = indexPath(for: cell) {
                // Note that this method will not call the delegate methods (-tableView:willSelectRowAtIndexPath:
                // or -tableView:didSelectRowAtIndexPath:), nor will it send out a notification
                selectRow(at: indexPath, animated: true, scrollPosition: .none)

                // Flash the cell before informing the delegate
                UIView.animate(withDuration: itemFlashDuration, animations: {
                    cell.backgroundColor = self.itemFlashColor
                }, completion: { _ in
                    cell.backgroundColor = self.itemBackgroundColor
                    self.listDelegate?.waypointList?(self, didSelect: self.waypointEntries[indexPath.row], at: indexPath.row)
                })

                return
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension WaypointList: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entryCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let entry = waypointEntries[indexPath.row]

        // Removes the existing content subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Cell's settings
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.editingAccessoryType = .none
        cell.backgroundColor = itemBackgroundColor

        // Creates the content view subview
        let view = WaypointItem()
        view.backgroundColor = itemBackgroundColor
        view.label.textColor = entry.isValid() ? itemTextColor : itemPlaceholderColor
        view.labelLeadingConstraint.constant = itemTextLeadingInset
        view.removeButton.tintColor = itemButtonsTintColor
        view.removeButton.backgroundColor = itemButtonBackgroundColor
        view.delegate = self
        view.tag = 1000
        view.entry = entry

        // Sets the view type
        switch indexPath.row {
        case 0:
            view.type = .startPoint

        case entryCount - 1:
            view.type = .endPoint

        default:
            view.type = .waypoint
        }

        // Finally adds the view to the content view
        cell.contentView.addSubviewBindToEdges(view)

        setAccessibility(cell, indexPath.row)

        return cell
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Is there any actual update?
        if sourceIndexPath.row != destinationIndexPath.row {
            // Yes, move the row to the new index
            waypointEntries.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)

            // Has any delegate?
            listDelegate?.waypointList?(self, didDragFrom: sourceIndexPath.row, to: destinationIndexPath.row)

            // Accessibility: after the dragging is completed, we want to focus on the
            // on the row dragged to the new row. Note that by default, the source row
            // is focused
            if UIAccessibility.isVoiceOverRunning {
                let focusedView = cellForRow(at: destinationIndexPath)
                UIAccessibility.post(notification: .screenChanged, argument: focusedView)
            }
        }
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Having a drag button depends on the entry at hand: is it draggable?
        return waypointEntries[indexPath.row].draggable
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // No delete button when in the editing mode or row dragged from the right
        return .none
    }
}

// MARK: - UITableViewDelegate

extension WaypointList: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Deleting a row?
        if editingStyle == .delete {
            let cell = cellForRow(at: indexPath)

            UIView.animate(withDuration: itemFlashDuration, animations: {
                cell?.backgroundColor = self.itemFlashColor
            }, completion: { _ in
                cell?.backgroundColor = self.itemBackgroundColor
                self.removeEntry(at: indexPath.row)
            })
        }
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    public func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        // Can the row move to the proposed row? i.e. is the proposed row draggable?
        return waypointEntries[proposedDestinationIndexPath.row].draggable == true ?
            proposedDestinationIndexPath : sourceIndexPath
    }
}
