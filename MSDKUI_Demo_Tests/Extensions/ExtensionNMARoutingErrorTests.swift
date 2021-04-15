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

// swiftlint:disable line_length

@testable import MSDKUI_Demo
import NMAKit
import XCTest

final class ExtensionNMARoutingErrorTests: XCTestCase {
    /// Tests the debugDescription for `.none`.
    func testNoneDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.none.debugDescription,
            "Error code \(NMARoutingError.none.rawValue). Possible reason: Route calculation succeeded."
        )
    }

    /// Tests the debugDescription for `.unknown`.
    func testUnknownDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.unknown.debugDescription,
            "Error code \(NMARoutingError.unknown.rawValue). Possible reason: Unknown error."
        )
    }

    /// Tests the debugDescription for `.outOfMemory`.
    func testOutOfMemoryDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.outOfMemory.debugDescription,
            "Error code \(NMARoutingError.outOfMemory.rawValue). Possible reason: Out-of-memory error."
        )
    }

    /// Tests the debugDescription for `.invalidParameters`.
    func testInvalidParametersDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.invalidParameters.debugDescription,
            "Error code \(NMARoutingError.invalidParameters.rawValue). Possible reason: Invalid parameters."
        )
    }

    /// Tests the debugDescription for `.invalidOperation`.
    func testInvalidOperationDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.invalidOperation.debugDescription,
            "Error code \(NMARoutingError.invalidOperation.rawValue). Possible reason: Another request already being processed."
        )
    }

    /// Tests the debugDescription for `.graphDisconnected`.
    func testGraphDisconnectedDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.graphDisconnected.debugDescription,
            "Error code \(NMARoutingError.graphDisconnected.rawValue). Possible reason: No route could be found."
        )
    }

    /// Tests the debugDescription for `.graphDisconnectedCheckOptions`.
    func testGraphDisconnectedCheckOptionsDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.graphDisconnectedCheckOptions.debugDescription,
            "Error code \(NMARoutingError.graphDisconnectedCheckOptions.rawValue). Possible reason: No route could be found, possibly due to some option preventing it."
        )
    }

    /// Tests the debugDescription for `.noStartPoint`.
    func testNoStartPointDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.noStartPoint.debugDescription,
            "Error code \(NMARoutingError.noStartPoint.rawValue). Possible reason: No starting waypoint could be found."
        )
    }

    /// Tests the debugDescription for `.noEndPoint`.
    func testNoEndPointDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.noEndPoint.debugDescription,
            "Error code \(NMARoutingError.noEndPoint.rawValue). Possible reason: No destination waypoint could be found."
        )
    }

    /// Tests the debugDescription for `.noEndPointCheckOptions`.
    func testNoEndPointCheckOptionsDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.noEndPointCheckOptions.debugDescription,
            "Error code \(NMARoutingError.noEndPointCheckOptions.rawValue). Possible reason: Destination point is unreachable, possibly due to some option preventing it."
        )
    }

    /// Tests the debugDescription for `.cannotDoPedestrian`.
    func testCannotDoPedestrianDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.cannotDoPedestrian.debugDescription,
            "Error code \(NMARoutingError.cannotDoPedestrian.rawValue). Possible reason: Pedestrian mode was specified yet is not practical."
        )
    }

    /// Tests the debugDescription for `.routingCancelled`.
    func testRoutingCancelledDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.routingCancelled.debugDescription,
            "Error code \(NMARoutingError.routingCancelled.rawValue). Possible reason: User cancelled the route calculation."
        )
    }

    /// Tests the debugDescription for `.violatesOptions`.
    func testViolatesOptionsDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.violatesOptions.debugDescription,
            "Error code \(NMARoutingError.violatesOptions.rawValue). Possible reason: Route calculation request included options that prohibit successful completion."
        )
    }

    /// Tests the debugDescription for `.routeCorrupted`.
    func testRouteCorruptedDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.routeCorrupted.debugDescription,
            "Error code \(NMARoutingError.routeCorrupted.rawValue). Possible reason: Service could not digest the requested route parameters."
        )
    }

    /// Tests the debugDescription for `.invalidCredentials`.
    func testInvalidCredentialsDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.invalidCredentials.debugDescription,
            "Error code \(NMARoutingError.invalidCredentials.rawValue). Possible reason: Invalid or missing HERE Developer credentials."
        )
    }

    /// Tests the debugDescription for `.insufficientMapData`.
    func testInsufficientMapDataDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.insufficientMapData.debugDescription,
            "Error code \(NMARoutingError.insufficientMapData.rawValue). Possible reason: Not enough local map data to perform route calculation."
        )
    }

    /// Tests the debugDescription for `.networkCommunication`.
    func testNetworkCommunicationDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.networkCommunication.debugDescription,
            "Error code \(NMARoutingError.networkCommunication.rawValue). Possible reason: Online route calculation request failed because of a networking error."
        )
    }

    /// Tests the debugDescription for `.unsupportedMapVersion`.
    func testUnsupportedMapVersionDebugDescription() {
        XCTAssertEqual(
            NMARoutingError.unsupportedMapVersion.debugDescription,
            "Error code \(NMARoutingError.unsupportedMapVersion.rawValue). Possible reason: Routing server does not support map version specified in request."
        )
    }
}

// swiftlint:enable line_length
