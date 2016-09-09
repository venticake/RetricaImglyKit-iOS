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
 *  Applies clarity to an instance of `CIImage`.
 */
@objc(IMGLYClarityFilter) public class ClarityFilter: CIFilter {

    // MARK: - Properties

    /// The input image.
    public var inputImage: CIImage?

    /// The intensity of this filter.
    public var inputIntensity: NSNumber?

    // MARK: - CIFilter

    /**
     :nodoc:
     */
    public override func setDefaults() {
        inputIntensity = 1
    }

    /// :nodoc:
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage, inputIntensity = inputIntensity else {
            return nil
        }

        // Apply unsharp mask.
        guard let unsharpMaskFilter = CIFilter(name: "CIUnsharpMask", withInputParameters: [kCIInputIntensityKey: 0.8, kCIInputRadiusKey: 2.50, kCIInputImageKey: inputImage]) else {
            return inputImage
        }

        guard let unsharpMaskImage = unsharpMaskFilter.outputImage else {
            return inputImage
        }

        // Apply color controls.
        guard let colorControlsFilter = CIFilter(name: "CIColorControls", withInputParameters: [kCIInputContrastKey: 1.0, kCIInputBrightnessKey: 0, kCIInputSaturationKey: 0.9, kCIInputImageKey: unsharpMaskImage]) else {
            return inputImage
        }

        guard let clarityImage = colorControlsFilter.outputImage else {
            return inputImage
        }

        // Create mask.
        let intensity = CGFloat(inputIntensity)
        let maskColor = CIColor(red: intensity, green: intensity, blue: intensity, alpha: 1)

        guard let maskImageFilter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: [kCIInputColorKey: maskColor]) else {
            return inputImage
        }

        guard let maskImage = maskImageFilter.outputImage?.imageByCroppingToRect(inputImage.extent) else {
            return inputImage
        }

        // Blend between original and clarity image.
        guard let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask", withInputParameters: [kCIInputMaskImageKey: maskImage, kCIInputBackgroundImageKey: inputImage, kCIInputImageKey: clarityImage]) else {
            return inputImage
        }

        return blendWithMaskFilter.outputImage
    }
}
