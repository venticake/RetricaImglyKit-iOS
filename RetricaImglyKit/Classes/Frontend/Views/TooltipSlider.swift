//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/// A TooltipSlider object is a visual control used to select a single value from a continuous range of
/// values. Sliders are always displayed as horizontal bars. An indicator, or thumb, notes the
/// current value of the slider and can be moved by the user to change the setting.
/// A vertical indicator, or neutral point, notes the default, unchanged value of the slider.
/// Additionally a `TooltipSlider` also presents a tooltip above the thumb image that displays the current
/// selected value while dragging.
public class TooltipSlider: Slider {

    // MARK: - Properties

    /// The tooltip that is displayed above the thumb image.
    public let tooltip = SliderTooltip()

    // MARK: - Initializers

    /**
    :nodoc:
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
    }

    /**
    :nodoc:
    */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = false
    }

    // MARK: - UIView

    /**
    :nodoc:
    */
    public override func layoutSubviews() {
        if tooltip.superview == nil {
            tooltip.alpha = 0
            tooltip.hidden = true
            addSubview(tooltip)
        }

        let thumbRect = thumbRectForBounds(bounds, value: value)
        tooltip.frame.size = tooltip.intrinsicContentSize()
        tooltip.center = CGPoint(x: thumbRect.midX, y: 0)
        tooltip.frame.origin.y = -tooltip.frame.size.height

        super.layoutSubviews()
    }

    /**
    :nodoc:
    */
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let begin = super.beginTrackingWithTouch(touch, withEvent: event)

        if begin && tooltip.hidden == true {
            tooltip.hidden = false
            UIView.animateWithDuration(0.25) {
                self.tooltip.alpha = 1
            }
        }

        return begin
    }

    /**
    :nodoc:
    */
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if tooltip.hidden == false {
            UIView.animateWithDuration(0.25, animations: {
                self.tooltip.alpha = 0
            }) { _ in
                self.tooltip.hidden = true
            }
        }
    }

    // MARK: - Value

    override func setValue(value: CGFloat, minValue: CGFloat, maxValue: CGFloat, neutralValue: CGFloat, andSendAction sendAction: Bool) {
        super.setValue(value, minValue: minValue, maxValue: maxValue, neutralValue: neutralValue, andSendAction: sendAction)

        if value >= neutralValue {
            let adjustedMaxValue = neutralValue == maximumValue ? minimumValue : maximumValue
            let percentage = (value - neutralValue) / (adjustedMaxValue - neutralValue)
            tooltip.attributedString = NSAttributedString(string: "\(Int(percentage * 100))%", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(16), NSKernAttributeName: 0.7])
        } else {
            let adjustedNeutralValue = neutralValue == minimumValue ? maximumValue : minimumValue
            let percentage = 1 - (value - minimumValue) / (neutralValue - adjustedNeutralValue)
            tooltip.attributedString = NSAttributedString(string: "-\(Int(percentage * 100))%", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(16), NSKernAttributeName: 0.7])
        }
    }
}
