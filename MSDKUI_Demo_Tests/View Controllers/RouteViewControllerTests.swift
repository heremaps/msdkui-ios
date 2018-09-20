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

@testable import MSDKUI_Demo
import NMAKit
import UIKit
import XCTest

class RouteViewControllerTests: XCTestCase {
    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: RouteViewController!

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromStoryboard(named: .routePlanner) as RouteViewController

        // Load the view hierarchy
        viewControllerUnderTest.loadViewIfNeeded()
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // The map view rendering is problematic at the end of tests
        viewControllerUnderTest.mapView.isRenderAllowed = false

        super.tearDown()
    }

    /// Tests the NMAMapView.addMarker(with:at:) method.
    func testAddMarker() {
        let location = CGPoint(x: 25, y: 35) // A random point on the map view

        // Initially no map marker
        let mapObjects = viewControllerUnderTest.mapView.objects(at: location)
        XCTAssertEqual(mapObjects.count, 0, "There should be no map marker initially!")

        // Try to get the coordinates of the location
        if let coordinates = viewControllerUnderTest.mapView.geoCoordinates(from: location) {
            viewControllerUnderTest.mapView.addMarker(with: "Route.start", at: coordinates)
            var timeout = 0
            var markerCount = 0

            // Wait until either the marker added to the map view or at most specified seconds
            while markerCount == 0 && timeout < 45 {
                let future = Calendar.current.date(byAdding: .second, value: 1, to: Date())!
                RunLoop.main.run(until: future)

                // Try to get the marker back
                let mapObjects = viewControllerUnderTest.mapView.objects(at: location)
                markerCount = mapObjects.count

                // Time elapsed
                timeout += 1
            }

            // Marker...
            XCTAssertEqual(markerCount, 1, "There should be one map marker!")
        } else {
            XCTFail("Unable to convert the location to coordinates!")
        }
    }
}
