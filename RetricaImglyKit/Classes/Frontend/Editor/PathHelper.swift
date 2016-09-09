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
 *  The `PathHelper` class bundles helper methods to work with paths.
 */
@available(iOS 8, *)
@objc(IMGLYPathHelper) public class PathHelper: NSObject {
    /**
     Can be used to add a rounded rectangle path to a context.

     - parameter context:    The context to add the path to.
     - parameter width:      The width of the rectangle.
     - parameter height:     The height of the rectangle.
     - parameter ovalWidth:  The horizontal corner radius.
     - parameter ovalHeight: The vertical corner radius.
     */
    static public func clipCornersToOvalWidth(context: CGContextRef, width: CGFloat, height: CGFloat, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        var fw = CGFloat(0)
        var fh = CGFloat(0)
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)

        if ovalWidth == 0 || ovalHeight == 0 {
            CGContextAddRect(context, rect)
            return
        }

        CGContextSaveGState(context)
        CGContextTranslateCTM(context, rect.minX, rect.minY)
        CGContextScaleCTM(context, ovalWidth, ovalHeight)
        fw = rect.width / ovalWidth
        fh = rect.height / ovalHeight
        CGContextMoveToPoint(context, fw, fh / 2)
        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1)
        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1)
        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1)
        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1)
        CGContextClosePath(context)
        CGContextRestoreGState(context)
    }
}
