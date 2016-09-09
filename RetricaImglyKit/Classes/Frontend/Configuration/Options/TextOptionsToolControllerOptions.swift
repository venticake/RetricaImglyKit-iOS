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
 The actions that can be used in an instance of `TextOptionsToolController`.

 - SelectFont:            Change the font of the text.
 - SelectColor:           Change the color of the text.
 - SelectBackgroundColor: Change the color of the text's bounding box.
 - Separator:             Represents a visual separator between the actions.
 */
@objc public enum TextAction: Int {
    /// Change the font of the text.
    case SelectFont
    /// Change the color of the text.
    case SelectColor
    /// Change the color of the text's bounding box.
    case SelectBackgroundColor
    /// Represents a visual separator between the actions.
    case Separator
}

/**
 The context actions that can be used in an instance of `TextOptionsToolController`.

 - Delete:                Delete the text.
 - BringToFront:          Bring the text to the front.
 - Separator:             Represents a visual separator between the actions.
 */
@objc public enum TextContextAction: Int {
    /// Delete the text.
    case Delete
    /// Bring the text to the front.
    case BringToFront
    /// Represents a visual separator between the actions.
    case Separator
}

/**
 Options for configuring a `TextOptionsToolController`.
 */
@available(iOS 8, *)
@objc(IMGLTextOptionsToolControllerOptions) public class TextOptionsToolControllerOptions: ToolControllerOptions {

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public let allowedTextActions: [TextAction]

    /// Defines all allowed context menu actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public let allowedTextContextActions: [TextContextAction]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: ((UICollectionViewCell, TextAction) -> ())?

    /// This closure allows further configuration of the context actions. The closure is called for
    /// each action and has the action and its corresponding enum value as parameters.
    public let contextActionConfigurationClosure: ((ContextMenuAction, TextContextAction) -> ())?

    /// This closure is called when the user selects an action.
    public let textActionSelectedClosure: ((TextAction) -> ())?

    /// This closure is called when the user selects a context menu action.
    public let textContextActionSelectedClosure: ((TextContextAction) -> ())?

    /**
     Returns a newly allocated instance of `TextOptionsToolControllerOptions` using the default builder.

     - returns: An instance of `TextOptionsToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: TextOptionsToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `TextOptionsToolControllerOptions` using the given builder.

     - parameter builder: A `TextOptionsToolControllerOptionsBuilder` instance.

     - returns: An instance of `TextOptionsToolControllerOptions`.
     */
    public init(builder: TextOptionsToolControllerOptionsBuilder) {
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        contextActionConfigurationClosure = builder.contextActionConfigurationClosure
        allowedTextActions = builder.allowedTextActions
        textActionSelectedClosure = builder.textActionSelectedClosure
        allowedTextContextActions = builder.allowedTextContextActions
        textContextActionSelectedClosure = builder.textContextActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `TextOptionsToolControllerOptionsBuilder` for `TextOptionsToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYTextOptionsToolControllerOptionsBuilder) public class TextOptionsToolControllerOptionsBuilder: ToolControllerOptionsBuilder {
    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public var allowedTextActions: [TextAction] = [.SelectFont, .SelectColor, .SelectBackgroundColor]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: ((UICollectionViewCell, TextAction) -> ())? = nil

    /// This closure allows further configuration of the context actions. The closure is called for
    /// each action and has the action and its corresponding enum value as parameters.
    public var contextActionConfigurationClosure: ((ContextMenuAction, TextContextAction) -> ())? = nil

    /// This closure is called when the user selects an action.
    public var textActionSelectedClosure: ((TextAction) -> ())? = nil

    /// This closure is called when the user selects a context menu action.
    public var textContextActionSelectedClosure: ((TextContextAction) -> ())?

    /// Defines all allowed context menu actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public var allowedTextContextActions: [TextContextAction] = [.BringToFront, .Separator, .Delete]

    /// An array of `TextAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedTextActions` with the corresponding `TextAction` values.
    public var allowedTextActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedTextActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedTextActions = newValue.flatMap { TextAction(rawValue: $0.integerValue) }
        }
    }

    /// An array of `TextContextAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedTextContextActions` with the corresponding `TextContextAction` values.
    public var allowedTextContextActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedTextContextActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedTextContextActions = newValue.flatMap { TextContextAction(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("TEXT OPTIONS")
    }
}
