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

/// Represents a row in `RouteDescriptionList` class. Note that the traffic delay depends on the `NMAMapView`'s
/// `isTrafficVisible` flag and `NMADynamicPenalty`'s `trafficPenaltyMode` setting: when the HERE map shows
/// traffic data, the traffic delay data appears. However, when the HERE map does not show traffic data and
/// the `trafficPenaltyMode` is not `.optimal`, then there is no traffic data available. In this case,
/// trying to show traffic delay results in "No delays" displayed automatically. Hence, it is advisable to
/// calculate the routes with `.optimal` penalty mode. Plus, traffic delay information is not available
/// when the transport mode is `.bike` or `.pedestrian`.
@IBDesignable open class RouteDescriptionItem: UIView {
    /// Describes atomic sections of the item for visibility.
    public struct Section: OptionSet {
        public let rawValue: Int

        /// The icon section indicating the transport mode of the route.
        public static let icon = Section(rawValue: 1 << 0)

        /// The duration section indicating the duration of the route.
        public static let duration = Section(rawValue: 1 << 1)

        /// The delay section indicating the traffic delay along the route.
        public static let delay = Section(rawValue: 1 << 2)

        /// The bar section visually indicating the length of the route.
        public static let bar = Section(rawValue: 1 << 3)

        /// The length section indicating the length of the route in meters.
        public static let length = Section(rawValue: 1 << 4)

        /// The time section indicating the arrival time of the route.
        public static let time = Section(rawValue: 1 << 5)

        /// All available sections combined in one array.
        public static let all: Section = [icon, duration, delay, bar, length, time]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// This function converts a String which mimics the or'ed Section values like
        /// "icon|duration|length" to a Section like Section(rawValue: 19). Unknown strings
        /// are simply ignored.
        /// - Parameter string: The string to be converted to a Section value.
        /// - Returns: The Section value created out of the string. Note that it will be empty
        ///            if the string does not have any Section-like substring.
        ///
        /// - Important: The "|" character should be used in the string to concatenate substrings.
        /// - Important: The function allows irregularities like blank chars before
        ///              or after a "|" char or using capital characters.
        public static func make(from string: String) -> Section {
            let trimmed = string.components(separatedBy: .whitespaces).joined()
            let lowercased = trimmed.lowercased()
            let tokens = lowercased.split(separator: "|")
            var section = Section() // Initially empty

            for token in tokens {
                switch token {
                case "icon":
                    section.insert(.icon)

                case "duration":
                    section.insert(.duration)

                case "delay":
                    section.insert(.delay)

                case "bar":
                    section.insert(.bar)

                case "length":
                    section.insert(.length)

                case "time":
                    section.insert(.time)

                case "all":
                    section.insert(.all)

                default:
                    () // Ignore the unknown string
                }
            }

            return section
        }

        /// This variable returns the Section as a String. For example, Section(rawValue: 19)
        /// is stringized as "icon|duration|length".
        ///
        /// - Important: The "|" character is used to concatanate the Section values.
        /// - Important: The returned string is all in lowercase.
        /// - Important: The order of the substrings follow the Section declaration order. For example
        ///              [.length, .icon] is converted as "icon|length".
        public var stringized: String {
            var string = "" // Initially empty

            // Always prefix the string with a "|" as a kind of "normalization"

            // Handle the .all as a special case
            if self == .all {
                string = "|all"
            } else {
                // Follow the Section declaration order
                if contains(.icon) {
                    string += "|icon"
                }

                if contains(.duration) {
                    string += "|duration"
                }

                if contains(.delay) {
                    string += "|delay"
                }

                if contains(.bar) {
                    string += "|bar"
                }

                if contains(.length) {
                    string += "|length"
                }

                if contains(.time) {
                    string += "|time"
                }
            }

            // If the string is not empty, remove the first char: due to "normalization" it is always "|"
            return string.isEmpty ? string : String(string.dropFirst())
        }
    }

    /// The leading constraint is by default 20 dp.
    @IBOutlet public private(set) var leadingConstraint: NSLayoutConstraint!

    /// The trailing constraint is by default 20 dp.
    @IBOutlet public private(set) var trailingConstraint: NSLayoutConstraint!

