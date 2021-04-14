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

/// The delegate of a `RouteDescriptionList` object must adopt the `RouteDescriptionListDelegate`
/// protocol. This protocol lets the `RouteDescriptionList` object to inform its `delegate` about
/// updates occurred.
@objc public protocol RouteDescriptionListDelegate: AnyObject {

    /// Tells the delegate that the specified row and route is selected.
    ///
    /// - Parameters:
    ///   - list: A `RouteDescriptionList` object informing the delegate about the new row selection.
    ///   - route: The route associated with the row.
    ///   - index: The index of the newly selected row.
    func routeDescriptionList(_ list: RouteDescriptionList, didSelect route: NMARoute, at index: Int)

    /// Tells the delegate the route description list is about to present a route description item.
    ///
    /// A route description list sends this message to its delegate just before it presents a route description item,
    /// thereby permitting the delegate to customize the route description item object before it is displayed. This method gives
    /// the delegate a chance to override state-based properties, such as background and text colors.
    ///
    /// - Parameters:
    ///   - list: The route description list presenting the route description item.
    ///   - item: The route description item to be presented.
    @objc optional func routeDescriptionList(_ list: RouteDescriptionList, willDisplay item: RouteDescriptionItem)
}

/// A panel displaying a list of scrollable `RouteDescriptionItem` elements for each of the set routes. Note that
/// in case there is no route, it shows a warning via `noRouteFoundLabel` property.
@IBDesignable open class RouteDescriptionList: UIView {

    // MARK: - Types

    /// Specifies the metric used for sorting the routes.
    public enum SortType: String {

        /// Sorts by duration.
        case duration

        /// Sorts by length.
        case length
    }

    /// Used for specifiying the sort order.
    public enum SortOrder: String {

        /// Sorting is in ascending order.
        case ascending

        /// Sorting is in descending order.
        case descending
    }

    // MARK: - Properties

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
                let titleItem = TitleItem()
                titleItem.label.text = title

                showTitle = true

                // Make sure it is placed at the top
                stackView.insertArrangedSubview(titleItem.view, at: 0)
                self.titleItem = titleItem

