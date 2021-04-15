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

import UIKit

extension UIImage {

    /// Creates an image object out ot a view object.
    ///
    /// - Parameter view: The view to be converted.
    convenience init?(view: UIView) {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }

        guard let cgImage = image.cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}
