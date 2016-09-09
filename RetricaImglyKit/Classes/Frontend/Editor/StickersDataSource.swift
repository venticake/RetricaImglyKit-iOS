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
 An object that adopts the `StickersDataSourceProtocol` protocol is responsible for providing the data
 that is required to display and add stickers to an image.
 */
@objc(IMGLYStickersDataSourceProtocol) public protocol StickersDataSourceProtocol {
    /**
     Returns the total count of stickers.

     - parameter completionBlock: Used to return the result asynchronously.
     */
    func stickerCount(completionBlock: (Int, NSError?) -> Void)

    /**
     Returns the thumbnail image and the label for a sticker.

     - parameter index:           The index of the sticker.
     - parameter completionBlock: Used to return the result asynchronously.
     */
    func thumbnailAndLabelAtIndex(index: Int, completionBlock: (UIImage?, String?, NSError?) -> ())

    /**
     Returns the sticker at a given index.

     - parameter index:           The index of the sticker.
     - parameter completionBlock: Used to return the result asynchronously.
     */
    func stickerAtIndex(index: Int, completionBlock: (Sticker?, NSError?) -> ())
}

/**
 An implementation of `StickersDataSourceProtocol` with all available stickers.
 */
@objc(IMGLYStickersDataSource) public class StickersDataSource: NSObject, StickersDataSourceProtocol {

    private let stickers: [Sticker]

    // MARK: Init

    /**
     :nodoc:
    */
    override init() {
        let stickerFilesAndLabels = [
            ("glasses_nerd", "Brown glasses"),
            ("glasses_normal", "Black glasses"),
            ("glasses_shutter_green", "Green glasses"),
            ("glasses_shutter_yellow", "Yellow glasses"),
            ("glasses_sun", "Sunglasses"),
            ("hat_cap", "Blue and white cap"),
            ("hat_party", "White and red party hat"),
            ("hat_sherrif", "Sherrif hat"),
            ("hat_zylinder", "Black high hat"),
            ("heart", "Red heart"),
            ("mustache_long", "Long black mustache"),
            ("mustache1", "Brown mustache"),
            ("mustache2", "Black mustache"),
            ("mustache3", "Brown mustache"),
            ("pipe", "Pipe"),
            ("snowflake", "Snowflake"),
            ("star", "Star")
        ]

        stickers = stickerFilesAndLabels.flatMap { fileAndLabel -> Sticker? in
            let label = fileAndLabel.1
            if let image = UIImage(named: fileAndLabel.0, inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil), thumbnail = UIImage(named: fileAndLabel.0 + "_thumbnail", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil) {
                return Sticker(image: image, thumbnail: thumbnail, accessibilityText: label)
            }

            return nil
        }

        super.init()
    }

    /**
     Creates a custom datasource offering the given stickers.
    */
    public init(stickers: [Sticker]) {
        self.stickers = stickers
        super.init()
    }

    // MARK: - StickersDataSource

    /**
    :nodoc:
    */
    public func stickerCount(completionBlock: (Int, NSError?) -> Void) {
        completionBlock(stickers.count, nil)
    }

    /**
     :nodoc:
     */
    public func thumbnailAndLabelAtIndex(index: Int, completionBlock: (UIImage?, String?, NSError?) -> ()) {
        if index < stickers.count {
            let sticker = stickers[index]
            sticker.thumbnail({ (image, error) -> () in
                completionBlock(image, sticker.accessibilityText, nil)
            })
        } else {
            completionBlock(nil, nil, NSError(info: Localize("Index out of bound")))
        }
    }

    /**
     :nodoc:
     */
    public func stickerAtIndex(index: Int, completionBlock: (Sticker?, NSError?) -> ()) {
      if index < stickers.count {
            completionBlock(stickers[index], nil)
        } else {
            completionBlock(nil, NSError(info: Localize("Index out of bound")))
        }
    }
}
