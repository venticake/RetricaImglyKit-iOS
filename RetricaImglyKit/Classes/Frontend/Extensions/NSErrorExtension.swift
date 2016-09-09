//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

let kIMGLYErrorDomain = "IMGLYErrorDomain"

@available(iOS 8, *)
extension NSError {
    convenience init(info: String) {
        self.init(domain: kIMGLYErrorDomain, code: 0, userInfo: [
            NSLocalizedDescriptionKey: info ])
    }
}
