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

extension UIImage {
    /// Creates an image object out ot a view object.
    ///
    /// - Parameter view: The view to be converted.
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }

    /// If the image has the `.alwaysTemplate` rendering mode, returns a new image in the specified color.
    ///
    /// - Parameter color: The color to paint the image with.
    /// - Returns: The new image in case of success and otherwise the existing image.
    func tint(with color: UIColor) -> UIImage {
        // Make sure to have image data and have the UIImageRenderingMode.alwaysTemplate
        guard let cgImage = self.cgImage, renderingMode == .alwaysTemplate else {
            return self
        }

        // Start creating the new image by beginning an image context
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }

        // Flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)

        // Multiply blend mode
        context.setBlendMode(.multiply)

        // Create the same sized image using the current image as the mask painted with the specified color
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        // Create the colored image
        guard let coloredImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }

        UIGraphicsEndImageContext()

        return coloredImage.resizableImage(withCapInsets: capInsets, resizingMode: resizingMode)
    }
}
