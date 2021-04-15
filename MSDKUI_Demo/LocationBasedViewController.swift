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

import MSDKUI
import NMAKit
import UIKit

/// This protocol is intended for view controllers requiring location data.
protocol LocationBasedViewController: AnyObject {
    typealias CLAuthorizationStatusProvider = () -> CLAuthorizationStatus

    /// Flag that can enable/disable location permission checking if necessary.
    var isLocationMandatory: Bool { get set }

    /// The location authorization status provider.
    var locationAuthorizationStatusProvider: CLAuthorizationStatusProvider { get set }

    /// An object capable of opening URLs.
    var urlOpener: URLOpening { get set }

    /// Alert to be displayed when location permission is denied.
    var noLocationAlert: UIAlertController? { get set }

    /// The notification dispatch mechanism used to receive information.
    var notificationCenter: NotificationCenterObserving { get set }

    /// Observer for `.UIApplicationDidBecomeActive` notification.
    var appBecomeActiveObserver: NSObjectProtocol? { get set }

    /// Sets up authorization observer.
    func setUpLocationAuthorizationObserver()

    /// Doing cleanup before controller is removed.
    func cleanUpLocationAuthorizationObserver()

    /// Checks location authorization status.
    ///
    /// - Note: If `isLocationMandatory` flag is set to `false`, this method is always calling `locationAuthorizationGrantedAction`.
    func checkLocationAuthorizationStatus()

    /// Delegate method called when user cancels "no location" alert.
    ///
    /// - Important: Must be provided by the protocol implementer.
    func noLocationAlertCanceledAction()
}

// MARK: - UIViewController

extension LocationBasedViewController where Self: UIViewController {
    func setUpLocationAuthorizationObserver() {
        appBecomeActiveObserver = notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.checkLocationAuthorizationStatus()
        }
    }

    func cleanUpLocationAuthorizationObserver() {
        if let appBecomeActiveObserver = appBecomeActiveObserver {
            notificationCenter.removeObserver(appBecomeActiveObserver)
        }
        appBecomeActiveObserver = nil
    }

    func checkLocationAuthorizationStatus() {
        guard isLocationMandatory else {
            locationAuthorizationGrantedAction()
            return
        }

        // Check location authorization status and display alert if needed
        switch locationAuthorizationStatusProvider() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationAuthorizationGrantedAction()

        default:
            locationAuthorizationDeniedAction()
        }
    }

    // MARK: - Private

    /// The action to be taken when the location authorization granted.
    private func locationAuthorizationGrantedAction() {
        NMAPositioningManager.sharedInstance().startPositioning()
    }

    /// The action to be taken when the location authorization denied.
    private func locationAuthorizationDeniedAction() {
        // Display alert only if alert is not already displayed
        guard noLocationAlert == nil else {
            return
        }

        // Create new alert
        let alert = UIAlertController(
            title: "msdkui_app_userposition_notfound".localized,
            message: "msdkui_app_userposition_notfound_subtitle".localized,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "LocationBasedViewController.AlertController.permissionsView"

        alert.addAction(UIAlertAction(title: "msdkui_app_cancel".localized, style: .cancel) { [weak self] _ in
            self?.noLocationAlert = nil
            self?.noLocationAlertCanceledAction()
        })

        alert.addAction(UIAlertAction(title: "msdkui_app_settings".localized, style: .default) { [weak self] _ in
            // Display application settings
            self?.noLocationAlert = nil
            guard let urlGeneral = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            self?.urlOpener.open(urlGeneral, options: [:], completionHandler: nil)
        })

        noLocationAlert = alert
        present(alert, animated: true)
    }
}
