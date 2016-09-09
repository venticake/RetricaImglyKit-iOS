//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/// A Slider object is a visual control used to select a single value from a continuous range of
/// values. Sliders are always displayed as horizontal bars. An indicator, or thumb, notes the
/// current value of the slider and can be moved by the user to change the setting.
/// A vertical indicator, or neutral point, notes the default, unchanged value of the slider.
@objc(IMGLYSlider) public class Slider: UIControl {

    // MARK: - Properties

    /// The color used to tint the thumb image. If no color is set, the default `tintColor` will be used.
    public var thumbTintColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// The color used to tint the neutral point image. If no color is set, the default `tintColor` will be used.
    public var neutralPointTintColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// The color used to tint the filled track. If no color is set, the default `tintColor` will be used.
    public var filledTrackColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// The color used to tint the unfilled track.
    public var unfilledTrackColor: UIColor = UIColor(red: 0.72265625, green: 0.72265625, blue: 0.72265625, alpha: 1) {
        didSet {
            updateColors()
        }
    }

    /// Contains the minimum value of the receiver.
    public var minimumValue: CGFloat {
        get {
            return _minimumValue
        }

        set {
            setValue(_value, minValue: newValue, maxValue: _maximumValue, neutralValue: _neutralValue, andSendAction: false)
        }
    }

    /// Contains the maximum value of the receiver.
    public var maximumValue: CGFloat {
        get {
            return _maximumValue
        }

        set {
            setValue(_value, minValue: _minimumValue, maxValue: newValue, neutralValue: _neutralValue, andSendAction: false)
        }
    }

    /// Contains the neutral value of the receiver.
    public var neutralValue: CGFloat {
        get {
            return _neutralValue
        }

        set {
            setValue(_value, minValue: _minimumValue, maxValue: _maximumValue, neutralValue: newValue, andSendAction: false)
        }
    }

    private var _minimumValue: CGFloat
    private var _maximumValue: CGFloat
    private var _neutralValue: CGFloat
    private var _value: CGFloat

    /// Contains the receiver’s current value.
    public var value: CGFloat {
        get {
            return _value
        }

        set {
            setValue(newValue, minValue: _minimumValue, maxValue: _maximumValue, neutralValue: _neutralValue, andSendAction: false)
        }
    }

    // MARK: - Statics

    private static let trackHeight = CGFloat(2)
    private static let neutralPointSize = CGSize(width: 2, height: 10)
    private static let thumbSize = CGSize(width: 16, height: 16)

    // MARK: - Initializers

    /**
     :nodoc:
     */
    override init(frame: CGRect) {
        _minimumValue = -1
        _maximumValue = 1
        _neutralValue = 0
        _value = 0.5

        super.init(frame: frame)

        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        _minimumValue = CGFloat(aDecoder.decodeFloatForKey(CodingKeys.MinimumValue.rawValue))
        _maximumValue = CGFloat(aDecoder.decodeFloatForKey(CodingKeys.MaximumValue.rawValue))
        _neutralValue = CGFloat(aDecoder.decodeFloatForKey(CodingKeys.NeutralValue.rawValue))
        _value = CGFloat(aDecoder.decodeFloatForKey(CodingKeys.Value.rawValue))

        if let thumbTintColor = aDecoder.decodeObjectForKey(CodingKeys.ThumbTintColor.rawValue) as? UIColor {
            self.thumbTintColor = thumbTintColor
        }

        if let neutralPointTintColor = aDecoder.decodeObjectForKey(CodingKeys.NeutralPointTintColor.rawValue) as? UIColor {
            self.neutralPointTintColor = neutralPointTintColor
        }

        if let filledTrackColor = aDecoder.decodeObjectForKey(CodingKeys.FilledTrackTintColor.rawValue) as? UIColor {
            self.filledTrackColor = filledTrackColor
        }

        if let unfilledTrackColor = aDecoder.decodeObjectForKey(CodingKeys.UnfilledTrackTintColor.rawValue) as? UIColor {
            self.unfilledTrackColor = unfilledTrackColor
        }

        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitAdjustable

        if value >= neutralValue {
            let adjustedMaxValue = neutralValue == maximumValue ? minimumValue : maximumValue
            let percentage = (value - neutralValue) / (adjustedMaxValue - neutralValue)
            accessibilityValue = "\(Int(percentage * 100))%"
        } else {
            let adjustedNeutralValue = neutralValue == minimumValue ? maximumValue : minimumValue
            let percentage = 1 - (value - minimumValue) / (neutralValue - adjustedNeutralValue)
            accessibilityValue = "-\(Int(percentage * 100))%"
        }
    }