                invalidateIntrinsicContentSize()
            }
        }
    }

    /// If traffic should be considered.
    @IBInspectable public var trafficEnabled: Bool = false

    /// Shows or hides the title.
    @IBInspectable public var showTitle: Bool = false {
        didSet {
            // Note: we are setting a view's isHidden property!
            titleItem?.view.isHidden = !showTitle
            titleItem?.view.isAccessibilityElement = showTitle
        }
    }

    /// The proxy property to make the `SortType` property accessible
    /// from the Interface Builder.
    @IBInspectable public var sortTypeProxy: String {
        get {
            sortType.rawValue
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

    /// The proxy property to make the `SortOrder` property accessible
    /// from the Interface Builder.
    @IBInspectable public var sortOrderProxy: String {
        get {
            sortOrder.rawValue
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

    /// The proxy property to make the `visibleSections` property accessible
    /// from the Interface Builder. It accepts a string like "icon|duration|length"
    /// to set the `visibleSections` property: the users can avoid arithmetic while
    /// setting this property. Note that unknown substrings are simply ignored.
    ///
    /// - Important: It shadows the visibleSections property.
    @IBInspectable public var visibleSectionsProxy: String {
        get {
            visibleSections.stringized
        }
        set {
            visibleSections = RouteDescriptionItem.Section.make(from: newValue)
        }
    }

    /// A string that can be used to represent the panel.
    public static let name = "msdkui_route_results_title".localized

    /// An array of `NMARoute` objects. The route summary of each route is displayed as
    /// a `RouteDescriptionItem` in a row of this list.
    public var routes: [NMARoute] {
        get {
            sortedRoutes
        }

        set {
            // Accepts the new value, refreshes the scaler and itself
            sortedRoutes = newValue
            scaler.refresh()
            refresh()
        }
    }

    /// Number of `RouteDescriptionItem` objects in the list.
    public var entryCount: Int {
        sortedRoutes.count
    }

    /// Sorts the type for this `RouteDescriptionList`.
    public var sortType: SortType = .duration {
        didSet {
            refresh()
        }
    }

    /// Sorts the order for this `RouteDescriptionList`.
    public var sortOrder: SortOrder = .ascending {
        didSet {
            refresh()
        }
    }

    /// Sets the visibility of `RouteDescriptionItem` sections.
    ///
    /// - Note: Initially all the sections are visible.
    public var visibleSections: RouteDescriptionItem.Section = .all {
        didSet {
            refresh()
        }
    }

    /// The label used to display a warning when no route is found.
    ///
    /// - Note: When not set, a label with default settings is used.
    public var noRouteFoundLabel: UILabel! {
        didSet {
            noRouteFoundLabel.text = "msdkui_no_route_found".localized
        }
    }

    /// A Boolean value that determines whether bouncing always occurs when
    /// vertical scrolling reaches the end of the route description list. The default value is `false`.
    public var alwaysBounceVertical: Bool = false {
        didSet { tableView.alwaysBounceVertical = alwaysBounceVertical }
    }

    /// Specifies the default inset of route description item separators. The default value is `(0, 72, 0, 0)`.
    public var separatorInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0) {
        didSet { tableView.separatorInset = separatorInset }
    }

    /// The color of separator rows in the route description list. The default value is `.colorDivider`.
    public var separatorColor: UIColor? = .colorDivider {
        didSet { tableView.separatorColor = separatorColor }
    }

    /// A boolean value that determines whether empty rows should be displayed in the route description list.
    public var showEmptyRows: Bool = false {
        didSet { tableView.tableFooterView = showEmptyRows ? nil : UIView(frame: .zero) }
    }

    /// The style for table cells used as separators. The default value is `.singleLine`.
    public var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine {
        didSet { tableView.separatorStyle = separatorStyle }
    }

    /// The optional delegate object. When it is set, the delegate object
    /// is informed about the user interactions with this list.
    public weak var listDelegate: RouteDescriptionListDelegate?

    /// All the title visuals are found on this item.
    ///
    /// - Note: This is an optional property and it is created only
    ///              when the `title` property is set.
    var titleItem: TitleItem?

    /// This tableview holds all the routes.
    var tableView = UITableView()

    /// This vertical stackview holds the title view and the option views.
    let stackView = UIStackView()

    /// The sorted routes.
    private var sortedRoutes: [NMARoute] = []

    /// The scaler for setting the scaling for the cells.
    private var scaler: RouteBarScaler!

    /// The cell reuse identifier.
    private var reuseIdentifier = String(describing: RouteDescriptionItem.self)

    // MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    // MARK: - Private

    /// Refreshes the rows.
    private func refresh() {
        // Should sort the routes?
        if sortedRoutes.count > 1 {
            sortRoutes()
        }

        tableView.reloadData()
    }

    /// Sorts the routes array based on the sort type and sort order.
    private func sortRoutes() {
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

    /// Sets up the stack view.
    private func setUpStackView() {
        stackView.spacing = 0.0
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.backgroundColor = nil
    }

    /// Sets up the table view.
    private func setUpTableView() {
        tableView.bounces = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.isEditing = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = alwaysBounceVertical
        tableView.separatorInset = separatorInset
        tableView.separatorColor = separatorColor
        tableView.backgroundColor = nil
        showEmptyRows = false
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        accessibilityIdentifier = "MSDKUI.RouteDescriptionList"
    }

    /// Sets the accessibility stuff for the row.
    ///
    /// - Parameter cell: The cell to be updated.
    /// - Parameter row: The row of the passed cell.
    private func setAccessibility(_ cell: UITableViewCell, _ row: Int) {
        if let view = cell.contentView.viewWithTag(1000) as? RouteDescriptionItem {
            view.tag = 0 // Done
            cell.accessibilityHint = view.accessibilityHint
        }

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = String(format: "msdkui_route_in_list".localized, arguments: [row, sortedRoutes.count])
        cell.accessibilityIdentifier = "MSDKUI.RouteDescriptionList.cell_\(row)"

        // If there is a delegate, consider it a button and otherwise text
        cell.accessibilityTraits = (listDelegate == nil) ? .staticText : .button
    }

    /// Initializes the content of this view.
    private func setUp() {
        backgroundColor = .colorForegroundLight

        // Sets up the stack view
        setUpStackView()

        // Sets up the table view
        setUpTableView()

        // Creates the scaler object
        scaler = RouteBarScaler(parent: self)

        // Sets the table row height out of the view used for the content view
        let view = RouteDescriptionItem()
        tableView.rowHeight = view.bounds.size.height

        // Registers the nib file for the custom cell
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: reuseIdentifier)

        setAccessibility()

        // Adds the table view: the title view is added when a title is set
        stackView.addArrangedSubview(tableView)

        addSubviewBindToEdges(stackView)
    }
}

// MARK: - UITableViewDataSource

extension RouteDescriptionList: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        // Is there any route? No route means no section
        let sections = sortedRoutes.isEmpty ? 0 : 1

        // Has the table a section? Set the background color always!
        if sections == 1 {
            tableView.backgroundView = nil
            tableView.separatorStyle = separatorStyle
        } else {
            // Is the label available?
            if noRouteFoundLabel == nil {
                noRouteFoundLabel = UILabel()
                noRouteFoundLabel.backgroundColor = .clear
                noRouteFoundLabel.font = UIFont.systemFont(ofSize: 20)
                noRouteFoundLabel.textColor = UIColor.red
                noRouteFoundLabel.textAlignment = .center
            }

            tableView.separatorStyle = .none
            tableView.backgroundView = noRouteFoundLabel
        }

        return sections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedRoutes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Removes the existing content subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Cells settings
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.editingAccessoryType = .none

        // Creates the content view subview
        let view = RouteDescriptionItem()
        view.trafficEnabled = trafficEnabled
        view.visibleSections = visibleSections
        view.route = sortedRoutes[indexPath.row]
        view.trailingInset = -20
        view.tag = 1000
        scaler.setScale(for: view)

        // Tells the delegate the view is about to be displayed
        listDelegate?.routeDescriptionList?(self, willDisplay: view)

        // Finally, add the view to the content view
        cell.contentView.addSubviewBindToEdges(view)

        setAccessibility(cell, indexPath.row)

        return cell
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // No delete button when in the editing mode or row dragged from the right
        return .none
    }
}

// MARK: - UITableViewDelegate

extension RouteDescriptionList: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listDelegate?.routeDescriptionList(self, didSelect: sortedRoutes[indexPath.row], at: indexPath.row)
    }
}
