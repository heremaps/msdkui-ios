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

/// A view for displaying the maneuvers during guidance.
@IBDesignable open class GuidanceManeuverView: UIView {

    // MARK: - Types

    /// All the supported guidance maneuver view states.
    ///
    /// - noData: State where the view does not have maneuver data (e.g. initial state).
    /// - updating: State where the view awaits maneuver data.
    /// - data: State where the view contains maneuver data.
    public enum State: Equatable {
        case noData
        case updating
        case data(_ data: GuidanceManeuverData)
    }

    /// The axis along which the arranged views are laid out.
    ///
    /// - vertical: The constraint applied when laying out the vertical relationship between objects.
    /// - horizontal: The constraint applied when laying out the horizontal relationship between objects.
    public enum Axis: Int {
        case vertical
        case horizontal
    }

    // MARK: - Properties

    /// The views.
    @IBOutlet private(set) var views: [UIView]!

    /// The busy indicators.
    @IBOutlet private(set) var busyIndicators: [UIActivityIndicatorView]!

    /// The maneuver images.
    @IBOutlet private(set) var maneuverImageViews: [UIImageView]!

    /// The road icon images.
    @IBOutlet private(set) var roadIconViews: [UIImageView]!

    /// The distance labels.
    @IBOutlet private(set) var distanceLabels: [UILabel]!

    /// The info1 labels.
    @IBOutlet private(set) var info1Labels: [UILabel]!

    /// The info2 labels.
    @IBOutlet private(set) var info2Labels: [UILabel]!

    /// The data containers.
    @IBOutlet private(set) var dataContainers: [UIStackView]!

    /// The info label containers
    @IBOutlet private(set) var infoLabelContainers: [UIStackView]!

    /// The height constraints.
    @IBOutlet private(set) var heightConstraints: [NSLayoutConstraint]!

    /// The horizontal road stack view.
    @IBOutlet private(set) var horizontalRoadViewContainer: UIStackView!

    /// The vertical content container (holding the distance & road icon + info labels)
    @IBOutlet private(set) var verticalContentContainer: UIStackView!

    /// The top constraints
    @IBOutlet private(set) var topConstraints: [NSLayoutConstraint]!

    /// The bottom constraints
    @IBOutlet private(set) var bottomConstraints: [NSLayoutConstraint]!

    /// The no data containers.
    @IBOutlet private(set) var noDataContainers: [UIView]!

    /// The no data images.
    @IBOutlet private(set) var noDataImageViews: [UIImageView]!

    /// The no data labels.
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

    /// The view state.
    public var state: State = .noData {
        didSet {
            switch state {
            case .noData:
                displayNoData()

            case .updating:
                displayBusyState()

            case .data(let maneuverData):
                displayData(data: maneuverData)
            }
        }
    }

    public var axis: Axis = .vertical {
        didSet {
            switch axis {
            case .vertical:
                adaptToVertical()

            case .horizontal:
                adaptToHorizontal()
            }

            calculateHeight()
        }
    }

