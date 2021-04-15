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

import NMAKit
import UIKit

/// Extension for `Array<NMAMapMarker>`.
extension Array where Element: NMAMapMarker {
    /// Insets that should be used to encompass all icons at the boarder of a rectangle.
    var iconsInsets: UIEdgeInsets {
        Element.calculateIconsInsets(from: self)
    }
}
