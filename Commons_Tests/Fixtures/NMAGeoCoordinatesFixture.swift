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

enum NMAGeoCoordinatesFixture {
    static func berlinNaturekundemuseum() -> NMAGeoCoordinates {
        NMAGeoCoordinates(latitude: 52.530555, longitude: 13.379257)
    }

    static func berlinReichstag() -> NMAGeoCoordinates {
        NMAGeoCoordinates(latitude: 52.518620, longitude: 13.376187)
    }

    static func berlinCenter() -> NMAGeoCoordinates {
        NMAGeoCoordinates(latitude: 52.52, longitude: 13.405)
    }

    static func berlinSophienStrasse() -> NMAGeoCoordinates {
        NMAGeoCoordinates(latitude: 52.525080, longitude: 13.402928)
    }
}
