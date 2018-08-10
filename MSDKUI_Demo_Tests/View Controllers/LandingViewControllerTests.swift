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
import UIKit
import XCTest

class LandingViewControllerTests: XCTestCase {
    /// The incoming view controller by a segue.
    static var incomingSegueViewController: UIViewController?

    /// The view controller to be tested. Note that it is re-created before each test.
    var viewControllerUnderTest: LandingViewController!

    /// This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()

        // Create the viewControllerUnderTest object
        viewControllerUnderTest = UIStoryboard.instantiateFromMainStoryboard() as LandingViewController

        // Load the view hierarchy
        viewControllerUnderTest.loadViewIfNeeded()
    }

    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        // Done
        LandingViewControllerTests.incomingSegueViewController = nil

        super.tearDown()
    }

    /// Tests that LandingViewController.getAppVersionStrings() brings the expected strings.
    func testGetAppVersionStrings() {
        let appVersionStrings = viewControllerUnderTest.getAppVersionStrings()

        XCTAssertEqual(appVersionStrings.version, "1.4.0", "Wrong app version strings!")
        XCTAssertEqual(appVersionStrings.build, "1", "Wrong app version strings!")
    }

    /// Tests that LandingViewController.getAppVersionStrings(sender:) launches the expected view controller.
    func testHandleRoutePannerTap() {
        viewControllerUnderTest.handleRoutePannerTap(sender: UITapGestureRecognizer())

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertNotNil(LandingViewControllerTests.incomingSegueViewController as? ViewController,
                        "No view controller is presented!")
    }

    /// Tests that LandingViewController.handleDriveNavTap(sender:) launches the expected view controller.
    func testHandleDriveNavTap() {
        viewControllerUnderTest.handleDriveNavTap(sender: UITapGestureRecognizer())

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertNotNil(LandingViewControllerTests.incomingSegueViewController as? WaypointViewController,
                        "No view controller is presented!")
    }

    /// Tests route planner ImageView.
    func testRoutePlannerImageView() {
        XCTAssertNotNil(viewControllerUnderTest.routePlannerImageView.image, "Image should exist")
        XCTAssertNotNil(viewControllerUnderTest.routePlannerImageView.superview, "Image should be in view hierarchy")
        XCTAssertFalse(viewControllerUnderTest.routePlannerImageView.isHidden, "Image should not be hidden")
        XCTAssertEqual(viewControllerUnderTest.routePlannerImageView.image, UIImage(named: "routeplanner_teaser"), "Should have correct image")
    }

    /// Tests drive navigation ImageView.
    func testDriveNavImageView() {
        XCTAssertNotNil(viewControllerUnderTest.driveNavImageView.image, "Image should exist")
        XCTAssertNotNil(viewControllerUnderTest.driveNavImageView.superview, "Image should be in view hierarchy")
        XCTAssertFalse(viewControllerUnderTest.driveNavImageView.isHidden, "Image should not be hidden")
        XCTAssertEqual(viewControllerUnderTest.driveNavImageView.image, UIImage(named: "drivenav_teaser"), "Should have correct image")
    }
}

/// This extension let us save the destination view controller of a segue
/// launched by LandingViewController: afterwards we can test this view controller
extension LandingViewController {
    override open func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        LandingViewControllerTests.incomingSegueViewController = segue.destination
    }
}
