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
import XCTest

/// Tests the MulticastDelegate object.
final class MulticastDelegateTests: XCTestCase {
    /// The object under test.
    private var multicastDelegateUnderTest = MulticastDelegate<ProtocolMock>()

    // MARK: - Add

    /// Tests the `.add(_:)` method.
    func testAdd() {
        let object = ObjectMock()

        // Triggers the method
        multicastDelegateUnderTest.add(object)

        XCTAssertFalse(
            multicastDelegateUnderTest.isEmpty,
            "It adds the object."
        )

        XCTAssertEqual(
            multicastDelegateUnderTest.count, 1,
            "It adds the correct number of objects."
        )
    }

    /// Tests the `.add(_:)` method with multiple objects.
    func testAddWithMultipleObjects() {
        let objectA = ObjectMock()
        let objectB = ObjectMock()

        // Triggers the methods
        multicastDelegateUnderTest.add(objectA)
        multicastDelegateUnderTest.add(objectB)

        XCTAssertFalse(
            multicastDelegateUnderTest.isEmpty,
            "It adds the objects."
        )

        XCTAssertEqual(
            multicastDelegateUnderTest.count, 2,
            "It adds the correct number of objects."
        )
    }

    // MARK: - Remove

    /// Tests the `.remove(_:)` method.
    func testRemove() {
        let object = ObjectMock()

        // Triggers the methods
        multicastDelegateUnderTest.add(object)
        multicastDelegateUnderTest.remove(object)

        XCTAssertTrue(
            multicastDelegateUnderTest.isEmpty,
            "It doesn't have objects."
        )
        XCTAssertEqual(
            multicastDelegateUnderTest.count, 0,
            "It doesn't have objects."
        )
    }

    /// Tests the `.remove(_:)` method with multiple objects.
    func testRemoveWithMultipleObjects() {
        let objectA = ObjectMock()
        let objectB = ObjectMock()

        // Triggers the method
        multicastDelegateUnderTest.add(objectA)
        multicastDelegateUnderTest.add(objectB)
        multicastDelegateUnderTest.remove(objectA)
        multicastDelegateUnderTest.remove(objectB)

        XCTAssertTrue(
            multicastDelegateUnderTest.isEmpty,
            "It doesn't have objects."
        )
        XCTAssertEqual(
            multicastDelegateUnderTest.count, 0,
            "It doesn't have objects."
        )
    }

    // MARK: - Invoke

    /// Tests the `.invoke(_:)` method with multiple objects.
    func testInvoke() {
        let objectA = ObjectMock()
        let objectB = ObjectMock()
        var numberOfMethodsTriggered = 0

        multicastDelegateUnderTest.add(objectA)
        multicastDelegateUnderTest.add(objectB)

        // Triggers the method
        multicastDelegateUnderTest.invoke {
            numberOfMethodsTriggered += $0.method()
        }

        XCTAssertEqual(
            numberOfMethodsTriggered, 2,
            "It invokes the method for all the objects."
        )
    }

    // MARK: - Corner Cases

    /// Tests `.isEmpty` and `.count` when an object is added but later released.
    func testCountAndIsEmptyAfterReleasingTheObject() throws {
        var object: ObjectMock? = ObjectMock()

        multicastDelegateUnderTest.add(try require(object))

        // Releases the object
        object = nil

        XCTAssertTrue(
            multicastDelegateUnderTest.isEmpty,
            "It doesn't have objects."
        )
        XCTAssertEqual(
            multicastDelegateUnderTest.count, 0,
            "It doesn't have objects."
        )
    }

    /// Tests the `.invoke(_:)` method after releasing an object.
    func testInvokeAfterReleasingAnObject() throws {
        let objectA = ObjectMock()
        var objectB: ObjectMock? = ObjectMock()
        var numberOfMethodsTriggered = 0

        multicastDelegateUnderTest.add(objectA)
        multicastDelegateUnderTest.add(try require(objectB))

        // Releases the object
        objectB = nil

        // Triggers the method
        multicastDelegateUnderTest.invoke {
            numberOfMethodsTriggered += $0.method()
        }

        XCTAssertEqual(
            numberOfMethodsTriggered, 1,
            "It invokes the method for the non-null object."
        )
    }

    /// Tests `.add(_:)`, `.isEmpty` and `.count` when the type added isn't an reference type.
    func testWhenAStructConformingToProtocolIsAdded() {
        let anotherMulticastDelegateUnderTest = MulticastDelegate<AnotherProtocolMock>()
        let entity = StructMock()

        // Triggers the method
        anotherMulticastDelegateUnderTest.add(entity)

        XCTAssertTrue(
            anotherMulticastDelegateUnderTest.isEmpty,
            "It doesn't add the entity."
        )
        XCTAssertEqual(
            anotherMulticastDelegateUnderTest.count, 0,
            "It doesn't have entity."
        )
    }
}

// MARK: - Mocks

private protocol ProtocolMock: AnyObject {
    func method() -> Int
}

private class ObjectMock: ProtocolMock {
    func method() -> Int {
        1
    }
}

private protocol AnotherProtocolMock {}

private struct StructMock: AnotherProtocolMock {}
