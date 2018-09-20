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
import NMAKit

/// This protocol provides the callback methods which a `ManeuverDescriptionList` object
/// calls after user interactions to inform the delegate object.
@objc public protocol ManeuverDescriptionListDelegate: AnyObject {
    /// Tells the delegate that the specified row and maneuver is selected.
    ///
    /// - Parameter list: A `ManeuverDescriptionList` object informing the delegate about the new row selection.
    /// - Parameter maneuver: The maneuver associated with the row.
    /// - Parameter index: The index of the newly selected row.
    func maneuverDescriptionList(_ list: ManeuverDescriptionList, didSelect maneuver: NMAManeuver, at index: Int)

    /// Tells the delegate the maneuver description list is about to present a maneuver description item.
    ///
    /// A maneuver description list sents this message to its delegate just before it presents a maneuver description item,
    /// thereby permitting the delegate to customize the maneuver description item object before it is displayed. This method gives
    /// the delegate a chance to override state-based properties, such as background and text colors.
    ///
    /// - Parameters:
    ///   - list: The maneuver description list presenting the maneuver description item.
    ///   - item: The maneuver description item to be presented.
    @objc optional func maneuverDescriptionList(_ list: ManeuverDescriptionList, willDisplay item: ManeuverDescriptionItem)
}

/// A panel to display all the maneuvers of a route based on the visible sections setting. Note that
/// in case there is no maneuver, it shows a warning via `noManeuverFoundLabel` property.
///
/// - SeeAlso: ManeuverDescriptionItem
@IBDesignable open class ManeuverDescriptionList: UITableView {
    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    public weak var listDelegate: ManeuverDescriptionListDelegate?

    /// The underlying route object. It provides the data to be displayed.
    public var route: NMARoute? {
        didSet {
            if let maneuvers = route?.maneuvers {
                self.maneuvers = maneuvers
                reloadData()

                // Flashing the scroll indicators help the user to scroll for more
                flashScrollIndicators()
            }
        }
    }

    /// Number of `ManeuverDescriptionItem` objects in the list.
    public var entryCount: Int {
        return maneuvers.count
    }

    /// Sets the visibility of `ManeuverDescriptionItem` sections.
    ///
    /// - Important: Initially all the sections are visible.
    public var visibleSections: ManeuverDescriptionItem.Section = .all {
        didSet {
            reloadData()
        }
    }

    /// The label used to display a warning when no maneuver is found.
    ///
    /// - Important: When not set, a label with default settings is used.
    public var noManeuverFoundLabel: UILabel! {
        didSet {
            noManeuverFoundLabel.text = "msdkui_no_maneuver_found".localized
        }
    }

    var maneuvers: [NMAManeuver] = []

    /// The cell reuse identifier.
    var reuseIdentifier = String(describing: ManeuverDescriptionItem.self)

    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    /// Sets the accessibility stuff.
    func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.ManeuverDescriptionList"
    }

    /// Sets the accessibility stuff for the row.
    ///
    /// - Parameter cell: The cell to be updated.
    /// - Parameter row: The row of the passed cell.
    func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
        let view = cell.contentView.viewWithTag(1000) as! ManeuverDescriptionItem
        view.tag = 0 // Done

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = String(format: "msdkui_maneuver_in_list".localized, arguments: [row + 1, entryCount])
        cell.accessibilityHint = view.accessibilityHint
        cell.accessibilityIdentifier = String(format: "MSDKUI.ManeuverDescriptionList.cell_%d", arguments: [row + 1])

        // If there is a delegate, consider it a button and otherwise text
        cell.accessibilityTraits |= (listDelegate == nil) ? UIAccessibilityTraitStaticText : UIAccessibilityTraitButton
    }

    /// Sets up the items array.
    private func setUp() {
        setUpTableView()

        // Set the table row height out of the view used for the content view
        let view = ManeuverDescriptionItem()
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = view.bounds.size.height

        // Register the nib file for the custom cell
        register(UITableViewCell.classForCoder(), forCellReuseIdentifier: reuseIdentifier)

        setAccessibility()
    }

    /// Sets up the maneuver table view.
    private func setUpTableView() {
        bounces = true
        allowsMultipleSelection = false
        allowsSelection = true
        isScrollEnabled = true
        isEditing = false
        dataSource = self
        delegate = self
        alwaysBounceVertical = false
        separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        backgroundColor = .colorForegroundLight
        separatorColor = .colorDivider
    }
}

// MARK: UITableViewDataSource

extension ManeuverDescriptionList: UITableViewDataSource {
    public func numberOfSections(in _: UITableView) -> Int {
        // Is there any maneuver? No maneuver means no section
        let sections = entryCount > 0 ? 1 : 0

        // Has the table a section?
        if sections == 1 {
            backgroundView = nil
            separatorStyle = .singleLine
        } else {
            // Is the label available?
            if noManeuverFoundLabel == nil {
                // Note that the label has the clear background color
                noManeuverFoundLabel = UILabel()
                noManeuverFoundLabel.font = UIFont.systemFont(ofSize: 20)
                noManeuverFoundLabel.textColor = UIColor.red
                noManeuverFoundLabel.textAlignment = .center
            }

            separatorStyle = .none
            backgroundView = noManeuverFoundLabel
        }

        return sections
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return entryCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Remove the existing content subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Cell settings
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.editingAccessoryType = .none

        // Create the content view subview
        let view = ManeuverDescriptionItem()
        view.visibleSections = visibleSections
        view.tag = 1000
        view.setManeuver(maneuvers: maneuvers, position: indexPath.row)

        // Tells the delegate the view is about to be displayed
        listDelegate?.maneuverDescriptionList?(self, willDisplay: view)

        // Finally add the view to the content view
        cell.contentView.addSubviewBindToEdges(view)

        setAccessibility(cell, indexPath.row)

        return cell
    }

    public func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCellEditingStyle {
        // No delete button when in the editing mode or row dragged from the right
        return .none
    }
}

// MARK: UITableViewDelegate

extension ManeuverDescriptionList: UITableViewDelegate {
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        listDelegate?.maneuverDescriptionList(self, didSelect: maneuvers[indexPath.row], at: indexPath.row)
    }
}
