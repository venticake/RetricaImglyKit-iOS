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
 *  A `ContextMenuDividerAction` is a special kind of `ContextMenuAction`. It takes no arguments and
 *  is displayed as a visual divider in a context menu controller.
 */
@available(iOS 8, *)
@objc(IMGLYContextMenuDividerAction) public class ContextMenuDividerAction: ContextMenuAction {

    // MARK: - Initializers

    /**
     Create and return an action that displays a visual divider in a context menu controller.

     - returns: A new context menu action object.
     */
    public init() {
        super.init(image: UIImage(), handler: { _ in })
    }

}
