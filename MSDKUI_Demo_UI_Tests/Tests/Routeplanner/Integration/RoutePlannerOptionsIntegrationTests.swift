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
import XCTest

class RoutePlannerOptionsIntegrationTests: XCTestCase {
    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routingPlanner)
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {

        // Return back from route options
        CoreActions.tap(element: RouteplannerOptionsView.backButtonOptions)

        // Set default transport mode to car
        CoreActions.tap(element: ActionbarView.transportModeCar)

        // The map view rendering is problematic at the end of tests
        Utils.allowMapViewRendering(MapView.mapView, false)

        // Return back to the landing view
        CoreActions.tap(element: ActionbarView.exitButton)

        super.tearDown()
    }

    // MSDKUI-891 [iOS] Implementation - Integration tests for Route Planner/Options
    // Tests that car route options are present and clickable
    func testCarRouteOptions() {

        // Open route options
        CoreActions.tap(element: ActionbarView.routeOptionsButton)

        let carRouteOptions = [RouteplannerOptionsView.optionRouteType,
                               RouteplannerOptionsView.optionAvoidTraffic,
                               RouteplannerOptionsView.optionRouteOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in carRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
        }
    }

    // MSDKUI-891 [iOS] Implementation - Integration tests for Route Planner/Options
    // Tests that truck route options are present and clickable
    func testTruckRouteOptions() {

        // Set default routes to truck
        CoreActions.tap(element: ActionbarView.transportModeTruck)

        // Open route options
        CoreActions.tap(element: ActionbarView.routeOptionsButton)

        let truckRouteOptions = [RouteplannerOptionsView.optionAvoidTraffic,
                                 RouteplannerOptionsView.optionRouteOptions,
                                 RouteplannerOptionsView.truckOptionTunnelsAllowed,
                                 RouteplannerOptionsView.truckOptionHazardousMaterials,
                                 RouteplannerOptionsView.truckOptionTruckOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in truckRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
        }
    }

    // MSDKUI-891 [iOS] Implementation - Integration tests for Route Planner/Options
    // Tests that pedestrian route options are present and clickable
    func testPedestrianRouteOptions() {

        // Set default routes to pedestrian
        CoreActions.tap(element: ActionbarView.transportModePedestrian)

        // Open route options
        CoreActions.tap(element: ActionbarView.routeOptionsButton)

        // Check for visibility of route option, taps on it and taps back
        EarlGrey.selectElement(with: RouteplannerOptionsView.optionRouteOptions)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
    }

    // MSDKUI-891 [iOS] Implementation - Integration tests for Route Planner/Options
    // Tests that bicycle route options are present and clickable
    func testBicycleRouteOptions() {

        // Set default routes to bicycle
        CoreActions.tap(element: ActionbarView.transportModeBike)

        // Open route options
        CoreActions.tap(element: ActionbarView.routeOptionsButton)

        // Check for visibility of route option, taps on it and taps back
        EarlGrey.selectElement(with: RouteplannerOptionsView.optionRouteOptions)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
    }

    // MSDKUI-891 [iOS] Implementation - Integration tests for Route Planner/Options
    // Tests that scooter route options are present and clickable
    func testScooterRouteOptions() {

        // Set default routes to scooter
        CoreActions.tap(element: ActionbarView.transportModeScooter)

        // Open route options
        CoreActions.tap(element: ActionbarView.routeOptionsButton)

        let scooterRouteOptions = [RouteplannerOptionsView.optionAvoidTraffic,
                                   RouteplannerOptionsView.optionRouteOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in scooterRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: RouteplannerView.backButton).perform(grey_tap())
        }
    }
}
