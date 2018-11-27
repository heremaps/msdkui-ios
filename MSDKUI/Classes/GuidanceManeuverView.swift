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

/// A view for displaying the maneuvers during guidance. Note that
/// this view displays a different view in portrait and landscape
/// orientations. The view listens to the `UIDeviceOrientationDidChange`
/// notification to monitor orientation changes.
///
@IBDesignable open class GuidanceManeuverView: UIView {

    // MARK: - Types

    /// All the suported orientations.
    enum Orientation: Int {
        case portrait
        case landscape
    }

    // MARK: - Properties

    /// The portrait & landscape views.
    @IBOutlet private(set) var views: [UIView]!

    /// The portrait & landscape busy indicators.
    @IBOutlet private(set) var busyIndicators: [UIActivityIndicatorView]!

    /// The portrait & landscape maneuver images.
    @IBOutlet private(set) var maneuverImageViews: [UIImageView]!

    /// The portrait & landscape road icon images.
    @IBOutlet private(set) var roadIconViews: [UIImageView]!

    /// The portrait & landscape distance labels.
    @IBOutlet private(set) var distanceLabels: [UILabel]!

    /// The portrait & landscape info1 labels.
    @IBOutlet private(set) var info1Labels: [UILabel]!

    /// The portrait & landscape info2 labels.
    @IBOutlet private(set) var info2Labels: [UILabel]!

    /// The portrait & landscape data containers.
    @IBOutlet private(set) var dataContainers: [UIStackView]!

    /// The portrait & landscape info label containers
    @IBOutlet private(set) var infoLabelContainers: [UIStackView]!

    /// The portrait & landscape height constraints.
    @IBOutlet private(set) var heightConstraints: [NSLayoutConstraint]!

    /// The landscape road stack view.
    @IBOutlet private(set) var landscapeRoadViewContainer: UIStackView!

    /// The portrait vertical container holding the distance & road icon + info labels
    @IBOutlet private(set) var portraitVerticalContainer: UIStackView!

    /// The portrait & landscape top constraints
    @IBOutlet private(set) var topConstraints: [NSLayoutConstraint]!

    /// The portrait & landscape bottom constraints
    @IBOutlet private(set) var bottomConstraints: [NSLayoutConstraint]!

    /// The portrait & landscape no data containers.
    @IBOutlet private(set) var noDataContainers: [UIView]!

    /// The portrait & landscape no data images.
    @IBOutlet private(set) var noDataImageViews: [UIImageView]!

    /// The portrait & landscape no data labels.
    @IBOutlet private(set) var noDataLabels: [UILabel]!

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    /// The default background color is colorBackgroundDark.
    override open var backgroundColor: UIColor? {
        didSet {
            views?.forEach { $0.backgroundColor = backgroundColor }
        }
    }

    /// The data used by the view.
    public var data: GuidanceManeuverData? {
        didSet {
            // Refresh only when old or new value are not nil
            // This will keep initial state when needed, also skip unnecessary updates
            if oldValue != nil || data != nil {
                // Reflect the new data
                refreshView()
            }
        }
    }

    /// Sets the view's foreground color, i.e. the color for the icons, text and busy indicators.
    /// The default foreground color is colorForegroundLight.
    public var foregroundColor: UIColor = .colorForegroundLight {
        didSet {
            distanceLabels.forEach { $0.textColor = foregroundColor }
            info1Labels.forEach { $0.textColor = foregroundColor }
            info2Labels.forEach { $0.textColor = foregroundColor }
            noDataLabels.forEach { $0.textColor = foregroundColor }

            maneuverImageViews.forEach { $0.tintColor = foregroundColor }
            roadIconViews.forEach { $0.tintColor = foregroundColor }
            noDataImageViews.forEach { $0.tintColor = foregroundColor }
            busyIndicators.forEach { $0.color = foregroundColor }
        }
    }

    /// The intrinsic content height is important for portrait/landscape orientation handling.
    private var intrinsicContentHeight = CGFloat(0.0)

    /// The height of portrait Info 1 label as designed.
    private var portraitInfo1LabelDesignHeight = CGFloat(0.0)

    /// The height of portrait Info 2 label as designed.
    private var portraitInfo2LabelDesignHeight = CGFloat(0.0)

