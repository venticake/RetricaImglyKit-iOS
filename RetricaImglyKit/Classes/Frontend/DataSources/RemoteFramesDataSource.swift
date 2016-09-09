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
 This protocol is used to get tokens and insert them into the called url.
 That way we can deal with urls that contain tokens.
 */
@objc(IMGLYTokenProvider) public protocol TokenProvider {
    /**
     Returns a token that is used to perform an API call.

     - parameter completionBlock: A completion block that has the token or an error as payload.
     */
    func getToken(completionBlock: (String?, NSError?) -> Void)
}

/**
 An implementation of `FramesDataSourceProtocol` that can be used to download frames from a remote source.
 */
@objc(IMGLYRemoteFramesDataSource) public class RemoteFramesDataSource: NSObject, FramesDataSourceProtocol {

    /// The placeholder string that will be replaced by the token of the token provider.
    public static let TokenString = "##Token##"

    /// A `FrameStore` that is used by this class. It defaults to the `sharedStore`.
    public var frameStore: FrameStoreProtocol = FrameStore.sharedStore

    /// The URL used for the call use ##Token## as place holder for a token that is set by a token provider.
    public var url = ""

    /// An object that implements the `TokenProvider` protocol.
    public var tokenProvider: TokenProvider? = nil

    private var frames: [Frame]? = nil

    // MARK: - Init

    private func getFrames(completionBlock: ([Frame]?, NSError?) -> Void) {
        guard url.characters.count > 0 else {
            completionBlock(nil, NSError(info: Localize("URL not set")))
            return
        }
        if let frames = self.frames {
            completionBlock(frames, nil)
        } else {
            if url.containsString(RemoteFramesDataSource.TokenString) {
                if let tokenProvider = tokenProvider {
                    tokenProvider.getToken({ (token, error) -> Void in
                        if let token = token {
                            let finalURL = self.url.stringByReplacingOccurrencesOfString(RemoteFramesDataSource.TokenString, withString: token)
                            self.performFrameCall(NSURL(string: finalURL)!, completionBlock: completionBlock)
                        }
                    })
                } else {
                    completionBlock(nil, NSError(info: Localize("Url contains the token place holder, but no token provider is set")))
                }
            } else {
                performFrameCall(NSURL(string: url)!, completionBlock: completionBlock)
            }
        }
    }

    private func performFrameCall(finalURL: NSURL, completionBlock: ([Frame]?, NSError?) -> Void) {
        frameStore.get(finalURL, completionBlock: { records, error in
            if let records = records {
                self.frames = [Frame]()
                for record in records {
                    let frame = Frame(info: record)
                    self.frames?.append(frame)
                }
                completionBlock(self.frames, nil)
            } else {
                completionBlock(nil, error)
            }
        })
    }

    // MARK: - StickersDataSource

    /**
    The count of frames.

    - parameter completionBlock: A completion block.
    */
    public func frameCount(ratio: Float, completionBlock: (Int, NSError?) -> Void) {
        getFrames({ frames, error in
            if let frames = frames {
                self.frames = frames
                completionBlock(frames.count, nil)
            } else {
                completionBlock(0, error)
            }
        })
    }

    /**
     Returns the thumbnail and label of the frame at a given index for the ratio.

     - parameter index:           The index of the frame.
     - parameter ratio:           The ratio of the image.
     - parameter completionBlock: Used to return the result asynchronously.

     */
    public func thumbnailAndLabelAtIndex(index: Int, ratio: Float, completionBlock: (UIImage?, String?, NSError?) -> ()) {
        getFrames({ frames, error in
            if let frames = self.frames {
                let frame = frames[index]
                frame.thumbnailForRatio(ratio, completionBlock: { (image, error) -> () in
                    if let image = image {
                        completionBlock(image, frame.accessibilityText, nil)
                    } else {
                        completionBlock(nil, nil, error)
                    }
                })
            } else {
                completionBlock(nil, nil, error)
            }
        })

    }

    /**
     Retrieves a the frame at the given index.

     - parameter index:           A index.
     - parameter completionBlock: A completion block.
     */
    public func frameAtIndex(index: Int, ratio: Float, completionBlock: (Frame?, NSError?) -> ()) {
        getFrames({ frames, error in
            self.frames = frames
            if let frames = frames {
                completionBlock(frames[index], nil)
            } else {
                completionBlock(nil, error)
            }
        })
    }
}
