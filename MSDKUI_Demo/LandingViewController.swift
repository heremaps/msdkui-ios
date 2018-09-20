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

import MSDKUI
import UIKit

class LandingViewController: UIViewController {
    enum Constants {
        // After all the layout calculations are done, a card's height cant't
        // be less than this value
        static let minCardViewHeight = CGFloat(240)

        // When a crad is tapped, flash it with this period
        static let cardFlashPeriodMilliSeconds = 75
    }

    @IBOutlet private(set) var titleItem: UINavigationItem!

    @IBOutlet private(set) var infoButton: UIBarButtonItem!

    @IBOutlet private(set) var scrollView: UIScrollView!

    @IBOutlet private(set) var routePlannerViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private(set) var driveNavHeightConstraint: NSLayoutConstraint!

    @IBOutlet private(set) var routePannerView: UIView!

    @IBOutlet private(set) var routePlannerTitleLabel: UILabel!

    @IBOutlet private(set) var routePlannerSubtitleLabel: UILabel!

    @IBOutlet private(set) var routePlannerActionLabel: UILabel!

    @IBOutlet private(set) var routePlannerImageView: UIImageView!

    @IBOutlet private(set) var driveNavView: UIView!

    @IBOutlet private(set) var driveNavTitleLabel: UILabel!

    @IBOutlet private(set) var driveNavSubtitleLabel: UILabel!

    @IBOutlet private(set) var driveNavActionLabel: UILabel!

    @IBOutlet private(set) var driveNavImageView: UIImageView!

    var isCardHandling = false

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        updateStyle()
        setAccessibility()

        // Add the tap gesture recognizers to the cards
        let tapGestureRecognizerRoutePanner = UITapGestureRecognizer(target: self, action: #selector(handleRoutePannerTap))
        routePannerView.addGestureRecognizer(tapGestureRecognizerRoutePanner)

        let tapGestureRecognizerDriveNav = UITapGestureRecognizer(target: self, action: #selector(handleDriveNavTap))
        driveNavView.addGestureRecognizer(tapGestureRecognizerDriveNav)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // At which orientation initially?
        adapToOrientation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Momentarily flash the scroll view indicators and make sure it scrolls to the top
        scrollView.flashScrollIndicators()
        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ShowDriveNav" {
            guard let viewController = segue.destination as? WaypointViewController else {
                return
            }

            // Init the vc
            viewController.controllerTitle = "msdkui_app_guidance_waypoint_title".localized
            viewController.controllerInfoString = "msdkui_app_guidance_waypoint_subtitle".localized
            viewController.exitButtonTitle = "msdkui_app_exit".localized
            viewController.performSegueAfterOK = "ShowRouteOverview"
        }
    }

    @IBAction private func unwindToLandingViewController(segue _: UIStoryboardSegue) {
    }

    @IBAction private func showAboutViewController(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AboutSegue", sender: self)
    }

    @objc func handleRoutePannerTap(sender _: UITapGestureRecognizer) {
        handleTap(view: routePannerView, segue: "ShowRoutePlanner")
    }

    @objc func handleDriveNavTap(sender _: UITapGestureRecognizer) {
        handleTap(view: driveNavView, segue: "ShowDriveNav")
    }

    func localize() {
        titleItem.title = "msdkui_app_name_title".localized

        routePlannerTitleLabel.text = "msdkui_app_rp_teaser_title".localized
        routePlannerSubtitleLabel.text = "msdkui_app_rp_teaser_description".localized
        routePlannerActionLabel.text = "msdkui_app_teaser_link".localized

        driveNavTitleLabel.text = "msdkui_app_guidance_teaser_title".localized
        driveNavSubtitleLabel.text = "msdkui_app_guidance_teaser_description".localized
        driveNavActionLabel.text = "msdkui_app_teaser_link".localized
    }

    func setAccessibility() {
        infoButton.accessibilityLabel = "msdkui_app_info".localized
        infoButton.accessibilityIdentifier = "LandingViewController.info"

        // Card subviews are not accessibility elements

        routePannerView.subviews.forEach {
            $0.isAccessibilityElement = false
        }
        driveNavView.subviews.forEach {
            $0.isAccessibilityElement = false
        }

        // For each card, make sure the whole card is the accessibility element
        // and combine the label texts with dots for better reading

        routePannerView.isAccessibilityElement = true
        routePannerView.accessibilityLabel = routePlannerTitleLabel.text! + "." +
            routePlannerSubtitleLabel.text! + "." +
            routePlannerActionLabel.text!
        routePannerView.accessibilityIdentifier = "LandingViewController.routePanner"

        driveNavView.isAccessibilityElement = true
        driveNavView.accessibilityLabel = driveNavTitleLabel.text! + "." +
            driveNavSubtitleLabel.text! + "." +
            driveNavActionLabel.text!
        driveNavView.accessibilityIdentifier = "LandingViewController.driveNav"
    }

    func updateStyle() {
        view.backgroundColor = UIColor.colorBackgroundLight
        routePannerView.backgroundColor = UIColor.colorBackgroundViewLight
        driveNavView.backgroundColor = UIColor.colorBackgroundViewLight

        routePlannerTitleLabel.textColor = UIColor.colorForeground
        routePlannerSubtitleLabel.textColor = UIColor.colorForegroundSecondary
        routePlannerActionLabel.textColor = UIColor.colorAccent

        routePannerView.layer.shadowColor = UIColor.colorDivider.cgColor
        routePannerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        routePannerView.layer.shadowOpacity = 1.0
        routePannerView.layer.shadowRadius = 1.0

        driveNavTitleLabel.textColor = UIColor.colorForeground
        driveNavSubtitleLabel.textColor = UIColor.colorForegroundSecondary
        driveNavActionLabel.textColor = UIColor.colorAccent

        driveNavView.layer.shadowColor = UIColor.colorDivider.cgColor
        driveNavView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        driveNavView.layer.shadowOpacity = 1.0
        driveNavView.layer.shadowRadius = 1.0
    }

    // Sets the tapped view's background color to another color
    // and after a delay, performs the segue and restores the
    // background color
    func handleTap(view: UIView, segue: String) {
        // If already handling a card, ignore the tap
        guard isCardHandling == false else {
            return
        }

        isCardHandling = true
        view.backgroundColor = UIColor.colorBackgroundPressed

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Constants.cardFlashPeriodMilliSeconds)) {
            self.performSegue(withIdentifier: segue, sender: self)
            view.backgroundColor = UIColor.colorBackgroundViewLight

            // Done
            self.isCardHandling = false
        }
    }

    func setCardHeight(view: UIView) -> CGFloat {
        var height = CGFloat(0)

        view.subviews.forEach {
            height += $0.frame.height
        }

        return max(Constants.minCardViewHeight, height)
    }

    func adapToOrientation() {
        routePlannerSubtitleLabel.sizeToFit()
        driveNavSubtitleLabel.sizeToFit()

        routePlannerViewHeightConstraint.constant = setCardHeight(view: routePannerView)
        driveNavHeightConstraint.constant = setCardHeight(view: driveNavView)

        // If the orientation is landscape, i.e. not portrait, we have to
        // set the height constraints carefully: the max one wins in this case
        if UIApplication.shared.statusBarOrientation != .portrait {
            let maxHeight = max(routePlannerViewHeightConstraint.constant, driveNavHeightConstraint.constant)
            routePlannerViewHeightConstraint.constant = maxHeight
            driveNavHeightConstraint.constant = maxHeight
        }
    }
}
