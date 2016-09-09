//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import UIKit

/**
 A class that wraps values for `hue`, `saturation` and `brightness`.
 */
@objc(IMGLYHSB) public class HSB: NSObject {
    /// The hue value.
    public let hue: CGFloat

    /// The saturation value.
    public let saturation: CGFloat

    /// The brightness value.
    public let brightness: CGFloat

    /**
    :nodoc:
    */
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        super.init()
    }
}

/**
 A few useful extensions to `UIColor`.
 */
public extension UIColor {
    /// Returns the hue, saturation and brightness values for the receiver.
    @objc(imgly_hsb) public var hsb: HSB {
        let model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        if (model == CGColorSpaceModel.Monochrome) || (model == CGColorSpaceModel.RGB) {
            let c = CGColorGetComponents(self.CGColor)

            let x = min(min(c[0], c[1]), c[2])
            let b = max(max(c[0], c[1]), c[2])

            if b == x {
                return HSB(hue: 0, saturation: 0, brightness: b)
            } else {
                let f: CGFloat
                let i: CGFloat

                if c[0] == x {
                    f = c[1] - c[2]
                    i = 3
                } else if c[1] == x {
                    f = c[2] - c[0]
                    i = 5
                } else {
                    f = c[0] - c[1]
                    i = 1
                }

                // Split into multiple lines to improve build times
                var hue = b - x
                hue = f / hue
                hue = i - hue
                hue = hue / 6

                // Split into multiple lines to improve build times
                var saturation = b - x
                saturation = saturation / b

                let brightness = b

                return HSB(hue: hue, saturation: saturation, brightness: brightness)
            }
        }

        return HSB(hue: 0, saturation: 0, brightness: 0)
    }
}
