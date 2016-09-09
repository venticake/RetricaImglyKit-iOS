//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

@available(iOS 8, *)
extension CGRect {
    init?(points: [CGPoint]) {
        var maxX: CGFloat?
        var maxY: CGFloat?
        var minX: CGFloat?
        var minY: CGFloat?

        for point in points {
            if let x = maxX {
                maxX = max(x, point.x)
            } else {
                maxX = point.x
            }

            if let y = maxY {
                maxY = max(y, point.y)
            } else {
                maxY = point.y
            }

            if let x = minX {
                minX = min(x, point.x)
            } else {
                minX = point.x
            }

            if let y = minY {
                minY = min(y, point.y)
            } else {
                minY = point.y
            }
        }

        if let maxX = maxX, maxY = maxY, minX = minX, minY = minY {
            origin = CGPoint(x: minX, y: minY)
            size = CGSize(width: maxX - minX, height: maxY - minY)
        } else {
            return nil
        }
    }

    init(size: CGSize, thatFitsIntoRect rect: CGRect) {
        if !(size.width > 0 && size.height > 0) {
            self = rect
            return
        }

        let scale = size.width / size.height
        let rectScale = rect.width / rect.height

        if scale <= rectScale {
            let width = scale * rect.height
            let x = width * -0.5 + rect.midX
            self = CGRect(x: x, y: rect.origin.y, width: width, height: rect.height)
            return
        } else {
            let height = rect.width / scale
            let y = height * -0.5 + rect.midY
            self = CGRect(x: rect.origin.x, y: y, width: rect.width, height: height)
        }
    }

    mutating func fittedIntoTargetRect(targetRect: CGRect, withContentMode contentMode: UIViewContentMode) {
        if !(contentMode == .ScaleAspectFit || contentMode == .ScaleAspectFill) {
            // Not implemented
            return
        }

        var scale = targetRect.width / self.width

        if contentMode == .ScaleAspectFit {
            if self.height * scale > targetRect.height {
                scale = targetRect.height / self.height
            }
        } else if contentMode == .ScaleAspectFill {
            if self.height * scale < targetRect.height {
                scale = targetRect.height / self.height
            }
        }

        let scaledWidth = self.width * scale
        let scaledHeight = self.height * scale
        let scaledX = targetRect.width / 2 - scaledWidth / 2
        let scaledY = targetRect.height / 2 - scaledHeight / 2

        self.origin.x = scaledX
        self.origin.y = scaledY
        self.size.width = scaledWidth
        self.size.height = scaledHeight
    }

    func rectFittedIntoTargetRect(targetRect: CGRect, withContentMode contentMode: UIViewContentMode) -> CGRect {
        var sourceRect = self
        sourceRect.fittedIntoTargetRect(targetRect, withContentMode: contentMode)
        return sourceRect
    }
}
