//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/// A SliderTooltip object is a visual element that displays a Slider's current value above the
/// thumb image while dragging.
public class SliderTooltip: UIView {

    // MARK: - Properties

    /// The background color of the tooltip.
    public var tooltipColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.8) {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The string to display in the tooltip.
    public var attributedString: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Intitializers

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
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = false
        opaque = false
    }

    // MARK: - UIView

    /**
    :nodoc:
    */
    override public func drawRect(rect: CGRect) {
        tooltipColor.setFill()

        let triangleHeight = CGFloat(10)
        let triangleWidth = CGFloat(20)

        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: bounds.minX, y: bounds.minY))
        bezierPath.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.minY))
        bezierPath.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.maxY - triangleHeight))
        bezierPath.addLineToPoint(CGPoint(x: bounds.maxX - round((bounds.width - triangleWidth) / 2), y: bounds.maxY - triangleHeight))
        bezierPath.addLineToPoint(CGPoint(x: bounds.midX, y: bounds.maxY))
        bezierPath.addLineToPoint(CGPoint(x: bounds.minX + round((bounds.width - triangleWidth) / 2), y: bounds.maxY - triangleHeight))
        bezierPath.addLineToPoint(CGPoint(x: bounds.minX, y: bounds.maxY - triangleHeight))
        bezierPath.closePath()
        bezierPath.fill()

        let stringSize = attributedString?.size() ?? .zero
        attributedString?.drawInRect(CGRect(origin: CGPoint(x: bounds.midX - stringSize.width / 2, y: bounds.midY - (stringSize.height + triangleHeight) / 2), size: stringSize).integral)

    }

    /**
    :nodoc:
    */
    public override func intrinsicContentSize() -> CGSize {
        let textSize = attributedString?.size() ?? .zero
        let insets = UIEdgeInsets(top: -4, left: -8, bottom: -18, right: -8)
        return CGSize(width: ceil(textSize.width - insets.left - insets.right), height: ceil(textSize.height - insets.top - insets.bottom))
    }
}
