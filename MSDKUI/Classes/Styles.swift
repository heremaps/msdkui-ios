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

/// Provides all the styling for the visual elements after they are loaded
/// out of nib files or created.
@objc public class Styles: NSObject {
    /// The look & feel of all the visual elements can be set through shared instance.
    public static let shared = Styles()

    override private init() {
        super.init()
    }

    // MARK: WaypointList

    /// Sets the `WaypointList` background color.
    public var waypointListBackgroundColor = UIColor.colorBackgroundDark

    /// Sets the `WaypointList` alwaysBounceVertical property.
    public var waypointListAlwaysBounceVertical = false

    /// Sets the `WaypointList` separator color.
    public var waypointListSeparatorColor = UIColor.colorDividerLight

    /// Sets the `WaypointList` separator style.
    public var waypointListSeparatorStyle = UITableViewCellSeparatorStyle.singleLine

    /// Sets the `WaypointList` separator inset.
    public var waypointListSeparatorInset = UIEdgeInsets.zero

    /// Sets the `WaypointList` flash color.
    public var waypointListFlashColor = UIColor.colorBackgroundDark

    /// Sets the `WaypointList` flash duration in Seconds.
    public var waypointListFlashDurationSeconds = 0.015

    /// Sets the `WaypointList` cell background color.
    public var waypointListCellBackgroundColor = UIColor.colorBackgroundDark

    /// Sets the `WaypointList` cell text color.
    public var waypointListCellTextColor = UIColor.colorForegroundLight

    /// Sets the `WaypointList` cell leading inset which sets the spacing between
    /// the remove button and the label. When the remove button is not displayed,
    /// increasing this inset may prove to be useful.
    public var waypointListCellLabelLeadingInset = CGFloat(5.0)

    /// Sets the background color of the `WaypointList` cell buttons.
    public var waypointListCellButtonBackgroundColor: UIColor?

    /// Sets the tint color of the `WaypointList` cell buttons.
    public var waypointListCellButtonTintColor = UIColor.colorForegroundLight

    // MARK: OptionItem

    /// Sets the `OptionItem` background color.
    public var optionItemBackgroundColor = UIColor.colorForegroundLight

    /// Sets the `OptionItem` text color.
    public var optionItemTextColor = UIColor.colorForeground

    /// Sets the `onTintColor` of the switch found on an `OptionItem` object.
    public var optionItemSwitchOnTintColor = UIColor.colorAccent

    /// Sets the `tintColor` of the switch found on an `OptionItem` object.
    public var optionItemSwitchTintColor: UIColor?

    /// Sets the `thumbTintColor` of the switch found on an `OptionItem` object.
    public var optionItemSwitchThumbTintColor: UIColor?

    /// Sets the background color of the button found on an `OptionItem` object.
    public var optionItemButtonBackgroundColor: UIColor?

    /// Sets the title color of the button found on an `OptionItem` object.
    public var optionItemButtonTitleColor = UIColor.colorForeground

    /// Sets the tint color of the button found on an `OptionItem` object.
    public var optionItemButtonTintColor: UIColor?

    // MARK: TitleItem

    /// Sets the `TitleItem` background color.
    public var titleItemBackgroundColor = UIColor.colorForegroundLight

    /// Sets the `TitleItem` line color. Note that a 1 px line is found at the top of `TitleItem`.
    public var titleItemLineColor = UIColor.colorDivider

    /// Sets the `TitleItem` text color.
    public var titleItemTextColor = UIColor.colorForeground

    // MARK: TransportModePanel

    /// Sets the color of the selector found on `TransportModePanel`.
    public var transportModePanelSelectorColor = UIColor.colorAccent

    /// Sets the background color of the buttons found on `TransportModePanel`.
    public var transportModePanelBackgroundColor = UIColor.colorBackgroundDark

    /// Sets the icon color of the buttons found on `TransportModePanel`.
    public var transportModePanelIconColor = UIColor.colorForegroundLight

    // MARK: TravelTimePanel

