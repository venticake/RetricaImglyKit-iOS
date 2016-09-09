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
internal class ContextMenuActionView: UIView {

    // MARK: - Properties

    private let imageView = UIImageView()

    internal weak var contextMenuController: ContextMenuController?
    internal var action: ContextMenuAction? {
        didSet {
            if action is ContextMenuDividerAction {
                backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
                imageView.image = nil
            } else {
                backgroundColor = UIColor.clearColor()
                imageView.image = action?.image
            }
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))

        NSLayoutConstraint.activateConstraints(constraints)

        // Using a long press gesture recognizer with `minimumPressDuration` of `0.0` so that the
        // action is called for the `.Began` and `.Ended` state instead of just the `.Ended` state
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ContextMenuActionView.tapped(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.0
        addGestureRecognizer(longPressGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func tapped(sender: UILongPressGestureRecognizer) {
        if let action = action where !(action is ContextMenuDividerAction) {
            if sender.state == .Began {
                backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
            } else if sender.state == .Ended {
                backgroundColor = UIColor.clearColor()
                action.handler(action)
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

@available(iOS 8, *)
extension ContextMenuActionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UISwipeGestureRecognizer {
            return true
        }

        return false
    }
}
