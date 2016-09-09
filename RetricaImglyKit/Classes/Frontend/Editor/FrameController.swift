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
 The `FrameControllerDelegate` protocol defines methods that allow you to pass information to an instance of `FrameController`.
 */
@objc(IMGLYFrameControllerDelegate) public protocol FrameControllerDelegate {
    /**
     The normalized cropping rect that is currently applied to the image.

     - parameter frameController: The frame controller that is asking for the cropping area.

     - returns: A `CGRect`.
     */
    func frameControllerNormalizedCropRect(frameController: FrameController) -> CGRect

    /**
     The size of the base image that is being edited.

     - parameter frameController: The frame controller that is asking for the size of the base image.

     - returns: The `CGSize` of the base image.
     */
    func frameControllerBaseImageSize(frameController: FrameController) -> CGSize
}

/**
 *  The `FrameController` takes care of positioning and updating a frame that is applied to an image.
 */
@objc(IMGLYFrameController) public class FrameController: NSObject {

    // MARK: - Properties

    /// The receiver's delegate.
    /// - seealso: `FrameControllerDelegate`.
    public weak var delegate: FrameControllerDelegate?

    internal var _frame: Frame?

    /// The currently selected frame.
    public var frame: Frame? {
        get {
            return _frame
        }

        set {
            let oldValue = _frame
            _frame = newValue

            if oldValue != _frame {
                _frame?.imageForRatio(imageRatio, completionBlock: { (image, error) -> () in
                    if let image = image {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imageView?.image = image
                            self.updateNormalizedRect()
                            self.updatePositioning()
                        })
                    }
                })
            }

            if _frame == nil {
                self.imageView?.image = nil
                self.updateNormalizedRect()
            }

            updatePositioning()
        }
    }

    internal var _imageRatio: Float = 0

    /// The currently active image ratio.
    public var imageRatio: Float {
        get {
            return _imageRatio
        }

        set {
            if !locked {
                if _imageRatio != newValue {
                    _imageRatio = newValue
                }
            }

            frame?.imageForRatio(newValue, completionBlock: { (image, error) -> () in
                if let image = image {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView?.image = image
                        self.updateNormalizedRect()
                        self.updatePositioning()
                    })
                }
            })
        }
    }

    internal var normalizedRectInImage = CGRect.zero

    /// Whether or not the frame controller is currently locked.
    public internal(set) var locked: Bool = false

    /// The image view that should be used to show the frame in.
    public var imageView: UIImageView?

    /// The view that contains `imageView`.
    public var imageViewContainerView: UIView?

    // MARK: - Locking

    /**
    Locks the frame controller so that the frame stays in place even when cropping.
    */
    public func lock() {
        locked = true
    }

    /**
     Unlocks the frame controller so that the frame's position and size is updated when cropping.
     */
    public func unlock() {
        locked = false
    }

    // MARK: - Helpers

    /**
    Updates the position and size of the frame if needed.
    */
    public func updatePositioning() {
        guard let normalizedCropRect = delegate?.frameControllerNormalizedCropRect(self), baseImageSize = delegate?.frameControllerBaseImageSize(self), imageViewContainerView = imageViewContainerView else {
            return
        }

        let convertedNormalizedCropRect = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.size.height, width: normalizedCropRect.size.width, height: normalizedCropRect.size.height)

        let denormalizedCropRect = CGRect(
            x: convertedNormalizedCropRect.origin.x * baseImageSize.width,
            y: convertedNormalizedCropRect.origin.y * baseImageSize.height,
            width: convertedNormalizedCropRect.size.width * baseImageSize.width,
            height: convertedNormalizedCropRect.size.height * baseImageSize.height
        )

        let viewToCroppedImageScale = min(imageViewContainerView.bounds.width / denormalizedCropRect.width, imageViewContainerView.bounds.height / denormalizedCropRect.height)

        let denormalizedFrameRect = CGRect(x: normalizedRectInImage.origin.x * baseImageSize.width, y: normalizedRectInImage.origin.y * baseImageSize.height, width: normalizedRectInImage.width * baseImageSize.width, height: normalizedRectInImage.height * baseImageSize.height)

        let frameRectInCropRect = CGRect(x: denormalizedFrameRect.origin.x - denormalizedCropRect.origin.x, y: denormalizedFrameRect.origin.y - denormalizedCropRect.origin.y, width: denormalizedFrameRect.width, height: denormalizedFrameRect.height)

        self.imageView?.frame = CGRect(x: frameRectInCropRect.origin.x * viewToCroppedImageScale, y: frameRectInCropRect.origin.y * viewToCroppedImageScale, width: frameRectInCropRect.width * viewToCroppedImageScale, height: frameRectInCropRect.height * viewToCroppedImageScale).integral
    }

    private func updateNormalizedRect() {
        guard let normalizedCropRect = delegate?.frameControllerNormalizedCropRect(self) else {
            return
        }

        normalizedRectInImage = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.height, width: normalizedCropRect.width, height: normalizedCropRect.height)
    }
}
