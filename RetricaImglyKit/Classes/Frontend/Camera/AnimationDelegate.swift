//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import QuartzCore

/**
 *  `AnimationDelegate` can be used as the delegate of a `CAAnimation` to easily specify a completion block.
 */
@objc(IMGLYAnimationDelegate) public class AnimationDelegate: NSObject {

    // MARK: - Properties

    /// The block that should be executed after a `CAAnimation` finishes.
    public let block: (Bool) -> ()

    // MARK: - Initializers

    /**
    Returns a newly allocated instance of `AnimationDelegate`.

    - parameter block: The block that should be executed after a `CAAnimation` finishes.

    - returns: An instance of `AnimationDelegate`.
    */
    init(block: (Bool) -> ()) {
        self.block = block
    }

    // MARK: - Animation Delegate

    /**
    :nodoc:
    */
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        block(flag)
    }
}