    /// Whether traffic should be considered when calculating the duration and arrival time.
    @IBInspectable public var trafficEnabled: Bool = false {
        didSet {
            guard route != nil else {
                return
            }

            // Reflect the update
            populate()
            refresh()
        }
    }

    /// The view containing the `transportModeImage`.
    @IBOutlet private(set) var transportModeView: UIView!

    /// The image showing the transport mode in use.
    @IBOutlet private(set) var transportModeImage: UIImageView!

    /// The label for displaying the route duration data.
    @IBOutlet private(set) var durationLabel: UILabel!

    /// The label for displaying the route duration data.
    @IBOutlet private(set) var warningIcon: UIImageView!

    /// The label for displaying the route delay data.
    @IBOutlet private(set) var delayLabel: UILabel!

    /// The bar view displaying the scaled route duration or length data.
    ///
    /// - Important: `RouteDescriptionList.sortType` sets the data in use.
    @IBOutlet private(set) var barView: UIProgressView!

    /// The label for displaying the route length data.
    @IBOutlet private(set) var lengthLabel: UILabel!

    /// The label for displaying the route departure or arrival time data.
    @IBOutlet private(set) var timeLabel: UILabel!

    /// The stack view for the duration & delay data.
    ///
    /// - Important: When both of the data labels are hidden, the
    ///              stack view is hidden automatically.
    @IBOutlet private(set) var durationDelayView: UIStackView!

    /// The stack view for the length & arrival data.
    ///
    /// - Important: When both of the data labels are hidden, the
    ///              stack view is hidden automatically.
    @IBOutlet private(set) var lengthArrrivalView: UIStackView!

    /// The color of the transport mode icon.
    public var transportModeImageColor: UIColor? {
        didSet { transportModeImage.tintColor = transportModeImageColor }
    }

    /// The bar view progress color.
    public var barViewProgressColor: UIColor? {
        didSet { barView.progressTintColor = barViewProgressColor }
    }

    /// The bar view track color.
    public var barViewTrackColor: UIColor? {
        didSet { barView.trackTintColor = barViewTrackColor }
    }

    /// The primary label (a.k.a. duration label) color.
    public var primaryLabelColor: UIColor? {
        didSet { durationLabel.textColor = primaryLabelColor }
    }

    /// The secondary labels (delay, length, and time labels) colors.
    public var secondaryLabelsColor: UIColor? {
        didSet {
            // If there is no `handler` or delay, `delayLabel` should use the
            // `secondaryLabelsColor` color
            if handler == nil || handler.hasDelay == false {
                delayLabel.textColor = secondaryLabelsColor
            }

            lengthLabel.textColor = secondaryLabelsColor
            timeLabel.textColor = secondaryLabelsColor
        }
    }

    /// The warning color.
    public var warningColor: UIColor? {
        didSet {
            // If there is a `handler` and delay, `delayLabel` should use the
            // `warningColor` color
            if handler != nil && handler.hasDelay == true {
                delayLabel.textColor = warningColor
            }

            warningIcon.tintColor = warningColor
        }
    }

    /// Sets the visibility of available sections.
    ///
    /// - Important: Initially all the sections are visible.
    public var visibleSections: Section = .all {
        didSet {
            refresh()
        }
    }

    /// The proxy property to make the `visibleSections` property accessible
    /// from the Interface Builder. It accepts a string like "icon|duration|length"
    /// to set the `visibleSections` property, so the users can avoid arithmetic while
    /// setting this property. Note that unknown substrings are simply ignored.
    ///
    /// - Important: It shadows the visibleSections property.
    @IBInspectable public var visibleSectionsProxy: String {
        get {
            return visibleSections.stringized
        }
        set {
            visibleSections = RouteDescriptionItem.Section.make(from: newValue)
        }
    }

    /// The `NMARoute` object associated with the item. The item visualizes its data.
    public var route: NMARoute? {
        didSet {
            guard route != nil else {
                return
            }

            populate()
            refresh()
        }
    }

    /// Determines the scaling of the bar.
    /// The normalized values should be between 0.0 and 1.0.
    public var scale = Double(0) {
        didSet {
            // Reflect the update
            barView.progress = Float(scale)
            updateAccessibility()
        }
    }

