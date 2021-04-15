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

extension NMARoutingError: CustomDebugStringConvertible {
    public var debugDescription: String {
        let reason: String

        switch self {
        case .none:
            reason = "Route calculation succeeded."
        case .unknown:
            reason = "Unknown error."
        case .outOfMemory:
            reason = "Out-of-memory error."
        case .invalidParameters:
            reason = "Invalid parameters."
        case .invalidOperation:
            reason = "Another request already being processed."
        case .graphDisconnected:
            reason = "No route could be found."
        case .graphDisconnectedCheckOptions:
            reason = "No route could be found, possibly due to some option preventing it."
        case .noStartPoint:
            reason = "No starting waypoint could be found."
        case .noEndPoint:
            reason = "No destination waypoint could be found."
        case .noEndPointCheckOptions:
            reason = "Destination point is unreachable, possibly due to some option preventing it."
        case .cannotDoPedestrian:
            reason = "Pedestrian mode was specified yet is not practical."
        case .routingCancelled:
            reason = "User cancelled the route calculation."
        case .violatesOptions:
            reason = "Route calculation request included options that prohibit successful completion."
        case .routeCorrupted:
            reason = "Service could not digest the requested route parameters."
        case .invalidCredentials:
            reason = "Invalid or missing HERE Developer credentials."
        case .insufficientMapData:
            reason = "Not enough local map data to perform route calculation."
        case .networkCommunication:
            reason = "Online route calculation request failed because of a networking error."
        case .unsupportedMapVersion:
            reason = "Routing server does not support map version specified in request."
        @unknown default:
            reason = "Unknown."
        }

        return "Error code \(rawValue). Possible reason: \(reason)"
    }
}
