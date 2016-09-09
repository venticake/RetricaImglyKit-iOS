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
 *  A `ContextMenuPresentationController` handles the presentation of a `ContextMenuController`. In
 *  nearly all cases you use this class as-is and do not create instances of it directly. imglyKit
 *  creates an instance of this class automatically when you present a context menu controller.
 */
@available(iOS 8, *)
@objc(IMGLYContextMenuPresentationController) public class ContextMenuPresentationController: UIPresentationController {

    // MARK: - Statics

    private static let margin: CGFloat = 20

    // MARK: - Properties

    private var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var passthroughView = PassthroughView()

    /// The frame in which to present the context menu.
    public var contentFrame: CGRect?

    /// An array of views that the user can interact with while the context menu is visible.
    public var passthroughViews: [UIView] {
        get {
            return passthroughView.passthroughViews
        }

        set {
            passthroughView.passthroughViews = newValue
        }
    }

    // MARK: - UIContentContainer

    /**
    :nodoc:
    */
    override public func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedView()?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) ?? .zero
    }

    // MARK: - UIPresentationController

    /**
     :nodoc:
     */
    override public func frameOfPresentedViewInContainerView() -> CGRect {
        let containerBounds = contentFrame ?? containerView?.bounds ?? .zero
        let size = sizeForChildContentContainer(self, withParentContainerSize: containerBounds.size)
        return CGRect(origin: CGPoint(x: floor(containerBounds.midX - size.width / 2), y: containerBounds.minY + ContextMenuPresentationController.margin), size: size)
    }

    /**
     :nodoc:
     */
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        passthroughView.frame = containerView?.bounds ?? .zero
    }

    /**
     :nodoc:
     */
    public override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        containerView.insertSubview(passthroughView, atIndex: 0)
    }

    /**
     :nodoc:
     */
    override public func presentationTransitionDidEnd(completed: Bool) {
        guard let containerView = containerView, presentedView = presentedView() where completed else {
            passthroughView.removeFromSuperview()
            return
        }

        let animator = UIDynamicAnimator(referenceView: containerView)
        let snapBehavior = UISnapBehavior(item: presentedView, snapToPoint: presentedView.center)
        snapBehavior.damping = 0.30

        let noRotationBehavior = UIDynamicItemBehavior(items: [presentedView])
        noRotationBehavior.allowsRotation = false

        animator.addBehavior(noRotationBehavior)
        animator.addBehavior(snapBehavior)

        self.snapBehavior = snapBehavior
        self.animator = animator

        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ContextMenuPresentationController.swiped(_:)))
        swipeUpGestureRecognizer.direction = .Up
        containerView.addGestureRecognizer(swipeUpGestureRecognizer)

        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ContextMenuPresentationController.swiped(_:)))
        swipeDownGestureRecognizer.direction = .Down
        containerView.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    // MARK: - Actions

    @objc private func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
        guard let containerView = containerView, presentedView = presentedView() else {
            return
        }

        let containerBounds = contentFrame ?? containerView.bounds
        let childSize = sizeForChildContentContainer(self, withParentContainerSize: containerBounds.size)

        if gestureRecognizer.direction == .Up {
            if let snapBehavior = snapBehavior {
                animator?.removeBehavior(snapBehavior)
            }

            let snap = UISnapBehavior(item: presentedView, snapToPoint: CGPoint(x: containerBounds.midX, y: containerBounds.minY + (childSize.height / 2 + ContextMenuPresentationController.margin)))
            snap.damping = 0.30

            self.snapBehavior = snap
            animator?.addBehavior(snap)
        } else if gestureRecognizer.direction == .Down {
            if let snapBehavior = snapBehavior {
                animator?.removeBehavior(snapBehavior)
            }

            let snap = UISnapBehavior(item: presentedView, snapToPoint: CGPoint(x: containerView.bounds.midX, y: containerBounds.maxY - (childSize.height / 2 + ContextMenuPresentationController.margin)))
            snap.damping = 0.30

            self.snapBehavior = snap
            animator?.addBehavior(snap)
        }
    }
}
