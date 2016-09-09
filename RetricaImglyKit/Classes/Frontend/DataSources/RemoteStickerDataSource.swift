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
 An implementation of `StickersDataSourceProtocol` that can be used to download stickers from a remote source.
 */
@objc(IMGLYRemoteStickersDataSource) public class RemoteStickersDataSource: NSObject, StickersDataSourceProtocol {

    /// The placeholder string that will be replaced by the token of the token provider.
    public static let TokenString = "##Token##"

    /// A `StickerStore` that is used by this class. It defaults to the `sharedStore`.
    public var stickerStore: StickerStoreProtocol = StickerStore.sharedStore

    /// A `ImageStore` that is used by this class. It defaults to the `sharedStore`.
    public var imageStore: ImageStore = ImageStore.sharedStore

    /// The URL used for the call use ##Token## as place holder for a token that is set by a token provider.
    public var url = ""

    /// An object that implements the `TokenProvider` protocol.
    public var tokenProvider: TokenProvider? = nil

    private var stickers: [Sticker]? = nil

    // MARK: Init

    private func getStickers(completionBlock: ([Sticker]?, NSError?) -> Void) {
        guard url.characters.count > 0 else {
            completionBlock(nil, NSError(info: Localize("URL not set")))
            return
        }
        if let stickers = self.stickers {
            completionBlock(stickers, nil)
        } else {
            if url.containsString(RemoteStickersDataSource.TokenString) {
                if let tokenProvider = tokenProvider {
                    tokenProvider.getToken({ (token, error) -> Void in
                        if let token = token {
                            let finalURL = self.url.stringByReplacingOccurrencesOfString(RemoteStickersDataSource.TokenString, withString: token)
                            self.performStickerCall(NSURL(string: finalURL)!, completionBlock: completionBlock)
                        }
                    })
                } else {
                    completionBlock(nil, NSError(info: Localize("Url contains the token place holder, but no token provider is set")))
                }
            } else {
                performStickerCall(NSURL(string: url)!, completionBlock: completionBlock)
            }
        }
    }

    private func performStickerCall(finalURL: NSURL, completionBlock: ([Sticker]?, NSError?) -> Void) {
        stickerStore.get(finalURL, completionBlock: { records, error in
            if let records = records {
                self.stickers = [Sticker]()
                for record in records {
                    let sticker = Sticker(imageURL: NSURL(string: record.imageInfo.urlAtlas["mediaMedium"]!)!, thumbnailURL: NSURL(string: record.imageInfo.urlAtlas["mediaThumb"]!)!, accessibilityText: record.accessibilityText)
                    self.stickers?.append(sticker)
                }
                completionBlock(self.stickers, nil)
            } else {
                completionBlock(nil, error)
            }
        })
    }

    // MARK: - StickersDataSource

    /**
    The count of stickers.

    - parameter completionBlock: A completion block.
    */
    public func stickerCount(completionBlock: (Int, NSError?) -> Void) {
        getStickers({ stickers, error in
            if let stickers = stickers {
                self.stickers = stickers

                completionBlock(stickers.count, nil)
            } else {
                completionBlock(0, error)
            }
        })
    }

    /**
     Retrieves a the sticker at the given index.

     - parameter index:           A index.
     - parameter completionBlock: A completion block.
     */
    public func stickerAtIndex(index: Int, completionBlock: (Sticker?, NSError?) -> ()) {
        getStickers({ stickers, error in
            if let stickers = self.stickers {
                completionBlock(stickers[index], nil)
            } else {
                completionBlock(nil, error)
            }
        })
    }

    /**
     Thumbnail and label at the given index.

     - parameter index:           A index.
     - parameter completionBlock: A completion block.
     */
    public func thumbnailAndLabelAtIndex(index: Int, completionBlock: (UIImage?, String?, NSError?) -> ()) {
        getStickers({ stickers, error in
            if let stickers = self.stickers {
                let sticker = stickers[index]
                sticker.thumbnail({ (image, error) -> () in
                    if let image = image {
                        completionBlock(image, sticker.accessibilityText, nil)
                    } else {
                        completionBlock(nil, nil, error)
                    }
                })
            } else {
                completionBlock(nil, nil, error)
            }
        })
    }
}