    /// Sets the `TravelTimePanel` background color.
    public var travelTimePanelBackgroundColor = UIColor.colorBackgroundLight

    /// Sets the `TravelTimePanel` text color.
    public var travelTimePanelTextColor = UIColor.colorForegroundSecondary

    /// Sets the `TravelTimePanel` icon tint color.
    public var travelTimePanelIconTintColor = UIColor.colorForegroundSecondary

    // MARK: TravelTimePicker

    /// Sets the `TravelTimePicker` background color.
    public var travelTimePickerBackgroundColor = UIColor.colorForegroundLight

    /// Sets the `TravelTimePicker` title background color.
    public var travelTimePickerTitleBackgroundColor = UIColor.colorBackgroundLight

    /// Sets the `TravelTimePicker` title text color.
    public var travelTimePickerTitleTextColor = UIColor.colorForeground

    /// Sets the `TravelTimePicker` title buttons text color.
    public var travelTimePickerTitleButtonsTextColor = UIColor.colorAccent

    /// Sets the background color of the date picker found on `TravelTimePicker`.
    public var travelTimePickerDatePickerBackgroundColor = UIColor.colorForegroundLight

    // MARK: RouteDescriptionList

    /// Sets the `RouteDescriptionList` background color.
    public var routeDescriptionListBackgroundColor = UIColor.colorForegroundLight

    /// Sets the `alwaysBounceVertical` property of a `RouteDescriptionList`.
    public var routeDescriptionListAlwaysBounceVertical = false

    /// Sets the `RouteDescriptionList` separator color.
    public var routeDescriptionListSeparatorColor = UIColor.colorDivider

    /// Sets the `RouteDescriptionList` separator style.
    public var routeDescriptionListSeparatorStyle = UITableViewCellSeparatorStyle.singleLine

