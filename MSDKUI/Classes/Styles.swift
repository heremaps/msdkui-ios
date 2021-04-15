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

import Foundation

/// Provides all the styling for the visual elements after they are loaded
/// out of nib files or created.
@objc public class Styles: NSObject {

    // MARK: - Properties

    /// The look & feel of all the visual elements can be set through shared instance.
    public static let shared = Styles()

    // MARK: - OptionItem

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

    // MARK: - SingleChoiceOptionItem

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

    // MARK: - Private

    override private init() {
        super.init()
    }
}
