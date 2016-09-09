//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import CoreGraphics
import CoreText

/**
  Provides functions to import font added as resource. It also registers them,
  so that the application can load them like any other pre-installed font.
*/
@available(iOS 8, *)
@objc(IMGLYFontImporter) public class FontImporter: NSObject {
    private static var fontsRegistered = false

    /**
    Imports all fonts added as resource. Supported formats are TTF and OTF.
    */
    public func importFonts() {
        if !FontImporter.fontsRegistered {
            importFontsWithExtension("ttf")
            importFontsWithExtension("otf")
            FontImporter.fontsRegistered = true
        }
    }

    private func importFontsWithExtension(ext: String) {
        let paths = NSBundle.imglyKitBundle.pathsForResourcesOfType(ext, inDirectory: nil)
        for fontPath in paths {
            let data: NSData? = NSFileManager.defaultManager().contentsAtPath(fontPath)
            var error: Unmanaged<CFError>?
            let provider = CGDataProviderCreateWithCFData(data)
            let font = CGFontCreateWithDataProvider(provider)

            if let font = font {
                if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                    print("Failed to register font, error: \(error)")
                    return
                }
            }
        }
    }
}
