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
 A `CropRectComponent` holds all the logic for the cropping view.
 */
@objc(IMGLYCropRectComponent) public class CropRectComponent: NSObject {
    /// The currently visible cropping area.
    public var cropRect = CGRect.zero

    private var topLineView = UIView(frame: CGRect.zero)
    private var bottomLineView = UIView(frame: CGRect.zero)
    private var leftLineView = UIView(frame: CGRect.zero)
    private var rightLineView = UIView(frame: CGRect.zero)

    /// The top left anchor image view.
    public var topLeftAnchor: UIImageView?

    /// The top right anchor image view.
    public var topRightAnchor: UIImageView?

    /// The bottom left anchor image view.
    public var bottomLeftAnchor: UIImageView?

    /// The bottom right anchor image view.
    public var bottomRightAnchor: UIImageView?
    private var transparentView: UIView?
    private var parentView: UIView?
    private var showAnchors = true

    /**
    Call this in `viewDidLoad`.

    - parameter transparentView: A view that is userd as transperent overlay.
    - parameter parentView:      The parent view.
    - parameter showAnchors:     A bool that determines whether the anchors are visible or not.
    */
    public func setup(transparentView: UIView, parentView: UIView, showAnchors: Bool) {
        self.transparentView = transparentView
        self.parentView = parentView
        self.showAnchors = showAnchors
        setupLineViews()
        setupAnchors()
    }

    /**
    Call this in `viewDidAppear`.
    */
    public func present() {
        layoutViewsForCropRect()
        showViews()
    }

    private func setupLineViews() {
        cropRect = CGRect(x: 100, y: 100, width: 150, height: 100)
        setupLineView(topLineView)
        setupLineView(bottomLineView)
        setupLineView(leftLineView)
        setupLineView(rightLineView)
    }

    private func setupLineView(lineView: UIView) {
        lineView.backgroundColor = UIColor.whiteColor()
        lineView.hidden = true
        lineView.userInteractionEnabled = false
        parentView!.addSubview(lineView)
    }

    private func addMaskRectView() {
        let bounds = CGRect(x: 0, y: 0, width: transparentView!.frame.size.width,
            height: transparentView!.frame.size.height)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.fillColor = UIColor.blackColor().CGColor
        let path = UIBezierPath(rect: cropRect)
        path.appendPath(UIBezierPath(rect: bounds))
        maskLayer.path = path.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd

        transparentView!.layer.mask = maskLayer

        let cropRectElement = UIAccessibilityElement(accessibilityContainer: self)
        cropRectElement.isAccessibilityElement = true
        cropRectElement.accessibilityLabel = Localize("Cropping area")
        cropRectElement.accessibilityHint = Localize("Double-tap and hold to move cropping area")
        cropRectElement.accessibilityFrame = transparentView!.convertRect(cropRect, toView: nil)

        transparentView!.accessibilityElements = [cropRectElement]

        if let topLeftAnchor = topLeftAnchor {
            transparentView!.accessibilityElements?.append(topLeftAnchor)
        }

        if let topRightAnchor = topRightAnchor {
            transparentView!.accessibilityElements?.append(topRightAnchor)
        }

        if let bottomLeftAnchor = bottomLeftAnchor {
            transparentView!.accessibilityElements?.append(bottomLeftAnchor)
        }

        if let bottomRightAnchor = bottomRightAnchor {
            transparentView!.accessibilityElements?.append(bottomRightAnchor)
        }
    }

    private func setupAnchors() {
        let anchorImage = UIImage(named: "crop_anchor", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection:nil)
        topLeftAnchor = createAnchorWithImage(anchorImage)
        topLeftAnchor?.accessibilityLabel = Localize("Top left cropping handle")
        topRightAnchor = createAnchorWithImage(anchorImage)
        topRightAnchor?.accessibilityLabel = Localize("Top right cropping handle")
        bottomLeftAnchor = createAnchorWithImage(anchorImage)
        bottomLeftAnchor?.accessibilityLabel = Localize("Bottom left cropping handle")
        bottomRightAnchor = createAnchorWithImage(anchorImage)
        bottomRightAnchor?.accessibilityLabel = Localize("Bottom right cropping handle")
    }

    private func createAnchorWithImage(image: UIImage?) -> UIImageView {
        let anchor = UIImageView(image: image!)
        anchor.isAccessibilityElement = true
        anchor.accessibilityTraits &= ~UIAccessibilityTraitImage
        anchor.accessibilityHint = Localize("Double-tap and hold to adjust cropping area")
        anchor.contentMode = UIViewContentMode.Center
        anchor.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        anchor.hidden = true
        transparentView!.addSubview(anchor)
        return anchor
    }

    // MARK: - Layout

    /**
    Initially lays out all needed views for the crop rect.
    */
    public func layoutViewsForCropRect() {
        layoutLines()
        layoutAnchors()
        addMaskRectView()
    }

    private func layoutLines() {
        let left = cropRect.origin.x + transparentView!.frame.origin.x
        let right = left + cropRect.size.width - 1.0
        let top = cropRect.origin.y + transparentView!.frame.origin.y
        let bottom = top + cropRect.size.height - 1.0
        let width = cropRect.size.width
        let height = cropRect.size.height

        leftLineView.frame = CGRect(x: left, y: top, width: 1, height: height)
        rightLineView.frame = CGRect(x: right, y: top, width: 1, height: height)
        topLineView.frame = CGRect(x: left, y: top, width: width, height: 1)
        bottomLineView.frame = CGRect(x: left, y: bottom, width: width, height: 1)
    }

    private func layoutAnchors() {
        let left = cropRect.origin.x
        let right = left + cropRect.size.width
        let top = cropRect.origin.y
        let bottom = top + cropRect.size.height
        topLeftAnchor!.center = CGPoint(x: left, y: top)
        topRightAnchor!.center = CGPoint(x: right, y: top)
        bottomLeftAnchor!.center = CGPoint(x: left, y: bottom)
        bottomRightAnchor!.center = CGPoint(x: right, y: bottom)
    }

    /**
     Makes all views visible.
     */
    public func showViews() {
        if showAnchors {
            topLeftAnchor!.hidden = false
            topRightAnchor!.hidden = false
            bottomLeftAnchor!.hidden = false
            bottomRightAnchor!.hidden = false
        }

        leftLineView.hidden = false
        rightLineView.hidden = false
        topLineView.hidden = false
        bottomLineView.hidden = false
    }
}
