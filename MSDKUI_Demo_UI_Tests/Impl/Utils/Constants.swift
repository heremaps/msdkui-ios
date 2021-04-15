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

import NMAKit

enum Constants {

    static let shortWait = CFTimeInterval(5.0)
    static let mediumWait = CFTimeInterval(20.0)
    static let longWait = CFTimeInterval(40.0)

    static let smallPollInterval = Double(0.5)
    static let mediumPollInterval = Double(2.0)
    static let longPollInterval = Double(3.0)

    static let longPressDuration = Double(2.0)

    static let aPointOnMapView = CGPoint(x: 100, y: 300)

    static let normalUpdateIntervalForEarlGrey = TimeInterval(11)
    static let fastUpdateIntervalForEarlGrey = TimeInterval(1)

    static let normalSimulationSpeed = Float(6)
    static let fastSimulationSpeed = Float(8)
    static let slowSimulationSpeed = Float(2)
}
