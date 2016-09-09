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
@objc(IMGLYFrameStoreProtocol) public protocol FrameStoreProtocol {
    /**
     Retrieves FrameInfoRecord data, from the JSON located at the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: NSURL, completionBlock: ([FrameInfoRecord]?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency, and performs a sanity check.
 */
@objc(IMGLYFrameStore) public class FrameStore: NSObject, FrameStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = FrameStore()

    /// The json parser to use.
    public var jsonParser: JSONFrameParserProtocol = JSONFrameParser()

    /// This store is used to retrieve the JSON data.
    public var jsonStore: JSONStoreProtocol = JSONStore()

    private var store: [NSURL : [FrameInfoRecord]] = [ : ]

    /**
     Retrieves FrameInfoRecord data, from the JSON located at the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: NSURL, completionBlock: ([FrameInfoRecord]?, NSError?) -> Void) {
        if let record = store[url] {
            completionBlock(record, nil)
        } else {
            jsonStore.get(url, completionBlock: { (dict, error) -> Void in
                if let dict = dict {
                    do {
                        try self.store[url] = self.jsonParser.parseJSON(dict)
                    } catch JSONParserError.IllegalFrameHash {
                        completionBlock(nil, NSError(info: Localize("Illegal frame hash")))
                    } catch JSONParserError.IllegalImageRecord(let recordName) {
                        completionBlock(nil, NSError(info: Localize("Illegal image record") + " .Tag: \(recordName)"))
                    } catch JSONParserError.IllegalImageRatio(let recordName) {
                        completionBlock(nil, NSError(info: Localize("Illegal image ratio" ) + " .Tag: \(recordName)"))
                    } catch JSONParserError.FrameNodeNoDictionary {
                        completionBlock(nil, NSError(info: Localize("Frame node not holding a dictionaty")))
                    } catch JSONParserError.FrameArrayNotFound {
                        completionBlock(nil, NSError(info: Localize("Frame node not found, or not holding an array")))
                    } catch {
                         completionBlock(nil, NSError(info: Localize("Unknown error")))
                    }
                    completionBlock(self.store[url], nil)
                } else {
                    completionBlock(nil, error)
                }
            })
        }
    }
}
