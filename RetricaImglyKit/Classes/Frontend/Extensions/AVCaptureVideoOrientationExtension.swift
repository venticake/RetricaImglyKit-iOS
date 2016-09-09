//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import AVFoundation

@available(iOS 8, *)
extension AVCaptureVideoOrientation {
    func toTransform(mirrored: Bool = false) -> CGAffineTransform {
        let result: CGAffineTransform

        switch self {
        case .Portrait:
            result = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        case .PortraitUpsideDown:
            result = CGAffineTransformMakeRotation(CGFloat(3 * M_PI_2))
        case .LandscapeRight:
            result = mirrored ? CGAffineTransformMakeRotation(CGFloat(M_PI)) : CGAffineTransformIdentity
        case .LandscapeLeft:
            result = mirrored ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(CGFloat(M_PI))
        }

        return result
    }
}
