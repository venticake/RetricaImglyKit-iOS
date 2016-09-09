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
 *  Represents a single image entry nested within a frame-JSON file.
 */
@available(iOS 8, *)
@objc(IMGLYImageInfoRecord) public class ImageInfoRecord: NSObject {
    /// The image ratio that image has, is out for.
    public var ratio: Float = 1.0

    /// An url atlas. This maps tags like 'thumbnail' onto an url
    public var urlAtlas = [String : String]()
}
