//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

internal class ContextMenuControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    // MARK: - UIViewControllerTransitioningDelegate

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ContextMenuControllerAnimatedTransitioning()
        animationController.presentation = true
        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ContextMenuControllerAnimatedTransitioning()
        animationController.presentation = false
        return animationController
    }

    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return ContextMenuPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
