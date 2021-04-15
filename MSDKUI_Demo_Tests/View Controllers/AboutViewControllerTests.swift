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

@testable import MSDKUI
@testable import MSDKUI_Demo
import UIKit
import XCTest

final class AboutViewControllerTests: XCTestCase {
    /// The object under test.
    private var aboutViewController: AboutViewController?

    override func setUp() {
        super.setUp()

        // Initializes the view controller under test
        aboutViewController = UIStoryboard.instantiateFromStoryboard(named: .about) as AboutViewController
        _ = aboutViewController?.view
    }

    // MARK: - Tests

    /// Tests if the view controller exists.
    func testIfExists() {
        XCTAssertNotNil(aboutViewController, "It exists")
    }

    /// Tests if the view controller has the correct navigation items.
    func testViewControllerNavigationItems() {
        XCTAssertLocalized(aboutViewController?.titleItem.title, key: "msdkui_app_about", "It has the correct navigation item title")
        XCTAssertLocalized(aboutViewController?.exitButton.title, key: "msdkui_app_exit", "It has the correct navigation button title")
    }

    /// Tests if the view controller has the correct status bar.
    func testPreferredStatusBarStyle() {
        XCTAssertEqual(aboutViewController?.preferredStatusBarStyle, .lightContent, "It has the correct status bar style")
    }

    /// Tests if the view controller has the table view data source.
    func testTableViewDataSource() {
        XCTAssertNotNil(aboutViewController?.tableViewDataSource, "It has a table view data source")
    }

    /// Tests the table view.
    func testTableView() throws {
        XCTAssertNotNil(aboutViewController?.tableView, "It exists")
        XCTAssertEqual(aboutViewController?.tableView.separatorColor, .colorHint, "It has the correct separator color")
        XCTAssertFalse(try require(aboutViewController?.tableView.allowsSelection), "It doesn't allow selection")
        XCTAssert(aboutViewController?.tableView.dataSource === aboutViewController?.tableViewDataSource, "It has the correct data source")
    }

    /// Tests the behavior when the 'exit' button is tapped.
    func testWhenExitButtonIsTapped() throws {
        let originalRootViewController = try require(UIApplication.shared.keyWindow?.rootViewController)
        let aboutViewController = try require(self.aboutViewController)

        // Presents the view controller under test
        originalRootViewController.present(aboutViewController, animated: false)
        XCTAssert(originalRootViewController.presentedViewController === aboutViewController, "It presents the view controller under test")

        // Sets the testing expectation
        let predicate = NSPredicate(format: "presentedViewController == nil")
        expectation(for: predicate, evaluatedWith: originalRootViewController)

        // Taps the exit button
        aboutViewController.exitButton.tap()

        // Sets the timeout for the expectation
        waitForExpectations(timeout: 5)

        // Confirms if the view controller under test is dismissed
        XCTAssertNil(originalRootViewController.presentedViewController, "It dismisses the view controller under test")
    }
}
