//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

var localizationBlock: ((stringToLocalize: String) -> String?)?
var localizationDictionary: [String: [String: String]]?

func Localize(stringToken: String) -> String {
    // If a custom localization block is set, try that
    if let localizationFromBlock = localizationBlock?(stringToLocalize: stringToken) {
        return localizationFromBlock
    }

    // If a custom localization dictionary is set, try that
    if let localizationDictionary = localizationDictionary {
        let preferredLocalizations = NSBundle.mainBundle().preferredLocalizations

        // Try preferred langauges
        for language in preferredLocalizations {
            if let localization = localizationDictionary[language]?[stringToken] {
                return localization
            }
        }
    }

    // Use standard NSLocalizedString
    let bundle = NSBundle.imglyKitBundle

    return NSLocalizedString(stringToken, tableName: nil, bundle: bundle, value: stringToken, comment: "")
}

/**
 Allows to set a custom dictionary that contains dictionaries with language locales.
 Will override localization found in the bundle, if a value is found.
 Falls back to "en" if localization key is not found in dictionary.

 - parameter localizationDict: A custom dictionary that contains dictionaries with language locales.
 */
public func IMGLYSetLocalizationDictionary(localizationDict: [String: [String: String]]) {
    localizationDictionary = localizationDict
}

/**
 Register a custom block that handles translation.
 If this block returns nil, the imglyKit.bundle + localizationDict will be used.

 - parameter localizationBlock: A custom block that handles translation.
 */
public func IMGLYSetLocalizationBlock(_localizationBlock: (stringToLocalize: String) -> String?) {
    localizationBlock = _localizationBlock
}
