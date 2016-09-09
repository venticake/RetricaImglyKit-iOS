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
 *  A `ContextMenuController` object displays a context menu to the user. After configuring the
 *  context menu controller with the actions you want, present it using
 *  the `presentViewController:animated:completion:` method.
 */
@objc(IMGLYContextMenuController) public class ContextMenuController: UIViewController {

    // MARK: - Properties

    /// The actions that the user can take in the context menu. (read-only)
    public private(set) var actions = [ContextMenuAction]()

    /// The background color of the context menu.
    public var menuColor: UIColor? {
        get {
            return contextMenuControllerView.backgroundColor
        }

        set {
            contextMenuControllerView.backgroundColor = newValue
        }
    }

    private let ownedTransitioningDelegate: ContextMenuControllerTransitioningDelegate

    private lazy var contextMenuControllerView: ContextMenuControllerView = {
        let contextMenuControllerView = ContextMenuControllerView()
        contextMenuControllerView.contextMenuController = self
        contextMenuControllerView.frame = UIScreen.mainScreen().bounds
        return contextMenuControllerView
    }()

    // MARK: - Initializers

    /**
    :nodoc:
    */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        ownedTransitioningDelegate = ContextMenuControllerTransitioningDelegate()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.transitioningDelegate = ownedTransitioningDelegate
        self.modalPresentationStyle = .Custom
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func loadView() {
        view = contextMenuControllerView
        contextMenuControllerView.actionsChanged()
    }

    /**
    :nodoc:
    */
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Action related methods

    /**
     Attaches an action object to the context menu.

     - parameter action: The action object to display as part of the context menu. Actions are displayed as buttons in the context menu.
     */
    public func addAction(action: ContextMenuAction) {
        actions.append(action)

        if isViewLoaded() {
            contextMenuControllerView.actionsChanged()
        }
    }

}
