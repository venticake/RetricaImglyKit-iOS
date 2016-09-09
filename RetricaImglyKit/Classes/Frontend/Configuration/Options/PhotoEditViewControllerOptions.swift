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
 The actions that can be used in an instance of `PhotoEditViewController`.

 - Crop:        Represents a tool to crop the image.
 - Orientation: Represents a tool to change the orientation of the image.
 - Filter:      Represents a tool to apply a filter to the image.
 - Adjust:      Represents a tool to adjust brightness, contrast and/or saturation of the image.
 - Text:        Represents a tool to add text to the image.
 - Sticker:     Represents a tool to add stickers to the image.
 - Focus:       Represents a tool to add a focus to the image.
 - Frame:       Represents a tool to add a frame to the image.
 - Magic:       Represents a tool to auto-enhance the image.
 - Separator:   Represents a visual separator between the actions.
 */
@objc public enum PhotoEditorAction: Int {
    /// Represents a tool to crop the image.
    case Crop
    /// Represents a tool to change the orientation of the image.
    case Orientation
    /// Represents a tool to apply a filter to the image.
    case Filter
    /// Represents a tool to apply a filter to the image.
    case RetricaFilter
    /// Represents a tool to adjust brightness, contrast and/or saturation of the image.
    case Adjust
    /// Represents a tool to add text to the image.
    case Text
    /// Represents a tool to add stickers to the image.
    case Sticker
    /// Represents a tool to add a focus to the image.
    case Focus
    /// Represents a tool to add a frame to the image.
    case Frame
    /// Represents a tool to auto-enhance the image.
    case Magic
    /// Represents a visual separator between the actions.
    case Separator
}

/**
 Options for configuring a `PhotoEditViewController`.
 */
@objc(IMGLYPhotoEditViewControllerOptions) public class PhotoEditViewControllerOptions: NSObject {

    /// The title of the main view. By default this will be displayed in the secondary toolbar.
    public let title: String?

    /// The main view's background color. Defaults to the configuration's global background color.
    public let backgroundColor: UIColor?

    /// A configuration closure to configure the apply button displayed at the bottom right.
    /// Defaults to a checkmark icon.
    public let applyButtonConfigurationClosure: ButtonConfigurationClosure?

    /// A configuration closure to configure the discard button displayed at the bottom left.
    /// Defaults to a cross icon.
    public let discardButtonConfigurationClosure: ButtonConfigurationClosure?

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: ((IconCaptionCollectionViewCell, PhotoEditorAction) -> ())?

    /// This closure is called every time the user selects an action.
    public let photoEditorActionSelectedClosure: ((PhotoEditorAction) -> ())?

    /// Defines all allowed actions. The action buttons are shown in the given order.
    /// Defaults to show all available actions. Use `.Separator` to show a visual separator between items.
    public let allowedPhotoEditorActions: [PhotoEditorAction]

    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public let allowsPreviewImageZoom: Bool

    /// Sets the frame scaling behaviour. Defaults to **.ScaleAspectFit**.
    public let frameScaleMode: UIViewContentMode

    /**
     Returns a newly allocated instance of a `PhotoEditViewControllerOptions` using the default builder.

     - returns: An instance of a `PhotoEditViewControllerOptions`.
     */
    public convenience override init() {
        self.init(builder: PhotoEditViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `PhotoEditViewControllerOptions` using the given builder.

     - parameter builder: A `PhotoEditViewControllerOptionsBuilder` instance.

     - returns: An instance of a `PhotoEditViewControllerOptions`.
     */
    public init(builder: PhotoEditViewControllerOptionsBuilder) {
        title = builder.title
        backgroundColor = builder.backgroundColor
        applyButtonConfigurationClosure = builder.applyButtonConfigurationClosure
        discardButtonConfigurationClosure = builder.discardButtonConfigurationClosure
        allowsPreviewImageZoom = builder.allowsPreviewImageZoom
        allowedPhotoEditorActions = builder.allowedPhotoEditorActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        photoEditorActionSelectedClosure = builder.photoEditorActionSelectedClosure
        frameScaleMode = builder.frameScaleMode
        super.init()
    }
}
/**
 The default `PhotoEditViewControllerOptionsBuilder` for `PhotoEditViewControllerOptions`.
 */
@objc(IMGLYPhotoEditViewControllerOptionsBuilder) public class PhotoEditViewControllerOptionsBuilder: NSObject {

    /// The title of the main view. By default this will be displayed in the secondary toolbar.
    public var title: String? = Localize("EDITOR")

    /// The main view's background color. Defaults to the configuration's global background color.
    public var backgroundColor: UIColor?

    /// A configuration closure to configure the apply button displayed at the bottom right.
    /// Defaults to a checkmark icon.
    public var applyButtonConfigurationClosure: ButtonConfigurationClosure?

    /// A configuration closure to configure the discard button displayed at the bottom left.
    /// Defaults to a cross icon.
    public var discardButtonConfigurationClosure: ButtonConfigurationClosure?

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: ((IconCaptionCollectionViewCell, PhotoEditorAction) -> ())? = nil

    /// This closure is called every time the user selects an action.
    public var photoEditorActionSelectedClosure: ((PhotoEditorAction) -> ())? = nil

    /// Defines all allowed actions. The action buttons are shown in the given order.
    /// Defaults to show all available actions. Use `.Separator` to show a visual separator between items.
    public var allowedPhotoEditorActions: [PhotoEditorAction] = [ .Crop, .Orientation, .Separator, .Filter, .Adjust, .Separator, .Text, .Sticker, .Separator, .Focus, .Magic ]

    /// Sets the frame scaling behaviour.
    public var frameScaleMode: UIViewContentMode = .ScaleAspectFit

    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public var allowsPreviewImageZoom: Bool = true

    /// An array of `PhotoEditorAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedPhotoEditorActions` with the corresponding `PhotoEditorAction` values.
    public var allowedPhotoEditorActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedPhotoEditorActions.map { NSNumber(integer: $0.rawValue) }
        }
        set {
            allowedPhotoEditorActions = newValue.flatMap { PhotoEditorAction(rawValue: $0.integerValue) }
        }
    }
}
