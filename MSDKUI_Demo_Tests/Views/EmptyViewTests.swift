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

@testable import MSDKUI_Demo
import XCTest

final class EmptyViewTests: XCTestCase {
    /// The view under test.
    private let view = EmptyView(frame: CGRect(x: 0, y: 0, width: 375, height: 255))

    // MARK: - Tests

    /// Tests the view default colors.
    func testViewColors() {
        XCTAssertEqual(view.backgroundColor, .colorBackgroundLight, "The default background color is correct")
        XCTAssertEqual(view.titleColor, .colorForeground, "The default title color is correct")
        XCTAssertEqual(view.subtitleColor, .colorForegroundSecondary, "The default subtitle color is correct")
    }

    /// Tests the title label.
    func testTitleLabel() {
        XCTAssertEqual(view.titleLabel.textColor, view.titleColor, "It matches the view title color")
        XCTAssertEqual(view.titleLabel.numberOfLines, 0, "It supports multiple lines")
    }

    /// Tests the subtitle label.
    func testSubtitleLabel() {
        XCTAssertEqual(view.subtitleLabel.textColor, view.subtitleColor, "It matches the view subtitle color")
        XCTAssertEqual(view.subtitleLabel.numberOfLines, 0, "It supports multiple lines")
    }

    /// Tests if the view configuration works as expected.
    func testConfiguration() {
        /// The view model used for configuring `view`.
        let viewModel = EmptyView.ViewModel(
            image: UIImage(),
            title: "Title Test",
            subtitle: "Subtitle Test"
        )

        view.configure(with: viewModel)

        XCTAssertEqual(view.imageView.image, viewModel.image, "The image is correctly set")
        XCTAssertEqual(view.titleLabel.text, viewModel.title, "The title is correctly set")
        XCTAssertEqual(view.subtitleLabel.text, viewModel.subtitle, "The subtitle is correctly set")
    }

    /// Tests if custom styling works as expected.
    func testCustomStyle() {
        let titleColor = UIColor.red
        let subtitleColor = UIColor.blue

        view.titleColor = titleColor
        view.subtitleColor = subtitleColor

        XCTAssertEqual(view.titleLabel.textColor, titleColor, "The custom title color is correct")
        XCTAssertEqual(view.subtitleLabel.textColor, subtitleColor, "The custom subtitle color is correct")
    }

    /// Tests the accessibility.
    func testAccessibility() {
        XCTAssertTrue(view.isAccessibilityElement, "The view is a accessibility element")

        XCTAssertEqual(
            view.accessibilityIdentifier, "EmptyView",
            "The view has the correct accessibility identifier"
        )

        XCTAssertEqual(
            view.accessibilityTraits, .none,
            "The view has the correct accessibility traits"
        )

        let accessibilityLabel = "\("msdkui_app_routeplanner_getdirections".localized), \("msdkui_app_routeplanner_startchoosingwaypoint".localized)"

        XCTAssertEqual(
            view.accessibilityLabel, accessibilityLabel,
            "The view has the correct accessibility label"
        )
    }

    /// Tests if the `imageView` visibility changes when the vertical trait collection changes.
    func testImageVisibilityChangesWhenVerticalTraitCollectionChanges() {
        let viewController = UIViewController()
        viewController.view.addSubview(view)

        let navigationController = UINavigationController(rootViewController: viewController)

        // Strangely, the `viewController` should be visible for the tests. Why?
        let originalRootViewController = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController

        // Expect hidden `view.imageView` in compact vertical trait collection
        let hiddenImageViewExpectation = keyValueObservingExpectation(
            for: view.imageView as Any,
            keyPath: #keyPath(UIView.isHidden),
            expectedValue: true
        )

        // Inject the compact vertical trait collection
        let compactTraitCollection = UITraitCollection(verticalSizeClass: .compact)
        navigationController.setOverrideTraitCollection(compactTraitCollection, forChild: viewController)

        wait(for: [hiddenImageViewExpectation], timeout: 5)

        // Expect visible `view.imageView` in regular vertical trait collection
        let visibleImageViewExpectation = keyValueObservingExpectation(
            for: view.imageView as Any,
            keyPath: #keyPath(UIView.isHidden),
            expectedValue: false
        )

        // Inject the regular vertical trait collection
        let regularTraitCollection = UITraitCollection(verticalSizeClass: .regular)
        navigationController.setOverrideTraitCollection(regularTraitCollection, forChild: viewController)

        wait(for: [visibleImageViewExpectation], timeout: 5)

        // Restore
        UIApplication.shared.keyWindow?.rootViewController = originalRootViewController
    }
}
