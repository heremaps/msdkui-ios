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

/// The helper class to make option items.
open class OptionItemSpec: NSObject {

    // MARK: - Properties

    /// The optional title assigned to a single choice option item.
    ///
    /// - Important: This property is used only for a `SingleChoiceOptionItem`.
    public private(set) var title: String?

    /// The input helper object assigned to a numeric option item.
    ///
    /// - Important: This property is used only for a `NumericOptionItem`.
    public private(set) var inputHelper: NumericOptionItemInputHelper?

    /// The type of the option item.
    public private(set) var type: OptionItem.ItemType

    /// The labels which are displayed.
    public private(set) var labels: [String]

    /// The id of the option item.
    public private(set) var id: Int

    // MARK: - Public

    /// Makes an option item spec configured for a Boolean option item.
    ///
    /// - Parameters:
    ///   - label: The string to be displayed.
    ///   - id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameter.
    public static func makeBooleanOptionItem(label: String, id: Int = 0) -> OptionItemSpec {
        OptionItemSpec(label: label, id: id)
    }

    /// Makes an option item spec configured for a multiple choice option item.
    ///
    /// - Parameters:
    ///   - labels: The strings to be displayed.
    ///   - id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameter.
    public static func makeMultipleChoiceOptionItem(labels: [String], id: Int = 0) -> OptionItemSpec {
        OptionItemSpec(labels: labels, id: id)
    }

    /// Makes an option item spec configured for a numeric option item.
    ///
    /// - Parameters:
    ///   - label: The string to be displayed.
    ///   - inputHelper: Provides all the input related helper parameters.
    ///   - id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameters.
    /// - Important: By default the button is titled "Set" which is localized.
    public static func makeNumericOptionItem(label: String, inputHelper: NumericOptionItemInputHelper, id: Int = 0) -> OptionItemSpec {
        OptionItemSpec(label: label, inputHelper: inputHelper, id: id)
    }

    /// Makes an option item spec configured for a single choice option item.
    ///
    /// - Parameters:
    ///   - title: The optional title provided for the item
    ///   - labels: The strings to be displayed.
    ///   - id: The optional id of the option item.
    /// - Returns: An `OptionItemSpec` instance created based on the parameters.
    public static func makeSingleChoiceOptionItem(title: String?, labels: [String], id: Int = 0) -> OptionItemSpec {
        OptionItemSpec(title: title, labels: labels, id: id)
    }

    /// Makes an option item out of the option item spec.
    ///
    /// - Returns: OptionItem instance created based on this spec.
    public func makeOptionItem() -> OptionItem {
        switch type {
        case .booleanOptionItem:
            let item = BooleanOptionItem()
            item.label = labels.first
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
            item.label = labels.first
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

    // MARK: - Private

    /// Creates a `BooleanOptionItem` spec with the given label and id.
    ///
    /// - Parameters:
    ///   - label: The label to be displayed.
    ///   - id: The id of the option item.
    private init(label: String, id: Int) {
        type = .booleanOptionItem
        labels = [label]
        self.id = id
    }

    /// Creates a `MultipleChoiceOptionItem` spec with the given labels and id.
    ///
    /// - Parameters:
    ///   - labels: The labels to be displayed.
    ///   - id: The id of the option item.
    private init(labels: [String], id: Int) {
        type = .multipleChoiceOptionItem
        self.labels = labels
        self.id = id
    }

    /// Creates a `NumericOptionItem` spec with the given label, value and id.
    ///
    /// - Parameters:
    ///   - label: The label to be displayed.
    ///   - inputHelper: The input helper object.
    ///   - id: The id of the option item.
    private init(label: String, inputHelper: NumericOptionItemInputHelper, id: Int) {
        type = .numericOptionItem
        labels = [label]
        self.inputHelper = inputHelper
        self.id = id
    }

    /// Creates a `SingleChoiceOptionItem` spec with the given title, labels and id.
    ///
    /// - Parameters:
    ///   - title:  The optional title to be displayed.
    ///   - labels: The strings to be displayed.
    ///   - id: The id of the option item.
    private init(title: String?, labels: [String], id: Int) {
        type = .singleChoiceOptionItem
        self.labels = labels
        self.title = title
        self.id = id
    }
}
