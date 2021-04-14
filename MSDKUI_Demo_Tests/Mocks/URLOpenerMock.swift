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

@testable import MSDKUI_Demo
import UIKit

/// Mock URL Openener used to check URLOpening expectations.
final class URLOpenerMock {
    private(set) var didCallOpen = false

    private(set) var lastURL: URL?
    private(set) var lastOptions: [UIApplication.OpenExternalURLOptionsKey: Any]? // swiftlint:disable:this discouraged_optional_collection
    private(set) var lastCompletionHandler: ((Bool) -> Void)?
}

// MARK: - URLOpening

extension URLOpenerMock: URLOpening {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        didCallOpen = true
        lastURL = url
        lastOptions = options
        lastCompletionHandler = completion
    }
}
