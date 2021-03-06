//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt
//  based on https://github.com/jawngee/ILColorPicker

import UIKit

/**
 The `ColorPickerViewDelegate` protocol defines a set of optional methods you can use to receive value-change messages for ColorPickerViewDelegate objects.
 */
@available(iOS 8, *)
@objc(IMGLYColorPickerViewDelegate) public protocol ColorPickerViewDelegate {
    /**
     Is called when a color has been picked.

     - parameter colorPickerView: The sender of the event.
     - parameter color:           The picked color value.
     */
    func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor)
    /**
     Is called when the picking process has been cancled.

     - parameter colorPickerView: The sender of the event.
     */
    func canceledColorPicking(colorPickerView: ColorPickerView)
}

/**
 The `ColorPickerView` class provides a class that is used to pick colors.
 It contains three elements. A hue-picker, a brightness-saturation-picker and a preview of the picked color.
 */
@available(iOS 8, *)
@objc(IMGLYColorPickerView) public class ColorPickerView: UIView {

    /// The receiver’s delegate.
    /// - seealso: `ColorPickerViewDelegate`.
    public weak var pickerDelegate: ColorPickerViewDelegate?

    /// The currently selected color.
    public var color = UIColor.blackColor() {
        didSet {
            huePickerView.color = color
            alphaPickerView.color = color
            saturationBrightnessPickerView.color = color
        }
    }

    /// The initial set color.
    public var initialColor = UIColor.blackColor() {
        didSet {
            color = initialColor
        }
    }

    private var saturationBrightnessPickerView = SaturationBrightnessPickerView()
    private var huePickerView = HuePickerView()
    private var alphaPickerView = AlphaPickerView()
    private var leftMostSpacer = UIView()
    private var leftSpacer = UIView()
    private var rightSpacer = UIView()
    private var rightMostSpacer = UIView()

    // MARK: - init

    /**
    :nodoc:
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
        configureSaturationBrightnessPicker()
        configureHuePickView()
        configureAlphaPickerView()
        configureSpacers()
        configureConstraints()
    }

    // MARK: - configuration

    private func configureSaturationBrightnessPicker() {
        self.addSubview(saturationBrightnessPickerView)
        saturationBrightnessPickerView.translatesAutoresizingMaskIntoConstraints = false
        saturationBrightnessPickerView.pickerDelegate = self
    }

    private func configureHuePickView() {
        self.addSubview(huePickerView)
        huePickerView.translatesAutoresizingMaskIntoConstraints = false
        huePickerView.pickerDelegate = self
    }

    private func configureAlphaPickerView() {
        self.addSubview(alphaPickerView)
        alphaPickerView.translatesAutoresizingMaskIntoConstraints = false
        alphaPickerView.pickerDelegate = self
    }

    private func configureSpacers() {
        leftMostSpacer.translatesAutoresizingMaskIntoConstraints = false
        leftSpacer.translatesAutoresizingMaskIntoConstraints = false
        rightSpacer.translatesAutoresizingMaskIntoConstraints = false
        rightMostSpacer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(leftMostSpacer)
        self.addSubview(leftSpacer)
        self.addSubview(rightSpacer)
        self.addSubview(rightMostSpacer)
    }

    private func configureConstraints() {
        let views = [
            "saturationBrightnessPickerView" : saturationBrightnessPickerView,
            "huePickerView" : huePickerView,
            "alphaPickerView" : alphaPickerView,
            "leftMostSpacer" : leftMostSpacer,
            "leftSpacer" : leftSpacer,
            "rightSpacer" : rightSpacer,
            "rightMostSpacer" : rightMostSpacer
        ]

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[saturationBrightnessPickerView(256)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[huePickerView(256)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[alphaPickerView(256)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[leftMostSpacer(1)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[leftSpacer(1)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[rightSpacer(1)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[rightMostSpacer(1)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[leftMostSpacer]-[huePickerView(20)]-[leftSpacer]-[saturationBrightnessPickerView(256)]-[rightSpacer]-[alphaPickerView(20)]-[rightMostSpacer]-|", options: [], metrics: nil, views: views))

        self.addConstraint(NSLayoutConstraint(item: leftMostSpacer, attribute: .Width, relatedBy: .Equal, toItem: leftSpacer, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: leftSpacer, attribute: .Width, relatedBy: .Equal, toItem: rightSpacer, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: rightSpacer, attribute: .Width, relatedBy: .Equal, toItem: rightMostSpacer, attribute: .Width, multiplier: 1.0, constant: 0))
    }
}

@available(iOS 8, *)
extension ColorPickerView: SaturationBrightnessPickerViewDelegate {
    /**
     :nodoc:
     */
    public func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor) {
        let alpha = alphaPickerView.alphaValue
        let colorWithAlpha = color.colorWithAlphaComponent(alpha)
        alphaPickerView.color = colorWithAlpha
        pickerDelegate?.colorPicked(self, didPickColor: colorWithAlpha)
    }
}

@available(iOS 8, *)
extension ColorPickerView: HuePickerViewDelegate {
    /**
     :nodoc:
     */
    public func huePicked(huePickerView: HuePickerView, hue: CGFloat) {
        saturationBrightnessPickerView.hue = hue
        let color = saturationBrightnessPickerView.color
        let alpha = alphaPickerView.alphaValue
        let colorWithAlpha = color.colorWithAlphaComponent(alpha)
        alphaPickerView.color = colorWithAlpha
        pickerDelegate?.colorPicked(self, didPickColor: colorWithAlpha)
    }
}

@available(iOS 8, *)
extension ColorPickerView: AlphaPickerViewDelegate {
    /**
     :nodoc:
     */
    public func alphaPicked(alphaPickerView: AlphaPickerView, alpha: CGFloat) {
        let color = saturationBrightnessPickerView.color
        pickerDelegate?.colorPicked(self, didPickColor: color.colorWithAlphaComponent(alpha))
    }
}
