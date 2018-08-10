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

/// This protocol provides the callback methods which a `RouteDescriptionList` object
/// calls after user interactions to inform the delegate object.
@objc public protocol RouteDescriptionListDelegate: AnyObject {
    /// Tells the delegate that the specified row and route is selected.
    ///
    /// - Parameter list: A `RouteDescriptionList` object informing the delegate about the new row selection.
    /// - Parameter index: The index of the newly selected row.
    /// - Parameter route: The route associated with the row.
    func routeSelected(_ list: RouteDescriptionList, index: Int, route: NMARoute)
}

/// A panel displaying a list of scrollable `RouteDescriptionItem` elements for each of the set routes. Note that
/// in case there is no route, it shows a warning via `noRouteFoundLabel` property.
@IBDesignable open class RouteDescriptionList: UIView {
    /// Used for specifiying the metric used for sorting the routes.
    public enum SortType: String {

        /// Sort by duration.
        case duration

        /// Sort by length.
        case length
    }

    /// Used for specifiying the sort order.
    public enum SortOrder: String {

        /// Sorting is in ascending order.
        case ascending

        /// Sorting is in descending order.
        case descending
    }

    /// A string that can be used to represent the panel.
    public static var name = "msdkui_route_results_title".localized

    /// The optional panel title.
    ///
    /// - Important: When it is set, the title is displayed at the top of the panel.
    /// - Important: When it is set to nil, `showTitle` property is set to false, too.
    @IBInspectable public var title: String? {
        didSet {
            // If the title is nil, sync the titleItem & showTitle properties accordingly
            guard title != nil else {
                showTitle = false

                // If titleItem is available, remove it first
                if let titleItem = titleItem {
                    stackView.removeArrangedSubview(titleItem.view)
                }

                titleItem = nil
                return
            }

            // If titleItem is available, update and otherwise create one
            if let titleItem = titleItem {
                titleItem.label.text = title
            } else {
                titleItem = TitleItem()
                titleItem!.label.text = title

                showTitle = true

                // Make sure it is placed at the top
                stackView.insertArrangedSubview(titleItem!.view, at: 0)

                invalidateIntrinsicContentSize()
            }
        }
    }

    /// Whether traffic should be considered.
    @IBInspectable public var trafficEnabled: Bool = false

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions with this list.
    public weak var listDelegate: RouteDescriptionListDelegate?

    /// An array of `NMARoute` objects. The route summary of each route is displayed as
    /// a `RouteDescriptionItem` in a row of this list.
    public var routes: [NMARoute] {
        get {
            return sortedRoutes
        }

        set {
            // Accept the new value, refreshes the scaler and itself
            sortedRoutes = newValue
            scaler.refresh()
            refresh()
        }
    }

    /// Number of `RouteDescriptionItem` objects in the list.
    public var entryCount: Int {
        return sortedRoutes.count
    }

    /// Sort type for this `RouteDescriptionList`.
    public var sortType: SortType = .duration {
        didSet {
            refresh()
        }
    }

    /// Shows or hides the title.
    @IBInspectable public var showTitle: Bool = false {
        didSet {
            // Be careful: we are setting a view's isHidden property!
            titleItem?.view.isHidden = !showTitle
            titleItem?.view.isAccessibilityElement = showTitle
        }
    }

    /// The proxy property to make the `SortType` property accessible
    /// from the Interface Builder.
    @IBInspectable public var sortTypeProxy: String {
        get {
            return sortType.rawValue
        }
        set {
            // Is a valid string specified?
            if let newSortType = SortType(rawValue: newValue) {
                // Is there an update?
                if newSortType != sortType {
                    sortType = newSortType
                }
            }
        }
    }

    /// Sort order for this `RouteDescriptionList`.
    public var sortOrder: SortOrder = .ascending {
        didSet {
            refresh()
        }
    }

    /// The proxy property to make the `SortOrder` property accessible
    /// from the Interface Builder.
    @IBInspectable public var sortOrderProxy: String {
        get {
            return sortOrder.rawValue
        }
        set {
            // Is a valid string specified?
            if let newSortOrder = SortOrder(rawValue: newValue) {
                // Is there an update?
                if newSortOrder != sortOrder {
                    sortOrder = newSortOrder
                }
            }
        }
    }

    /// Sets the visibility of `RouteDescriptionItem` sections.
    ///
    /// - Important: Initially all the sections are visible.
    public var visibleSections: RouteDescriptionItem.Section = .all {
        didSet {
            refresh()
        }
    }

    /// The proxy property to make the `visibleSections` property accessible
    /// from the Interface Builder. It accepts a string like "icon|duration|length"
    /// to set the `visibleSections` property: the users can avoid arithmetic while
    /// setting this property. Note that unknown substrings are simply ignored.
    ///
    /// - Important: It shadows the visibleSections property.
    @IBInspectable public var visibleSectionsProxy: String {
        get {
            return visibleSections.stringized
        }
        set {
            visibleSections = RouteDescriptionItem.Section.make(from: newValue)
        }
    }

