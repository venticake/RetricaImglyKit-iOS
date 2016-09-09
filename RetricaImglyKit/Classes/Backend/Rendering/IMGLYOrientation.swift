//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

@available(iOS 7, *)
extension IMGLYOrientation: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .Normal:
            return "Normal"
        case .FlipX:
            return "FlipX"
        case .Rotate180:
            return "Rotate180"
        case .FlipY:
            return "FlipY"
        case .Transpose:
            return "Transpose"
        case .Rotate90:
            return "Rotate90"
        case .Transverse:
            return "Transverse"
        case .Rotate270:
            return "Rotate270"
        }
    }

    /**
     Returns a newly allocated instance of `IMGLYOrientation` that corresponds to the given `UIImageOrientation`.

     - parameter imageOrientation: A `UIImageOrientation`.

     - returns: An instance of `IMGLYOrientation`.
     */
    public init(imageOrientation: UIImageOrientation) {
        switch imageOrientation {
        case .Up:
            self = .Normal
        case .Down:
            self = .Rotate180
        case .Left:
            self = .Rotate270
        case .Right:
            self = .Rotate90
        case .UpMirrored:
            self = .FlipX
        case .DownMirrored:
            self = .FlipY
        case .LeftMirrored:
            self = .Transpose
        case .RightMirrored:
            self = .Transverse
        }
    }

    /**
     Returns a newly allocated instance of `IMGLYOrientation` by concatenating two other orientations.

     - parameter firstOrientation:  The first orientation.
     - parameter secondOrientation: The second orientation.

     - returns: An instance of `IMGLYOrientation`.
     */
    public init(concatOrientation firstOrientation: IMGLYOrientation, withOrientation secondOrientation: IMGLYOrientation) {
        switch firstOrientation {
        case .Normal:
            self = secondOrientation
        case .FlipX:
            switch secondOrientation {
            case .Normal:
                self = .FlipX
            case .FlipX:
                self = .Normal
            case .Rotate180:
                self = .FlipY
            case .FlipY:
                self = .Rotate180
            case .Transpose:
                self = .Rotate270
            case .Rotate90:
                self = .Transverse
            case .Transverse:
                self = .Rotate90
            case .Rotate270:
                self = .Transpose
            }
        case .Rotate180:
            switch secondOrientation {
            case .Normal:
                self = .Rotate180
            case .FlipX:
                self = .FlipY
            case .Rotate180:
                self = .Normal
            case .FlipY:
                self = .FlipX
            case .Transpose:
                self = .Transverse
            case .Rotate90:
                self = .Rotate270
            case .Transverse:
                self = .Transpose
            case .Rotate270:
                self = .Rotate90
            }
        case .FlipY:
            switch secondOrientation {
            case .Normal:
                self = .FlipY
            case .FlipX:
                self = .Rotate180
            case .Rotate180:
                self = .FlipX
            case .FlipY:
                self = .Normal
            case .Transpose:
                self = .Rotate90
            case .Rotate90:
                self = .Transpose
            case .Transverse:
                self = .Rotate270
            case .Rotate270:
                self = .Transverse
            }
        case .Transpose:
            switch secondOrientation {
            case .Normal:
                self = .Transpose
            case .FlipX:
                self = .Rotate90
            case .Rotate180:
                self = .Transverse
            case .FlipY:
                self = .Rotate270
            case .Transpose:
                self = .Normal
            case .Rotate90:
                self = .FlipX
            case .Transverse:
                self = .Rotate180
            case .Rotate270:
                self = .FlipY
            }
        case .Rotate90:
            switch secondOrientation {
            case .Normal:
                self = .Rotate90
            case .FlipX:
                self = .Transpose
            case .Rotate180:
                self = .Rotate270
            case .FlipY:
                self = .Transverse
            case .Transpose:
                self = .FlipY
            case .Rotate90:
                self = .Rotate180
            case .Transverse:
                self = .FlipX
            case .Rotate270:
                self = .Normal
            }
        case .Transverse:
            switch secondOrientation {
            case .Normal:
                self = .Transverse
            case .FlipX:
                self = .Rotate270
            case .Rotate180:
                self = .Transpose
            case .FlipY:
                self = .Rotate90
            case .Transpose:
                self = .Rotate180
            case .Rotate90:
                self = .FlipY
            case .Transverse:
                self = .Normal
            case .Rotate270:
                self = .FlipX
            }
        case .Rotate270:
            switch secondOrientation {
            case .Normal:
                self = .Rotate270
            case .FlipX:
                self = .Transverse
            case .Rotate180:
                self = .Rotate90
            case .FlipY:
                self = .Transpose
            case .Transpose:
                self = .FlipX
            case .Rotate90:
                self = .Normal
            case .Transverse:
                self = .FlipY
            case .Rotate270:
                self = .Rotate180
            }
        }
    }

    /**
     Returns a newly allocated instance of `IMGLYOrientation` that is between two other orientations.

     - parameter firstOrientation:  The first orientation.
     - parameter secondOrientation: The second orientation.

     - returns: An instance of `IMGLYOrientation`.
     */
    public init(betweenOrientation firstOrientation: IMGLYOrientation, andOrientation secondOrientation: IMGLYOrientation) {
        switch firstOrientation {
        case .Normal:
            self = secondOrientation
        case .FlipX:
            switch secondOrientation {
            case .Normal:
                self = .FlipX
            case .FlipX:
                self = .Normal
            case .Rotate180:
                self = .FlipY
            case .FlipY:
                self = .Rotate180
            case .Transpose:
                self = .Rotate270
            case .Rotate90:
                self = .Transverse
            case .Transverse:
                self = .Rotate90
            case .Rotate270:
                self = .Transpose
            }
        case .Rotate180:
            switch secondOrientation {
            case .Normal:
                self = .Rotate180
            case .FlipX:
                self = .FlipY
            case .Rotate180:
                self = .Normal
            case .FlipY:
                self = .FlipX
            case .Transpose:
                self = .Transverse
            case .Rotate90:
                self = .Rotate270
            case .Transverse:
                self = .Transpose
            case .Rotate270:
                self = .Rotate90
            }
        case .FlipY:
            switch secondOrientation {
            case .Normal:
                self = .FlipY
            case .FlipX:
                self = .Rotate180
            case .Rotate180:
                self = .FlipX
            case .FlipY:
                self = .Normal
            case .Transpose:
                self = .Rotate90
            case .Rotate90:
                self = .Transpose
            case .Transverse:
                self = .Rotate270
            case .Rotate270:
                self = .Transverse
            }
        case .Transpose:
            switch secondOrientation {
            case .Normal:
                self = .Transpose
            case .FlipX:
                self = .Rotate90
            case .Rotate180:
                self = .Transverse
            case .FlipY:
                self = .Rotate270
            case .Transpose:
                self = .Normal
            case .Rotate90:
                self = .FlipX
            case .Transverse:
                self = .Rotate180
            case .Rotate270:
                self = .FlipY
            }
        case .Rotate90:
            switch secondOrientation {
            case .Normal:
                self = .Rotate270
            case .FlipX:
                self = .Transverse
            case .Rotate180:
                self = .Rotate90
            case .FlipY:
                self = .Transpose
            case .Transpose:
                self = .FlipX
            case .Rotate90:
                self = .Normal
            case .Transverse:
                self = .FlipY
            case .Rotate270:
                self = .Rotate180
            }
        case .Transverse:
            switch secondOrientation {
            case .Normal:
                self = .Transverse
            case .FlipX:
                self = .Rotate270
            case .Rotate180:
                self = .Transpose
            case .FlipY:
                self = .Rotate90
            case .Transpose:
                self = .Rotate180
            case .Rotate90:
                self = .FlipY
            case .Transverse:
                self = .Normal
            case .Rotate270:
                self = .FlipX
            }
        case .Rotate270:
            switch secondOrientation {
            case .Normal:
                self = .Rotate90
            case .FlipX:
                self = .Transpose
            case .Rotate180:
                self = .Rotate270
            case .FlipY:
                self = .Transverse
            case .Transpose:
                self = .FlipY
            case .Rotate90:
                self = .Rotate180
            case .Transverse:
                self = .FlipX
            case .Rotate270:
                self = .Normal
            }
        }
    }

    /// The inverse orientation of the receiver.
    public var inverseOrientation: IMGLYOrientation {
        switch self {
        case .Normal:
            return .Normal
        case .FlipX:
            return .FlipX
        case .Rotate180:
            return .Rotate180
        case .FlipY:
            return .FlipY
        case .Transpose:
            return .Transverse
        case .Rotate90:
            return .Rotate270
        case .Transverse:
            return .Transpose
        case .Rotate270:
            return .Rotate90
        }
    }

    /**
     Creates a `CGAffineTransform` for an object of the given size that represents the receiver's orientation.

     - parameter size: The size of the object. This is needed to calulcate the correct translations.

     - returns: A `CGAffineTransform`.
     */
    public func transformWithSize(size: CGSize) -> CGAffineTransform {
        switch self {
        case .Normal:
            return CGAffineTransformIdentity
        case .FlipX:
            return CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0)
        case .Rotate180:
            return CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: size.width, ty: size.height)
        case .FlipY:
            return CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        case .Transpose:
            return CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
        case .Rotate90:
            return CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: size.width)
        case .Transverse:
            return CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: size.height, ty: size.width)
        case .Rotate270:
            return CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: size.height, ty: 0)
        }
    }
}
