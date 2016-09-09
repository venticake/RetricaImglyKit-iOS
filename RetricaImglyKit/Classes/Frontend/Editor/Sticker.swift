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
 *  The `Sticker` class holds all informations needed to be managed and rendered.
 */
@objc(IMGLYSticker) public class Sticker: NSObject {
    /// The image URL of the sticker.
    public let imageURL: NSURL?

    /// The thumbnail URL of the sticker.
    public let thumbnailURL: NSURL?

    /// The image of the sticker.
    public let image: UIImage?

    /// The thumbnail image of the sticker.
    public let thumbnail: UIImage?

    /// The text that is read out when accessibility is enabled.
    public let accessibilityText: String?

    /**
     Returns a newly allocated instance of a `Sticker`.

     - parameter imageURL:          The url of an image. This can either be in your bundle or remote.
     - parameter thumbnailURL:      The thumbnail url of an image. This can either be in your bundle or remote.
     - parameter accessibilityText: The accessibility text that describes this sticker.

     - returns: An instance of `Sticker`.

     This initializer creates an instance of `Sticker` that loads its image and its thumbnail image from
     an `NSURL` when needed. That image is then placed in a cache, that is purged when a memory warning is
     received.
     */
    public init(imageURL: NSURL, thumbnailURL: NSURL, accessibilityText: String?) {
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.image = nil
        self.thumbnail = nil
        self.accessibilityText = accessibilityText
        super.init()
    }

    /**
     Returns a newly allocated instance of a `Sticker`.

     - parameter image:             The image to use for this sticker.
     - parameter thumbnail:         The thumbnail image to use for this sticker.
     - parameter accessibilityText: The accessibility text that describes this sticker.

     - returns: An instance of `Sticker`.

     This initializer creates an instance of `Sticker` which already has an image and thumbnail image
     associated. This image is **not** placed in a cache by this SDK. If you choose to use this initializer,
     then you should create the `UIImage`s that you pass with `init(named:)` or `init(named:inBundle:compatibleWithTraitCollection:)`,
     so that they are added to the system cache and automatically purged when memory is low.
     */
    public init(image: UIImage, thumbnail: UIImage, accessibilityText: String?) {
        self.image = image
        self.thumbnail = thumbnail
        self.imageURL = nil
        self.thumbnailURL = nil
        self.accessibilityText = accessibilityText
        super.init()
    }

    /**
     Gets the image of the sticker.

     - parameter completionBlock: A completion block.
     */
    public func image(completionBlock: (Image?, NSError?) -> ()) {
        if let image = image {
            completionBlock(image, nil)
        } else if let imageURL = imageURL {
            ImageStore.sharedStore.showSpinner = true
            ImageStore.sharedStore.get(imageURL) { (image, error) -> Void in
                completionBlock(image, error)
            }
        }
    }

    /**
     Gets the thumbmail of the sticker.

     - parameter completionBlock: A completion block.
     */
    public func thumbnail(completionBlock: (Image?, NSError?) -> ()) {
        if let thumbnail = thumbnail {
            completionBlock(thumbnail, nil)
        } else if let thumbnailURL = thumbnailURL {
            ImageStore.sharedStore.showSpinner = false
            ImageStore.sharedStore.get(thumbnailURL) { (image, error) -> Void in
                completionBlock(image, error)
            }
        }
    }
}
