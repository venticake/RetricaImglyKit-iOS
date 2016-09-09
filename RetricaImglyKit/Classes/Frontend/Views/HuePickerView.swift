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
 *  The `HuePickerViewDelegate` will be used to broadcast changes of the picked hue.
 */
@available(iOS 8, *)
@objc(IMGLYHuePickerViewDelegate) public protocol HuePickerViewDelegate {
    /**
     Called when a hue was picked.

     - parameter huePickerView: The hue picker view that changed its `hue` value.
     - parameter hue:           The new hue value.
     */
    func huePicked(huePickerView: HuePickerView, hue: CGFloat)
}

/**
 *  The `HuePickerView` class provides a view to visualy pick a hue.
 */
@available(iOS 8, *)
@objc(IMGLYHuePickerView) public class HuePickerView: UIView {

    /// The receiver’s delegate.
    /// - seealso: `HuePickerViewDelegate`.
    public weak var pickerDelegate: HuePickerViewDelegate?

    private let markerView = UIView(frame: CGRect(x: -10, y: 0, width: 40, height: 4))

    /// The currently selected hue.
    public var hue = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /**
     :nodoc:
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        markerView.backgroundColor = UIColor.whiteColor()
        markerView.layer.shadowColor = UIColor.blackColor().CGColor
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowOpacity = 0.25
        markerView.layer.shadowRadius = 2
        self.addSubview(markerView)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        opaque = false
        backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }

    /// The selected color.
    public var color = UIColor.redColor() {
        didSet {
            hue = color.hsb.hue
            updateMarkerPosition()
            self.setNeedsDisplay()
        }
    }

    /**
     :nodoc:
     */
    public override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorSpectrum(context, rect:rect)
        }
    }

    private func drawColorSpectrum(context: CGContextRef, rect: CGRect) {
        CGContextSaveGState(context)
        PathHelper.clipCornersToOvalWidth(context, width:frame.size.width, height: frame.size.height, ovalWidth:2.0, ovalHeight:2.0)
        CGContextClip(context)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let step = CGFloat(0.166666666666667)
        let locs: [CGFloat] = [0.00, step, step * 2, step * 3, step * 4, step * 5, 1.0]
        let colors = [
            UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:1.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:1.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:0.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:0.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0).CGColor
        ]

        let grad = CGGradientCreateWithColors(colorSpace, colors, locs)
        CGContextDrawLinearGradient(context, grad, CGPoint(x: 0, y: rect.size.height), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
    }

    /**
     :nodoc:
     */
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    /**
     :nodoc:
     */
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    /**
     :nodoc:
     */
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    private func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let pos = touch.locationInView(self)
        let p = min(max(pos.y, 0), self.frame.size.height)
        hue = 1.0 - (p / self.frame.size.height)
        updateMarkerPosition()
        pickerDelegate?.huePicked(self, hue: hue)
        self.setNeedsDisplay()
    }

    /**
     :nodoc:
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        markerView.frame.size = CGSize(width: frame.width * 1.5, height: 4)
        markerView.center = CGPoint(x: self.frame.size.width / 2.0, y: 0)
    }

    private func updateMarkerPosition() {
        let markerY =  (1.0 - hue) * self.frame.size.height
        markerView.center = CGPoint(x: self.frame.size.width / 2.0, y: markerY)
    }
}
