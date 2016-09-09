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
 Options for configuring a `FocusToolController`.
 */
@objc(IMGLYFocusToolControllerOptions) public class FocusToolControllerOptions: ToolControllerOptions {
    /// Defines all allowed focus types. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off type is always added. To set this
    /// property from Obj-C, see the `allowedFocusTypesAsNSNumbers` property.
    public let allowedFocusTypes: [IMGLYFocusType]

    /// This closure allows further configuration of the focus type buttons. The closure is called for
    /// each focus type button and has the button and its corresponding focus type as parameters.
    public let focusTypeButtonConfigurationClosure: ((IconCaptionCollectionViewCell, IMGLYFocusType) -> ())?

    /// This closure is called when the user selects a focus type.
    public let focusTypeSelectedClosure: ((IMGLYFocusType) -> ())?

    /// This closure can be used to configure the slider.
    public let sliderConfigurationClosure: SliderConfigurationClosure?

    /// This closure can be used to configure the view that contains the slider.
    public let sliderContainerConfigurationClosure: ViewConfigurationClosure?

    /// This closure is called whenever the slider changes its value. The instance of `Slider` and
    /// the active focus type are passed as parameters.
    public let sliderChangedValueClosure: ((Slider, IMGLYFocusType) -> ())?

    /// This closure can be used to configure the circle gradient view.
    public let circleGradientViewConfigurationClosure: ((CircleGradientView) -> ())?

    /// This closure can be used to configure the box gradient view.
    public let boxGradientViewConfigurationClosure: ((BoxGradientView) -> ())?

    /**
     Returns a newly allocated instance of a `FocusToolControllerOptions` using the default builder.

     - returns: An instance of a `FocusToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: FocusToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `FocusToolControllerOptions` using the given builder.

     - parameter builder: A `FocusToolControllerOptionsBuilder` instance.

     - returns: An instance of a `FocusToolControllerOptions`.
     */
    public init(builder: FocusToolControllerOptionsBuilder) {
        allowedFocusTypes = builder.allowedFocusTypes
        focusTypeButtonConfigurationClosure = builder.focusTypeButtonConfigurationClosure
        focusTypeSelectedClosure = builder.focusTypeSelectedClosure
        sliderConfigurationClosure = builder.sliderConfigurationClosure
        sliderContainerConfigurationClosure = builder.sliderContainerConfigurationClosure
        sliderChangedValueClosure = builder.sliderChangedValueClosure
        circleGradientViewConfigurationClosure = builder.circleGradientViewConfigurationClosure
        boxGradientViewConfigurationClosure = builder.boxGradientViewConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `FocusToolControllerOptionsBuilder` for `FocusToolControllerOptions`.
 */
@objc(IMGLYFocusToolControllerOptionsBuilder) public class FocusToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// Defines all allowed focus types. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off type is always added. To set this
    /// property from Obj-C, see the `allowedFocusTypesAsNSNumbers` property.
    public var allowedFocusTypes: [IMGLYFocusType] = [ .Off, .Linear, .Radial ] {
        didSet {
            if !allowedFocusTypes.contains(.Off) {
                allowedFocusTypes.append(.Off)
            }
        }
    }

    /// This closure allows further configuration of the focus type buttons. The closure is called for
    /// each focus type button and has the button and its corresponding focus type as parameters.
    public var focusTypeButtonConfigurationClosure: ((IconCaptionCollectionViewCell, IMGLYFocusType) -> ())?

    /// This closure is called when the user selects a focus type.
    public var focusTypeSelectedClosure: ((IMGLYFocusType) -> ())?

    /// This closure can be used to configure the slider.
    public var sliderConfigurationClosure: SliderConfigurationClosure?

    /// This closure can be used to configure the view that contains the slider.
    public var sliderContainerConfigurationClosure: ViewConfigurationClosure?

    /// This closure is called whenever the slider changes its value. The instance of `Slider` and
    /// the active focus type are passed as parameters.
    public var sliderChangedValueClosure: ((Slider, IMGLYFocusType) -> ())?

    /// This closure can be used to configure the circle gradient view.
    public var circleGradientViewConfigurationClosure: ((CircleGradientView) -> ())?

    /// This closure can be used to configure the box gradient view.
    public var boxGradientViewConfigurationClosure: ((BoxGradientView) -> ())?

    /// An array of `IMGLYFocusType` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedFocusTypes` with the corresponding `IMGLYFocusType` values.
    public var allowedFocusTypesAsNSNumbers: [NSNumber] {
        get {
            return allowedFocusTypes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedFocusTypes = newValue.flatMap { IMGLYFocusType(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("FOCUS")
    }
}
