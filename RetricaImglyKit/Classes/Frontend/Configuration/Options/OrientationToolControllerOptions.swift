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
 The actions that can be used in an instance of `OrientationToolController`.

 - RotateLeft:       Rotate the image to the left.
 - RotateRight:      Rotate the image to the right.
 - FlipHorizontally: Flip the image horizontally.
 - FlipVertically:   Flip the image vertically.
 - Separator:        Represents a visual separator between the actions.
 */
@objc public enum OrientationAction: Int {
    /// Rotate the image to the left.
    case RotateLeft
    /// Rotate the image to the right.
    case RotateRight
    /// Flip the image horizontally.
    case FlipHorizontally
    /// Flip the image vertically.
    case FlipVertically
    /// Represents a visual separator between the actions.
    case Separator
}

/**
 Options for configuring a `OrientationEditorViewController`.
 */
@objc(IMGLYOrientationToolControllerOptions) public class OrientationToolControllerOptions: ToolControllerOptions {

    /// Defines all allowed actions. The action buttons are shown in the given order.
    /// Defaults to show all available actions. Use `.Separator` to add a visual separator between cells.
    public let allowedOrientationActions: [OrientationAction]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let orientationActionButtonConfigurationClosure: ((IconCaptionCollectionViewCell, OrientationAction) -> ())?

    /// This closure is called every time the user selects an action
    public let orientationActionSelectedClosure: ((OrientationAction) -> ())?

    /**
     Returns a newly allocated instance of a `OrientationToolControllerOptions` using the default builder.

     - returns: An instance of a `OrientationToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: OrientationToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `OrientationToolControllerOptions` using the given builder.

     - parameter builder: A `OrientationToolControllerOptionsBuilder` instance.

     - returns: An instance of a `OrientationToolControllerOptions`.
     */
    public init(builder: OrientationToolControllerOptionsBuilder) {
        allowedOrientationActions = builder.allowedOrientationActions
        orientationActionButtonConfigurationClosure = builder.orientationActionButtonConfigurationClosure
        orientationActionSelectedClosure = builder.orientationActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

/**
 The default `OrientationToolControllerOptionsBuilder` for `OrientationToolControllerOptions`.
 */
@objc(IMGLYOrientationToolControllerOptionsBuilder) public class OrientationToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// Defines all allowed actions. The action buttons are shown in the given order.
    /// Defaults to show all available actions. Use `.Separator` to add a visual separator between
    /// cells. To set this property from Obj-C, see the `allowedOrientationActionsAsNSNumbers` property.
    public var allowedOrientationActions: [OrientationAction] = [ .RotateLeft, .RotateRight, .Separator, .FlipHorizontally, .FlipVertically ]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var orientationActionButtonConfigurationClosure: ((IconCaptionCollectionViewCell, OrientationAction) -> ())? = nil


    /// An array of `OrientationAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedOrientationActions` with the corresponding `OrientationAction` values.
    public var allowedOrientationActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedOrientationActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedOrientationActions = newValue.flatMap { OrientationAction(rawValue: $0.integerValue) }
        }
    }

    /// This closure is called every time the user selects an action
    public var orientationActionSelectedClosure: ((OrientationAction) -> ())? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("ORIENTATION")
    }
}
