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
import MSDKUI

final class TravelTimePanelDelegateMock {
    private(set) var didCallWillDisplayPicker = false
    private(set) var didCallDidUpdate = false

    private(set) var lastPanel: TravelTimePanel?
    private(set) var lastPickerViewController: TravelTimePicker?
    private(set) var lastDate: Date?
}

// MARK: - TravelTimePanelDelegate

extension TravelTimePanelDelegateMock: TravelTimePanelDelegate {
    func travelTimePanel(_ panel: TravelTimePanel, willDisplay pickerViewController: TravelTimePicker) {
        didCallWillDisplayPicker = true
        lastPanel = panel
        lastPickerViewController = pickerViewController
    }

    func travelTimePanel(_ panel: TravelTimePanel, didUpdate date: Date) {
        didCallDidUpdate = true
        lastPanel = panel
        lastDate = date
    }
}
