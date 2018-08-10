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

/// A panel for displaying the maneuvers during guidance. Note that
/// this panel displays a different view in portrait and landscape
/// orientations. For the portrait orientation, the panel is expected
/// to be at the top and for the landscape orientation, the panel is
/// expected to be on the left side. The panel listens to the
/// `UIDeviceOrientationDidChange` notification to monitor orientation
/// changes.
///
@IBDesignable open class GuidanceManeuverPanel: UIView {

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// The data used by the panel.
    public var data: GuidanceManeuverData! {
        didSet {
            // Reflect the new data
            refreshPanel()
        }
    }

    /// All the suported orientations.
    enum Orientation: Int {
        case portrait
        case landscape
    }

    /// The portrait & landscape views of the panel.
    @IBOutlet private(set) var views: [UIView]!

    /// The portrait & landscape maneuver images.
    @IBOutlet private(set) var maneuverImageViews: [UIImageView]!

    /// The portrait & landscape highway images.
    @IBOutlet private(set) var highwayImageViews: [UIImageView]!

    /// The portrait & landscape distance labels.
    @IBOutlet private(set) var distanceLabels: [UILabel]!

    /// The portrait & landscape info1 labels.
    @IBOutlet private(set) var info1Labels: [UILabel]!

    /// The portrait & landscape info2 labels.
    @IBOutlet private(set) var info2Labels: [UILabel]!

    /// The portrait & landscape no data images.
    @IBOutlet private(set) var noDataImageViews: [UIImageView]!

    /// The portrait & landscape no data labels.
    @IBOutlet private(set) var noDataLabels: [UILabel]!

    /// The portrait & landscape data containers.
    @IBOutlet private(set) var dataContainers: [UIView]!

    /// The portrait & landscape no data containers.
    @IBOutlet private(set) var noDataContainers: [UIView]!

    /// The intrinsic content height is important for portrait/landscape orientation handling.
    var intrinsicContentHeight = CGFloat(0.0)

    // The styles observer.
    private var observer: GuidanceManeuverPanelStylesObserver!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    /// This method highlights the current maneuver with the specified text color.
    ///
    /// - Parameter textColor: The new highlight color.
    public func highlightManeuver(textColor: UIColor) {
        info2Labels.forEach { $0.textColor = textColor }

        adaptHeight()
    }

    /// Handles to the portrait orientation.
    func adaptToPortrait() {
        views[Orientation.portrait.rawValue].isHidden = false
        views[Orientation.landscape.rawValue].isHidden = true
    }

    /// Handles to the landscape orientation.
    func adaptToLandscape() {
        views[Orientation.portrait.rawValue].isHidden = true
        views[Orientation.landscape.rawValue].isHidden = false
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Load the nib file
        let nibFile = UINib(nibName: String(describing: GuidanceManeuverPanel.self), bundle: .MSDKUI)

        // Create the portrait & landscape orientation specific views
        views[Orientation.portrait.rawValue] = nibFile.instantiate(withOwner: self, options: nil)[0] as! UIView
        views[Orientation.landscape.rawValue] = nibFile.instantiate(withOwner: self, options: nil)[1] as! UIView

        // We use autolayout
        translatesAutoresizingMaskIntoConstraints = false
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // We want to monitor the style updates
        observer = GuidanceManeuverPanelStylesObserver(self)

        // We expect that the owner will constraint us depending on the orientation
        views.forEach { addSubviewBindToEdges($0) }

        // Initially adapt to the current orientation
        orientationDidChange()

        // We want to monitor the UIDeviceOrientationDidChange notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)

        // Sets the information about missing maneuver information
        noDataLabels.forEach { $0.text = "msdkui_maneuverpanel_nodata".localized }
        noDataImageViews.forEach {
            $0.image = UIImage(named: "car_position_marker", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }

        // Finally
        updateStyle()
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        views.forEach { $0.backgroundColor = Styles.shared.guidanceManeuverPanelBackgroundColor }

        distanceLabels.forEach { $0.textColor = Styles.shared.guidanceManeuverIconAndTextColor }
        info1Labels.forEach { $0.textColor = Styles.shared.guidanceManeuverIconAndTextColor }
        info2Labels.forEach { $0.textColor = Styles.shared.guidanceManeuverIconAndTextColor }

        maneuverImageViews.forEach { $0.tintColor = Styles.shared.guidanceManeuverIconAndTextColor }
        highwayImageViews.forEach { $0.tintColor = Styles.shared.guidanceManeuverIconAndTextColor }
        noDataImageViews.forEach { $0.tintColor = Styles.shared.guidanceManeuverIconAndTextColor }
    }

    /// Handles the orientation changes.
    @objc private func orientationDidChange() {
        if UIApplication.shared.statusBarOrientation == .portrait {
            adaptToPortrait()
        } else {
            adaptToLandscape()
        }

        adaptHeight()
    }

    /// Sets the very important intrinsic content height
    /// depending on the Info2Label visibility.
    private func adaptHeight() {
        let portraitView = views[Orientation.portrait.rawValue]
        if portraitView.isHidden == false {
            let viewHeight = portraitView.frame.size.height
            let info1Label = info1Labels[Orientation.portrait.hashValue]
            intrinsicContentHeight = info1Label.isHidden == true ? viewHeight - info1Label.frame.size.height : viewHeight

            invalidateIntrinsicContentSize()
        }

        setNeedsLayout()
    }

    /// This method refreshs the panel with the new data set.
    private func refreshPanel() {
        if let maneuverIcon = data.maneuverIcon {
            let image = UIImage(named: maneuverIcon, in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

            maneuverImageViews.forEach { $0.image = image }
        }

        if let distance = data.distance {
            distanceLabels.forEach { $0.text = distance }
        }

        // Info1 is an optional string
        if let info1 = data.info1 {
            info1Labels.forEach {
                $0.text = info1
                $0.isHidden = false
            }
        } else {
            info1Labels.forEach {
                $0.text = nil
                $0.isHidden = true
            }
        }

        if let info2 = data.info2 {
            info2Labels.forEach { $0.text = info2 }
        }

        // Sets the visibility of the two containers to display the maneuver data
        dataContainers.forEach { $0.isHidden = false }
        noDataContainers.forEach { $0.isHidden = true }

        adaptHeight()
    }
}
