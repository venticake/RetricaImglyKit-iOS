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
internal class ContextMenuControllerView: UIView {

    // MARK: - Properties

    internal weak var contextMenuController: ContextMenuController?
    private var actionViews = [ContextMenuActionView]()
    private var actionViewConstraints: [NSLayoutConstraint]?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = false
        userInteractionEnabled = true

        layer.cornerRadius = 4
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    // MARK: - Action related methods

    private var actions: [ContextMenuAction]? {
        return contextMenuController?.actions
    }

    internal func actionsChanged() {
        guard let actions = actions else {
            return
        }

        let delta = actions.count - actionViews.count

        if delta > 0 {
            (0 ..< delta).forEach { _ in
                actionViews.append(ContextMenuActionView())
            }
        } else {
            actionViews.removeLast(delta * -1)
        }

        (0 ..< actionViews.count).forEach { i in
            let actionView = actionViews[i]
            let action = actions[i]

            actionView.isAccessibilityElement = action is ContextMenuDividerAction ? false : true
            actionView.accessibilityLabel = action.accessibilityLabel
            actionView.accessibilityTraits |= UIAccessibilityTraitButton
            actionView.contextMenuController = contextMenuController
            actionView.action = action
        }

        updateActionViews()
    }

    // MARK: - View Preparation

    private func updateActionViews() {
        actionViews.filter({ !subviews.contains($0) }).forEach { actionView in
            addSubview(actionView)
        }

        actionViewConstraints = nil
        setNeedsUpdateConstraints()
    }

    // MARK: - UIView

    override func updateConstraints() {
        super.updateConstraints()

        if actionViewConstraints == nil {
            actionViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

            var constraints = [NSLayoutConstraint]()
            var previousActionView: ContextMenuActionView?

            let margin: CGFloat = 6

            for actionView in actionViews {
                if let previousActionView = previousActionView {
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Left, relatedBy: .Equal, toItem: previousActionView, attribute: .Right, multiplier: 1, constant: margin))
                } else {
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: margin))
                }

                if actionView.action is ContextMenuDividerAction {
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30))
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
                } else {
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50))
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50))
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
                }

                if actionView == actionViews.last {
                    constraints.append(NSLayoutConstraint(item: actionView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -margin))
                }

                previousActionView = actionView
            }

            NSLayoutConstraint.activateConstraints(constraints)
            self.actionViewConstraints = constraints
        }
    }

}
