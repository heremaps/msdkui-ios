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

import MSDKUI
import NMAKit
import UIKit

/// A set of methods for communicating interactions with options.
protocol OptionsDelegate: AnyObject {
    func optionsUpdated(_ viewController: UIViewController)
}

class OptionsViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var tableView: UITableView!

    var routingMode: NMARoutingMode?

    var dynamicPenalty: NMADynamicPenalty?

    var transportMode: NMATransportMode?

    weak var delegate: OptionsDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var isUpdated = false

    private var panels: [String] = []

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // No empty rows and customize the cell tint color
        tableView.tableFooterView = UIView(frame: .zero)

        loadPanels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPanel", let viewController = segue.destination as? OptionPanelViewController {
            prepare(incoming: viewController)
        }
    }

    // MARK: - Private

    private func prepare(incoming viewController: OptionPanelViewController) {
        guard
            let selectedRow = tableView.indexPathForSelectedRow?.row,
            panels.indices.contains(selectedRow),
            case let selectedOptionsPanelName = panels[selectedRow],
            let panel = configuredOptionsPanel(for: selectedOptionsPanelName) else {
            return
        }

        viewController.panelTitle = selectedOptionsPanelName
        viewController.panel = panel
        viewController.delegate = self
    }

    private func localize() {
        backButton.title = "msdkui_app_back".localized
        titleItem.title = "msdkui_app_options".localized
    }

    private func updateStyle() {
        backButton.tintColor = .colorAccentLight
    }

    private func setAccessibility() {
        backButton.accessibilityIdentifier = "OptionsViewController.backButton"
        tableView.accessibilityIdentifier = "OptionsViewController.tableView"
    }

    private func loadPanels() {
        panels = panelNames(for: transportMode)
        tableView.reloadData()
    }

    private func optionsPanel(for name: String, configuredWith dynamicPenalty: NMADynamicPenalty?) -> OptionsPanel? {
        switch name {
        case TrafficOptionsPanel.name:
            let panel = TrafficOptionsPanel()
            panel.dynamicPenalty = dynamicPenalty
            return panel

        default:
            return nil
        }
    }

    private func optionsPanel(for name: String, configuredWith routingMode: NMARoutingMode?) -> OptionsPanel? {
        switch name {
        case HazardousMaterialsOptionsPanel.name:
            let panel = HazardousMaterialsOptionsPanel()
            panel.routingMode = routingMode
            return panel

        case RouteTypeOptionsPanel.name:
            let panel = RouteTypeOptionsPanel()
            panel.routingMode = routingMode
            return panel

        case RoutingOptionsPanel.name:
            let panel = RoutingOptionsPanel()
            panel.routingMode = routingMode
            return panel

        case TruckOptionsPanel.name:
            let panel = TruckOptionsPanel()
            panel.routingMode = routingMode
            return panel

        case TunnelOptionsPanel.name:
            let panel = TunnelOptionsPanel()
            panel.routingMode = routingMode
            return panel

        default:
            return nil
        }
    }

    /// Maps `transportMode` to panel names.
    ///
    /// - Parameter transportMode: the mode of transportation a person will be using to travel a route.
    /// - Returns: `OptionsPanel` names.
    private func panelNames(for transportMode: NMATransportMode?) -> [String] {
        switch transportMode {
        case .some(.car):
            return [
                RouteTypeOptionsPanel.name,
                TrafficOptionsPanel.name,
                RoutingOptionsPanel.name
            ]

        case .some(.bike), .some(.pedestrian):
            return [
                RoutingOptionsPanel.name
            ]

        case .some(.truck):
            return [
                TrafficOptionsPanel.name,
                RoutingOptionsPanel.name,
                TunnelOptionsPanel.name,
                HazardousMaterialsOptionsPanel.name,
                TruckOptionsPanel.name
            ]

        case .some(.scooter):
            return [
                TrafficOptionsPanel.name,
                RoutingOptionsPanel.name
            ]

        default:
            return []
        }
    }

    /// Creates an `OptionsPanel` by name with configuration from view controller's `routingMode` or
    /// `dynamicPenalty` properties depending on which type of `OptionPanel` is chosen.
    ///
    /// - Parameter name: corresponds to `name` property on `OptionsPanel`. Used to choose which
    ///                   OptionsPanel to create and configure.
    /// - Returns: An instance of configured `OptionsPanel` or nil when no panel of such name exists.
    private func configuredOptionsPanel(for name: String) -> OptionsPanel? {
        if let panel = optionsPanel(for: name, configuredWith: routingMode) {
            return panel
        } else if let panel = optionsPanel(for: name, configuredWith: dynamicPenalty) {
            return panel
        }
        return nil
    }

    @IBAction private func goBack(_ sender: UIBarButtonItem) {
        // In case of an update, inform the delegate if any
        if isUpdated {
            delegate?.optionsUpdated(self)
        }

        dismiss(animated: true)
    }
}

// MARK: - OptionsDelegate

extension OptionsViewController: OptionsDelegate {
    func optionsUpdated(_ viewController: UIViewController) {
        isUpdated = true
    }
}

// MARK: - UITableViewDataSource

extension OptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        panels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Option", for: indexPath)
        cell.textLabel?.text = panels[indexPath.row]

        return cell
    }
}

// MARK: - UITableViewDelegate

extension OptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPanel", sender: self)

        tableView.deselectRow(at: indexPath, animated: false)
    }
}
