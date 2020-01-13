//
// Copyright (C) 2017-2020 HERE Europe B.V.
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

enum RoutePlannerMatchers {
    static var viewContollerRight: GREYMatcher {
        return grey_accessibilityID("ViewController.rightButton")
    }

    static var waypointList: GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointList")
    }

    static var swapButton: GREYMatcher {
        return grey_accessibilityID("IconButton.swapButton")
    }

    static var travelTimePanel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePanel")
    }

    static var travelTimePanelTitle: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.titleLabel")
    }

    static var travelTimePanelTime: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePanel.timeLabel")
    }

    static var transportModePanel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel")
    }

    static var transportModeTruck: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.truckButton")
    }

    static var transportModePedestrian: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.pedestrianButton")
    }

    static var transportModeScooter: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.scooterButton")
    }

    static var transportModeBike: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.bikeButton")
    }

    static var transportModeCar: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TransportModePanel.carButton")
    }

    static var addButton: GREYMatcher {
        return grey_accessibilityID("IconButton.addButton")
    }

    static var travelTimePickerDatePicker: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.datePicker")
    }

    static var routeOptionsButton: GREYMatcher {
        return grey_accessibilityID("IconButton.optionsButton")
    }

    static var waypointItemLabel: GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointItem.label")
    }

    static var travelTimePickerOk: GREYMatcher {
        return grey_accessibilityID("MSDKUI.TravelTimePicker.okButton")
    }

    static func waypointListCell(cellNr: Int) -> GREYMatcher {
        return grey_accessibilityID("MSDKUI.WaypointList.cell_\(cellNr)")
    }

    static var backButton: GREYMatcher {
        return grey_accessibilityID("RouteViewController.backButton")
    }

    static var routeDescriptionList: GREYMatcher {
        return grey_accessibilityID("MSDKUI.RouteDescriptionList")
    }

    static var routeOverviewMapView: GREYMatcher {
        return grey_accessibilityID("RouteViewController.mapView")
    }

    static var routeStackView: GREYMatcher {
        return grey_accessibilityID("RouteViewController.routeStackView")
    }

    static func routeDescriptionListCell(cellNr: Int) -> GREYMatcher {
        return grey_accessibilityID("MSDKUI.RouteDescriptionList.cell_\(cellNr)")
    }

    static var helperScrollView: GREYMatcher {
        return grey_accessibilityID("ViewController.helperScrollView")
    }
}
