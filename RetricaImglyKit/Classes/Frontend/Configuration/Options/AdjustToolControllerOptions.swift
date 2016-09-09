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
 The tools that can be used in an instance of `AdjustToolController`.

 - Brightness: Change the brightness of the image.
 - Contrast:   Change the contrast of the image.
 - Saturation: Change the saturation of the image.
 */
@objc public enum AdjustTool: Int {
    /// Change the brightness of the image.
    case Brightness
    /// Change the contrast of the image.
    case Contrast
    /// Change the saturation of the image.
    case Saturation
    /// Change the shadows of the image.
    case Shadows
    /// Change the highlights of the image.
    case Highlights
    /// Change the exposure of the image.
    case Exposure
    /// Change the clarity of the image.
    case Clarity
}

/**
 Options for configuring an `AdjustToolController`.
 */
@available(iOS 8, *)
@objc(IMGLYAdjustToolControllerOptions) public class AdjustToolControllerOptions: ToolControllerOptions {

    /// Defines all allowed tools. The adjust tool buttons are shown in the given order.
    /// Defaults to show all available tools. To set this property from Obj-C, see the
    /// `allowedAdjustToolsAsNSNumbers` property.
    public let allowedAdjustTools: [AdjustTool]

    /// This closure allows further configuration of the adjust tool buttons. The closure is called for
    /// each adjust tool button and has the button and its corresponding adjust tool as parameters.
    public let adjustToolButtonConfigurationClosure: ((IconCaptionCollectionViewCell, AdjustTool) -> ())?

    /// This closure is called every time the user selects a tool.
    public let adjustToolSelectedClosure: ((AdjustTool) -> ())?

    /// This closure can be used to configure the slider that is visible when selecting an adjust tool.
    public let sliderConfigurationClosure: ((Slider) -> ())?

    /// This closure can be used to configure the view that contains the slider and that is visible when selecting
    /// an adjust tool.
    public let sliderContainerConfigurationClosure: ViewConfigurationClosure?

    /// This closure will be called whenever the value of the slider changes. The `Slider` and the active `AdjustTool`
    /// will be passed as parameters.
    public let sliderChangedValueClosure: ((Slider, AdjustTool) -> ())?

    /**
     Returns a newly allocated instance of `AdjustToolControllerOptions` using the default builder.

     - returns: An instance of `AdjustToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: AdjustToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `AdjustToolControllerOptions` using the given builder.

     - parameter builder: A `AdjustToolControllerOptionsBuilder` instance.

     - returns: An instance of `AdjustToolControllerOptions`.
     */
    public init(builder: AdjustToolControllerOptionsBuilder) {
        allowedAdjustTools = builder.allowedAdjustTools
        adjustToolButtonConfigurationClosure = builder.adjustToolButtonConfigurationClosure
        adjustToolSelectedClosure = builder.adjustToolSelectedClosure
        sliderConfigurationClosure = builder.sliderConfigurationClosure
        sliderContainerConfigurationClosure = builder.sliderContainerConfigurationClosure
        sliderChangedValueClosure = builder.sliderChangedValueClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `AdjustToolControllerOptionsBuilder` for `AdjustToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYAdjustToolControllerOptionsBuilder) public class AdjustToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// Defines all allowed tools. The adjust tool buttons are always shown in the given order.
    /// Defaults to show all available adjust tools. To set this
    /// property from Obj-C, see the `allowedAdjustToolsAsNSNumbers` property.
    public var allowedAdjustTools: [AdjustTool] = [ .Brightness, .Contrast, .Saturation, .Clarity, .Shadows, .Highlights, .Exposure ]

    /// This closure allows further configuration of the adjust tool buttons. The closure is called for
    /// each adjust tool button and has the button and its corresponding adjust tool as parameters.
    public var adjustToolButtonConfigurationClosure: ((IconCaptionCollectionViewCell, AdjustTool) -> ())? = nil

    /// This closure is called every time the user selects a tool.
    public var adjustToolSelectedClosure: ((AdjustTool) -> ())? = nil

    /// This closure can be used to configure the slider that is visible when selecting an adjust tool.
    public var sliderConfigurationClosure: ((Slider) -> ())?

    /// This closure can be used to configure the view that contains the slider and that is visible when selecting
    /// an adjust tool.
    public var sliderContainerConfigurationClosure: ViewConfigurationClosure? = nil

    /// This closure will be called whenever the value of the slider changes. The `Slider` and the active `AdjustTool`
    /// will be passed as parameters.
    public var sliderChangedValueClosure: ((Slider, AdjustTool) -> ())? = nil

    /// An array of `AdjustTool` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedAdjustTools` with the corresponding `AdjustTool` values.
    public var allowedAdjustToolsAsNSNumbers: [NSNumber] {
        get {
            return allowedAdjustTools.map { NSNumber(integer: $0.rawValue) }
        }
        set {
            allowedAdjustTools = newValue.flatMap { AdjustTool(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        title = Localize("ADJUST")
    }
}
