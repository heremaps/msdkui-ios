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

/// The delegate of a `ManeuverTableView` object must adopt the `ManeuverTableViewDelegate`
/// protocol. This protocol lets the `ManeuverTableView` object to inform its `delegate` about
/// updates occurred.
@objc public protocol ManeuverTableViewDelegate: AnyObject {

    /// Tells the delegate that the specified row and maneuver is selected.
    ///
    /// - Parameter tableView: A `ManeuverTableView` object informing the delegate about the new row selection.
    /// - Parameter maneuver: The maneuver associated with the row.
    /// - Parameter index: The index of the newly selected row.
    func maneuverTableView(_ tableView: ManeuverTableView, didSelect maneuver: NMAManeuver, at index: Int)

    /// Tells the delegate the maneuver table view is about to present a maneuver item view.
    ///
    /// A maneuver table view sends this message to its delegate just before it presents a maneuver item view,
    /// thereby permitting the delegate to customize the maneuver item view object before it is displayed.
    /// This method gives the delegate a chance to override state-based properties, such as background and text colors.
    ///
    /// - Parameters:
    ///   - tableView: The maneuver table view presenting the maneuver item view.
    ///   - view: The maneuver item view to be presented.
    @objc optional func maneuverTableView(_ tableView: ManeuverTableView, willDisplay view: ManeuverItemView)
}

/// A view to display all the maneuvers of a route based on the visible sections setting. Note that
/// in case there is no maneuver, it shows a warning via `noManeuverFoundLabel` property.
///
/// - SeeAlso: ManeuverItemView
@IBDesignable open class ManeuverTableView: UITableView {

    // MARK: - Properties

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

    /// Number of `ManeuverItemView` objects in the table view.
    public var entryCount: Int {
        maneuvers.count
    }

    /// Sets the measurement formatter used to format distances.
    /// The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var measurementFormatter = MeasurementFormatter.currentMediumUnitFormatter {
        didSet {
            reloadData()
        }
    }

    /// The label used to display a warning when no maneuver is found.
    ///
    /// - Note: When not set, a label with default settings is used.
    public var noManeuverFoundLabel: UILabel! {
        didSet {
            noManeuverFoundLabel.text = "msdkui_no_maneuver_found".localized
        }
    }

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions.
    public weak var maneuverTableViewDelegate: ManeuverTableViewDelegate?

    /// All the maneuvers.
    private var maneuvers: [NMAManeuver] = []

    /// The cell reuse identifier.
    private var reuseIdentifier = String(describing: ManeuverItemView.self)

    // MARK: - Public

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    // MARK: - Private

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.ManeuverTableView"
    }

    /// Sets the accessibility stuff for the row.
    ///
    /// - Parameter cell: The cell to be updated.
    /// - Parameter row: The row of the passed cell.
    private func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
        if let view = cell.contentView.viewWithTag(1000) as? ManeuverItemView {
            view.tag = 0 // Done
            cell.accessibilityHint = view.accessibilityHint
        }

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = String(format: "msdkui_maneuver_in_list".localized, arguments: [row, entryCount])
        cell.accessibilityIdentifier = "MSDKUI.ManeuverTableView.cell_\(row)"

        // If there is a delegate, consider it a button and otherwise text
        cell.accessibilityTraits = (maneuverTableViewDelegate == nil) ? .staticText : .button
    }

    /// Sets up the items array.
    private func setUp() {
        setUpTableView()

        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = UITableView.automaticDimension

        // Registers the nib file for the custom cell
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

// MARK: - UITableViewDataSource

extension ManeuverTableView: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
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

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entryCount
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

        let resource = ManeuverResource(maneuvers: maneuvers, at: indexPath.row)

        let view = ManeuverItemView()
        view.tag = 1000
        view.icon = resource.icon
        view.instructions = resource.instructions
        view.address = resource.address
        view.distance = resource.distance
        view.distanceFormatter = measurementFormatter

        // Tells the delegate the view is about to be displayed
        maneuverTableViewDelegate?.maneuverTableView?(self, willDisplay: view)

        // Finally add the view to the content view
        cell.contentView.addSubviewBindToEdges(view, inset: UIEdgeInsets(top: 20, left: 16, bottom: -20, right: -16))

        setAccessibility(cell, indexPath.row)

        return cell
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // No delete button when in the editing mode or row dragged from the right
        return .none
    }
}

// MARK: - UITableViewDelegate

extension ManeuverTableView: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        maneuverTableViewDelegate?.maneuverTableView(self, didSelect: maneuvers[indexPath.row], at: indexPath.row)
    }
}