    /// The distance measurement formatter. The default value is `MeasurementFormatter.currentMediumUnitFormatter`.
    public var distanceFormatter: MeasurementFormatter = .currentMediumUnitFormatter {
        didSet {
            // There's no need to refresh the distance label, unless there's maneuver data.
            guard case let .data(maneuverData) = state else {
                return
            }

            displayData(data: maneuverData)
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

    /// The intrinsic content height.
    private var intrinsicContentHeight = CGFloat(0.0)

    /// The height of vertical Info 1 label as designed.
    private var verticalInfo1LabelDesignHeight = CGFloat(0.0)

    /// The height of vertical Info 2 label as designed.
    private var verticalInfo2LabelDesignHeight = CGFloat(0.0)

    /// The height of horozintal Info 1 label as designed.
    private var horizontalInfo1LabelDesignHeight = CGFloat(0.0)

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

    // MARK: - Private

    /// Handles to the horizontal orientation.
    private func adaptToHorizontal() {
        views[Axis.vertical.rawValue].isHidden = false
        views[Axis.horizontal.rawValue].isHidden = true
    }

    /// Handles to the vertical orientation.
    private func adaptToVertical() {
        views[Axis.vertical.rawValue].isHidden = true
        views[Axis.horizontal.rawValue].isHidden = false
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Creates nib instance
        UINib(nibName: String(describing: GuidanceManeuverView.self), bundle: .MSDKUI).instantiate(withOwner: self)

        // Ensure that views are sorted by tags, because tags with the value of 1 represents vertical and value of 2 represents horizontal.
        // Order of views in `views` array are inline with order of cases in `Orientation` enumeration.
        // Since indexing `views` array with `rawValue` from `Orientation` enumeration is based on an assumption,
        // an assumption is also made for `tag` of related views and representation of their values.
        views.sort { $0.tag < $1.tag }

        // We use autolayout
        translatesAutoresizingMaskIntoConstraints = false
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Saves the label design heights which will be used to calculate the height constraints
        verticalInfo1LabelDesignHeight = info1Labels[Axis.vertical.rawValue].frame.height
        verticalInfo2LabelDesignHeight = info2Labels[Axis.vertical.rawValue].frame.height
        horizontalInfo1LabelDesignHeight = info1Labels[Axis.horizontal.rawValue].frame.height

        // We expect that the owner will constraint us depending on the orientation
        views.forEach { addSubviewBindToEdges($0) }

        // Use monospcaed digits for distance to next maneuver
        distanceLabels.forEach { $0.font = .monospacedDigitSystemFont(ofSize: 34, weight: .regular) }

        // Sets the information about missing maneuver information
        noDataLabels.forEach { $0.text = "msdkui_maneuverpanel_nodata".localized }
        noDataImageViews.forEach {
            $0.image = UIImage(named: "car_position_marker", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }

        // Sets the initial state.
        state = .noData
        axis = .horizontal

        // Finally
        updateStyle()
    }

    /// Updates the style for the visuals.
    private func updateStyle() {
        backgroundColor = .colorBackgroundDark
        foregroundColor = .colorForegroundLight
    }

    /// Calculates the very important intrinsic content height depending on the subview visibilities.
    private func calculateHeight() {
        // Disable both constraints
        heightConstraints[Axis.horizontal.rawValue].isActive = false
        heightConstraints[Axis.vertical.rawValue].isActive = false

        // Proceed based on the visible view
        if views[Axis.vertical.rawValue].isHidden == false {
            calculateVerticalHeight()
        } else {
            calculateHorizontalHeight()
        }

        invalidateIntrinsicContentSize()
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }

    /// Calculates the intrinsic content height and set the height constraint and for the vertical content.
    private func calculateVerticalHeight() {
        let topPadding = topConstraints[Axis.vertical.rawValue].constant
        let bottomPadding = abs(bottomConstraints[Axis.vertical.rawValue].constant)

        // Unconditional height contributors: top padding + distance label height + bottom padding
        intrinsicContentHeight = topPadding + distanceLabels[Axis.vertical.rawValue].frame.height + bottomPadding

        // Spacing between the distance label and info labels
        if info1Labels[Axis.vertical.rawValue].isHidden == false ||
            info2Labels[Axis.vertical.rawValue].isHidden == false {
            intrinsicContentHeight += verticalContentContainer.spacing
        }

        // If visible, add info 1 label height
        if info1Labels[Axis.vertical.rawValue].isHidden == false {
            intrinsicContentHeight += verticalInfo1LabelDesignHeight
        }

        // Spacing bteween the info 1 & 2 labels, e.g. 2
        if info1Labels[Axis.vertical.rawValue].isHidden == false &&
            info2Labels[Axis.vertical.rawValue].isHidden == false {
            intrinsicContentHeight += infoLabelContainers[Axis.vertical.rawValue].spacing
        }

        /// If visible, add info 2 label height
        if info2Labels[Axis.vertical.rawValue].isHidden == false {
            intrinsicContentHeight += verticalInfo2LabelDesignHeight
        }

        // Height constraint = intrinsic content height - (top + bottom paddings)
        heightConstraints[Axis.vertical.rawValue].constant = intrinsicContentHeight - (topPadding + bottomPadding)
        heightConstraints[Axis.vertical.rawValue].isActive = true
    }

    /// Calculates the intrinsic content height and set the height constraint and for the landscape orientation.
    private func calculateHorizontalHeight() {
        let topPadding = topConstraints[Axis.horizontal.rawValue].constant
        let bottomPadding = abs(bottomConstraints[Axis.horizontal.rawValue].constant)

        // Unconditional height contributors: top padding + distance label height + bottom padding
        intrinsicContentHeight = topPadding + distanceLabels[Axis.horizontal.rawValue].frame.height + bottomPadding

        // Spacing between the distance label and info labels, e.g. 12
        if info1Labels[Axis.horizontal.rawValue].isHidden == false ||
            info2Labels[Axis.horizontal.rawValue].isHidden == false {
            intrinsicContentHeight += dataContainers[Axis.horizontal.rawValue].spacing
        }

        /// If visible, add info 1 label height
        if info1Labels[Axis.horizontal.rawValue].isHidden == false {
            intrinsicContentHeight += horizontalInfo1LabelDesignHeight
        }

        // Spacing bteween the info 1 & 2 labels
        if info1Labels[Axis.horizontal.rawValue].isHidden == false &&
            info2Labels[Axis.horizontal.rawValue].isHidden == false {
            intrinsicContentHeight += infoLabelContainers[Axis.horizontal.rawValue].spacing
        }

        // If visible, add info 2 label height which is a two-lines label
        if info2Labels[Axis.horizontal.rawValue].isHidden == false {
            info2Labels[Axis.horizontal.rawValue].sizeToFit()
            intrinsicContentHeight += info2Labels[Axis.horizontal.rawValue].frame.height
        }

        // If visible, add road icon
        if roadIconViews[Axis.horizontal.rawValue].image == nil {
            horizontalRoadViewContainer.isHidden = true
        } else {
            // Spacing between the info labels and road icon + road icon height
            intrinsicContentHeight += dataContainers[Axis.horizontal.rawValue].spacing +
                horizontalRoadViewContainer.frame.height
            horizontalRoadViewContainer.isHidden = false
        }

        // Height constraint = intrinsic content height - (top + bottom paddings)
        heightConstraints[Axis.horizontal.rawValue].constant = intrinsicContentHeight - (topPadding + bottomPadding)
        heightConstraints[Axis.horizontal.rawValue].isActive = true
    }

    private func displayData(data: GuidanceManeuverData) {
        // Sets the maneuver icon
        maneuverImageViews.forEach {
            $0.image = data.maneuverIcon
        }

        // Sets the distance text
        distanceLabels.forEach {
            $0.text = data.distance.map(distanceFormatter.string)
        }

        // Sets the road icon
        roadIconViews.forEach {
            $0.image = data.nextRoadIcon
        }

        // Sets the info 1 and info 2 texts
        info1Labels.forEach {
            $0.text = data.info1
            $0.isHidden = data.info1 == nil
        }

        info2Labels.forEach {
            $0.text = data.info2
            $0.isHidden = data.info2 == nil
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
}
