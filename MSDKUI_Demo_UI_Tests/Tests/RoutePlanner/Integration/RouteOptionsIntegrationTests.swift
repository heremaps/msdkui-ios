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

import EarlGrey
@testable import MSDKUI
import XCTest

final class RouteOptionsIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .routePlanner)
    }

    override func tearDown() {
        // Return back from route options
        CoreActions.tap(element: CoreMatchers.backButton)

        // Set default transport mode to car
        CoreActions.tap(element: RoutePlannerMatchers.transportModeCar)

        // Return back to the landing view
        CoreActions.tap(element: CoreMatchers.exitButton)

        super.tearDown()
    }

    // MARK: - Tests

    // MSDKUI-891: Car route options
    // Check that car route options are present and clickable
    func testCarRouteOptions() {

        // Open route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)

        let carRouteOptions = [RoutePlannerOptionMatchers.optionRouteType,
                               RoutePlannerOptionMatchers.optionAvoidTraffic,
                               RoutePlannerOptionMatchers.optionRouteOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in carRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
        }
    }

    // MSDKUI-891: Truck route options
    // Check that truck route options are present and clickable
    func testTruckRouteOptions() {

        // Set default routes to truck
        CoreActions.tap(element: RoutePlannerMatchers.transportModeTruck)

        // Open route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)

        let truckRouteOptions = [RoutePlannerOptionMatchers.optionAvoidTraffic,
                                 RoutePlannerOptionMatchers.optionRouteOptions,
                                 RoutePlannerOptionMatchers.truckOptionTunnelsAllowed,
                                 RoutePlannerOptionMatchers.truckOptionHazardousMaterials,
                                 RoutePlannerOptionMatchers.truckOptionTruckOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in truckRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
        }
    }

    // MSDKUI-891: Pedestrian route options
    // Check that pedestrian route options are present and clickable
    func testPedestrianRouteOptions() {

        // Set default routes to pedestrian
        CoreActions.tap(element: RoutePlannerMatchers.transportModePedestrian)

        // Open route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)

        // Check for visibility of route option, taps on it and taps back
        EarlGrey.selectElement(with: RoutePlannerOptionMatchers.optionRouteOptions)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
    }

    // MSDKUI-891: Bicycle route options
    // Check that bicycle route options are present and clickable
    func testBicycleRouteOptions() {

        // Set default routes to bicycle
        CoreActions.tap(element: RoutePlannerMatchers.transportModeBike)

        // Open route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)

        // Check for visibility of route option, taps on it and taps back
        EarlGrey.selectElement(with: RoutePlannerOptionMatchers.optionRouteOptions)
            .assert(grey_sufficientlyVisible())
            .perform(grey_tap())

        EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
    }

    // MSDKUI-891: Scooter route options
    // Check that scooter route options are present and clickable
    func testScooterRouteOptions() {

        // Set default routes to scooter
        CoreActions.tap(element: RoutePlannerMatchers.transportModeScooter)

        // Open route options
        CoreActions.tap(element: RoutePlannerMatchers.routeOptionsButton)

        let scooterRouteOptions = [RoutePlannerOptionMatchers.optionAvoidTraffic,
                                   RoutePlannerOptionMatchers.optionRouteOptions]

        // Check for visibility of route option, taps on it and taps back
        for routeOptions in scooterRouteOptions {
            EarlGrey.selectElement(with: routeOptions)
                .assert(grey_sufficientlyVisible())
                .perform(grey_tap())

            EarlGrey.selectElement(with: CoreMatchers.backButton).perform(grey_tap())
        }
    }
}
