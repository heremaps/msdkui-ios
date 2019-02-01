//
// Copyright (C) 2017-2019 HERE Europe B.V.
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

/// A visual item to display a `NMAManeuver` object based on its visible sections.
@IBDesignable open class ManeuverItemView: UIView {

    // MARK: - Types

    /// Describes atomic sections of the item for visibility.
    public struct Section: OptionSet {

        // MARK: - Properties

        /// The icon section indicating the next maneuver.
        public static let icon = Section(rawValue: 1 << 0)

        /// The instructions section indicating the next turns to take.
        public static let instructions = Section(rawValue: 1 << 1)

        /// The address section indicating address information of the next maneuver.
        public static let address = Section(rawValue: 1 << 2)

        /// The distance section indicating the distance to next maneuver in meters.
        public static let distance = Section(rawValue: 1 << 3)

        /// All available sections combined in one array.
        public static let all: Section = [icon, instructions, address, distance]

        /// This variable returns the Section as a String. For example, Section(rawValue: 19)
        /// is stringized as "icon|duration|length".
        ///
        /// - Note: The "|" character is used to concatenate the Section values.
        /// - Note: The returned string is all in lowercase.
        /// - Note: The order of the substrings follow the Section declaration order. For example
        ///              [.address, .icon] is converted as "icon|address".
        public var stringized: String {
            var string = "" // Initially empty

            // Always prefix the string with a "|" as a kind of "normalization"

            // Handles the .all as a special case
            if self == .all {
                string = "|all"
            } else {
                // Follows the Section declaration order
                if contains(.icon) {
                    string += "|icon"
                }

                if contains(.instructions) {
                    string += "|instructions"
                }

                if contains(.address) {
                    string += "|address"
                }

                if contains(.distance) {
                    string += "|distance"
                }
            }

            // If the string is not empty, remove the first char: due to "normalization", it is always "|"
            return string.isEmpty ? string : String(string.dropFirst())
        }

        /// The corresponding value of the raw type.
        public let rawValue: Int

        // MARK: - Public

        /// This function converts a String which mimics the or'ed Section values like
        /// "icon|instructions|distance" to a Section like Section(rawValue: 11). Unknown strings
        /// are simply ignored.
        /// - Parameter string: The string to be converted to a Section value.
        /// - Returns: The Section value created out of the string. Note that it will be empty
        ///            if the string does not have any Section-like substring.
        ///
        /// - Note: The "|" character should be used in the string to concatenate substrings.
        /// - Note: The function allows irregularities like blank chars before
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

                case "instructions":
                    section.insert(.instructions)

                case "address":
                    section.insert(.address)

                case "distance":
                    section.insert(.distance)

                case "all":
                    section.insert(.all)

