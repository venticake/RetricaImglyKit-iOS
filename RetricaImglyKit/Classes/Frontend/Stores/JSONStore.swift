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
@objc(IMGLYJSONStoreProtocol) public protocol JSONStoreProtocol {
    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: NSURL, completionBlock: (NSDictionary?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency.
 */
@objc(IMGLYJSONStore) public class JSONStore: NSObject, JSONStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = JSONStore()

    /// A service that is used to perform http get requests.
    public var requestService: RequestServiceProtocol = RequestService()

    private var store: [NSURL : NSDictionary?] = [ : ]

    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: NSURL, completionBlock: (NSDictionary?, NSError?) -> Void) {
        if let dict = store[url] {
            completionBlock(dict, nil)
        } else {
            startJSONRequest(url, completionBlock: completionBlock)
        }
    }

    private func startJSONRequest(url: NSURL, completionBlock: (NSDictionary?, NSError?) -> Void) {
        requestService.get(url, cached: false, callback: {
            (data, error) -> Void in
            if error != nil {
                completionBlock(nil, error)
            } else {
                if let data = data {
                    if let dict = self.dictionaryFromData(data) {
                        self.store[url] = dict
                        completionBlock(dict, nil)
                    } else {
                        completionBlock(nil, NSError(info: Localize("No valid json found at ") + url.absoluteString))
                    }
                }
            }
        })
    }

    private func dictionaryFromData(data: NSData) -> NSDictionary? {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dict = jsonObject as? NSDictionary {
                return dict
            }
        } catch _ {
            return nil
        }
        return nil
    }
}
