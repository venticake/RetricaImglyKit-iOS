//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

let ToolStackItemDidChangeNotification = "ToolStackItemDidChangeNotification"

/**
 *  A `ToolStackItem` object manages the views to be displayed in the toolbars of a `ToolStackController`.
 */
@available(iOS 8, *)
@objc(IMGLYToolStackItem) public class ToolStackItem: NSObject {

    private var transactionDepth: Int = 0
    private var _mainToolbarView: UIView?
    private var _titleLabel: UILabel? = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.45)
        return label
    }()

    private var _discardButton: UIButton? = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "discard_changes_icon", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil), forState: .Normal)
        return button
    }()

    private var _applyButton: UIButton? = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "apply_changes_icon", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil), forState: .Normal)
        return button
    }()


    /// The view that should be displayed in the main toolbar.
    public var mainToolbarView: UIView? {
        get {
            return _mainToolbarView
        }

        set {
            performChanges {
                _mainToolbarView = newValue
            }
        }
    }

    /// The title label that is shown in the secondary toolbar.
    public var titleLabel: UILabel? {
        get {
            return _titleLabel
        }

        set {
            performChanges {
                _titleLabel = newValue
            }
        }
    }

    /// The discard button that is shown in the secondary toolbar. Set to `nil` to remove.
    public var discardButton: UIButton? {
        get {
            return _discardButton
        }

        set {
            performChanges {
                _discardButton = newValue
            }
        }
    }

    /// The apply button that is shown in the secondary toolbar. Set to `nil` to remove.
    public var applyButton: UIButton? {
        get {
            return _applyButton
        }

        set {
            performChanges {
                _applyButton = newValue
            }
        }
    }

    /**
    Use this method to apply changes to an instance of `ToolStackItem`.

    - parameter block: The changes to apply.
    */
    public func performChanges(@noescape block: () -> Void) {
        transactionDepth = transactionDepth + 1
        block()
        transactionDepth = transactionDepth - 1

        if transactionDepth == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName(ToolStackItemDidChangeNotification, object: self)
        }
    }
}
