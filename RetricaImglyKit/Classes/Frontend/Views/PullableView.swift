//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt
import UIKit
import AVFoundation

@objc(IMGLYPullableViewDelegate) protocol PullableViewDelegate {
    func pullableView(pView: PullableView, didChangeState opend: Bool)
}

class PullableView: UIView, UIGestureRecognizerDelegate {
    var marginConstraint: NSLayoutConstraint?
    var openedMargin = CGFloat(0)
    var closedMargin = CGFloat(800)
    var handleView = UIView()
    var opened = false
    var handleColor = UIColor.whiteColor() {
        didSet {
            gripView.backgroundColor = handleColor
        }
    }

    var handleBackgroundColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1) {
        didSet {
            handleView.backgroundColor = handleBackgroundColor
        }
    }

    let handleHeight = CGFloat(26)

    private var dragRecognizer = UIPanGestureRecognizer()
    private var handleDragRecognizer = UIPanGestureRecognizer()
    private var tapRecognizer = UITapGestureRecognizer()
    private var startPos = CGPoint(x: 0, y: 0)
    private var minPos = CGFloat(0)
    private var maxPos = CGFloat(0)
    private let gripHeight = CGFloat(4)
    private let gripWidth = CGFloat(40)
    private var gripView = UIView()

    var toggleOnTap: Bool {
        set {
            tapRecognizer.enabled = newValue
        }
        get {
            return tapRecognizer.enabled
        }
    }
    var animate = true
    var animationDuration: Double = 0.0

    /// The receiver’s delegate.
    /// - seealso: `PullableViewDelegate`.
    weak var delegate: PullableViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func commonInit() {
        animate = true
        animationDuration = 0.2
        toggleOnTap = true
        configureHandleView()
        // Creates the handle view. Subclasses should resize, reposition and style this view
        dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PullableView.handleDrag(_:)))
        dragRecognizer.minimumNumberOfTouches = 1
        dragRecognizer.maximumNumberOfTouches = 1
        dragRecognizer.delegate = self
        self.addGestureRecognizer(dragRecognizer)

        handleDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PullableView.handleDrag(_:)))
        handleDragRecognizer.minimumNumberOfTouches = 1
        handleDragRecognizer.maximumNumberOfTouches = 1
        handleView.addGestureRecognizer(handleDragRecognizer)

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PullableView.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        handleView.addGestureRecognizer(tapRecognizer)
        opened = false
    }

    private func configureHandleView() {
        handleView = UIView(frame: CGRect(x:0, y:0, width:frame.size.width, height:handleHeight))
        handleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(handleView)

        gripView.backgroundColor = handleColor
        gripView.translatesAutoresizingMaskIntoConstraints = false
        gripView.layer.cornerRadius = 2

        handleView.addSubview(gripView)
        handleView.backgroundColor = handleBackgroundColor

        let views = [
            "handleView" : handleView,
            "gripView" : gripView
        ]

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[handleView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[handleView(==\(handleHeight))]", options: [], metrics: nil, views: views))

        handleView.addConstraint(NSLayoutConstraint(item: handleView, attribute: .CenterX, relatedBy: .Equal, toItem: gripView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        handleView.addConstraint(NSLayoutConstraint(item: handleView, attribute: .CenterY, relatedBy: .Equal, toItem: gripView, attribute: .CenterY, multiplier: 1.0, constant: 0))

        handleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[gripView(==\(gripWidth))]", options: [], metrics: nil, views: views))
        handleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[gripView(==\(gripHeight))]", options: [], metrics: nil, views: views))
    }

    @objc func handleDrag(sender: UIPanGestureRecognizer) {
        guard let marginConstraint = self.marginConstraint else {
            return
        }

        if sender.state == .Began {
            startPos = CGPoint(x: self.center.x, y: marginConstraint.constant)
            minPos = closedMargin < openedMargin ? closedMargin : openedMargin
            maxPos = closedMargin > openedMargin ? closedMargin : openedMargin

        } else if sender.state == .Changed {
            var translate: CGPoint = sender.translationInView(self.superview)
            var newPos = CGPoint(x: startPos.x, y: startPos.y + translate.y)
            if newPos.y < minPos {
                newPos.y = minPos
                translate = CGPoint(x: 0, y: newPos.y - startPos.y)
            }
            if newPos.y > maxPos {
                newPos.y = maxPos
                translate = CGPoint(x: 0, y: newPos.y - startPos.y)
            }
        sender.setTranslation(translate, inView: self.superview)
            marginConstraint.constant = newPos.y
        } else if sender.state == .Ended {
            // Gets the velocity of the gesture in the axis, so it can be
            // determined to which endpoint the state should be set.
            let vectorVelocity = sender.velocityInView(self.superview)
            let axisVelocity = vectorVelocity.y
            let target = axisVelocity < 0 ? minPos : maxPos
            let opened = target == openedMargin
            self.setOpened(opened, animated: animate)
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.setOpened(!opened, animated: animate)
        }
    }

    func setOpened(opened: Bool, animated anim: Bool) {
        guard let marginConstraint = self.marginConstraint else {
            return
        }
        self.opened = opened
        // For the duration of the animation, no further interaction with the view is permitted
        dragRecognizer.enabled = false
        tapRecognizer.enabled = false
        marginConstraint.constant = opened ? self.openedMargin : self.closedMargin
        self.needsUpdateConstraints()
        UIView.animateWithDuration(animationDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    // Restores interaction after the animation is over
                    self.dragRecognizer.enabled = true
                    self.tapRecognizer.enabled = true
                    self.delegate?.pullableView(self, didChangeState: self.opened)
                }
        })
    }

    @objc override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.locationInView(self)
        let target = self.hitTest(location, withEvent: nil)
        if let target = target {
            if !target.isKindOfClass(ColorPickerView) && !target.isKindOfClass(FontSelectorView) && target != handleView {
                return false
            }
        }
        return true
    }

}
