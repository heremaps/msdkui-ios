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

/// The helper class to make option items.
open class OptionItemSpec: NSObject {
    /// Makes an option item spec configured for a Boolean option item.
    ///
    /// - Parameter label: The string to be displayed.
    /// - Parameter id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameter.
    public static func makeBooleanOptionItem(label: String, id: Int = 0) -> OptionItemSpec {
        return OptionItemSpec(label: label, id: id)
    }

    /// Makes an option item spec configured for a multiple choice option item.
    ///
    /// - Parameter labels: The strings to be displayed.
    /// - Parameter id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameter.
    public static func makeMultipleChoiceOptionItem(labels: [String], id: Int = 0) -> OptionItemSpec {
        return OptionItemSpec(labels: labels, id: id)
    }

    /// Makes an option item spec configured for a numeric option item.
    ///
    /// - Parameter label: The string to be displayed.
    /// - Parameter inputHelper: Provides all the input related helper parameters.
    /// - Parameter id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameters.
    /// - Important: By default the button is titled "Set" which is localized.
    public static func makeNumericOptionItem(label: String, inputHelper: NumericOptionItemInputHelper, id: Int = 0) -> OptionItemSpec {
        return OptionItemSpec(label: label, inputHelper: inputHelper, id: id)
    }

    /// Makes an option item spec configured for a single choice option item.
    ///
    /// - Parameter title: The optional title provided for the item.
    /// - Parameter labels: The strings to be displayed.
    /// - Parameter id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameters.
    public static func makeSingleChoiceOptionItem(title: String?, labels: [String], id: Int = 0) -> OptionItemSpec {
        return OptionItemSpec(title: title, labels: labels, id: id)
    }

    /// Makes an option item out of the option item spec.
    ///
    /// - Returns: OptionItem instance created based on this spec.
    public func makeOptionItem() -> OptionItem {
        switch type {
        case .booleanOptionItem:
            let item = BooleanOptionItem()
            item.label = labels[0]
            item.id = id
            return item

        case .multipleChoiceOptionItem:
            let item = MultipleChoiceOptionItem()
            item.labels = labels
            item.id = id
            return item

        case .numericOptionItem:
            let item = NumericOptionItem()
            // The order is important: first set the labels as setting the
            // labels creates the item.
            item.label = labels[0]
            item.inputHelper = inputHelper
            item.id = id
            return item

        case .singleChoiceOptionItem:
            let item = SingleChoiceOptionItem()
            // The order is important: first set the title and then set
            // the labels which creates the item. So, when the labels are set,
            // the title should be set already.
            item.title = title
            item.labels = labels
            item.id = id
            return item
        }
    }

    /// The type of the option item.
    public private(set) var type: OptionItem.ItemType

    /// The labels which are displayed.
    public private(set) var labels: [String]

    /// The id of the option item.
    public private(set) var id: Int

    /// The optional title assigned to a single choice option item.
    ///
    /// - Important: This property is used only for a `SingleChoiceOptionItem`.
    public var title: String?

    /// The input helper object assigned to a numeric option item.
    ///
    /// - Important: This property is used only for a `NumericOptionItem`.
    public var inputHelper: NumericOptionItemInputHelper?

    /// Creates a boolean option item spec with the given label.
    ///
    /// - Parameter label: The label to be displayed.
    /// - Returns: An option item spec configured with the parameter.
    private init(label: String, id: Int) {
        type = .booleanOptionItem
        labels = [label]
        self.id = id
    }

    /// Creates a multiple choice option item spec with the given labels.
    ///
    /// - Parameter labels: The labels to be displayed.
    /// - Returns: An option item spec configured with the parameters.
    private init(labels: [String], id: Int) {
        type = .multipleChoiceOptionItem
        self.labels = labels
        self.id = id
    }

    /// Creates a numeric option item spec with the given label and value.
    ///
    /// - Parameter label: The label to be displayed.
    /// - Parameter inputHelper: The input helper object.
    /// - Returns: An option item spec configured with the parameters.
    private init(label: String, inputHelper: NumericOptionItemInputHelper, id: Int) {
        type = .numericOptionItem
        labels = [label]
        self.inputHelper = inputHelper
        self.id = id
    }

    /// Creates a single choice option item spec with the given title and labels.
    ///
    /// - Parameter title: The optional title to be displayed.
    /// - Parameter labels: The strings to be displayed.
    /// - Returns: An option item spec configured with the parameters.
    private init(title: String?, labels: [String], id: Int) {
        type = .singleChoiceOptionItem
        self.labels = labels
        self.title = title
        self.id = id
    }
}
