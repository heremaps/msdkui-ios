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

final class ManeuverResourcesTest: XCTestCase {
    private var maneuverResources: ManeuverResources?

    // MARK: - Tests

    func testJunctionTurnHeavyLeft() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.heavyLeft, expectedString: "msdkui_maneuver_turn_sharply_left".localized)
    }

    func testJunctionTurnHeavyRight() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.heavyRight, expectedString: "msdkui_maneuver_turn_sharply_right".localized)
    }

    func testJunctionTurnKeepLeft() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.keepLeft, expectedString: "msdkui_maneuver_turn_keep_left".localized)
    }

    func testJunctionTurnKeepMiddle() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.keepMiddle, expectedString: "msdkui_maneuver_turn_keep_middle".localized)
    }

    func testJunctionTurnKeepRight() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.keepRight, expectedString: "msdkui_maneuver_turn_keep_right".localized)
    }

    func testJunctionTurnLightLeft() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.lightLeft, expectedString: "msdkui_maneuver_turn_slightly_left".localized)
    }

    func testJunctionTurnLightRight() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.lightRight, expectedString: "msdkui_maneuver_turn_slightly_right".localized)
    }

    func testJunctionTurnQuiteLeft() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.quiteLeft, expectedString: "msdkui_maneuver_turn_left".localized)
    }

    func testJunctionTurnQuiteRight() {
        junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn.quiteRight, expectedString: "msdkui_maneuver_turn_right".localized)
    }

    func testManeuverActionChangeHighway() {
        maneuverAction(maneuverAction: NMAManeuverAction.changeHighway, expectedString: "msdkui_maneuver_continue".localized)
    }

    func testManeuverActionChangeHighwayKeepLeft() {
        maneuverActionTurn(
            maneuverAction: NMAManeuverAction.changeHighway, maneuverTurn: NMAManeuverTurn.keepLeft,
            expectedString: "msdkui_maneuver_turn_keep_left".localized
        )
    }

    func testManeuverActionContinueHighway() {
        maneuverAction(maneuverAction: NMAManeuverAction.changeHighway, expectedString: "msdkui_maneuver_continue".localized)
    }

    func testManeuverActionContinueHighwayKeepRight() {
        maneuverActionTurn(
            maneuverAction: NMAManeuverAction.changeHighway, maneuverTurn: NMAManeuverTurn.keepRight,
            expectedString: "msdkui_maneuver_turn_keep_right".localized
        )
    }

    func testManeuverActionEnd() {
        maneuverAction(maneuverAction: NMAManeuverAction.end, expectedString: "msdkui_maneuver_arrive_at_02y".localized)
    }

    func testManeuverEnterHighway() {
        maneuverAction(maneuverAction: NMAManeuverAction.enterHighway, expectedString: "msdkui_maneuver_enter_highway".localized)
    }

    func testManeuverEnterHighwayFromLeft() {
        maneuverAction(maneuverAction: NMAManeuverAction.enterHighwayFromLeft, expectedString: "msdkui_maneuver_turn_keep_right".localized)
    }

    func testManeuverEnterHighwayFromRight() {
        maneuverAction(maneuverAction: NMAManeuverAction.enterHighwayFromRight, expectedString: "msdkui_maneuver_turn_keep_left".localized)
    }

    func testManeuverLeaveHighway() {
        maneuverAction(maneuverAction: NMAManeuverAction.leaveHighway, expectedString: "msdkui_maneuver_leave_highway".localized)
    }

    func testManeuverActionFerryForFerries() {
        maneuverAction(maneuverAction: NMAManeuverAction.ferry, expectedString: "msdkui_maneuver_enter_ferry".localized)
    }

    func testManeuverActionUturn() {
        maneuverAction(maneuverAction: NMAManeuverAction.uTurn, expectedString: "msdkui_maneuver_uturn".localized)
    }

    func testRoundabout1() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout1, expectedString: "msdkui_maneuver_turn_roundabout_exit_1".localized)
    }

    func testRoundabout2() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout2, expectedString: "msdkui_maneuver_turn_roundabout_exit_2".localized)
    }

    func testRoundabout3() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout3, expectedString: "msdkui_maneuver_turn_roundabout_exit_3".localized)
    }

    func testRoundabout4() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout4, expectedString: "msdkui_maneuver_turn_roundabout_exit_4".localized)
    }

    func testRoundabout5() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout5, expectedString: "msdkui_maneuver_turn_roundabout_exit_5".localized)
    }

    func testRoundabout6() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout6, expectedString: "msdkui_maneuver_turn_roundabout_exit_6".localized)
    }

    func testRoundabout7() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout7, expectedString: "msdkui_maneuver_turn_roundabout_exit_7".localized)
    }

    func testRoundabout8() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout8, expectedString: "msdkui_maneuver_turn_roundabout_exit_8".localized)
    }

    func testRoundabout9() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout9, expectedString: "msdkui_maneuver_turn_roundabout_exit_9".localized)
    }

    func testRoundabout10() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout10, expectedString: "msdkui_maneuver_turn_roundabout_exit_10".localized)
    }

    func testRoundabout11() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout11, expectedString: "msdkui_maneuver_turn_roundabout_exit_11".localized)
    }

    func testRoundabout12() {
        roundAboutActionTest(maneuverTurn: NMAManeuverTurn.roundabout12, expectedString: "msdkui_maneuver_turn_roundabout_exit_12".localized)
    }

    func testUndefinedManeuverAction() {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.undefined, with: NMAManeuverTurn.undefined)
        fallthroughManeuverAction(maneuver: maneuver)
    }

    func testNoActionManeuverAction() {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.none, with: NMAManeuverTurn.undefined)
        fallthroughManeuverAction(maneuver: maneuver)
    }

    func testUndefinedTurnManeuverAction() {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.junction, with: NMAManeuverTurn.undefined)
        fallthroughManeuverAction(maneuver: maneuver)
    }

    func testUndefinedRoundaboutManeuverAction() {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.roundabout, with: NMAManeuverTurn.undefined)
        fallthroughManeuverAction(maneuver: maneuver)
    }

    // MARK: - Private

    private func maneuverAction(maneuverAction: NMAManeuverAction, expectedString: String) {
        let maneuver = MockUtils.mockManeuver(maneuverAction, with: NMAManeuverTurn.none)
        maneuverResources = ManeuverResources(maneuvers: [maneuver])
        let maneuverInstruction = maneuverResources?.getInstruction(for: 0)

        XCTAssertEqual(maneuverInstruction, expectedString, "Action instruction is not correct")
    }

    private func maneuverActionTurn(
        maneuverAction: NMAManeuverAction,
        maneuverTurn: NMAManeuverTurn,
        expectedString: String
    ) {
        let maneuver = MockUtils.mockManeuver(maneuverAction, with: maneuverTurn)
        maneuverResources = ManeuverResources(maneuvers: [maneuver])
        let maneuverInstruction = maneuverResources?.getInstruction(for: 0)

        XCTAssertEqual(maneuverInstruction, expectedString, "Action instruction is not correct")
    }

    private func roundAboutActionTest(maneuverTurn: NMAManeuverTurn, expectedString: String) {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.roundabout, with: maneuverTurn)
        maneuverResources = ManeuverResources(maneuvers: [maneuver])
        let maneuverInstruction = maneuverResources?.getInstruction(for: 0)

        XCTAssertEqual(maneuverInstruction, expectedString, "Round about instruction is not correct")
    }

    private func junctionManeuverTurnTest(maneuverTurn: NMAManeuverTurn, expectedString: String) {
        let maneuver = MockUtils.mockManeuver(NMAManeuverAction.junction, with: maneuverTurn)
        maneuverResources = ManeuverResources(maneuvers: [maneuver])
        let maneuverInstruction = maneuverResources?.getInstruction(for: 0)

        XCTAssertEqual(maneuverInstruction, expectedString, "Junction instruction is not correct")
    }

    private func fallthroughManeuverAction(maneuver: NMAManeuver) {
        maneuverResources = ManeuverResources(maneuvers: [maneuver])
        let maneuverInstruction = maneuverResources?.getInstruction(for: 0)

        XCTAssertLocalized(
            maneuverInstruction,
            formatKey: "msdkui_maneuver_head_to",
            arguments: "msdkui_maneuver_orientation_north".localized,
            bundle: .MSDKUI,
            message: "Failed instruction is not correct"
        )
    }
}
