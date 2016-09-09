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
 *  A `StickerImageView` displays an instance of `Sticker` and provides improved support for accessibility.
 */
@objc(IMGLYStickerImageView) public class StickerImageView: UIImageView {

    // MARK: - Properties

    /// The sticker that this image view should display.
    public let sticker: Sticker

    /// Called by accessibility to make the image view smaller.
    public var decrementHandler: (() -> Void)?

    /// Called by accessibility to make the image view bigger.
    public var incrementHandler: (() -> Void)?

    /// Called by accessibility to rotate the image view to the left.
    public var rotateLeftHandler: (() -> Void)?

    /// Called by accessibility to rotate the image view to the right.
    public var rotateRightHandler: (() -> Void)?

    /// This property holds the normalized center of the view within the image without any crops added.
    /// It is used to calculate the correct position of the sticker within the preview view.
    public var normalizedCenterInImage = CGPoint.zero

    // MARK: - Initializers

    /**
    Returns a newly allocated instance of `StickerImageView` with the given sticker.

    - parameter sticker: The sticker that should be shown in this image view.

    - returns: An instance of `StickerImageView`.
    */
    public init(sticker: Sticker) {
        self.sticker = sticker
        super.init(image: nil)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        userInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityTraits &= ~UIAccessibilityTraitImage
        accessibilityTraits |= UIAccessibilityTraitAdjustable
        accessibilityHint = Localize("Double-tap and hold to move")

        let rotateLeftAction = UIAccessibilityCustomAction(name: Localize("Rotate left"), target: self, selector: #selector(StickerImageView.rotateLeft))
        let rotateRightAction = UIAccessibilityCustomAction(name: Localize("Rotate right"), target: self, selector: #selector(StickerImageView.rotateRight))
        accessibilityCustomActions = [rotateLeftAction, rotateRightAction]
    }

    @objc internal func flipVertically() {
        guard let stickerImage = image, cgImage = stickerImage.CGImage else {
            return
        }

        if let flippedOrientation = UIImageOrientation(rawValue: (stickerImage.imageOrientation.rawValue + 4) % 8) {
            image = UIImage(CGImage: cgImage, scale: stickerImage.scale, orientation: flippedOrientation)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
    }

    @objc internal func flipHorizontally() {
        guard let stickerImage = image, cgImage = stickerImage.CGImage else {
            return
        }

        if let flippedOrientation = UIImageOrientation(rawValue: (stickerImage.imageOrientation.rawValue + 4) % 8) {
            image = UIImage(CGImage: cgImage, scale: stickerImage.scale, orientation: flippedOrientation)
        }
    }

    /**
     :nodoc:
     */
    public override func accessibilityDecrement() {
        decrementHandler?()
    }

    /**
     :nodoc:
     */
    public override func accessibilityIncrement() {
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
}
