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
 The actions that can be used in an instance of `StickerToolControllerOptions`.

 - Delete:           Delete the sticker.
 - BringToFront:     Bring the sticker to the front.
 - FlipHorizontally: Flip the sticker horizontally.
 - FlipVertically:   Flip the sticker vertically.
 - Separator:        Represents a visual separator between the actions.
 */
@objc public enum StickerContextAction: Int {
    /// Delete the sticker.
    case Delete
    /// Bring the sticker to the front.
    case BringToFront
    /// Flip the sticker horizontally.
    case FlipHorizontally
    /// Flip the sticker vertically.
    case FlipVertically
    /// Represents a visual separator between the actions.
    case Separator
}


/**
 Options for configuring a `StickerToolController`.
 */
@available(iOS 8, *)
@objc(IMGLYStickerToolControllerOptions) public class StickerToolControllerOptions: ToolControllerOptions {
    /// An object conforming to `StickersDataSourceProtocol`. By default an instance of
    /// `StickersDataSource` offering all filters is used.
    public let stickersDataSource: StickersDataSourceProtocol

    /// This closure is called when the user adds a sticker.
    public let addedStickerClosure: ((Sticker) -> ())?

    /// This closure allows further configuration of the sticker buttons. The closure is called for
    /// each sticker button and has the button and its corresponding sticker as parameters.
    public let stickerButtonConfigurationClosure: ((IconCollectionViewCell) -> ())?

    /// This closure allows further configuration of the context actions. The closure is called for
    /// each action and has the action and its corresponding enum value as parameters.
    public let contextActionConfigurationClosure: ((ContextMenuAction, StickerContextAction) -> ())?

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions. Use `.Separator` to show a visual separator between actions.
    /// To set this property from Obj-C, see the `allowedStickerActionsAsNSNumbers` property.
    public let allowedStickerContextActions: [StickerContextAction]

    /// This closure is called when the user selects an action.
    public let stickerActionSelectedClosure: ((StickerContextAction) -> ())?

    /// This closure is called when the user removes a sticker.
    public let removedStickerClosure: ((Sticker) -> ())?

    /**
     Returns a newly allocated instance of a `StickersToolControllerOptions` using the default builder.

     - returns: An instance of a `MainToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: StickerToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `StickersToolControllerOptions` using the given builder.

     - parameter builder: A `StickersToolControllerOptionsBuilder` instance.

     - returns: An instance of a `StickersToolControllerOptions`.
     */
    public init(builder: StickerToolControllerOptionsBuilder) {
        stickersDataSource = builder.stickersDataSource
        addedStickerClosure = builder.addedStickerClosure
        stickerButtonConfigurationClosure = builder.stickerButtonConfigurationClosure
        contextActionConfigurationClosure = builder.contextActionConfigurationClosure
        allowedStickerContextActions = builder.allowedStickerContextActions
        stickerActionSelectedClosure = builder.stickerActionSelectedClosure
        removedStickerClosure = builder.removedStickerClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `StickerToolControllerOptionsBuilder` for `StickerToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYStickerToolControllerOptionsBuilder) public class StickerToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// An object conforming to `StickersDataSourceProtocol`. By default an instance of
    /// `StickersDataSource` offering all filters is used.
    public var stickersDataSource: StickersDataSourceProtocol = StickersDataSource()

    /// This closure is called when the user adds a sticker.
    public var addedStickerClosure: ((Sticker) -> ())?

    /// This closure allows further configuration of the sticker buttons. The closure is called for
    /// each sticker button and has the button and its corresponding sticker as parameters.
    public var stickerButtonConfigurationClosure: ((IconCollectionViewCell) -> ())?

    /// This closure allows further configuration of the context actions. The closure is called for
    /// each action and has the action and its corresponding enum value as parameters.
    public var contextActionConfigurationClosure: ((ContextMenuAction, StickerContextAction) -> ())? = nil

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions. Use `.Separator` to show a visual separator between actions.
    /// To set this property from Obj-C, see the `allowedStickerActionsAsNSNumbers` property.
    public var allowedStickerContextActions: [StickerContextAction] = [.FlipHorizontally, .FlipVertically, .BringToFront, .Separator, .Delete]

    /// This closure is called when the user selects an action.
    public var stickerActionSelectedClosure: ((StickerContextAction) -> ())?

    /// This closure is called when the user removes a sticker.
    public var removedStickerClosure: ((Sticker) -> ())?

    /// An array of `action` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedStickerContextActions` with the corresponding `StickerContextAction` values.
    public var allowedStickerContextActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedStickerContextActions.map { NSNumber(integer: $0.rawValue) }
        }
        set {
            allowedStickerContextActions = newValue.flatMap { StickerContextAction(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("STICKER")
    }
}
