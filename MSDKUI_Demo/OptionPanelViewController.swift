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

class OptionPanelViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var scrollView: UIScrollView!

    var panelTitle: String?

    var panel: OptionsPanel?

    weak var delegate: OptionsDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var isUpdated = false

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Set the title
        titleItem.title = panelTitle

        // Is there a panel set?
        guard let panel = panel else {
            return
        }

        // Add the panel to the scroll view
        scrollView.addSubview(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false

        // Add panel constraints
        panel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        panel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        panel.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true

        // Set scroll view width
        let widthConstraint = NSLayoutConstraint(
            item: panel,
            attribute: .width,
            relatedBy: .equal,
            toItem: scrollView,
            attribute: .width,
            multiplier: 1,
            constant: 0
        )
        scrollView.addConstraint(widthConstraint)

        // We want to monitor the updates
        panel.delegate = self

        // We want to customize the picker views:
        // so, set self as the delegate if the panel has a picker view
        if let routeTypeOptionsPanel = panel as? RouteTypeOptionsPanel {
            routeTypeOptionsPanel.pickerDelegate = self
        } else if let trafficOptionsPanel = panel as? TrafficOptionsPanel {
            trafficOptionsPanel.pickerDelegate = self
        } else if let truckOptionsPanel = panel as? TruckOptionsPanel {
            truckOptionsPanel.pickerDelegate = self
            truckOptionsPanel.presenter = self
        } else if let tunnelOptionsPanel = panel as? TunnelOptionsPanel {
            tunnelOptionsPanel.pickerDelegate = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isBeingPresented {
            // Set the initial `scrollView.contentSize`
            if let panel = panel {
                scrollView.contentSize = panel.frame.size
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update `scrollView.contentSize` after transition
        coordinator.animate(alongsideTransition: nil) { _ in
            if let panel = self.panel {
                self.scrollView.contentSize = panel.frame.size
            }
        }
    }

    // MARK: - Private

    private func localize() {
        backButton.title = "msdkui_app_back".localized
    }

    private func updateStyle() {
        backButton.tintColor = .colorAccentLight
    }

    private func setAccessibility() {
        backButton.accessibilityIdentifier = "OptionPanelViewController.backButton"
        scrollView.accessibilityIdentifier = "OptionPanelViewController.scrollView"
    }

    @IBAction private func goBack(_ sender: UIBarButtonItem) {
        // In case of an update, inform the delegate if any
        if isUpdated {
            delegate?.optionsUpdated(self)
        }

        dismiss(animated: true)
    }
}

// MARK: - PickerViewDelegate

extension OptionPanelViewController: PickerViewDelegate {
    func makeLabel(_ pickerView: UIPickerView, text: String) -> UILabel {
        let pickerLabel = UILabel()
        let title = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Verdana", size: 17.0) ?? UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor: UIColor.colorAccent
        ])

        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
}

// MARK: - OptionsPanelDelegate

extension OptionPanelViewController: OptionsPanelDelegate {
    func optionsPanel(_ panel: OptionsPanel, didChangeTo option: OptionItem) {
        isUpdated = true
    }
}
