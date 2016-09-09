//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import CoreImage

/**
 *  Applies a radial focus to an instance of `CIImage`.
 */
@objc(IMGLYRadialFocusFilter) public class RadialFocusFilter: CIFilter {

    // MARK: - Properties

    /// The input image.
    public var inputImage: CIImage?

    /// The first normalized control point of the focus. This control point should use the coordinate system of Core Image, which means that (0,0) is at the top left.
    public var inputNormalizedControlPoint1: NSValue?

    /// The second normalized control point of the focus. This control point should use the coordinate system of Core Image, which means that (0,0) is at the top left.
    public var inputNormalizedControlPoint2: NSValue?

    /// The blur radius to use for focus. Default is 4.
    public var inputRadius: NSNumber?

    // MARK: - CIFilter

    /**
     :nodoc:
     */
    public override func setDefaults() {
        inputNormalizedControlPoint1 = NSValue(CGPoint: CGPoint.zero)
        inputNormalizedControlPoint2 = NSValue(CGPoint: CGPoint.zero)
        inputRadius = 4
    }

    /// :nodoc:
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage, inputNormalizedControlPoint1 = inputNormalizedControlPoint1, inputNormalizedControlPoint2 = inputNormalizedControlPoint2, inputRadius = inputRadius else {
            return nil
        }

        if inputRadius.floatValue < 0.16 {
            return inputImage
        }

        guard let blurFilter = CIFilter(name: "CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputRadius, kCIInputImageKey: inputImage]) else {
            return inputImage
        }

        guard let blurredImage = blurFilter.outputImage?.imageByCroppingToRect(inputImage.extent) else {
            return inputImage
        }

        let opaqueColor = CIColor(red: 0, green: 1, blue: 0, alpha: 1)
        let transparentColor = CIColor(red: 0, green: 1, blue: 0, alpha: 0)

        let denormalizedControlPoint1 = CGPoint(x: inputNormalizedControlPoint1.CGPointValue().x * inputImage.extent.width, y: inputNormalizedControlPoint1.CGPointValue().y * inputImage.extent.height)
        let denormalizedControlPoint2 = CGPoint(x: inputNormalizedControlPoint2.CGPointValue().x * inputImage.extent.width, y: inputNormalizedControlPoint2.CGPointValue().y * inputImage.extent.height)

        let vector = CGVector(startPoint: denormalizedControlPoint1, endPoint: denormalizedControlPoint2)

        let radius = vector.length / 2
        let fadeWidth = radius * 0.4
        let center = denormalizedControlPoint1 + 0.5 * vector

        guard let maskImage = CIFilter(name: "CIRadialGradient", withInputParameters: ["inputRadius0": radius, "inputRadius1": radius + fadeWidth, "inputCenter": CIVector(CGPoint: center), "inputColor0": transparentColor, "inputColor1": opaqueColor])?.outputImage else {
            return inputImage
        }

        guard let blendFilter = CIFilter(name: "CIBlendWithMask", withInputParameters: [kCIInputImageKey: blurredImage, kCIInputMaskImageKey: maskImage, kCIInputBackgroundImageKey: inputImage]) else {
            return inputImage
        }

        return blendFilter.outputImage
    }
}
