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
@testable import MSDKUI
import NMAKit
import XCTest

class StartStopNavigationIntegrationUITests: XCTestCase {

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Make sure the EarlGrey is ready for testing
        CoreActions.reset(card: .driveNav)

        // Position is needed to advance in tests
        Positioning.shared.start()

        // Dismiss permission alert
        CoreActions.dismissAlert(element: CoreView.permissionsAlert)
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()

        // Stop positioning
        Positioning.shared.stop()
    }

    // MSDKUI-889 Integration tests for start/stop navigation
    func testStartStopNavigationIntegration() {
        Utils.initTest(name: #function)

        // Drive navigation and map view is shown.
        // Destination marker appears on the map and location address is shown
        MapActions.mustHaveDestinationSelected(with: .tap)

        // Show guidance
        CoreActions.tap(element: ActionbarView.waypointViewControllerOk)
        CoreActions.dismissAlert(element: CoreView.permissionsAlert)
        CoreActions.tap(element: RouteOverviewView.startNavigationButton)
        CoreActions.dismissAlert(element: CoreView.permissionsAlert)
        Utils.waitFor(element: GuidanceView.mapView)

        // Stop guidance
        CoreActions.tap(element: GuidanceView.stopNavigationButton)
        Utils.waitFor(element: LandingView.driveNav)
    }
}
