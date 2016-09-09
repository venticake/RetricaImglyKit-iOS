//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import CoreImage

@available(iOS 8, *)
extension CGAffineTransform {
    var xScale: CGFloat {
        return sqrt(a * a + c * c)
    }

    var yScale: CGFloat {
        return sqrt(b * b + d * d)
    }

    var rotation: CGFloat {
        return atan2(b, a)
    }
}
