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
 *  Instances of this class can be used together with the `CropEditorViewController` to specify the
 *  crop ratios that should be supported.
 */
@objc(IMGLYCropRatio) public class CropRatio: NSObject {

    /// The ratio of the crop as `CGFloat`.
    public let ratio: CGFloat?

    /// The ratio of the crop as `NSNumber`. This should only be used with Objective-C because
    /// primitives can't be `nil`.
    public var ratioAsNSNumber: NSNumber? {
        guard let ratio = ratio else {
            return nil
        }

        return NSNumber(float: Float(ratio))
    }

    /// A name to be shown in the UI.
    public let title: String

    /// An icon to be shown in the UI.
    public let icon: UIImage?

    /**
     Initializes and returns a newly allocated crop ratio object with the specified ratio, title and icon.

     - parameter ratio: The aspect ratio to enforce. If this is `nil`, the user can perform a free form crop.
     - parameter title: The title of this aspect ratio, e.g. '1:1'
     - parameter icon:  The icon to use for this aspect ratio. The image should be 36x36 pixels.

     - returns: An initialized crop ratio object.
     */
    public init(ratio: CGFloat?, title: String, accessibilityLabel: String?, icon: UIImage?) {
        self.ratio = ratio
        self.title = title
        self.icon = icon
        super.init()

        self.accessibilityLabel = accessibilityLabel
    }

    /**
     Initializes and returns a newly allocated crop ratio object with the specified ratio, title and icon.
     This initializer should only be used with Objective-C because primitives can't be `nil`.

     - parameter ratio: The aspect ratio to enforce. If this is `nil`, the user can perform a free form crop.
     - parameter title: The title of this aspect ratio, e.g. '1:1'
     - parameter icon:  The icon to use for this aspect ratio. The image should be 36x36 pixels.

     - returns: An initialized crop ratio object.
     */
    public init(ratio: NSNumber?, title: String, accessibilityLabel: String?, icon: UIImage?) {
        if let ratio = ratio {
            self.ratio = CGFloat(ratio.floatValue)
        } else {
            self.ratio = nil
        }

        self.title = title
        self.icon = icon
        super.init()

        self.accessibilityLabel = accessibilityLabel
    }
}
