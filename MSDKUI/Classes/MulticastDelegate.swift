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

/// This generic class is designed to maintain an array of objects
/// all conforming to a common protocol. It uses a closure to invoke
/// the registered objects. Note that in the closure protocol-specific
/// handlings are expected to take place.
class MulticastDelegate<T> {

    // MARK: - Properties

    /// Returns the number of the delegates.
    var count: Int {
        delegates.allObjects.count
    }

    /// A Boolean value indicating whether the delegates collection is empty.
    var isEmpty: Bool {
        delegates.allObjects.isEmpty
    }

    /// All the `Weak` objects conforming to the delegate protocol.
    private var delegates = NSHashTable<AnyObject>(options: .weakMemory)

    // MARK: - Public

    /// Adds an object.
    ///
    /// - Parameter delegate: An object conforming to the protocol.
    func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    /// Removes an object.
    ///
    /// - Parameter delegate: An object conforming to the protocol.
    func remove(_ delegate: T) {
        delegates.remove(delegate as AnyObject)
    }

    /// Invokes all the registered objects with the closure passed.
    ///
    /// - Parameter invocation: The closure to be called for each object.
    func invoke(_ invocation: (T) -> Void) {
        // One-by-one for each delegate invoke the closure
        delegates.allObjects.forEach {
            let delegate = $0 as! T // swiftlint:disable:this force_cast
            invocation(delegate)
        }
    }
}