    /// Sets the `RouteDescriptionList` separator inset.
    public var routeDescriptionListSeparatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)

    /// Sets whether to display empty rows when the list has more visible rows than available routes.
    public var routeDescriptionListNoEmptyRows = true

    // MARK: RouteDescriptionItem

    /// Sets the background color of `RouteDescriptionItem`.
    public var routeDescriptionItemBackgroundColor = UIColor.colorBackgroundViewLight

    /// Sets the transport mode icon color of `RouteDescriptionItem`.
    public var routeDescriptionItemTransportModeColor = UIColor.colorForeground

    /// Sets the progress bar `progressTintColor` property of`RouteDescriptionItem`.
    public var routeDescriptionItemBarProgressColor = UIColor.colorAccentSecondary

    /// Sets the progress bar `trackTintColor` property of`RouteDescriptionItem`.
    public var routeDescriptionItemBarTrackColor = UIColor.colorBackgroundLight

    /// Sets the duration text color of `RouteDescriptionItem`.
    public var routeDescriptionItemDurationTextColor = UIColor.colorForeground

    /// Sets the warning icon color of `RouteDescriptionItem`.
    public var routeDescriptionItemWarningIconColor = UIColor.colorAlert

    /// Sets the delay text color of `RouteDescriptionItem`.
    public var routeDescriptionItemDelayTextColor = UIColor.colorAlert

    /// Sets the "No delays" text color of `RouteDescriptionItem`.
    public var routeDescriptionItemNoDelayTextColor = UIColor.colorForegroundSecondary

    /// Sets the length text color of `RouteDescriptionItem`.
    public var routeDescriptionItemLengthTextColor = UIColor.colorForegroundSecondary

    /// Sets the time text color of `RouteDescriptionItem`.
    public var routeDescriptionItemTimeTextColor = UIColor.colorForegroundSecondary

    // MARK: ManeuverDescriptionList

    /// Sets the `ManeuverDescriptionList` background color.
    public var maneuverDescriptionListBackgroundColor = UIColor.colorForegroundLight

    /// Sets the `ManeuverDescriptionList` alwaysBounceVertical property.
    public var maneuverDescriptionListAlwaysBounceVertical = false

    /// Sets the `ManeuverDescriptionList` separator style.
    public var maneuverDescriptionListSeparatorStyle = UITableViewCellSeparatorStyle.singleLine

    /// Sets the `ManeuverDescriptionList` separator color.
    public var maneuverDescriptionListSeparatorColor = UIColor.colorDivider

    /// Sets the `ManeuverDescriptionList` separator inset.
    public var maneuverDescriptionListSeparatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)

    /// Sets whether to show empty rows when the list has more visible rows than available maneuvers.
    public var maneuverDescriptionListNoEmptyRows = true

    // MARK: ManeuverDescriptionItem

    /// Sets the background color of `ManeuverDescriptionItem`.
    public var maneuverDescriptionItemBackgroundColor = UIColor.colorForegroundLight

    /// Sets the icon color of `ManeuverDescriptionItem`.
    public var maneuverDescriptionItemIconColor = UIColor.colorForeground

    /// Sets the instruction text color of `ManeuverDescriptionItem`.
    public var maneuverDescriptionItemInstructionTextColor = UIColor.colorForeground

    /// Sets the address text color of `ManeuverDescriptionItem`.
    public var maneuverDescriptionItemAddressTextColor = UIColor.colorForegroundSecondary

    /// Sets the distance text color of `ManeuverDescriptionItem`.
    public var maneuverDescriptionItemDistanceTextColor = UIColor.colorForegroundSecondary

    // MARK: SingleChoiceOptionItem

    /// Sets the title background color of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemTitleBackgroundColor = UIColor.colorBackgroundLight

    /// Sets the title alignment of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemTitleTextAlignment = NSTextAlignment.left

    /// Sets the title leading constraint of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemTitleLeadingConstraint = CGFloat(40)

    /// Sets the title trailing constraint of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemTitleTrailingConstraint = CGFloat(-20)

    /// Sets the background color of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemBackgroundColor = UIColor.colorForegroundLight

    /// Sets the alignment of options of `SingleChoiceOptionItem`.
    public var singleChoiceOptionItemTextAlignment = NSTextAlignment.center

    // MARK: InputBox

    /// Sets the background color of `InputBox`.
    public var inputBoxBackgroundColor = UIColor.colorForegroundLight

    /// Sets the corner radius of `InputBox`.
    public var inputBoxCornerRadius = CGFloat(12)

    /// Sets the title alignment of `InputBox`.
    public var inputBoxTitleTextAlignment = NSTextAlignment.center

    /// Sets the title text color of `InputBox`.
    public var inputBoxTitleTextColor = UIColor.colorForeground

    /// Sets the message alignment of `InputBox`.
    public var inputBoxMessageTextAlignment = NSTextAlignment.center

    /// Sets the message text color of `InputBox`.
    public var inputBoxMessageTextColor = UIColor.colorForeground

    /// Sets the text field text color of `InputBox`.
    public var inputBoxTextFieldTextColor = UIColor.colorForeground

    /// Sets the text field place holder text color of `InputBox`.
    public var inputBoxTextFieldPlaceHolderTextColor = UIColor.colorBackgroundBrand

    /// Sets the text field border style of `InputBox`.
    public var inputBoxTextFieldBorderStyle = UITextBorderStyle.roundedRect

    /// Sets the `OK` button text color of `InputBox`.
    public var inputBoxCancelButtonTextColor = UIColor.colorAccent

    /// Sets the `Cancel` button text color of `InputBox`.
    public var inputBoxTitleOkButtonTextColor = UIColor.colorAccent

    /// Sets the color of the lines of `InputBox`.
    public var inputBoxLineColor = UIColor.colorDivider

    // MARK: GuidanceManeuverPanel

    /// Sets the background color of `GuidanceManeuverPanel`.
    public dynamic var guidanceManeuverPanelBackgroundColor = UIColor.colorBackgroundDark

    /// Sets the text and icon color of `GuidanceManeuverPanel`.
    public dynamic var guidanceManeuverIconAndTextColor = UIColor.colorForegroundLight

    /// Sets the arrival text color of `GuidanceManeuverPanel`.
    public var guidanceManeuverArrivalTextColor = UIColor.colorAccentLight
}
