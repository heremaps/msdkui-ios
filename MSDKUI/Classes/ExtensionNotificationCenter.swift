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

/// This helper protocol is introduced to make testing with `NotificationCenter` easier.
public protocol NotificationCenterObserving {

    /// Adds an entry to the notification center's dispatch table that includes a notification
    /// queue and a block to add to the queue, and an optional notification name and sender.
    ///
    /// - Parameters:
    ///   - name: The name of the notification for which to register the observer; that is,
    ///           only notifications with this name are used to add the block to the operation queue.
    ///   - obj: The object whose notifications the observer wants to receive; that is, only
    ///          notifications sent by this sender are delivered to the observer.
    ///   - queue: The operation queue to which block should be added.
    ///   - block: The block to be executed when the notification is received.
    /// - Returns: An opaque object to act as the observer.
    func addObserver(forName name: NSNotification.Name?,
                     object obj: Any?,
                     queue: OperationQueue?,
                     using block: @escaping (Notification) -> Void) -> NSObjectProtocol

    /// Removes all entries specifying a given observer from the notification center's dispatch table.
    ///
    /// - Parameter observer: The observer to remove.
    func removeObserver(_ observer: Any)
}

extension NotificationCenter: NotificationCenterObserving {}
