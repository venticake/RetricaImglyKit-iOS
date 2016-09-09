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
 Options for configuring a `PhotoEditToolController`.
 */
@available(iOS 8, *)
@objc(IMGLYToolControllerOptions) public class ToolControllerOptions: NSObject {

    /// The title of the tool. By default this will be displayed in the secondary toolbar.
    public let title: String?

    /// The tool's background color. Defaults to the configuration's global background color.
    public let backgroundColor: UIColor?

    /// A configuration closure to configure the apply button displayed at the bottom right.
    /// Defaults to a checkmark icon.
    public let applyButtonConfigurationClosure: ButtonConfigurationClosure?

    /// A configuration closure to configure the discard button displayed at the bottom left.
    /// Defaults to a cross icon.
    public let discardButtonConfigurationClosure: ButtonConfigurationClosure?

    /// This closure will be called when a tool has been entered.
    public let didEnterToolClosure: DidEnterToolClosure?

    /// The closure will be called when a tool is about to be left.
    public let willLeaveToolClosure: WillLeaveToolClosure?

    /**
     Returns a newly allocated instance of a `ToolControllerOptions` using the default builder.

     - returns: An instance of a `ToolControllerOptions`.
     */
    public convenience override init() {
        self.init(editorBuilder: ToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `ToolControllerOptions` using the given builder.

     - parameter builder: A `ToolControllerOptionsBuilder` instance.

     - returns: An instance of a `ToolControllerOptions`.
     */
    public init(editorBuilder: ToolControllerOptionsBuilder) {
        title = editorBuilder.title
        backgroundColor = editorBuilder.backgroundColor
        didEnterToolClosure = editorBuilder.didEnterToolClosure
        willLeaveToolClosure = editorBuilder.willLeaveToolClosure
        applyButtonConfigurationClosure = editorBuilder.applyButtonConfigurationClosure
        discardButtonConfigurationClosure = editorBuilder.discardButtonConfigurationClosure
        super.init()
    }
}

/**
 The default `ToolControllerOptionsBuilder` for `ToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYToolControllerOptionsBuilder) public class ToolControllerOptionsBuilder: NSObject {
    /// The title of the tool. By default this will be displayed in the secondary toolbar.
    public var title: String? = nil

    /// The tools background color. If this property is `nil`, the `backgroundColor` property of the
    /// `Configuration` will be used instead.
    public var backgroundColor: UIColor?

    /// This closure will be called when a tool has been entered.
    public var didEnterToolClosure: DidEnterToolClosure? = nil

    /// The closure will be called when a tool is about to be left.
    public var willLeaveToolClosure: WillLeaveToolClosure? = nil

    /**
     A configuration closure to configure the apply button displayed at the bottom right.
     Defaults to a checkmark icon.
     */
    public var applyButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /**
     A configuration closure to configure the discard button displayed at the bottom left.
     Defaults to a cross icon.
     */
    public var discardButtonConfigurationClosure: ButtonConfigurationClosure? = nil
}