    /// The label used to display a warning when no route is found.
    ///
    /// - Important: When not set, a label with default settings is used.
    public var noRouteFoundLabel: UILabel! {
        didSet {
            noRouteFoundLabel.text = "msdkui_no_route_found".localized
        }
    }

    /// The sorted routes.
    var sortedRoutes: [NMARoute] = []

    /// The scaler for setting the scaling for the cells.
    var scaler: RouteBarScaler!

    /// This vertical stackview holds the title view and the option views.
    let stackView = UIStackView()

    /// All the title visuals are found on this item.
    ///
    /// - Important: This is an optional property and it is created only
    ///              when the `title` property is set.
    var titleItem: TitleItem?

    /// The cell reuse identifier.
    var reuseIdentifier = String(describing: RouteDescriptionItem.self)

    /// This tableview holds all the routes.
    var tableView = UITableView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        updateStyle()
    }

    /// Refreshes the rows.
    func refresh() {
        // Should sort the routes?
        if sortedRoutes.count > 1 {
            sortRoutes()
        }

        tableView.reloadData()
    }

    /// Sorts the routes array based on the sort type and sort order.
    func sortRoutes() {
        sortedRoutes.sort {
            switch sortType {
            case .length:
                if sortOrder == .ascending {
                    return $0.length < $1.length
                } else {
                    return $0.length > $1.length
                }

            case .duration:
                if sortOrder == .ascending {
                    return $0.durationWithTraffic() < $1.durationWithTraffic()
                } else {
                    return $0.durationWithTraffic() > $1.durationWithTraffic()
                }
            }
        }
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        tableView.alwaysBounceVertical = Styles.shared.routeDescriptionListAlwaysBounceVertical
        tableView.separatorInset = Styles.shared.routeDescriptionListSeparatorInset
        tableView.separatorColor = Styles.shared.routeDescriptionListSeparatorColor

        if Styles.shared.routeDescriptionListNoEmptyRows == true {
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }

    /// Sets the accessibility stuff.
    func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.RouteDescriptionList"
    }

    /// Sets the accessibility stuff for the row.
    ///
    /// - Parameter cell: The cell to be updated.
    /// - Parameter row: The row of the passed cell.
    func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
        let view = cell.contentView.viewWithTag(1000) as! RouteDescriptionItem
        view.tag = 0 // Done

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = String(format: "msdkui_route_in_list".localized, arguments: [row + 1, sortedRoutes.count])
        cell.accessibilityHint = view.accessibilityHint
        cell.accessibilityIdentifier = String(format: "MSDKUI.RouteDescriptionList.cell_%d", arguments: [row + 1])

        // If there is a delegate, consider it a button and otherwise text
        cell.accessibilityTraits |= (listDelegate == nil) ? UIAccessibilityTraitStaticText : UIAccessibilityTraitButton
    }

    /// Initializes the content of this view.
    private func setUp() {
        // Stackview settings
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.axis = .vertical

        // Tableview settings
        tableView.bounces = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.isEditing = false
        tableView.dataSource = self
        tableView.delegate = self

        // Create the scaler object
        scaler = RouteBarScaler(parent: self)

        // Set the table row height out of the view used for the content view
        let view = RouteDescriptionItem()
        tableView.rowHeight = view.bounds.size.height

        // Register the nib file for the custom cell
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: reuseIdentifier)

        setAccessibility()

        // Add the table view: the title view is added when a title is set
        stackView.addArrangedSubview(tableView)

        addSubviewBindToEdges(stackView)
    }
}

// MARK: UITableViewDataSource

extension RouteDescriptionList: UITableViewDataSource {
    public func numberOfSections(in _: UITableView) -> Int {
        // Is there any route? No route means no section
        let sections = sortedRoutes.isEmpty ? 0 : 1

        // Has the table a section? Set the background color always!
        if sections == 1 {
            tableView.backgroundView = nil
            tableView.separatorStyle = Styles.shared.routeDescriptionListSeparatorStyle
            tableView.backgroundColor = Styles.shared.routeDescriptionListBackgroundColor
        } else {
            // Is the label available?
            if noRouteFoundLabel == nil {
                noRouteFoundLabel = UILabel()
                noRouteFoundLabel.backgroundColor = Styles.shared.routeDescriptionListBackgroundColor
                noRouteFoundLabel.font = UIFont.systemFont(ofSize: 20)
                noRouteFoundLabel.textColor = UIColor.red
                noRouteFoundLabel.textAlignment = .center
            }

            tableView.separatorStyle = .none
            tableView.backgroundView = noRouteFoundLabel
        }

        return sections
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return sortedRoutes.count
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
        let view = RouteDescriptionItem()
        view.trafficEnabled = trafficEnabled
        view.visibleSections = visibleSections
        view.route = sortedRoutes[indexPath.row]
        view.tag = 1000
        scaler.setScale(for: view)

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

extension RouteDescriptionList: UITableViewDelegate {
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Has any delegate?
        listDelegate?.routeSelected(self, index: indexPath.row, route: sortedRoutes[indexPath.row])
    }
}
