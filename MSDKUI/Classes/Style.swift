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

import CoreGraphics
import UIKit

extension UIColor {
    private struct LUI {
        // Opaque dark shades for backgrounds
        public static let brand = #colorLiteral(red: 0.1529411765, green: 0.1725490196, blue: 0.2117647059, alpha: 1)
        public static let dark1 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 1)
        public static let dark2 = #colorLiteral(red: 0.2470588235, green: 0.2705882353, blue: 0.3019607843, alpha: 1)

        // Opaque light shades for backgrounds
        public static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        public static let light = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)

        // Brand color for accents
        public static let accent = #colorLiteral(red: 0, green: 0.7320529222, blue: 0.7001396418, alpha: 1)
        public static let accentLight = #colorLiteral(red: 0, green: 0.8566522598, blue: 0.7899546027, alpha: 1)
        public static let accentSecondary = #colorLiteral(red: 0.1725490196, green: 0.2823529412, blue: 0.631372549, alpha: 1)
        public static let accentSecondaryLight = #colorLiteral(red: 0.1137254902, green: 0.2784313725, blue: 0.6392156863, alpha: 1)

        // Transparent dark shades for foregrounds
        public static let dark90 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.9)
        public static let dark85 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.85)
        public static let dark75 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.75)
        public static let dark60 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.6)
        public static let dark50 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.5)
        public static let dark40 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.4)
        public static let dark30 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.3)
        public static let dark20 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.2)
        public static let dark15 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.15)
        public static let dark05 = #colorLiteral(red: 0.05882352941, green: 0.0862745098, blue: 0.1294117647, alpha: 0.05)

        // Transparent white shades for foregrounds
        public static let white90 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
        public static let white80 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        public static let white70 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
        public static let white60 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        public static let white50 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        public static let white40 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
        public static let white30 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
        public static let white20 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        public static let white15 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15)
        public static let white05 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05)

        // Opaque colors indicating state
        // e.g. traffic / error (red), success (green)
        public static let positive = #colorLiteral(red: 0, green: 0.737254902, blue: 0.4901960784, alpha: 1)
        public static let positive15 = #colorLiteral(red: 0, green: 0.737254902, blue: 0.4901960784, alpha: 0.15)
        public static let alert = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 1)
        public static let alert15 = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 0.15)
        public static let negative = #colorLiteral(red: 0.8352941176, green: 0.137254902, blue: 0.1843137255, alpha: 1)
        public static let negative15 = #colorLiteral(red: 0.8352941176, green: 0.137254902, blue: 0.1843137255, alpha: 0.15)
        public static let significant = #colorLiteral(red: 0.9254901961, green: 0.3803921569, blue: 0.05490196078, alpha: 1)
        public static let significant15 = #colorLiteral(red: 0.9254901961, green: 0.3803921569, blue: 0.05490196078, alpha: 0.15)
    }

    public static let colorBackgroundBrand = LUI.brand

    public static let colorBackgroundDark = LUI.dark1
    public static let colorBackgroundViewDark = LUI.dark2

    public static let colorBackgroundLight = LUI.light
    public static let colorBackgroundViewLight = LUI.white

    public static let colorAccentLight = LUI.accentLight
    public static let colorAccent = LUI.accent

    public static let colorAccentSecondaryLight = LUI.accentSecondaryLight
    public static let colorAccentSecondary = LUI.accentSecondary

    public static let colorForegroundLight = LUI.white
    public static let colorForeground = LUI.dark90

    public static let colorForegroundSecondaryLight = LUI.white70
    public static let colorForegroundSecondary = LUI.dark60

    public static let colorHintLight = LUI.white40
    public static let colorHint = LUI.dark30

    public static let colorPositive = LUI.positive
    public static let colorPositiveLight = LUI.positive15
    public static let colorAlert = LUI.alert
    public static let colorAlertLight = LUI.alert15
    public static let colorNegative = LUI.negative
    public static let colorNegativeLight = LUI.negative15
    public static let colorSignificant = LUI.significant
    public static let colorSignificantLight = LUI.significant15

    // Additional color styles in case you need them, you might also add new ones.
    public static let colorDividerLight = LUI.white15
    public static let colorDivider = LUI.dark15

    public static let colorDisabledLight = LUI.white15
    public static let colorDisabled = LUI.dark15

    public static let colorBackgroundPressedLight = LUI.white05
    public static let colorBackgroundPressed = LUI.dark05

    public static let colorBackgroundMapLight = LUI.white80
    public static let colorBackgroundMap = LUI.dark90

    public static let colorOpacityMaskLight = LUI.dark90
    public static let colorOpacityMask = LUI.dark85

    public static let colorLocation = LUI.accent

    public static let colorRoute = LUI.brand
}
