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
 The `JSONStore` provides methods to retrieve JSON data from any URL.
 */
@available(iOS 8, *)
@objc(IMGLYImageStoreProtocol) public protocol ImageStoreProtocol {
    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: NSURL, completionBlock: (UIImage?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency.
 */
@available(iOS 8, *)
@objc(IMGLYImageStore) public class ImageStore: NSObject, ImageStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = ImageStore()

    /// A service that is used to perform http get requests.
    public var requestService: RequestServiceProtocol = RequestService()

    private var store = NSCache()

    /// Whether or not to display an activity indicator while fetching the images. Default is `true`.
    public var showSpinner = true

    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: NSURL, completionBlock: (UIImage?, NSError?) -> Void) {
        if let image = store[url] as? UIImage {
            completionBlock(image, nil)
        } else {
            if url.fileURL {
                if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                    if url.absoluteString.containsString(".9.") {
                        completionBlock(image.resizableImageFrom9Patch(image), nil)
                    } else {
                        completionBlock(image, nil)
                    }
                } else {
                    let error = NSError(info: Localize("Image not found: ") + url.absoluteString)
                    completionBlock(nil, error)
                }
            } else {
                startRequest(url, completionBlock: completionBlock)
            }
        }
    }

    private func startRequest(url: NSURL, completionBlock: (UIImage?, NSError?) -> Void) {
        showProgress()
        requestService.get(url, cached: true) { (data, error) -> Void in
            self.hideProgress()
            if error != nil {
                completionBlock(nil, error)
            } else {
                if let data = data {
                    if var image = UIImage(data: data) {
                        if url.absoluteString.containsString(".9.") {
                            image = image.resizableImageFrom9Patch(image)
                        }
                        self.store[url] = image
                        completionBlock(image, nil)
                    } else {
                        completionBlock(nil, NSError(info: "No image found at \(url)."))
                    }
                }
            }
        }
    }

    private func showProgress() {
        if showSpinner {
            dispatch_async(dispatch_get_main_queue()) {
                ProgressView.sharedView.showWithMessage(Localize("Downloading..."))
            }
        }
    }

    private func hideProgress() {
        dispatch_async(dispatch_get_main_queue()) {
            ProgressView.sharedView.hide()
        }
    }
}
