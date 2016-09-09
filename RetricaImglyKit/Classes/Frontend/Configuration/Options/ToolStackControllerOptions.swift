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
 Options for configuring a `ToolStackController`.
 */
@objc(IMGLYToolStackControllerOptions) public class ToolStackControllerOptions: NSObject {

    /// The background color of the main toolbar.
    public let mainToolbarBackgroundColor: UIColor

    /// The background color of the secondary toolbar.
    public let secondaryToolbarBackgroundColor: UIColor

    /// Whether or not the `navigationBar` of the embedding `navigationController` should be used
    /// to navigate between different tools. Setting this to `true` means that the lower bar will
    /// not display any buttons to apply or discard changes, but the navigation bar at the top will.
    /// Default is `false`.
    ///
    /// You would typically set this to `true`, if you push the editor onto a navigation stack.
    /// If a back button is present, that back button will be displayed while inside the main editor
    /// (i.e. when you are not inside a tool). If no back button is present, a `Cancel` button will
    /// be displayed.
    public let useNavigationControllerForNavigationButtons: Bool

    /// Whether or not the `navigationBar` of the embedding `navigationController` should be used
    /// to show the title of the different tools. Setting this to `true` means that the lower bar
    /// will not display any title, but the navigation bar at the top will. Default is `false`.
    public let useNavigationControllerForTitles: Bool

    /**
     Returns a newly allocated instance of `ToolStackControllerOptions` using the default builder.

     - returns: An instance of `ToolStackControllerOptions`.
     */
    public convenience override init() {
        self.init(builder: ToolStackControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `ToolStackControllerOptions` using the given builder.

     - parameter builder: A `ToolStackControllerOptionsBuilder` instance.

     - returns: An instance of `ToolStackControllerOptions`.
     */
    public init(builder: ToolStackControllerOptionsBuilder) {
        mainToolbarBackgroundColor = builder.mainToolbarBackgroundColor
        secondaryToolbarBackgroundColor = builder.secondaryToolbarBackgroundColor
        useNavigationControllerForNavigationButtons = builder.useNavigationControllerForNavigationButtons
        useNavigationControllerForTitles = builder.useNavigationControllerForTitles
        super.init()
    }
}

/**
 The default `ToolStackControllerOptionsBuilder` for `ToolStackControllerOptions`.
 */
@objc(IMGLYToolStackControllerOptionsBuilder) public class ToolStackControllerOptionsBuilder: NSObject {

    /// The background color of the main toolbar
    public var mainToolbarBackgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)

    /// The background color of the secondary toolbar
    public var secondaryToolbarBackgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)

    /// Whether or not the `navigationBar` of the embedding `navigationController` should be used
    /// to navigate between different tools. Setting this to `true` means that the lower bar will
    /// not display any buttons to apply or discard changes, but the navigation bar at the top will.
    /// Default is `false`.
    ///
    /// You would typically set this to `true`, if you push the editor onto a navigation stack.
    /// If a back button is present, that back button will be displayed while inside the main editor
    /// (i.e. when you are not inside a tool). If no back button is present, a `Cancel` button will
    /// be displayed.
    public var useNavigationControllerForNavigationButtons = false

    /// Whether or not the `navigationBar` of the embedding `navigationController` should be used
    /// to show the title of the different tools. Setting this to `true` means that the lower bar
    /// will not display any title, but the navigation bar at the top will. Default is `false`.
    public var useNavigationControllerForTitles = false
}
