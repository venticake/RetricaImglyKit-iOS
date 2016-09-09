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
 *  The `Frame` class holds all informations needed to be managed and rendered.
 */
@objc(IMGLYFrame) public class Frame: NSObject {

    /// The label of the frame. This is used for accessibility.
    public var accessibilityText: String {
        get {
            return self.info.accessibilityText
        }
    }

    private var ratioToImageMap = [Float : FrameContainer]()
    private var ratioToThumbnailMap = [Float : FrameContainer]()
    private var info = FrameInfoRecord()

     /**
     Returns a newly allocated instance of `Frame` using the given accessibility text.

     - parameter accessibilityText: The accessibility text that describes this frame.

     - returns: An instance of a `Frame`.
     */
    public init(info: FrameInfoRecord) {
        self.info = info
        super.init()
        buildURIMaps()
    }

    private func buildURIMaps() {
        for imageInfo in info.imageInfos {
            if let imageURL = NSURL(string: imageInfo.urlAtlas["mediaBase"]!) {
                ratioToImageMap[imageInfo.ratio] = FrameContainer(url: imageURL)
            }

            if let thumbnailURL = NSURL(string: imageInfo.urlAtlas["mediaThumb"]!) {
                ratioToThumbnailMap[imageInfo.ratio] = FrameContainer(url: thumbnailURL)
            }
        }
    }

    /**
     Get a frame image matching the aspect ratio.

     - parameter ratio:     The desired ratio.
     - parameter completionBlock: A completion block.
     */
    public func imageForRatio(ratio: Float, completionBlock: (Image?, NSError?) -> ()) {
        guard ratioToImageMap.count > 0 else {
            return
        }

        var minDistance: Float = 99999.0
        var nearestRatio: Float = 0.0

        //  if we dont have a nine patch image, seek for the closest possible
        if ratioToImageMap[0.0] == nil {
            for keyRatio in ratioToImageMap.keys {
                let distance = abs(keyRatio - ratio)
                if distance < minDistance {
                    minDistance = distance
                    nearestRatio = keyRatio
                }
            }
        }

        if let frameContainer = ratioToImageMap[nearestRatio] {
            if let image = frameContainer.image {
                completionBlock(image, nil)
            } else if let url = frameContainer.url {
                ImageStore.sharedStore.showSpinner = true
                ImageStore.sharedStore.get(url) { (image, error) -> Void in
                    completionBlock(image, error)
                }
            }
        }
    }

     /**
     Get a frame thumbnail matching the aspect ratio.

     - parameter ratio:           The desired ratio.
     - parameter completionBlock: A completion block.
     */
    public func thumbnailForRatio(ratio: Float, completionBlock: (Image?, NSError?) -> ()) {
        guard ratioToThumbnailMap.count > 0 else {
            return
        }

        var minDistance: Float = 99999.0
        var nearestRatio: Float = 0.0

        for keyRatio in ratioToThumbnailMap.keys {
            let distance = abs(keyRatio - ratio)
            if distance < minDistance {
                minDistance = distance
                nearestRatio = keyRatio
            }
        }

        if let frameContainer = ratioToThumbnailMap[nearestRatio] {
            if let image = frameContainer.image {
                completionBlock(image, nil)
            } else if let url = frameContainer.url {
                ImageStore.sharedStore.showSpinner = false
                ImageStore.sharedStore.get(url) { (image, error) -> Void in
                    completionBlock(image, error)
                }
            }
        }
    }

    /**
     Add an image that is used as a frame for a ratio.

     - parameter imageURL: The url of an image. This can either be in your bundle or remote.
     - parameter ratio: An aspect ratio.

     This method adds an url to an image to the frame which then loads its image and its thumbnail image from
     an `NSURL` when needed. That image is then placed in a cache, that is purged when a memory warning is
     received.
     */
    public func addImageURL(imageURL: NSURL, ratio: Float) {
        ratioToImageMap[ratio] = FrameContainer(url: imageURL)
    }

    /**
     Add an thumbnail that is used as a frame for a ratio.

     - parameter imageURL: The url of an image. This can either be in your bundle or remote.
     - parameter ratio: An aspect ratio.

     This method adds an url to an image to the frame which then loads its image and its thumbnail image from
     an `NSURL` when needed. That image is then placed in a cache, that is purged when a memory warning is
     received.
     */
    public func addThumbnailURL(imageURL: NSURL, ratio: Float) {
        ratioToThumbnailMap[ratio] = FrameContainer(url: imageURL)
    }

    /**
     Add an image that is used as a frame for a ratio.

     - parameter image: The image to use for this frame.
     - parameter ratio: An aspect ratio.

     This method adds an `UIImage` to a frame. This image is **not** placed in a cache by this SDK. If you choose to use this initializer,
     then you should create the `UIImage`s that you pass with `init(named:)` or `init(named:inBundle:compatibleWithTraitCollection:)`,
     so that they are added to the system cache and automatically purged when memory is low.
     */
    public func addImage(image: UIImage, ratio: Float) {
        ratioToImageMap[ratio] = FrameContainer(image: image)
    }

    /**
     Add an thumbnail that is used as a frame for a ratio.

     - parameter image: The image to use for this frame.
     - parameter ratio: An aspect ratio.

     This method adds an `UIImage` to a frame. This image is **not** placed in a cache by this SDK. If you choose to use this initializer,
     then you should create the `UIImage`s that you pass with `init(named:)` or `init(named:inBundle:compatibleWithTraitCollection:)`,
     so that they are added to the system cache and automatically purged when memory is low.
     */
    public func addThumbnail(image: UIImage, ratio: Float) {
        ratioToThumbnailMap[ratio] = FrameContainer(image: image)
    }

    // MARK: - NSObject

    /**
    :nodoc:
    */
    public override func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? Frame else {
            return false
        }

        if accessibilityText != rhs.accessibilityText {
            return false
        }

        if ratioToImageMap != rhs.ratioToImageMap {
            return false
        }

        if ratioToThumbnailMap != rhs.ratioToThumbnailMap {
            return false
        }

        if info != rhs.info {
            return false
        }

        return true
    }
}

private struct FrameContainer: Equatable {
    let url: NSURL?
    let image: UIImage?

    init(url: NSURL) {
        self.url = url
        self.image = nil
    }

    init(image: UIImage) {
        self.image = image
        self.url = nil
    }
}

private func == (lhs: FrameContainer, rhs: FrameContainer) -> Bool {
    if lhs.url != rhs.url {
        return false
    }

    if lhs.image != rhs.image {
        return false
    }

    return true
}
