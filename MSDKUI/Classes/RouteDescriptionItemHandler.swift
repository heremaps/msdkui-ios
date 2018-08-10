//
// Copyright (C) 2017-2018 HERE Europe B.V.
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

/// Helps to convert the route data into a usable format for a `RouteDescriptionItem` object. Note
/// that it is used internally and only by the `RouteDescriptionItem` objects.
struct RouteDescriptionItemHandler {
    /// The route object which provides the main data.
    let route: NMARoute

    /// The time to arrival time interval in seconds of the route.
    let tta: NMARouteTta?

    /// If a delay in seconds is reported, this property provides it.
    var delaySeconds: TimeInterval = -1

    /// Time it takes to reach the destination.
    ///
    /// - Important: When the arrival data is unknown, "Unknown" in the current language is returned.
    var duration: String {
        if let tta = self.tta {
            return tta.duration.stringize
        } else {
            return "msdkui_unknown".localized
        }
    }

    /// Date and time of the estimated arrival.
    ///
    /// - Important: When the arrival data is unknown, "Unknown" in the current language is returned.
    var arrivalTime: String {
        var date: Date?

        if let tta = self.tta, let departureTime = route.routingMode.departureTime {
            date = Date(timeInterval: tta.duration, since: departureTime)
        }

        // Convert the date to a string
        return date?.formatted() ?? "msdkui_unknown".localized
    }

    /// Formatted message that explains how much traffic delay is included in the arrival estimation.
    var trafficDelay: String {
        var delayString = ""

        if let tta = self.tta {
            if tta.isBlocked {
                delayString = "msdkui_traffic_blocked".localized
            } else if delaySeconds != -1 { // Is a delay found?
                if delaySeconds < 60 { // Ignore less than a min delays
                    delayString = "msdkui_no_traffic_delays".localized
                } else {
                    delayString = String(format: "msdkui_incl_traffic_delay".localized, delaySeconds.stringize)
                }
            }
        }

        return delayString
    }

    /// Has actual delay or not.
    var hasDelay: Bool {
        return delaySeconds > 60
    }

    /// Graphical representation of the transportation mode.
    var icon: UIImage {
        var imageName = ""

        switch route.routingMode.transportMode {
        case .car:
            imageName = "TransportModePanel.car"

        case .pedestrian:
            imageName = "TransportModePanel.pedestrian"

        case .truck:
            imageName = "TransportModePanel.truck"

        case .bike:
            imageName = "TransportModePanel.bike"

        case .scooter:
            imageName = "TransportModePanel.scooter"

        default:
            assertionFailure("Unsupported option!")
        }

        // Create the image in the template mode for customization as the backgroundColor and tintColor
        // properties works well with layered images
        return UIImage(named: imageName, in: .MSDKUI, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
    }

    /// Stringize the selected icon for better accessibility support.
    var iconDescription: String? {
        switch route.routingMode.transportMode {
        case .car:
            return "msdkui_car".localized

        case .pedestrian:
            return "msdkui_pedestrian".localized

        case .truck:
            return "msdkui_truck".localized

        case .bike:
            return "msdkui_bike".localized

        case .scooter:
            return "msdkui_scooter".localized

        default:
            assertionFailure("Unsupported option!")
            return nil
        }
    }

    /// Length of the route in meters or in kilometers.
    var length: String {
        // route.length is NSUInteger
        return Utils.formatDistance(Int(route.length))
    }

    /// Inits the handler.
    ///
    /// - Parameter route: The route object to be used.
    /// - Parameter traffic: Whether traffic should be included in the arrival time or not.
    init(for route: NMARoute, with trafficEnabled: Bool) {
        // swiftformat:disable redundantSelf
        self.route = route
        self.tta = route.tta(withTraffic: trafficEnabled ? .optimal : .disabled)

        if let tta = self.tta {
            // Is the route blocked?
            if tta.isBlocked == false {
                // Should calculate the delay?
                if trafficEnabled {
                    // If the transport mode is bike or pedestrian or the time is not within the limits, do nothing
                    if route.routingMode.transportMode != .bike && route.routingMode.transportMode != .pedestrian && isDepartureNearCurrentTime() {
                        if let noTrafficTta = route.tta(withTraffic: .disabled) {
                            delaySeconds = tta.duration - noTrafficTta.duration
                        }
                    }
                }
            }
        }
        // swiftformat:enable redundantSelf
    }

    /// If the departure time is set well into the future, we don't have any traffic data at all. In this case, naturally
    /// delaySeconds = 0 and we would display "No delays". However, it is misleading completely: there is no traffic data!
    /// So, we need to know whether the departure time is reasonable to expect the traffic data or not.
    private func isDepartureNearCurrentTime() -> Bool {
        var verdict = false

        // Is the departure within the limit seconds of the current time?
        if let time = route.routingMode.departureTime {
            // Only if we are within now ± the limit seconds, we consider that we have the traffic data:
            // we don't want to show "No delays" whenever delay seconds is 0
            let pastLimitSeconds = Double(-5 * 60) // -5 minutes
            let futureLimitSeconds = Double(30 * 60) // +30 minutes
            let interval = time.timeIntervalSinceNow

            verdict = pastLimitSeconds < interval && interval < futureLimitSeconds
        }

        return verdict
    }
}
