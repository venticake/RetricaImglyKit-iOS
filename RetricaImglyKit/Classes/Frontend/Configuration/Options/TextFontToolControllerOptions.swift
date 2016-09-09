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
 Options for configuring a `TextFontToolController`.
 */
@available(iOS 8, *)
@objc(IMGLYTextFontToolControllerOptions) public class TextFontToolControllerOptions: ToolControllerOptions {

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: ((LabelCaptionCollectionViewCell, String) -> ())?

    /// This closure is called every time the user selects a crop ratio.
    public let textFontActionSelectedClosure: ((String) -> ())?

    /**
     Returns a newly allocated instance of `TextFontToolControllerOptions` using the default builder.

     - returns: An instance of `TextFontToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: TextFontToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `TextColorToolControllerOptions` using the given builder.

     - parameter builder: A `TextColorToolControllerOptionsBuilder` instance.

     - returns: An instance of `TextColorToolControllerOptions`.
     */
    public init(builder: TextFontToolControllerOptionsBuilder) {
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        textFontActionSelectedClosure = builder.textFontActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `TextFontToolControllerOptionsBuilder` for `TextFontToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYTextFontToolControllerOptionsBuilder) public class TextFontToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: ((LabelCaptionCollectionViewCell, String) -> ())? = nil

    /// This closure is called every time the user selects a crop ratio.
    public var textFontActionSelectedClosure: ((String) -> ())? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("FONT")
    }
}