    /// The height of landscape Info 1 label as designed.
    private var landscapeInfo1LabelDesignHeight = CGFloat(0.0)

    // MARK: - Public

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

        calculateHeight()
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

    // MARK: - Private

    /// Initialises the contents of this view.
    private func setUp() {
        // Create nib instance
        UINib(nibName: String(describing: GuidanceManeuverView.self), bundle: .MSDKUI).instantiate(withOwner: self)

        // Ensure that views are sorted by tag, because tag with value of 1 represents portrait and value of 2 represents landscape.
        // Order of views in `views` array are inline with order of cases in `Orientation` enumeration.
        // Since indexing `views` array with `rawValue` from `Orientation` enumeration is based on a assumption,
        // an assumption is also made for `tag` of related views and representation of their values.
        views.sort { $0.tag < $1.tag }

        // We use autolayout
        translatesAutoresizingMaskIntoConstraints = false
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Save the label design heights which will be used to calculate the height constraints
        portraitInfo1LabelDesignHeight = info1Labels[Orientation.portrait.rawValue].frame.height
        portraitInfo2LabelDesignHeight = info2Labels[Orientation.portrait.rawValue].frame.height
        landscapeInfo1LabelDesignHeight = info1Labels[Orientation.landscape.rawValue].frame.height

        // We expect that the owner will constraint us depending on the orientation
        views.forEach { addSubviewBindToEdges($0) }

        // Use monospcaed digits for distance to next maneuver
        distanceLabels.forEach { $0.font = .monospacedDigitSystemFont(ofSize: 34, weight: .regular) }

        // Initially adapt to the current orientation
        orientationDidChange()

        // We want to monitor the UIDeviceOrientationDidChange notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)

        // Sets the information about missing maneuver information
        noDataLabels.forEach { $0.text = "msdkui_maneuverpanel_nodata".localized }
        noDataImageViews.forEach {
            $0.image = UIImage(named: "car_position_marker", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }

        // Finally
        updateStyle()
        displayNoData()
    }

    /// Updates the style for the visuals.
    private func updateStyle() {
        backgroundColor = .colorBackgroundDark
        foregroundColor = .colorForegroundLight
    }

    /// Calculates the very important intrinsic content height depending on the subview visibilities.
    private func calculateHeight() {
        // Disable both constraints
        heightConstraints[Orientation.landscape.rawValue].isActive = false
        heightConstraints[Orientation.portrait.rawValue].isActive = false

        // Proceed based on the visible view
        if views[Orientation.portrait.rawValue].isHidden == false {
            calculatePortraitHeight()
        } else {
            calculateLandscapeHeight()
        }

        invalidateIntrinsicContentSize()
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }

    /// Calculates the intrinsic content height and set the height constraint and for the portrait orientation.
    private func calculatePortraitHeight() {
        let topPadding = topConstraints[Orientation.portrait.rawValue].constant
        let bottomPadding = abs(bottomConstraints[Orientation.portrait.rawValue].constant)

        // Unconditional height contributors: top padding + distance label height + bottom padding
        intrinsicContentHeight = topPadding + distanceLabels[Orientation.portrait.rawValue].frame.height + bottomPadding

        // Spacing between the distance label and info labels
        if info1Labels[Orientation.portrait.rawValue].isHidden == false ||
            info2Labels[Orientation.portrait.rawValue].isHidden == false {
            intrinsicContentHeight += portraitVerticalContainer.spacing
        }

        // If visible, add info 1 label height
        if info1Labels[Orientation.portrait.rawValue].isHidden == false {
            intrinsicContentHeight += portraitInfo1LabelDesignHeight
        }

        // Spacing bteween the info 1 & 2 labels, e.g. 2
        if info1Labels[Orientation.portrait.rawValue].isHidden == false &&
            info2Labels[Orientation.portrait.rawValue].isHidden == false {
            intrinsicContentHeight += infoLabelContainers[Orientation.portrait.rawValue].spacing
        }

        /// If visible, add info 2 label height
        if info2Labels[Orientation.portrait.rawValue].isHidden == false {
            intrinsicContentHeight += portraitInfo2LabelDesignHeight
        }

        // Height constraint = intrinsic content height - (top + bottom paddings)
        heightConstraints[Orientation.portrait.rawValue].constant = intrinsicContentHeight - (topPadding + bottomPadding)
        heightConstraints[Orientation.portrait.rawValue].isActive = true
    }

    /// Calculates the intrinsic content height and set the height constraint and for the landscape orientation.
    private func calculateLandscapeHeight() {
        let topPadding = topConstraints[Orientation.landscape.rawValue].constant
        let bottomPadding = abs(bottomConstraints[Orientation.landscape.rawValue].constant)

        // Unconditional height contributors: top padding + distance label height + bottom padding
        intrinsicContentHeight = topPadding + distanceLabels[Orientation.landscape.rawValue].frame.height + bottomPadding

        // Spacing between the distance label and info labels, e.g. 12
        if info1Labels[Orientation.landscape.rawValue].isHidden == false ||
            info2Labels[Orientation.landscape.rawValue].isHidden == false {
            intrinsicContentHeight += dataContainers[Orientation.landscape.rawValue].spacing
        }

        /// If visible, add info 1 label height
        if info1Labels[Orientation.landscape.rawValue].isHidden == false {
            intrinsicContentHeight += landscapeInfo1LabelDesignHeight
        }

        // Spacing bteween the info 1 & 2 labels
        if info1Labels[Orientation.landscape.rawValue].isHidden == false &&
            info2Labels[Orientation.landscape.rawValue].isHidden == false {
            intrinsicContentHeight += infoLabelContainers[Orientation.landscape.rawValue].spacing
        }

        // If visible, add info 2 label height which is a two-lines label
        if info2Labels[Orientation.landscape.rawValue].isHidden == false {
            info2Labels[Orientation.landscape.rawValue].sizeToFit()
            intrinsicContentHeight += info2Labels[Orientation.landscape.rawValue].frame.height
        }

        // If visible, add road icon
        if roadIconViews[Orientation.landscape.rawValue].image == nil {
            landscapeRoadViewContainer.isHidden = true
        } else {
            // Spacing between the info labels and road icon + road icon height
            intrinsicContentHeight += dataContainers[Orientation.landscape.rawValue].spacing +
                landscapeRoadViewContainer.frame.height
            landscapeRoadViewContainer.isHidden = false
        }

        // Height constraint = intrinsic content height - (top + bottom paddings)
        heightConstraints[Orientation.landscape.rawValue].constant = intrinsicContentHeight - (topPadding + bottomPadding)
        heightConstraints[Orientation.landscape.rawValue].isActive = true
    }

    /// This method refreshs the view with the new data set.
    private func refreshView() {
        if let data = data {
            displayData(data: data)
        } else {
            displayBusyState()
        }
    }

    private func displayData(data: GuidanceManeuverData) {
        if let maneuverIcon = data.maneuverIcon {
            let image = UIImage(named: maneuverIcon, in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

            maneuverImageViews.forEach { $0.image = image }
        }

        if let distance = data.distance {
            distanceLabels.forEach { $0.text = distance }
        }

        // Always set the road icon (since nextRoadIcon is optional)
        roadIconViews.forEach {
            $0.image = data.nextRoadIcon
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
        busyIndicators.forEach {
            $0.stopAnimating()
            $0.isHidden = true
        }

        calculateHeight()
    }

    private func displayNoData() {
        dataContainers.forEach { $0.isHidden = true }
        noDataLabels.forEach { $0.text = "msdkui_maneuverpanel_nodata".localized }
        noDataImageViews.forEach { $0.isHidden = false }
        noDataContainers.forEach { $0.isHidden = false }
        busyIndicators.forEach {
            $0.stopAnimating()
            $0.isHidden = true
        }
    }

    private func displayBusyState() {
        dataContainers.forEach { $0.isHidden = true }
        noDataLabels.forEach { $0.text = "msdkui_maneuverpanel_updating".localized }
        noDataImageViews.forEach { $0.isHidden = true }
        noDataContainers.forEach { $0.isHidden = false }
        busyIndicators.forEach {
            $0.startAnimating()
            $0.isHidden = false
        }
    }

    /// Handles the orientation changes.
    @objc private func orientationDidChange() {
        if UIApplication.shared.statusBarOrientation == .portrait {
            adaptToPortrait()
        } else {
            adaptToLandscape()
        }

        calculateHeight()
    }
}
