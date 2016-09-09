//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

func * (lhs: CGFloat, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
}

func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

func * (lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx * rhs.dx, dy: lhs.dy * rhs.dy)
}

func + (lhs: CGVector, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.dx + rhs.x, y: lhs.dy + rhs.y)
}

func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

func - (lhs: CGVector, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.dx - rhs.x, y: lhs.dy - rhs.y)
}

func - (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}

extension CGVector {
    init(startPoint: CGPoint, endPoint: CGPoint) {
        dx = endPoint.x - startPoint.x
        dy = endPoint.y - startPoint.y
    }

    func normalizedVector() -> CGVector {
        var copy = self
        copy.normalize()
        return copy
    }

    var length: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    mutating func normalize() {
        let length = self.length

        dx = dx / length
        dy = dy / length
    }
}
