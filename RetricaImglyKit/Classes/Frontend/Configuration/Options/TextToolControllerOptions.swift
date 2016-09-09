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
 Options for configuring a `TextToolController`.
 */
@objc(IMGLYTextToolControllerOptions) public class TextToolControllerOptions: ToolControllerOptions {

    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public let textFieldConfigurationClosure: ((UITextField) -> ())?

    /**
     Returns a newly allocated instance of a `MainToolControllerOptions` using the default builder.

     - returns: An instance of a `MainToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: TextToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `TextToolControllerOptions` using the given builder.

     - parameter builder: A `TextToolControllerOptionsBuilder` instance.

     - returns: An instance of a `TextToolControllerOptions`.
     */
    public init(builder: TextToolControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `TextToolControllerOptionsBuilder` for `TextToolControllerOptions`.
 */
@objc(IMGLYTextToolControllerOptionsBuilder) public class TextToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// Use this closure to configure the text input field.
    public var textFieldConfigurationClosure: ((UITextField) -> ())? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("ADD TEXT")
    }
}
