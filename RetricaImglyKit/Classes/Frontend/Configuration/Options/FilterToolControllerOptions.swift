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
 Options for configuring a `FilterToolController`.
 */
@objc(IMGLYFilterToolControllerOptions) public class FilterToolControllerOptions: ToolControllerOptions {

    /// This closure can be used to configure the filter intensity slider.
    public let filterIntensitySliderConfigurationClosure: SliderConfigurationClosure?

    /// This closure can be used to configure the filter intensity slider's container view.
    public let filterIntensitySliderContainerConfigurationClosure: ViewConfigurationClosure?

    /// Enable/Disable the filter intensity slider. Defaults to true.
    public let showFilterIntensitySlider: Bool

    /// The intensity that should be initialy applied to a filter when selecting it. Defaults to 75 %.
    public let initialFilterIntensity: CGFloat

    /// This closure is called every time the user selects a filter.
    public let filterSelectedClosure: ((PhotoEffect) -> ())?

    /// This closure will be called whenever the value of the slider changes. The `Slider` and the
    /// selected instance of `PhotoEffect` will be passed as parameters.
    public let filterIntensityChangedClosure: ((Slider, PhotoEffect) -> ())?

    /// This closure allows further configuration of the filter cells. The closure is called for
    /// each filter cell and has the cell and its corresponding instance of `PhotoEffect` as parameters.
    public let filterCellConfigurationClosure: ((FilterCollectionViewCell, PhotoEffect) -> ())?

    /**
     Returns a newly allocated instance of a `FilterToolControllerOptions` using the default builder.

     - returns: An instance of a `FilterToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: FilterToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `FilterToolControllerOptions` using the given builder.

     - parameter builder: A `FilterToolControllerOptionsBuilder` instance.

     - returns: An instance of a `FilterToolControllerOptions`.
     */
    public init(builder: FilterToolControllerOptionsBuilder) {
        filterIntensitySliderConfigurationClosure = builder.filterIntensitySliderConfigurationClosure
        filterIntensitySliderContainerConfigurationClosure = builder.filterIntensitySliderContainerConfigurationClosure
        showFilterIntensitySlider = builder.showFilterIntensitySlider
        initialFilterIntensity = builder.initialFilterIntensity
        filterSelectedClosure = builder.filterSelectedClosure
        filterIntensityChangedClosure = builder.filterIntensityChangedClosure
        filterCellConfigurationClosure = builder.filterCellConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `FilterToolControllerOptionsBuilder` for `FilterToolControllerOptions`.
 */
@objc(IMGLYFilterToolControllerOptionsBuilder) public class FilterToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// This closure can be used to configure the filter intensity slider.
    public var filterIntensitySliderConfigurationClosure: SliderConfigurationClosure?

    /// This closure can be used to configure the filter intensity slider's container view.
    public var filterIntensitySliderContainerConfigurationClosure: ViewConfigurationClosure?

    /// Enable/Disable the filter intensity slider. Defaults to true.
    public var showFilterIntensitySlider: Bool = true

    /// The intensity that should be initialy applied to a filter when selecting it. Defaults to 75 %.
    public var initialFilterIntensity: CGFloat = 0.75

    /// This closure is called every time the user selects a filter.
    public var filterSelectedClosure: ((PhotoEffect) -> ())?

    /// This closure will be called whenever the value of the slider changes. The `Slider` and the
    /// selected instance of `PhotoEffect` will be passed as parameters.
    public var filterIntensityChangedClosure: ((Slider, PhotoEffect) -> ())?

    /// This closure allows further configuration of the filter cells. The closure is called for
    /// each filter cell and has the cell and its corresponding instance of `PhotoEffect` as parameters.
    public var filterCellConfigurationClosure: ((FilterCollectionViewCell, PhotoEffect) -> ())?

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("FILTER")
    }
}
