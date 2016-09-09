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
 Options for configuring a `FramesEditorViewController`.
 */
@available(iOS 8, *)
@objc(IMGLYFrameToolControllerOptions) public class FrameToolControllerOptions: ToolControllerOptions {

    /// An object conforming to the `FramesDataSourceProtocol`
    /// Per default an instance of `FramesDataSource` offering all filters
    /// is set.
    public let framesDataSource: FramesDataSourceProtocol

    /// This closure is called when the user selects a frame. The closure is passed `nil` when no frame
    /// was selected.
    public let selectedFrameClosure: ((Frame?) -> ())?

    /// The tolerance that is used to pick the correct frame image based on the aspect ratio. Defaults
    /// to `0.1`.
    public let tolerance: Float

    /**
     Returns a newly allocated instance of a `FrameToolControllerOptions` using the default builder.

     - returns: An instance of a `MainToolControllerOptions`.
     */
    public convenience init() {
        self.init(builder: FrameToolControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `FrameToolControllerOptions` using the given builder.

     - parameter builder: A `FrameToolControllerOptionsBuilder` instance.

     - returns: An instance of a `FrameToolControllerOptions`.
     */
    public init(builder: FrameToolControllerOptionsBuilder) {
        framesDataSource = builder.framesDataSource
        selectedFrameClosure = builder.selectedFrameClosure
        tolerance = builder.tolerance
        super.init(editorBuilder: builder)
    }
}

/**
 The default `FrameToolControllerOptionsBuilder` for `FrameToolControllerOptions`.
 */
@available(iOS 8, *)
@objc(IMGLYFrameToolControllerOptionsBuilder) public class FrameToolControllerOptionsBuilder: ToolControllerOptionsBuilder {

    /// An object conforming to the `FramesDataSourceProtocol`
    /// Per default an instance of `FramesDataSource` offering all filters
    /// is set.
    public var framesDataSource: FramesDataSourceProtocol = FramesDataSource()

    /// This closure is called when the user selects a frame. The closure is passed `nil` when no frame
    /// was selected.
    public var selectedFrameClosure: ((Frame?) -> ())?

    /// The tolerance that is used to pick the correct frame image based on the aspect ratio. Defaults
    /// to `0.1`.
    public var tolerance: Float = 0.1

    /**
     :nodoc:
     */
    public override init() {
        super.init()
        /// Override inherited properties with default values
        self.title = Localize("FRAME")
    }
}
