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

import MSDKUI
import NMAKit
import UIKit

class OptionPanelViewController: UIViewController {

    @IBOutlet private(set) var backButton: UIBarButtonItem!

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var scrollView: UIScrollView!

    var panelTitle: String?

    var panel: OptionsPanel?

    weak var delegate: OptionsDelegate?

    private var isUpdated = false

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Set the title
        titleItem.title = panelTitle

        guard let panel = panel else {
            return
        }

        // Add the panel to our scroll view
        scrollView.addSubviewsWithVerticalScrolling([panel])

        // We want to monitor the updates
        panel.onOptionChanged = onOptionChanged

        // We want to customize the picker views:
        // so, set self as the delegate if the panel has a picker view
        if let routeTypeOptionsPanel = panel as? RouteTypeOptionsPanel {
            routeTypeOptionsPanel.delegate = self
        } else if let trafficOptionsPanel = panel as? TrafficOptionsPanel {
            trafficOptionsPanel.delegate = self
        } else if let truckOptionsPanel = panel as? TruckOptionsPanel {
            truckOptionsPanel.delegate = self
            truckOptionsPanel.presenter = self
        } else if let tunnelOptionsPanel = panel as? TunnelOptionsPanel {
            tunnelOptionsPanel.delegate = self
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction private func goBack(_: UIBarButtonItem) {
        // In case of an update, inform the delegate if any
        if isUpdated {
            delegate?.optionsUpdated(self)
        }

        dismiss(animated: true, completion: nil)
    }

    func localize() {
        backButton.title = "msdkui_app_back".localized
    }

    func updateStyle() {
        backButton.tintColor = .colorAccentLight
    }

    func setAccessibility() {
        backButton.accessibilityIdentifier = "OptionPanelViewController.backButton"
        scrollView.accessibilityIdentifier = "OptionPanelViewController.scrollView"
    }

    // Monitor the panel updates
    func onOptionChanged(_: OptionItem) {
        isUpdated = true
    }
}

// MARK: PickerViewDelegate

extension OptionPanelViewController: PickerViewDelegate {

    func makeLabel(_: UIPickerView, text: String) -> UILabel {
        let pickerLabel = UILabel()
        let title = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Verdana", size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.colorAccent
            ])

        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
}
