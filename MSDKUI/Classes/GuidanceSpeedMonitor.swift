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

/// The protocol used to notify the delegate about changes on the speed and speed limit.
public protocol GuidanceSpeedMonitorDelegate: AnyObject {

    /// Notifies the delegate about changes on the speed and speed limit.
    ///
    /// - Parameters:
    ///   - monitor: The monitor announcing the changes.
    ///   - currentSpeed: The current speed.
    ///   - isSpeeding: A boolean indicating if the current speed is above the road speed limit.
    ///   - speedLimit: The lane speed limit, can be nil if no information is available
    func guidanceSpeedMonitor(_ monitor: GuidanceSpeedMonitor,
                              didUpdateCurrentSpeed currentSpeed: Measurement<UnitSpeed>,
                              isSpeeding: Bool,
                              speedLimit: Measurement<UnitSpeed>?)
}

/// Monitors and notifies the delegate about changes on speed and speed limit.
open class GuidanceSpeedMonitor: NSObject {

    // MARK: - Types

    /// The model used to store and compute speeds.
    private struct MonitorModel {

        // MARK: - Properties

        var currentSpeed: Measurement<UnitSpeed>
        var speedLimit: Measurement<UnitSpeed>?

        /// A boolean indicating if the current speed is above the road limit.
        var isSpeeding: Bool {
            guard let lastSpeedLimit = speedLimit else {
                return false
            }

            return currentSpeed > lastSpeedLimit
        }

        // MARK: - Public

        /// Creates and returns a `GuidanceSpeedMonitor.MonitorModel`.
        ///
        /// - Parameters:
        ///   - currentSpeed: The current speed.
        ///   - speedLimit: The route speed limit.
        init(currentSpeed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond), speedLimit: Measurement<UnitSpeed>? = nil) {
            self.currentSpeed = currentSpeed
            self.speedLimit = speedLimit
        }
    }

    // MARK: - Properties

    /// The delegate object which will receive the changes on speed and speed limit.
    public weak var delegate: GuidanceSpeedMonitorDelegate?

    /// The notification dispatch mechanism used to listen to notifications.
    private let notificationCenter: NotificationCenterObserving

    /// The positioning manager used to retrieve the current location.
    private let positioningManager: CurrentPositionProviding

    /// Reference to the `NMAPositioningManagerDidUpdatePosition` observer.
    private var positionUpdateObserver: NSObjectProtocol?

    /// The model used to store and compute speeds.
    private var model = MonitorModel()

    // MARK: - Public

    /// Creates and returns a `GuidanceSpeedMonitor` object.
    override public convenience init() {
        self.init(notificationCenter: NotificationCenter.default, positioningManager: NMAPositioningManager.sharedInstance())
    }

    /// Creates and returns a `GuidanceSpeedMonitor` object.
    ///
    /// - Parameters:
    ///   - notificationCenter: The notification center for observing position updates.
    ///   - positioningManager: The positioning manager for observing speed and speed limit updates.
    init(notificationCenter: NotificationCenterObserving, positioningManager: CurrentPositionProviding) {
        self.notificationCenter = notificationCenter
        self.positioningManager = positioningManager

        super.init()

        setUpSubscriptions()
    }

    deinit {
        // Removes the observer
        positionUpdateObserver.flatMap(notificationCenter.removeObserver)
    }

    // MARK: - Private

    /// Sets up subscriptions.
    private func setUpSubscriptions() {
        // Sets up the observer for position updates
        positionUpdateObserver = notificationCenter.addObserver(forName: .NMAPositioningManagerDidUpdatePosition,
                                                                object: nil,
                                                                queue: nil) { [weak self] _ in self?.handlePositionUpdate() }
    }

    /// Handle necessary changes after position update.
    private func handlePositionUpdate() {
        notifyCurrentSpeedChanges()
        notifySpeedLimitChanges()
    }

    /// Notifies the delegate about current speed changes if necessary.
    private func notifyCurrentSpeedChanges() {
        // Checks if the current speed is valid and different from its previous value, otherwise exit without updating the model and telling the delegate
        guard
            let currentSpeed = positioningManager.currentPosition?.speed,
            currentSpeed != NMAGeoPositionUnknownValue,
            case let speed = Measurement<UnitSpeed>(value: currentSpeed, unit: .metersPerSecond),
            speed != model.currentSpeed else {
                return
        }

        model.currentSpeed = speed
        delegate?.guidanceSpeedMonitor(self, didUpdateCurrentSpeed: model.currentSpeed, isSpeeding: model.isSpeeding, speedLimit: model.speedLimit)
    }

    /// Notifies the delegate about speed limit changes if necessary.
    private func notifySpeedLimitChanges() {
        var limit: Measurement<UnitSpeed>?

        // Checks if the speed limit is valid and sets the limit
        if let speedLimit = positioningManager.currentRoadElement()?.speedLimit, speedLimit > 0 {
            limit = Measurement<UnitSpeed>(value: Double(speedLimit), unit: .metersPerSecond)
        }

        // Checks if the speed limit is different from its previous value, otherwise exit without updating the model and telling the delegate
        guard limit != model.speedLimit else {
            return
        }

        model.speedLimit = limit
        delegate?.guidanceSpeedMonitor(self, didUpdateCurrentSpeed: model.currentSpeed, isSpeeding: model.isSpeeding, speedLimit: model.speedLimit)
    }
}
