//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/**
 *  A `GradientView` shows a gradient from its top to its bottom.
 */
@available(iOS 8, *)
@objc(IMGLYGradientView) public class GradientView: UIView {

    // MARK: - Properties

    /// The top color of the gradient.
    public let topColor: UIColor

    /// The bottom color of the gradient.
    public let bottomColor: UIColor

    // MARK: - Initializers

    /**
    Returns a newly allocated instance of a `GradientView`.

    - parameter topColor:    The color at the top of the view.
    - parameter bottomColor: The color at the bottom of the view.

    - returns: An instance of a `GradientView`.
    */
    public init(topColor: UIColor, bottomColor: UIColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
        super.init(frame: CGRect.zero)
        opaque = false
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        self.topColor = UIColor.clearColor()
        self.bottomColor = UIColor.blackColor()
        super.init(frame: CGRect.zero)
        opaque = false
    }

    // MARK: - UIView

    /**
    :nodoc:
    */
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [topColor.CGColor, bottomColor.CGColor], [0, 1])
        CGContextDrawLinearGradient(context, gradient, CGPoint(x: bounds.midX, y: bounds.minY), CGPoint(x: bounds.midX, y: bounds.maxY), [])
    }

}
