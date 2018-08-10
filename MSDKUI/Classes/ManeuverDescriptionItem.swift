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

/// A visual item to display a maneuver based on its visible sections.
///
/// - SeeAlso: NMAManeuver
@IBDesignable open class ManeuverDescriptionItem: UIView {
    /// Describes atomic sections of the item for visibility.
    public struct Section: OptionSet {
        public let rawValue: Int

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

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// This function converts a String which mimics the or'ed Section values like
        /// "icon|instructions|distance" to a Section like Section(rawValue: 19). Unknown strings
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

        /// This variable returns the Section as a String. For example, Section(rawValue: 19)
        /// is stringized as "icon|duration|length".
        ///
        /// - Important: The "|" character is used to concatanate the Section values.
        /// - Important: The returned string is all in lowercase.
        /// - Important: The order of the substrings follow the Section declaration order. For example
        ///              [.address, .icon] is converted as "icon|address".
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

            // If the string is not empty, remove the first char: due to "normalization" it is always "|"
            return string.isEmpty ? string : String(string.dropFirst())
        }
    }

    /// The label for displaying the maneuver icon.
    @IBOutlet public private(set) var iconView: UIImageView!

    /// The label for displaying the maneuver instruction.
    @IBOutlet public private(set) var instructionLabel: UILabel!

    /// The label for displaying the address info.
    @IBOutlet public private(set) var addressLabel: UILabel!

    /// The label for displaying the distance info.
    @IBOutlet public private(set) var distanceLabel: UILabel!

    /// This view holds the related XIB file contents.
    @IBOutlet private var view: UIView!

    /// The `NMAManeuver` object associated with this item.
    public private(set) var maneuver: NMAManeuver?

    /// Helper `ManeuverResources` type object.
    var maneuverResources: ManeuverResources!

    /// The visibility of the maneuver data.
    ///
    /// - Important: Initially all the sections are visible.
    public var visibleSections: Section = .all {
        didSet {
            refresh()
        }
    }

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
            visibleSections = ManeuverDescriptionItem.Section.make(from: newValue)
        }
    }

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

    /// Sets the `NMAManeuver` to be visualized by this item.
    ///
    /// - Parameter maneuvers: All `NMAManeuver` elements of route.
    /// - Parameter position: The position to get the maneuver from the given array.
    public func setManeuver(maneuvers: [NMAManeuver], position: Int) {
        // We need to update the style before assignments due to the iconView:
        // setting tintColor after image is set doesn't work!
        updateStyle()

        maneuver = maneuvers.indices.contains(position) ? maneuvers[position] : nil
        maneuverResources = ManeuverResources(maneuvers: maneuvers)
        instructionLabel.text = maneuverResources.getManeuverInstruction(index: position)

        if let address = maneuverResources.getRoadToDisplay(index: position) {
            addressLabel.text = address
        } else {
            setSectionVisible(.address, false)
        }

        // If there is no distance, hide the distance label
        let distance = maneuverResources.getDistance(index: position)
        if distance == 0 {
            setSectionVisible(.distance, false)
        } else {
            distanceLabel.text = Utils.formatDistance(distance)
        }

        let imageName = maneuverResources.getManeuverIconName(index: position)
        if let name = imageName {
            // Create the image in the template mode for customization as the backgroundColor and tintColor
            // properties works well with layered images
            iconView.image = UIImage(named: name, in: .MSDKUI, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        } else {
            setSectionVisible(.icon, false)
        }

        // Update the accessibility stuff
        updateAccessibility()
    }

    /// Initialises the contents of this view.
    private func setUp() {
        // Load the view nib file
        let nibFile = UINib(nibName: String(describing: ManeuverDescriptionItem.self), bundle: .MSDKUI)
        view = nibFile.instantiate(withOwner: self, options: nil)[0] as! UIView

        // Use the view's bounds
        bounds = view.bounds

        addSubviewBindToEdges(view)
        setAccessibility()
    }

    /// Paints the maneuver based on the visible sections.
    func refresh() {
        iconView.isHidden = !isSectionVisible(Section.icon)
        instructionLabel.isHidden = !isSectionVisible(Section.instructions)
        addressLabel.isHidden = !isSectionVisible(Section.address)
        distanceLabel.isHidden = !isSectionVisible(Section.distance)

        // Update the accessibility stuff
        updateAccessibility()
    }

    /// Updates the style for the visuals.
    func updateStyle() {
        view.backgroundColor = Styles.shared.maneuverDescriptionItemBackgroundColor
        iconView.tintColor = Styles.shared.maneuverDescriptionItemIconColor
        instructionLabel.textColor = Styles.shared.maneuverDescriptionItemInstructionTextColor
        addressLabel.textColor = Styles.shared.maneuverDescriptionItemAddressTextColor
        distanceLabel.textColor = Styles.shared.maneuverDescriptionItemDistanceTextColor
    }

    /// Sets the accessibility stuff.
    private func setAccessibility() {
        iconView.isAccessibilityElement = false
        instructionLabel.isAccessibilityElement = false
        addressLabel.isAccessibilityElement = false
        distanceLabel.isAccessibilityElement = false

        // Let it be accessed as one-piece
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitStaticText
        accessibilityLabel = "msdkui_maneuver".localized
        accessibilityIdentifier = "MSDKUI.ManeuverDescriptionItem"
    }

    /// Updates the accessibility stuff.
    private func updateAccessibility() {
        var hint: String = ""

        // If the maneuver is not available yet, do nothing
        if maneuver != nil {
            if isSectionVisible(.instructions) {
                hint.appendComma()
                hint += instructionLabel.text!
            }

            if isSectionVisible(.address) {
                hint.appendComma()
                hint += addressLabel.text!
            }

            if isSectionVisible(.distance) {
                hint.appendComma()
                hint += distanceLabel.text!
            }
        }

        // Any hint?
        accessibilityHint = hint.isEmpty ? nil : hint
    }
}
