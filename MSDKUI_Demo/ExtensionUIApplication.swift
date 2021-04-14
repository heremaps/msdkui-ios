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

import UIKit

/// This protocol is introduced to make testing the URL opening feature easier.
protocol URLOpening {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Swift.Void)?)
}

/// This protocol is introduced to make testing the idle timer disabling feature easier.
protocol IdleTimerDisabling {
    var isIdleTimerDisabled: Bool { get set }
}

extension UIApplication: URLOpening, IdleTimerDisabling {}
