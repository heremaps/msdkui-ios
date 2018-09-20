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

import EarlGrey
import Foundation
@testable import MSDKUI
import NMAKit

enum ActionbarView {
    static var viewContollerRight: GREYMatcher {
        return grey_accessibilityID("ViewController.right")
    }

    static var exitButton: GREYMatcher {
        return grey_accessibilityID("ViewController.exit")
    }

    static var waypointList: GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointList")
    }

    static var swapButton: GREYMatcher {
        return grey_accessibilityID("IconButton.swap")
    }

    static var travelTimePanel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePanel")
    }

    static var travelTimePanelTitle: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.title")
    }

    static var travelTimePanelTime: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePanel.time")
    }

    static var transportModePanel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel")
    }

    static var transportModeTruck: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.truck")
    }

    static var transportModePedestrian: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.pedestrian")
    }

    static var transportModeScooter: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.scooter")
    }

    static var transportModeBike: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.bike")
    }

    static var transportModeCar: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.car")
    }

    static var addButton: GREYMatcher {
        return grey_accessibilityID("IconButton.add")
    }

    static var travelTimePickerDatePicker: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.datePicker")
    }

    static var routeOptionsButton: GREYMatcher {
        return grey_accessibilityID("IconButton.options")
    }

    static var waypointItemLabel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointItem.label")
    }

    static var waypointViewControllerOk: GREYMatcher {
        return grey_accessibilityID("WaypointViewController.ok")
    }

    static var travelTimePickerOk: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.ok")
    }

    static func waypointListCell(cellNr: Int) -> GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointList.cell_\(cellNr)")
    }
}
