//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

extension NSBundle {
    /// The bundle that contains all assets of the PhotoEditor SDK.
    public class var imglyKitBundle: NSBundle {
        let frameworkBundle = NSBundle(forClass: IMGLYPhotoEditModel.self)

        guard let resourceBundleURL = frameworkBundle.URLForResource("imglyKit", withExtension: "bundle"), resourceBundle = NSBundle(URL: resourceBundleURL) else {
            fatalError("Unable to find resource bundle.")
        }

        return resourceBundle
    }
}
