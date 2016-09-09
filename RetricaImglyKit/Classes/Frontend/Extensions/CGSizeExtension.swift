//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
}
