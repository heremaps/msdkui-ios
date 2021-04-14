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
@testable import MSDKUI

final class NotificationCenterObservingMock {
    private(set) var didCallAddObserver = false
    private(set) var didCallRemoveObserver = false

    private(set) var didCallAddObserverCount = 0

    private(set) var lastNotificationName: NSNotification.Name?
    private(set) var lastObject: Any?
    private(set) var lastQueue: OperationQueue?
    private(set) var lastBlock: ((Notification) -> Void)?
    private(set) var lastObserver: Any?
}

// MARK: - NotificationCenterObserving

extension NotificationCenterObservingMock: NotificationCenterObserving {
    func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NSObjectProtocol {
        didCallAddObserver = true
        didCallAddObserverCount += 1

        lastNotificationName = name
        lastObject = obj
        lastQueue = queue
        lastBlock = block

        return NSObject()
    }

    func removeObserver(_ observer: Any) {
        didCallRemoveObserver = true
        lastObserver = observer
    }
}
