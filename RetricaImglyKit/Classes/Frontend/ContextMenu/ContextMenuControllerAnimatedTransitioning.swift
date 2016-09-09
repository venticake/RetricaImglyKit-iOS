//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

@available(iOS 8, *)
internal class ContextMenuControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    var presentation: Bool = false

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let animationViewKey: String
        let animationViewControllerKey: String

        if presentation {
            animationViewKey = UITransitionContextToViewKey
            animationViewControllerKey = UITransitionContextToViewControllerKey
        } else {
            animationViewKey = UITransitionContextFromViewKey
            animationViewControllerKey = UITransitionContextFromViewControllerKey
        }

        guard let containerView = transitionContext.containerView(), animationView = transitionContext.viewForKey(animationViewKey), animationViewController = transitionContext.viewControllerForKey(animationViewControllerKey) else {
            transitionContext.completeTransition(false)
            return
        }

        if presentation {
            animationView.alpha = 0
            containerView.addSubview(animationView)
            animationView.frame = transitionContext.finalFrameForViewController(animationViewController)
            animationView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            if self.presentation {
                animationView.alpha = 1
                animationView.transform = CGAffineTransformIdentity
            } else {
                animationView.alpha = 0
            }
        }) { _ in
            animationView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}