                default:
                    () // Ignore the unknown string
                }
            }

            return section
        }

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    // MARK: - Properties

    /// The label for displaying the maneuver icon.
    @IBOutlet public private(set) var iconImageView: UIImageView!

    /// The label for displaying the maneuver instruction.
    @IBOutlet public private(set) var instructionLabel: UILabel!

    /// The label for displaying the address info.
    @IBOutlet public private(set) var addressLabel: UILabel!

    /// The label for displaying the distance info.
    @IBOutlet public private(set) var distanceLabel: UILabel!

    /// This constraint helps us to set a leading inset.
    @IBOutlet public private(set) var leadingConstraint: NSLayoutConstraint!

    /// This constraint helps us to set a trailing inset.
    @IBOutlet public private(set) var trailingConstraint: NSLayoutConstraint!

    /// View containing subviews for landscape and portrait.
    @IBOutlet private var view: UIView!

    /// The stack view which contains the address and the distance labels.
    @IBOutlet private(set) var addressDistanceStackView: UIStackView!

    /// The proxy property to make the `visibleSections` property accessible
    /// from the Interface Builder. It accepts a string like "icon|instructions|date"
    /// to set the `visibleSections` property, so the users can avoid arithmetic while
    /// setting this property. Note that unknown substrings are simply ignored.
    ///
    /// - Important: It shadows the visibleSections property.
    @IBInspectable public var visibleSectionsProxy: String {
        get {
            return visibleSections.stringized
        }
        set {
            visibleSections = ManeuverItemView.Section.make(from: newValue)
        }
    }

    /// The visibility of the maneuver data.
    ///
    /// - Important: Initially all the sections are visible.
    public var visibleSections: Section = .all {
        didSet {
            refresh()
        }
    }

    /// The item leading inset, which sets the spacing between the leading side and the visible subviews.
    public var leadingInset = CGFloat(16) {
        didSet { leadingConstraint.constant = leadingInset }
    }

    /// The item trailing inset, which sets the spacing between the visible subviews and the trailing side.
    public var trailingInset = CGFloat(-16) {
        didSet { trailingConstraint.constant = trailingInset }
    }

    /// The `NMAManeuver` object associated with this item.
    public private(set) var maneuver: NMAManeuver?

    /// Helper `ManeuverResources` type object.
    private var maneuverResources: ManeuverResources!

    // MARK: - Public

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
    /// - Parameter section: The section whose visibility is to be queried.
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

    /// Sets the `NMAManeuver` to be visualized by this item.
    ///
    /// - Parameters:
    ///   - maneuvers: All `NMAManeuver` elements of route.
    ///   - index: The index to get the maneuver from the given array.
    ///   - measurementFormatter: The measurement formatter used to format the distance.
    ///   - accessibilityMeasurementFormatter: The measurement formatter used to format
    ///     the distance for accessibility VoiceOver.
    public func setManeuver(maneuvers: [NMAManeuver],
                            index: Int,
                            measurementFormatter: MeasurementFormatter = .currentMediumUnitFormatter,
                            accessibilityMeasurementFormatter: MeasurementFormatter = .currentLongUnitFormatter) {
        setUpStyle()

        maneuver = maneuvers.indices.contains(index) ? maneuvers[index] : nil
        maneuverResources = ManeuverResources(maneuvers: maneuvers)

        if let instruction = maneuverResources.getInstruction(for: index) {
            instructionLabel.text = instruction
        } else {
            setSectionVisible(.instructions, false)
        }

        if let address = maneuverResources.getRoadName(for: index) {
            addressLabel.text = address
        } else {
            setSectionVisible(.address, false)
        }

        // If there is no distance, hide the distance label
        let distanceValue = maneuverResources.getDistance(for: index)
        if distanceValue == 0 {
            setSectionVisible(.distance, false)
        } else {
            let distance = Measurement(value: Double(distanceValue), unit: UnitLength.meters)
            distanceLabel.text = measurementFormatter.string(from: distance)
            distanceLabel.accessibilityLabel = accessibilityMeasurementFormatter.string(from: distance)
        }

        if let iconFileName = maneuverResources.getIconFileName(for: index) {
            iconImageView.image = UIImage(named: iconFileName,
                                          in: .MSDKUI,
                                          compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        } else {
            setSectionVisible(.icon, false)
        }

        // Updates the accessibility contents
        updateAccessibility()
    }

    // MARK: - Private

    /// Initialises the contents of this view.
    private func setUp() {
        // Instantiates the view
        UINib(nibName: String(describing: ManeuverItemView.self), bundle: .MSDKUI).instantiate(withOwner: self)

        // Uses the view's bounds
        bounds = view.bounds

        // Adds the view to the hierarchy
        addSubviewBindToEdges(view)

        setAccessibility()
    }

    /// Paints the maneuver based on the visible sections.
    private func refresh() {
        iconImageView.isHidden = !isSectionVisible(.icon)
        instructionLabel.isHidden = !isSectionVisible(.instructions)
        addressLabel.isHidden = !isSectionVisible(.address)
        distanceLabel.isHidden = !isSectionVisible(.distance)

        // Updates the accessibility contents
        updateAccessibility()
    }

    /// Sets up item style.
    private func setUpStyle() {
        backgroundColor = .colorForegroundLight

        iconImageView.tintColor = .colorForeground
        instructionLabel.textColor = .colorForeground
        addressLabel.textColor = .colorForegroundSecondary
        distanceLabel.textColor = .colorForegroundSecondary
    }

    /// Sets the accessibility contents.
    private func setAccessibility() {
        iconImageView.isAccessibilityElement = false
        instructionLabel.isAccessibilityElement = false
        addressLabel.isAccessibilityElement = false
        distanceLabel.isAccessibilityElement = false

        // Lets it be accessed as one-piece
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityLabel = "msdkui_maneuver".localized
        accessibilityIdentifier = "MSDKUI.ManeuverItemView"
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        var hint: String = ""

        // If the maneuver is not available yet, do nothing
        if maneuver != nil {
            if isSectionVisible(.instructions), let text = instructionLabel.text {
                hint.appendComma()
                hint += text
            }

            if isSectionVisible(.address), let text = addressLabel.text {
                hint.appendComma()
                hint += text
            }

            if isSectionVisible(.distance), let text = distanceLabel.text {
                hint.appendComma()
                hint += text
            }
        }

        // Any hint?
        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
