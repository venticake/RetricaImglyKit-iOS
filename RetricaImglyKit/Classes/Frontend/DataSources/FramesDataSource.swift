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
 An object that adopts the `FramesDataSourceProtocol` protocol is responsible for providing the data
 that is required to display and add frames to an image.
 */
@available(iOS 8, *)
@objc(IMGLYFramesDataSourceProtocol) public protocol FramesDataSourceProtocol {
    /**
     Returns the count of the frames. We added a ratio parameter in case you only to show frames that have a mathing ratio.

     - parameter ratio:           The ratio of the image.
     - parameter completionBlock: Used to return the result asynchronously.
     */
    func frameCount(ratio: Float, completionBlock: (Int, NSError?) -> Void)

    /**
     Returns the thumbnail and label of the frame at a given index for the ratio.

     - parameter index:           The index of the frame.
     - parameter ratio:           The ratio of the image.
     - parameter completionBlock: Used to return the result asynchronously.

     */
    func thumbnailAndLabelAtIndex(index: Int, ratio: Float, completionBlock: (UIImage?, String?, NSError?) -> ())

    /**
     Returns the frame at a given index for the given ratio.

     - parameter index:           The index of the frame.
     - parameter ratio:           The ratio of the image.
     - parameter completionBlock: Used to return the result asynchronously.
     */
    func frameAtIndex(index: Int, ratio: Float, completionBlock: (Frame?, NSError?) -> ())
}

/**
 An implementation of `FramesDataSourceProtocol` with all available frames.
 */
@available(iOS 8, *)
@objc(IMGLYFramesDataSource) public class FramesDataSource: NSObject, FramesDataSourceProtocol {

    private var frames = [Frame]()

    // MARK: Init

    /**
    :nodoc:
    */
    override init() {
        let record = FrameInfoRecord()
        record.accessibilityText = "black border"
        let frame1 = Frame(info: record)
        frame1.addImage(UIImage(named: "blackwood1_1", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!, ratio: 1.0)
        frame1.addImage(UIImage(named: "blackwood4_6", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!, ratio: 4.0 / 6.0)
        frame1.addImage(UIImage(named: "blackwood6_4", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!, ratio: 6.0 / 4.0)
        frame1.addThumbnail(UIImage(named: "blackwood_thumbnail", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!, ratio: 1.0)
        frames.append(frame1)
        super.init()
    }

    /**
     Returns a newly allocated instance of `FramesDataSource` for the given frames.

     - parameter frames: An array of frames that this data source offers.

     - returns: An instance of a `FramesDataSource`.
     */
    public init(frames: [Frame]) {
        self.frames = frames
        super.init()
    }

    // MARK: - StickersDataSource

    /**
    Gets the count of the frames. We added a ratio parameter in case you only to show frames that have a mathing ratio.

    - parameter ratio:           The ratio.
    - parameter completionBlock: A completion block that receives the results.
    */
    public func frameCount(ratio: Float, completionBlock: (Int, NSError?) -> Void) {
        completionBlock(frames.count, nil)
    }

    /**
     Gets the matching sticker at index.

     - parameter index:           The index of the frame.
     - parameter ratio:           The allowed ratio.
     - parameter tolerance:       The tolerance applied to the ratio.
     - parameter completionBlock: A completion block that receives the results.
     */
    public func frameAtIndex(index: Int, ratio: Float, completionBlock: (Frame?, NSError?) -> ()) {
        completionBlock(frames[index], nil)
    }

    /**
     Returns the thumbnail and label of the frame at a given index for the ratio.

     - parameter index:           The index of the frame.
     - parameter ratio:           The ratio of the image.
     - parameter completionBlock: Used to return the result asynchronously.

     */
    public func thumbnailAndLabelAtIndex(index: Int, ratio: Float, completionBlock: (UIImage?, String?, NSError?) -> ()) {
        let frame = frames[index]
        frame.thumbnailForRatio(ratio, completionBlock: { (image, error) -> () in
            if let image = image {
                completionBlock(image, frame.accessibilityText, nil)
            } else {
                completionBlock(nil, nil, error)
            }
        })
    }
}
