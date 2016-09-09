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
 The `SaturationBrightnessPickerViewDelegate` protocol defines methods that allow you respond to the
 events of an instance of `SaturationBrightnessPickerView`.
 */
@available(iOS 8, *)
@objc(IMGLYSaturationBrightnessPickerViewDelegate) public protocol SaturationBrightnessPickerViewDelegate {
    /**
     Called when a saturation brightness picker view picked a color.

     - parameter saturationBrightnessPickerView: The saturation brightness picker view that picked a color.
     - parameter color:                          The color that was picked.
     */
    func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor)
}

/**
 *  A `SaturationBrightnessPickerView` presents a view that can be dragged to select the saturation
 *  within an instance of `ColorPickerView`.
 */
@available(iOS 8, *)
@objc(IMGLYSaturationBrightnessPickerView) public class SaturationBrightnessPickerView: UIView {

    /// The receiver’s delegate.
    /// - seealso: `SaturationBrightnessPickerViewDelegate`.
    public weak var pickerDelegate: SaturationBrightnessPickerViewDelegate?

    /// The currently picked hue.
    public var hue = CGFloat(0) {
        didSet {
            updateMarkerPosition()
            self.setNeedsDisplay()
        }
    }

    /// The currently picked color.
    public var color: UIColor {
        set {
            let hsb = newValue.hsb
            hue = hsb.hue
            brightness = hsb.brightness
            saturation = hsb.saturation
            updateMarkerPosition()
            setNeedsDisplay()
        }
        get {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
    }

    /// The currently picked saturation.
    public var saturation = CGFloat(1)

    /// The currently picked brightness.
    public var brightness = CGFloat(1)

    private let markerView = UIView()

    /**
     :nodoc:
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
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
        self.clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        configureMarkerView()
    }

    private func configureMarkerView() {
        markerView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        markerView.layer.borderColor = UIColor.whiteColor().CGColor
        markerView.layer.borderWidth = 2.0
        markerView.layer.cornerRadius = 10
        markerView.backgroundColor = UIColor.clearColor()
        markerView.layer.shadowColor = UIColor.blackColor().CGColor
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowOpacity = 0.25
        markerView.layer.shadowRadius = 2
        markerView.center = CGPoint.zero
        self.addSubview(markerView)
    }

    /**
     :nodoc:
     */
    override public func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorMatrixToContext(context, rect: rect)
        }
    }

    private func drawColorMatrixToContext(context: CGContextRef, rect: CGRect) {
        CGContextSaveGState(context)
        PathHelper.clipCornersToOvalWidth(context, width:frame.size.width, height: frame.size.height, ovalWidth:2.0, ovalHeight:2.0)
        CGContextClip(context)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locs: [CGFloat] = [0.00, 1.0]
        var colors = [UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor]
        var grad = CGGradientCreateWithColors(colorSpace, colors, locs)

        CGContextDrawLinearGradient(context, grad, CGPoint(x:rect.size.width, y: 0), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        colors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor]
        grad = CGGradientCreateWithColors(colorSpace, colors, locs)
        CGContextDrawLinearGradient(context, grad, CGPoint(x: 0, y: 0), CGPoint(x: 0, y: rect.size.height), CGGradientDrawingOptions(rawValue: 0))
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
        var pos = touch.locationInView(self)

        let w = self.frame.size.width
        let h = self.frame.size.height

        pos.x = min(max(pos.x, 0), w)
        pos.y = min(max(pos.y, 0), h)

        saturation = pos.x / w
        brightness = 1 - (pos.y / h)
        updateMarkerPosition()

        pickerDelegate?.colorPicked(self, didPickColor: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0))

        self.setNeedsDisplay()
    }

    private func updateMarkerPosition() {
        let realPos = CGPoint(x: saturation * self.frame.size.width, y: self.frame.size.height - (brightness * self.frame.size.height))
        markerView.center = realPos
    }
}
