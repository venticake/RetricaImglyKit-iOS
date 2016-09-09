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
 *  A `TextLabel` is used to show text that has been added to an image and provides improved support for accessibility.
 */
@objc(IMGLYTextLabel) public class TextLabel: UILabel {

    // MARK: - Properties

    /// Called by accessibility to select this label.
    public var activateHandler: (() -> Void)?

    /// Called by accessibility to make this label smaller.
    public var decrementHandler: (() -> Void)?

    /// Called by accessibility to make this label bigger.
    public var incrementHandler: (() -> Void)?

    /// Called by accessibility to rotate this label to the left.
    public var rotateLeftHandler: (() -> Void)?

    /// Called by accessibility to rotate this label to the right.
    public var rotateRightHandler: (() -> Void)?

    /// Called by accessibility to change the text of this label.
    public var changeTextHandler: (() -> Void)?

    /// This property holds the normalized center of the view within the image without any crops added.
    /// It is used to calculate the correct position of the label within the preview view.
    public var normalizedCenterInImage = CGPoint.zero

    // MARK: - Initializers

    /**
    :nodoc:
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        userInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitAdjustable
        accessibilityHint = Localize("Double-tap and hold to move")

        let rotateLeftAction = UIAccessibilityCustomAction(name: Localize("Rotate left"), target: self, selector: #selector(TextLabel.rotateLeft))
        let rotateRightAction = UIAccessibilityCustomAction(name: Localize("Rotate right"), target: self, selector: #selector(TextLabel.rotateRight))
        let changeAction = UIAccessibilityCustomAction(name: Localize("Change text"), target: self, selector: #selector(TextLabel.changeText))
        accessibilityCustomActions = [rotateLeftAction, rotateRightAction, changeAction]
    }

    // MARK: - Accessibility

    /**
    :nodoc:
    */
    public override func accessibilityActivate() -> Bool {
        activateHandler?()
        return true
    }

    /**
     :nodoc:
     */
    override public func accessibilityDecrement() {
        decrementHandler?()
    }

    /**
     :nodoc:
     */
    override public func accessibilityIncrement() {
        incrementHandler?()
    }

    @objc private func rotateLeft() -> Bool {
        rotateLeftHandler?()
        return true
    }

    @objc private func rotateRight() -> Bool {
        rotateRightHandler?()
        return true
    }

    @objc private func changeText() -> Bool {
        changeTextHandler?()
        return true
    }
}
