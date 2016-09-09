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
 *  The JSONParser class is out to parse a JSON dicionary into an array of `StickerInfoRecord` entries.
 */
@objc(IMGLYJSONStickerParserProtocol) public protocol JSONStickerParserProtocol {
    /**
     Parses the retrieved JSON data to an array of `StickerInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `StickerInfoRecord`s.
     */
    func parseJSON(dict: NSDictionary)  throws -> [StickerInfoRecord]
}

/**
 *  The JSONParser class is out to parse a JSON dicionary into an array of `StickerInfoRecord` entries.
 */
@objc(IMGLYJSONStickerParser) public class JSONStickerParser: NSObject, JSONStickerParserProtocol {

    /**
     Parses the retrieved JSON data to an array of `StickerInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `StickerInfoRecord`'s.
     */
    public func parseJSON(dict: NSDictionary)  throws -> [StickerInfoRecord] {
        var records = [StickerInfoRecord]()
        if let stickers = dict["stickers"] as? NSArray {
            for sticker in stickers {
                if let sticker = sticker as? NSDictionary {
                    guard let name = sticker["name"] as? String,
                        accessibilityText = sticker["accessibilityText"] as? String,
                        images = sticker["images"] as? NSDictionary else {
                            throw JSONParserError.IllegalFrameHash
                    }
                    let record = StickerInfoRecord()
                    record.name = name
                    record.accessibilityText = accessibilityText
                    let imageInfo = ImageInfoRecord()
                    for (key, value) in images {
                        if let metaInfo = value as? NSDictionary {
                            // swiftlint:disable force_cast
                            imageInfo.urlAtlas[key as! String] = metaInfo["uri"] as? String
                            // swiftlint:enable force_cast
                        }
                    }
                    record.imageInfo = imageInfo
                    records.append(record)
                } else {
                    throw JSONParserError.IllegalFrameHash
                }
            }
        } else {
            throw JSONParserError.IllegalFrameHash
        }
        return records
    }
}
