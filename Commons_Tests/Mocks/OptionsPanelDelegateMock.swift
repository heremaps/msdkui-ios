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

final class OptionsPanelDelegateMock {
    private(set) var didChangeToOption = false
    private(set) var didChangeToOptionCount = 0

    private(set) var lastPanel: OptionsPanel?
    private(set) var lastOption: OptionItem?
}

// MARK: - OptionsPanelDelegate

extension OptionsPanelDelegateMock: OptionsPanelDelegate {
    func optionsPanel(_ panel: OptionsPanel, didChangeTo option: OptionItem) {
        didChangeToOption = true
        didChangeToOptionCount += 1
        lastPanel = panel
        lastOption = option
    }
}
