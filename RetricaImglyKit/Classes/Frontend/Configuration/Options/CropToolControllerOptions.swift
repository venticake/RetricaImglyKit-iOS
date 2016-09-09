//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/**
 Options for configuring a `CropToolController`.
 */
@available(iOS 8, *)
@objc(IMGLYCropToolControllerOptions) public class CropToolControllerOptions: ToolControllerOptions {
    /// Defines all allowed crop ratios. The crop ratio buttons are shown in the given order.
    /// Defaults to `Free`, `1:1`, `4:3` and `16:9`. Setting this to an empty array is ignored.
    public let allowedCropRatios: [CropRatio]

    /// This closure allows further configuration of the crop ratio buttons. The closure is called for
    /// each crop ratio button and has the button and its corresponding crop ratio as parameters.
    public let cropRatioButtonConfigurationClosure: ((IconCaptionCollectionViewCell, CropRatio) -> ())?

    /// This closure is called every time the user selects a crop ratio.
    public let cropRatioSelectedClosure: ((CropRatio) -> ())?

    /**
     Returns a newly allocated instance of a `CropToolControllerOptions` using the default builder.

     - returns: An instance of a `CropToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: CropToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `CropToolControllerOptions` using the given builder.

     - parameter builder: A `CropToolControllerOptionsBuilder` instance.

     - returns: An instance of a `CropToolControllerOptions`.
     */
    public init(builder: CropToolControllerOptionsBuilder) {
        allowedCropRatios = builder.allowedCropRatios
        cropRatioButtonConfigurationClosure = builder.cropRatioButtonConfigurationClosure
        cropRatioSelectedClosure = builder.cropRatioSelectedClosure
        super.init(editorBuilder: builder)
    }
}

/**
The default `CropToolControllerOptionsBuilder` for `CropToolControllerOptions`.
*/
@available(iOS 8, *)
@objc(IMGLYCropToolControllerOptionsBuilder) public class CropToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// Defines all allowed crop ratios. The crop ratio buttons are shown in the given order.
    /// Defaults to `Free`, `1:1`, `4:3` and `16:9`. Setting this to an empty array is ignored.
    public var allowedCropRatios: [CropRatio] = {
        let bundle = NSBundle.imglyKitBundle
        let freeCropRatio = CropRatio(ratio: nil, title: Localize("Free"), accessibilityLabel: Localize("Free"), icon: UIImage(named: "imgly_icon_option_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate))
        let oneToOneCropRatio = CropRatio(ratio: 1, title: Localize("1:1"), accessibilityLabel: Localize("1 to 1"), icon: UIImage(named: "imgly_icon_option_crop_square", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate))
        let fourToThreeCropRatio = CropRatio(ratio: 4 / 3, title: Localize("4:3"), accessibilityLabel: Localize("4 to 3"), icon: UIImage(named: "imgly_icon_option_crop_4_3", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate))
        let sixteenToNineCropRatio = CropRatio(ratio: 16 / 9, title: Localize("16:9"), accessibilityLabel: Localize("16 to 9"), icon: UIImage(named: "imgly_icon_option_crop_16_9", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate))

        return [freeCropRatio, oneToOneCropRatio, fourToThreeCropRatio, sixteenToNineCropRatio]
        }() {
        didSet {
            if allowedCropRatios.count == 0 {
                allowedCropRatios = oldValue
            }
        }
    }

    /// This closure allows further configuration of the crop ratio buttons. The closure is called for
    /// each crop ratio button and has the button and its corresponding crop ratio as parameters.
    public var cropRatioButtonConfigurationClosure: ((IconCaptionCollectionViewCell, CropRatio) -> ())? = nil

    /// This closure is called every time the user selects a crop ratio.
    public var cropRatioSelectedClosure: ((CropRatio) -> ())? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("CROP")
    }
}
