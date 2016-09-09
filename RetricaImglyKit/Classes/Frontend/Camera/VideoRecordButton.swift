//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/// A `VideoRecordButton` is a button that can be used to start a video recording. It animates between
/// a 'Start recording' and a 'Stop recording' state.
@available(iOS 8, *)
public final class VideoRecordButton: UIControl {

    // MARK: - Properties

    static let lineWidth = CGFloat(2)
    static let recordingColor = UIColor(red: 0.94, green: 0.27, blue: 0.25, alpha: 1)

    /// Whether or not the button is currently in recording mode.
    public var recording = false {
        didSet {
            updateInnerLayer()
        }
    }

    private lazy var outerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.whiteColor().CGColor
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
        }()

    private lazy var innerLayer: ShapeLayer = {
        let layer = ShapeLayer()
        layer.fillColor = recordingColor.CGColor
        return layer
        }()

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
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)

        isAccessibilityElement = true
        accessibilityLabel = Localize("Record video")
    }

    // MARK: - Helpers

    private func updateOuterLayer() {
        let outerRect = bounds.insetBy(dx: VideoRecordButton.lineWidth, dy: VideoRecordButton.lineWidth)
        outerLayer.frame = bounds
        outerLayer.path = UIBezierPath(ovalInRect: outerRect).CGPath
    }

    private func updateInnerLayer() {
        if recording {
            let innerRect = bounds.insetBy(dx: 0.3 * bounds.size.width, dy: 0.3 * bounds.size.height)
            innerLayer.frame = bounds
            innerLayer.path = UIBezierPath(roundedRect: innerRect, cornerRadius: 4).CGPath
        } else {
            let innerRect = bounds.insetBy(dx: VideoRecordButton.lineWidth * 2.5, dy: VideoRecordButton.lineWidth * 2.5)
            innerLayer.frame = bounds
            innerLayer.path = UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.size.width / 2).CGPath
        }
    }

    // MARK: - UIView

    /**
    :nodoc:
    */
    override public func layoutSubviews() {
        super.layoutSubviews()

        updateOuterLayer()
        updateInnerLayer()
    }

    // MARK: - UIControl

    /**
    :nodoc:
    */
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        if !innerLayer.containsPoint(location) {
            return false
        }

        innerLayer.fillColor = VideoRecordButton.recordingColor.colorWithAlphaComponent(0.3).CGColor
        return true
    }

    /**
     :nodoc:
     */
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if recording {
            accessibilityLabel = Localize("Stop recording video")
        } else {
            accessibilityLabel = Localize("Record video")
        }

        recording = !recording
        innerLayer.fillColor = VideoRecordButton.recordingColor.CGColor
    }

    /**
     :nodoc:
     */
    public override func cancelTrackingWithEvent(event: UIEvent?) {
        innerLayer.fillColor = VideoRecordButton.recordingColor.CGColor
    }
}
