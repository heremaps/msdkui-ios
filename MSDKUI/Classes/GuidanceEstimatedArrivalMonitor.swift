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

/// The protocol used to notify the delegate about changes on the estimated arrival at the destination.
public protocol GuidanceEstimatedArrivalMonitorDelegate: AnyObject {

    /// Notifies the delegate about changes on the estimated arrival to the destination.
    ///
    /// - Parameters:
    ///   - monitor: The monitor announcing the changes.
    ///   - timeOfArrival: The estimated time of arrival at the destination.
    ///   - distance: The distance to the destination.
    ///   - duration: The duration of the trip to the destination.
    func guidanceEstimatedArrivalMonitor(_ monitor: GuidanceEstimatedArrivalMonitor,
                                         didChangeTimeOfArrival timeOfArrival: Date?,
                                         distance: Measurement<UnitLength>?,
                                         duration: Measurement<UnitDuration>?)
}

/// Monitors and notifies the delegate about changes on the estimated arrival at the destination.
open class GuidanceEstimatedArrivalMonitor {

    // MARK: - Properties

    /// The delegate object which will receive the estimated arrival changes.
    public weak var delegate: GuidanceEstimatedArrivalMonitorDelegate?

    /// The notification dispatch mechanism used to listen to notifications.
    private let notificationCenter: NotificationCenterObserving

    /// The estimated arrival provider used to receive navigation information.
    private let estimatedArrivalProvider: EstimatedArrivalProviding

    /// Reference to the 'NMAPositioningManagerDidUpdatePosition' observer.
    private var positionUpdateObserver: NSObjectProtocol?

    // MARK: - Public

    /// Creates and returns a `GuidanceEstimatedArrivalMonitor` object.
    public convenience init() {
        self.init(notificationCenter: NotificationCenter.default, estimatedArrivalProvider: NMANavigationManager.sharedInstance())
    }

    /// Creates and returns a `GuidanceEstimatedArrivalMonitor` object.
    ///
    /// - Parameters:
    ///   - notificationCenter: The notification center for observing position updates.
    ///   - estimatedArrivalProvider: The estimated arrival provider for duration, distance and time of arrival data.
    init(notificationCenter: NotificationCenterObserving, estimatedArrivalProvider: EstimatedArrivalProviding) {
        self.notificationCenter = notificationCenter
        self.estimatedArrivalProvider = estimatedArrivalProvider

        setUpPositionUpdateObserver()
    }

    deinit {
        // Removes the observer
        positionUpdateObserver.flatMap(notificationCenter.removeObserver)
    }

    // MARK: - Private

    /// Sets up the observer for position updates.
    private func setUpPositionUpdateObserver() {
        positionUpdateObserver = notificationCenter.addObserver(forName: .NMAPositioningManagerDidUpdatePosition,
                                                                object: nil,
                                                                queue: nil) { [weak self] _ in self?.notifyEstimatedArrivalChanges() }
    }

    /// Notifies the delegate about estimated arrival changes.
    private func notifyEstimatedArrivalChanges() {
        var timeOfArrival: Date?
        var duration: Measurement<UnitDuration>?
        var distance: Measurement<UnitLength>?

        let timeToArrival = estimatedArrivalProvider.timeToArrival(withTraffic: .optimal, wholeRoute: true)

        if timeToArrival != -.greatestFiniteMagnitude {
            timeOfArrival = Date().addingTimeInterval(timeToArrival)
            duration = Measurement<UnitDuration>(value: timeToArrival, unit: .seconds)
        }

        if estimatedArrivalProvider.distanceToDestination != NMANavigationManagerInvalidValue {
            distance = Measurement<UnitLength>(value: Double(estimatedArrivalProvider.distanceToDestination), unit: .meters)
        }

        delegate?.guidanceEstimatedArrivalMonitor(self, didChangeTimeOfArrival: timeOfArrival, distance: distance, duration: duration)
    }
}
