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
 *  A `ContextMenuAction` object represents an action that can be taken when tapping a button in a
 *  context menu. You use this class to configure information about a single action, including the
 *  image, and a handler to execute when the user taps the button. After creating an context menu
 *  action object, add it to a `ContextMenuController` object before displaying the corresponding
 *  context menu to the user.
 */
@available(iOS 8, *)
@objc(IMGLYContextMenuAction) public class ContextMenuAction: NSObject {

    // MARK: - Properties

    /// The image of the action's button. (read-only)
    public let image: UIImage
    internal let handler: (ContextMenuAction) -> Void

    // MARK: - Initializers

    /**
     Create and return an action with the specified image and behavior.

     - parameter image:   The image to use for this button.
     - parameter handler: A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.

     - returns: A new context menu action object.
     */
    public init(image: UIImage, handler: (ContextMenuAction) -> Void) {
        self.image = image
        self.handler = handler
        super.init()
    }
}