    /// Helper object for extracting the route data for display purposes.
    var handler: RouteDescriptionItemHandler!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    /// Queries the visibility of the given section.
    ///
    /// - Parameter section: The section whose visibility to be queried.
    /// - Returns: true if the section is visible and false otherwise.
    public func isSectionVisible(_ section: Section) -> Bool {
        return visibleSections.contains(section)
    }

    /// Sets the given section visible or not.
    ///
    /// - Parameter section: The section whose visibility to be set.
    /// - Parameter visible: The new visibility of the section.
    public func setSectionVisible(_ section: Section, _ visible: Bool) {
        if visible {
            visibleSections.insert(section)
        } else {
            visibleSections.remove(section)
        }
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Load the view nib file
        let nibFile = UINib(nibName: String(describing: RouteDescriptionItem.self), bundle: .MSDKUI)
        let view = nibFile.instantiate(withOwner: self, options: nil)[0] as! UIView

        // Use the view's bounds
        bounds = view.bounds

        addSubviewBindToEdges(view)
        setAccessibility()
        setUpStyle()
    }

    /// Assigns data from the route.
    func populate() {
        handler = RouteDescriptionItemHandler(for: route!, with: trafficEnabled)
        transportModeImage.image = handler.icon
        durationLabel.text = handler.duration
        delayLabel.text = handler.trafficDelay
        lengthLabel.text = handler.length
        timeLabel.text = handler.arrivalTime

        // If there is a delay, `delayLabel` should use the
        // `warningColor` color
        if handler.hasDelay {
            delayLabel.textColor = warningColor
        }
    }

    /// Refreshes the view based on the visible sections.
    func refresh() {
        transportModeView.isHidden = !isSectionVisible(Section.icon)
        durationLabel.isHidden = !isSectionVisible(Section.duration)
        delayLabel.isHidden = !isSectionVisible(Section.delay) || delayLabel.attributedText!.length == 0
        warningIcon.isHidden = handler != nil && handler.hasDelay ? delayLabel.isHidden : true
        barView.isHidden = !isSectionVisible(Section.bar)
        lengthLabel.isHidden = !isSectionVisible(Section.length)
        timeLabel.isHidden = !isSectionVisible(Section.time)

        // If both of the labels are hidden, hide the container view, too
        durationDelayView.isHidden = durationLabel.isHidden && delayLabel.isHidden
        lengthArrrivalView.isHidden = lengthLabel.isHidden && timeLabel.isHidden

        // Update the accessibility stuff
        updateAccessibility()
    }

    /// Sets up the default style.
    func setUpStyle() {
        backgroundColor = .colorBackgroundViewLight

        transportModeImageColor = .colorForeground
        barViewProgressColor = .colorAccentSecondary
        barViewTrackColor = .colorBackgroundLight
        primaryLabelColor = .colorForeground
        warningColor = .colorAlert
        secondaryLabelsColor = .colorForegroundSecondary

        warningIcon.image = UIImage(named: "RouteDescriptionItem.warning", in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        transportModeImage.isAccessibilityElement = false
        durationLabel.isAccessibilityElement = false
        delayLabel.isAccessibilityElement = false
        barView.isAccessibilityElement = false
        lengthLabel.isAccessibilityElement = false
        timeLabel.isAccessibilityElement = false

        // Let it be accessed as one-piece
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitStaticText
        accessibilityLabel = "msdkui_route".localized
        accessibilityIdentifier = "MSDKUI.RouteDescriptionItem"
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        var hint: String = ""

        // If the helper object is not available yet, do nothing
        if handler != nil {
            if isSectionVisible(.icon) {
                hint.appendComma()
                hint += handler.iconDescription!
            }

            if isSectionVisible(.duration) {
                hint.appendComma()
                hint += String(format: "msdkui_duration_time".localized, arguments: [handler.duration])
            }

            if isSectionVisible(.delay) && handler.trafficDelay.isEmpty == false {
                hint.appendComma()
                hint += "\(handler.trafficDelay)"
            }

            if isSectionVisible(.length) {
                hint.appendComma()
                hint += String(format: "msdkui_route_length".localized, arguments: [handler.length])
            }

            if isSectionVisible(.time) {
                hint.appendComma()
                hint += String(format: "msdkui_arrival_time".localized, arguments: [handler.arrivalTime])
            }
        }

        // Any hint?
        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