    // MARK: - Accessibility

    /**
    :nodoc:
    */
    public override func accessibilityIncrement() {
        // Increase by 10%
        let percentage = (value - minimumValue) / (maximumValue - minimumValue) + 0.1
        value = min(maximumValue, percentage * (maximumValue - minimumValue) + minimumValue)
    }

    /**
    :nodoc:
    */
    public override func accessibilityDecrement() {
        // Decrease by 10%
        let percentage = (value - minimumValue) / (maximumValue - minimumValue) - 0.1
        value = max(minimumValue, percentage * (maximumValue - minimumValue) + minimumValue)
    }

    // MARK: - NSCoding

    /**
     :nodoc:
     */
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)

        aCoder.encodeFloat(Float(value), forKey: CodingKeys.Value.rawValue)
        aCoder.encodeFloat(Float(minimumValue), forKey: CodingKeys.MinimumValue.rawValue)
        aCoder.encodeFloat(Float(maximumValue), forKey: CodingKeys.MaximumValue.rawValue)
        aCoder.encodeFloat(Float(neutralValue), forKey: CodingKeys.NeutralValue.rawValue)
        aCoder.encodeObject(neutralPointTintColor, forKey: CodingKeys.NeutralPointTintColor.rawValue)
        aCoder.encodeObject(thumbTintColor, forKey: CodingKeys.ThumbTintColor.rawValue)
        aCoder.encodeObject(unfilledTrackColor, forKey: CodingKeys.UnfilledTrackTintColor.rawValue)
        aCoder.encodeObject(filledTrackColor, forKey: CodingKeys.FilledTrackTintColor.rawValue)
    }

    // MARK: - UIView

    /**
     :nodoc:
     */
    public override func layoutSubviews() {
        if thumbView == nil || neutralView == nil || filledTrackView == nil || unfilledTrackView == nil {
            initSubviews()
        }

        let trackRect = trackRectForBounds(bounds)
        let thumbRect = thumbRectForBounds(bounds, value: _value)
        let neutralPointRect = neutralPointRectForBounds(bounds)

        unfilledTrackView?.frame = trackRect
        thumbView?.frame = thumbRect
        neutralView?.frame = neutralPointRect

        if thumbRect.midX < neutralPointRect.midX {
            let width = neutralPointRect.midX - thumbRect.midX
            let origin = thumbRect.midX
            filledTrackView?.frame = CGRect(x: origin, y: trackRect.origin.y, width: width, height: trackRect.height)
        } else {
            let width = thumbRect.midX - neutralPointRect.midX
            let origin = neutralPointRect.midX
            filledTrackView?.frame = CGRect(x: origin, y: trackRect.origin.y, width: width, height: trackRect.height)
        }

        if neutralValue == minimumValue || neutralValue == maximumValue {
            neutralView?.hidden = true
        } else {
            neutralView?.hidden = false
        }

        super.layoutSubviews()
    }

    /**
     :nodoc:
     */
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
    }

    /**
     :nodoc:
     */
    public override func tintColorDidChange() {
        updateColors()
    }

    // MARK: - Layout

    /**
     Returns the drawing rectangle for the slider’s track.

     - parameter bounds: The bounding rectangle of the receiver.

     - returns: The computed drawing rectangle for the track. This rectangle corresponds to the entire length of the track between the minimum and maximum values.
     */
    public func trackRectForBounds(bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: round((bounds.height - Slider.trackHeight) * 0.5), width: bounds.width, height: Slider.trackHeight).insetBy(dx: 2, dy: 0)
    }

    /**
     Returns the drawing rectangle for the slider’s thumb image.

     - parameter bounds: The bounding rectangle of the receiver.
     - parameter value:  The current value of the slider.

     - returns: The computed drawing rectangle for the thumb image.
     */
    public func thumbRectForBounds(bounds: CGRect, value: CGFloat) -> CGRect {
        var value = value

        if minimumValue > value {
            value = minimumValue
        }

        if value > maximumValue {
            value = maximumValue
        }

        let factor = (value - minimumValue) / (maximumValue - minimumValue)

        return CGRect(origin: CGPoint(x: round((bounds.width - Slider.thumbSize.width) * factor), y: round((bounds.height - Slider.thumbSize.height) * 0.5)), size: Slider.thumbSize)
    }

    /**
     Returns the drawing rectangle of the slider's neutral point image.

     - parameter bounds: The bounding rectangle of the receiver.

     - returns: The computed drawing rectangle for the neutral point image.
     */
    public func neutralPointRectForBounds(bounds: CGRect) -> CGRect {
        let factor = (neutralValue - minimumValue) / (maximumValue - minimumValue)

        return CGRect(origin: CGPoint(x: round((bounds.width - Slider.neutralPointSize.width) * factor), y: round((bounds.height - Slider.neutralPointSize.height) * 0.5)), size: Slider.neutralPointSize)
    }

    // MARK: - NSObject

    /**
     :nodoc:
     */
    public override var description: String {
        var description = super.description
        description.removeAtIndex(description.endIndex.predecessor())
        description.appendContentsOf("; value: \(value)>")
        return description
    }

    // MARK: - Initialization

    private var thumbView: UIView?
    private var neutralView: UIView?
    private var unfilledTrackView: UIView?
    private var filledTrackView: UIView?

    private func initSubviews() {
        if unfilledTrackView == nil {
            let unfilledTrackView = UIView()
            unfilledTrackView.userInteractionEnabled = false
            self.unfilledTrackView = unfilledTrackView
            addSubview(unfilledTrackView)
        }

        if filledTrackView == nil {
            let filledTrackView = UIView()
            filledTrackView.userInteractionEnabled = false
            self.filledTrackView = filledTrackView
            addSubview(filledTrackView)
        }

        if thumbView == nil {
            let image = UIImage(named: "knob", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
            let thumbView = UIImageView(image: image)
            thumbView.userInteractionEnabled = false
            self.thumbView = thumbView
            addSubview(thumbView)
        }

        if neutralView == nil {
            let neutralView = UIView()
            neutralView.userInteractionEnabled = false
            self.neutralView = neutralView
            addSubview(neutralView)
        }

        updateColors()
    }

    private func updateColors() {
        unfilledTrackView?.backgroundColor = unfilledTrackColor
        filledTrackView?.backgroundColor = filledTrackColor ?? tintColor
        thumbView?.tintColor = thumbTintColor ?? tintColor
        neutralView?.backgroundColor = neutralPointTintColor ?? tintColor
    }

    // MARK: - Private Types

    private enum CodingKeys: String {
        case Value = "SliderValue"
        case MinimumValue = "SliderMinimumValue"
        case MaximumValue = "SliderMaximumValue"
        case NeutralValue = "SliderNeutralValue"
        case UnfilledTrackTintColor = "SliderUnfilledTrackTintColor"
        case FilledTrackTintColor = "SliderFilledTrackTintColor"
        case ThumbTintColor = "SliderThumbTintColor"
        case NeutralPointTintColor = "SliderNeutralPointTintColor"
    }

    // MARK: - UIView

    /**
    :nodoc:
    */
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let hitTestBounds = bounds.insetBy(dx: -20, dy: 0)
        return hitTestBounds.contains(point)
    }

    // MARK: - UIResponder

    private var thumbHitEdgeInsets: UIEdgeInsets {
        guard let thumbView = thumbView else {
            return UIEdgeInsetsZero
        }

        var horizontalDelta = (48 - thumbView.bounds.width) * 0.5
        var verticalDelta = (48 - thumbView.bounds.height) * 0.5

        if horizontalDelta > 0 {
            horizontalDelta = horizontalDelta * -1
        } else {
            horizontalDelta = 0
        }

        if verticalDelta > 0 {
            verticalDelta = verticalDelta * -1
        } else {
            verticalDelta = 0
        }

        return UIEdgeInsets(top: verticalDelta, left: horizontalDelta, bottom: verticalDelta, right: horizontalDelta)
    }

    private var hitOffset: CGFloat?

    private func valueForPoint(point: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> CGFloat {
        let trackRect = trackRectForBounds(self.bounds)

        // Build time optimization, should use `hitOffset ?? 0`
        let offset: CGFloat

        if let hitoffSet = hitOffset {
            offset = hitoffSet
        } else {
            offset = 0
        }

        var value = (maxValue - minValue) * (point + offset - trackRect.origin.x)
        value = value / trackRect.size.width
        value = value + minValue

        if value < minValue {
            return minValue
        } else if maxValue < value {
            return maxValue
        } else {
            // Snap to neutral value if very close to it
            let range = abs(minimumValue) + abs(maximumValue)
            let snapRange = range * 0.01

            if value >= neutralValue - snapRange && value <= neutralValue + snapRange {
                value = neutralValue
            }

            return value
        }
    }

    /**
     :nodoc:
     */
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        guard let thumbView = thumbView else {
            return false
        }

        let point = touch.locationInView(self)
        let pointInThumb = thumbView.convertPoint(point, fromView: self)
        let insets = thumbHitEdgeInsets

        let hitTestBounds = CGRect(x: thumbView.bounds.origin.x + insets.left, y: thumbView.bounds.origin.y + insets.top, width: thumbView.bounds.size.width - insets.left - insets.right, height: thumbView.bounds.size.height - insets.top - insets.bottom)

        hitTestBounds

        if hitTestBounds.contains(pointInThumb) {
            let thumbFrame = thumbView.frame
            hitOffset = round(thumbFrame.width * 0.5 - pointInThumb.x)
            value = valueForPoint(point.x, minValue: minimumValue, maxValue: maximumValue)

            sendActionsForControlEvents(.ValueChanged)

            return true
        }

        return false
    }

    /**
     :nodoc:
     */
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let point = touch.locationInView(self)
        value = valueForPoint(point.x, minValue: minimumValue, maxValue: maximumValue)

        sendActionsForControlEvents(.ValueChanged)

        highlighted = true
        return true
    }

    /**
     :nodoc:
     */
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let touch = touch {
            let point = touch.locationInView(self)
            value = valueForPoint(point.x, minValue: minimumValue, maxValue: maximumValue)
            super.endTrackingWithTouch(touch, withEvent: event)
            sendActionsForControlEvents(.ValueChanged)
        } else {
            super.endTrackingWithTouch(touch, withEvent: event)
        }

        highlighted = false
    }

    // MARK: - Value

    internal func setValue(value: CGFloat, minValue: CGFloat, maxValue: CGFloat, neutralValue: CGFloat, andSendAction sendAction: Bool) {
        precondition(minValue <= maxValue, "Attempting to set a slider's minimumValue (\(minValue)) to be larger than the maximumValue (\(maxValue))")
        precondition(minValue <= neutralValue && neutralValue <= maxValue, "Attempting to set a slider's neutralValue (\(neutralValue)) to be smaller than the minimumValue (\(minimumValue)) or larger than the maximumValue (\(maximumValue))")

        let currentValue = min(max(value, minValue), maxValue)

        if _value != currentValue || _minimumValue != minValue || _maximumValue != maxValue || _neutralValue != neutralValue {
            self._value = value
            self._minimumValue = minValue
            self._maximumValue = maxValue
            self._neutralValue = neutralValue
            setNeedsLayout()

            // Accessibility
            if value >= neutralValue {
                let adjustedMaxValue = neutralValue == maximumValue ? minimumValue : maximumValue
                let percentage = (value - neutralValue) / (adjustedMaxValue - neutralValue)
                accessibilityValue = "\(Int(percentage * 100))%"
            } else {
                let adjustedNeutralValue = neutralValue == minimumValue ? maximumValue : minimumValue
                let percentage = 1 - (value - minimumValue) / (neutralValue - adjustedNeutralValue)
                accessibilityValue = "-\(Int(percentage * 100))%"
            }
        }

        if sendAction {
            sendActionsForControlEvents(.ValueChanged)
        }
    }
}
