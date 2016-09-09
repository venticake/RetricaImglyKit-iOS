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
 Options for configuring a `TextColorToolController`.
 */
@objc(IMGLYTextColorToolControllerOptions) public class TextColorToolControllerOptions: ToolControllerOptions {

    /// A list of colors that is available in the text color dialog. This property is optional.
    public let availableFontColors: [UIColor]?

    /// A list of color-names that is available in the text color dialog. This property is optional.
    public let availableFontColorNames: [String]?

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding color and color name as parameters.
    public let textColorActionButtonConfigurationClosure: ((ColorCollectionViewCell, UIColor, String) -> ())?

    /// This closure is called every time the user selects an action
    public let textColorActionSelectedClosure: ((UIColor, String) -> ())?

    /**
     Returns a newly allocated instance of `TextColorToolControllerOptions` using the default builder.

     - returns: An instance of `TextColorToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: TextColorToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `TextColorToolControllerOptions` using the given builder.

     - parameter builder: A `TextColorToolControllerOptionsBuilder` instance.

     - returns: An instance of `TextColorToolControllerOptions`.
     */
    public init(builder: TextColorToolControllerOptionsBuilder) {
        availableFontColors = builder.availableFontColors
        availableFontColorNames = builder.availableFontColorNames
        textColorActionButtonConfigurationClosure = builder.textColorActionButtonConfigurationClosure
        textColorActionSelectedClosure = builder.textColorActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `TextColorToolControllerOptionsBuilder` for `TextColorToolControllerOptions`.
 */
@objc(IMGLYTextColorToolControllerOptionsBuilder) public class TextColorToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// A list of colors that is available in the text color dialog. This property is optional.
    public var availableFontColors: [UIColor]? = nil

    /// A list of color-names that is available in the text color dialog. This property is optional.
    public var availableFontColorNames: [String]? = nil

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding color and color name as parameters.
    public var textColorActionButtonConfigurationClosure: ((ColorCollectionViewCell, UIColor, String) -> ())? = nil

    /// This closure is called every time the user selects an action
    public var textColorActionSelectedClosure: ((UIColor, String) -> ())? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("TEXT COLOR")
    }
}
