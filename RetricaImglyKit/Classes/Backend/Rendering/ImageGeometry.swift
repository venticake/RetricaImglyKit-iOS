//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

/**
 *  Handles the geometry of an image and provides helpers to easily rotate or flip an image.
 */
@available(iOS 8, *)
@objc(IMGLYImageGeometry) public class ImageGeometry: NSObject, NSCopying {

    // MARK: - Properties

    /// The rectangle of the input image.
    public let inputRect: CGRect

    /// The currently applied orientation.
    public var appliedOrientation: IMGLYOrientation

    // MARK: - Initializers

    /**
    :nodoc:
    */
    public convenience override init() {
        self.init(inputSize: CGSize.zero)
    }

    /**
     Returns a newly allocated instance of an `ImageGeometry` using the given input size.

     - parameter inputSize: The input size of the image.

     - returns: An instance of an `ImageGeometry`.
     */
    public init(inputSize: CGSize) {
        inputRect = CGRect(origin: CGPoint.zero, size: inputSize)
        appliedOrientation = .Normal
        super.init()
    }

    /**
     Returns a newly allocated instance of an `ImageGeometry` using the given input size and the given
     initial orientation.

     - parameter inputSize:          The input size of the image.
     - parameter initialOrientation: The initial orientation to use.

     - returns: An instance of an `ImageGeometry`.
     */
    public convenience init(inputSize: CGSize, initialOrientation: IMGLYOrientation) {
        self.init(inputSize: inputSize)
        applyOrientation(initialOrientation)
    }

    // MARK: - Orientation Handling

    /**
    Creates a `CGAffineTransform` from a given `IMGLYOrientation`.

    - parameter orientation: The `IMGLYOrientation` to get the transform for.

    - returns: A `CGAffineTransform`, that when applied to a view rotates it to the same orientation as the passed orientation.
    */
    public func transformFromOrientation(orientation: IMGLYOrientation) -> CGAffineTransform {
        return transformFromOrientation(orientation, toOrientation: appliedOrientation)
    }

    /**
     Creates a `CGAffineTransform` to get from one `IMGLYOrientation` to another `IMGLYOrientation`.

     - parameter fromOrientation: The orientation to start from.
     - parameter toOrientation:   The orientation to go to.

     - returns: A `CGAffineTransform`, that represents rotating from one orientation to another.
     */
    private func transformFromOrientation(fromOrientation: IMGLYOrientation, toOrientation: IMGLYOrientation) -> CGAffineTransform {
        let orientation = IMGLYOrientation(betweenOrientation: fromOrientation, andOrientation: toOrientation).inverseOrientation
        return orientation.transformWithSize(inputRect.size)
    }

    /**
     Apply a vertical flip to the image's geometry.
    */
    public func flipVertically() {
        applyOrientation(.FlipY)
    }

    /**
     Apply a horizontal flip to the image's geometry.
     */
    public func flipHorizontally() {
        applyOrientation(.FlipX)
    }

    /**
     Rotate the image's geometry clockwise by 90 degrees.
     */
    public func rotateClockwise() {
        applyOrientation(.Rotate90)
    }

    /**
     Rotate the image's geometry counter clockwise by 90 degrees.
     */
    public func rotateCounterClockwise() {
        applyOrientation(.Rotate270)
    }

    /**
     Directly applies a given orientation to the image's geometry.

     - parameter orientation: The orientation to apply.
     */
    public func applyOrientation(orientation: IMGLYOrientation) {
        appliedOrientation = IMGLYOrientation(concatOrientation: appliedOrientation, withOrientation: orientation)
    }

    // MARK: - NSObject

    /// :nodoc:
    public override var description: String {
        return "Input size: {\(inputRect.size.width), \(inputRect.size.height)}, applied orientation: \(appliedOrientation)"
    }

    // MARK: - NSCopying

    /**
    :nodoc:
    */
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let geometry = ImageGeometry(inputSize: inputRect.size)
        geometry.appliedOrientation = appliedOrientation
        return geometry
    }
}
