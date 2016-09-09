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
 The errors that can occour during the parse process.

 - IllegalFrameHash:      Occurs when the data within a frame structure is invalid.
 - IllegalImageRecord:     Occurs when the image record is invalid.
 - IllegalImageRatio:      Occurs when the image aspect ratio can not be parsed.
 - FrameNodeNoDictionary: Occurs when a frame node does not hold a dicionary.
 - FrameArrayNotFound:    Occurs when no frames tag has been found, or it holds no array.
 */
enum JSONParserError: ErrorType {
    case IllegalFrameHash
    case IllegalStickerHash
    case IllegalImageRecord(recordName: String)
    case IllegalImageRatio(recordName: String)
    case FrameNodeNoDictionary
    case StickerNodeNoDictionary
    case FrameArrayNotFound
    case StickerArrayNotFound
}

/**
 *  The JSONParser class is out to parse a JSON dicionary into an array of `FrameInfoRecord` entries.
 */
@objc(IMGLYJSONFrameParserProtocol) public protocol JSONFrameParserProtocol {
    /**
     Parses the retrieved JSON data to an array of `FrameInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `FrameInfoRecord`s.
     */
    func parseJSON(dict: NSDictionary)  throws -> [FrameInfoRecord]
}

/**
 *  The JSONParser class is out to parse a JSON dicionary into an array of `FrameInfoRecord` entries.
 */
@objc(IMGLYJSONFrameParser) public class JSONFrameParser: NSObject, JSONFrameParserProtocol {

    /**
     Parses the retrieved JSON data to an array of `FrameInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `FrameInfoRecord`s.
     */
    public func parseJSON(dict: NSDictionary)  throws -> [FrameInfoRecord] {
        var records = [FrameInfoRecord]()
        if let frames = dict["borders"] as? NSArray {
            for frame in frames {
                if let frame = frame as? NSDictionary {
                    guard let name = frame["name"] as? String,
                        accessibilityText = frame["accessibilityText"] as? String,
                        images = frame["images"] as? NSDictionary else {
                            throw JSONParserError.IllegalFrameHash
                    }
                    let record = FrameInfoRecord()
                    record.name = name
                    record.accessibilityText = accessibilityText
                    for (key, value) in images {
                        let imageInfo = ImageInfoRecord()
                        guard let ratioString = key as? String,
                            imageDict = value as? NSDictionary else {
                                throw JSONParserError.IllegalImageRecord(recordName: record.name)
                        }
                        let expn = NSExpression(format:ratioString)
                        if let ratio = expn.expressionValueWithObject(nil, context: nil) as? Float {
                            imageInfo.ratio = ratio
                        } else {
                            throw JSONParserError.IllegalImageRatio(recordName: record.name)
                        }
                        for (key, value) in imageDict {
                            if let metaInfo = value as? NSDictionary {
                                // swiftlint:disable force_cast
                                imageInfo.urlAtlas[key as! String] = metaInfo["uri"] as? String
                                // swiftlint:enable force_cast
                            }
                        }
                        record.imageInfos.append(imageInfo)
                    }
                    records.append(record)
                } else {
                    throw JSONParserError.FrameNodeNoDictionary
                }
            }
        } else {
            throw JSONParserError.FrameArrayNotFound
        }
        return records
    }
}
