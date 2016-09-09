//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

/**
 *  Represents a single sticker information retrieved via JSON.
 */
@available(iOS 8, *)
@objc(IMGLYStickerInfoRecord) public class StickerInfoRecord: NSObject {
    /// The name of the image.
    public var name = ""

    /// The label of the sticker. This is used for accessibility.
    public var accessibilityText = ""

    /// An array of `ImageInfoRecord` representing the associated  images.
    public var imageInfo = ImageInfoRecord()
}
