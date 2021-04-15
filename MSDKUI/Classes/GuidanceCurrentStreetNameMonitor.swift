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
import NMAKit

/// The protocol used to notify the delegate about changes in the current street name.
public protocol GuidanceCurrentStreetNameMonitorDelegate: AnyObject {

    /// Notifies the delegate about changes of the current street name.
    ///
    /// - Parameters:
    ///   - monitor: The monitor announcing the changes.
    ///   - currentStreetName: The current street name.
    func guidanceCurrentStreetNameMonitor(_ monitor: GuidanceCurrentStreetNameMonitor, didUpdateCurrentStreetName currentStreetName: String?)
}

/// Monitors and notifies the delegate about changes of the current street name.
open class GuidanceCurrentStreetNameMonitor: NSObject {

    // MARK: - Properties

    /// The delegate object which will receive the current street name changes.
    public weak var delegate: GuidanceCurrentStreetNameMonitorDelegate?

    private let navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatching

    // MARK: - Public

    /// Creates and returns a new instance of the current street name monitor.
    override public convenience init() {
        self.init(navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatcher.shared)
    }

    init(navigationManagerDelegateDispatcher: NavigationManagerDelegateDispatching) {
        self.navigationManagerDelegateDispatcher = navigationManagerDelegateDispatcher

        super.init()

        self.navigationManagerDelegateDispatcher.add(delegate: self)
    }

    deinit {
        navigationManagerDelegateDispatcher.remove(delegate: self)
    }
}

// MARK: - NMANavigationManagerDelegate

extension GuidanceCurrentStreetNameMonitor: NMANavigationManagerDelegate {

    public func navigationManager(_ navigationManager: NMANavigationManager, didUpdateManeuvers currentManeuver: NMAManeuver?, _ nextManeuver: NMAManeuver?) {
        delegate?.guidanceCurrentStreetNameMonitor(self, didUpdateCurrentStreetName: currentManeuver?.getCurrentStreet())
    }
}
