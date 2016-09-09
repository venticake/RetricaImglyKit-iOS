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
 *  A `ProgressView` is an activity indicator that is shown on top of all other views in a HUD style
 *  and temporarily blocks all user interaction with other views.
 */
@available(iOS 8, *)
@objc(IMGLYProgressView) public class ProgressView: NSObject {
    /// The main container view of the progress view.
    public var overlayView = UIView(frame: CGRect(x: 0, y: 0, width: 202, height: 200))

    /// The background view that is being animated in.
    public var backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 202, height: 142))

    /// The image view that holds the spinner.
    public var imageView = UIImageView(frame: CGRect(x: 101 - 22, y: 29, width: 44, height: 44))

    /// The label that contains the loading message.
    public var label = UILabel(frame:  CGRect(x: 0, y: 82, width: 202, height: 44))

    /// The duration of one rotation of the spinner.
    public var animationDuration = 0.3

    /// The text that should be displayed in the progress view.
    public var text: String {
        get {
            return label.text!
        }
        set {
            label.text = newValue
        }
    }

    private var keepRotating = true

    /// A shared instance for convenience.
    public static let sharedView = ProgressView()

    /**
     :nodoc:
     */
    public override init() {
        super.init()
        commonInit()
    }

    private func commonInit() {
        overlayView.addSubview(backgroundView)
        configureBackground()
        imageView.image = UIImage(named: "imgly_spinner", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)
        configureLabel()
        backgroundView.transform = CGAffineTransformMakeScale(3, 3)
        backgroundView.alpha = 0.0
     }

    private func configureBackground() {
        backgroundView.addSubview(imageView)
        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 4
    }

    private func configureLabel() {
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        label.text = ""
        backgroundView.addSubview(label)
    }

    /**
     Presents the activity indicator with the given message.

     - parameter message: The message to present.
     */
    public func showWithMessage(message: String) {
        text = message
        if overlayView.superview == nil {
            addOverlayViewToWindow()
            updateOverlayFrame()
        }
        startAnimation()
        UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
            self.backgroundView.alpha = 1
            self.backgroundView.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }

    /**
     Hides the activity indicator.
     */
    public func hide() {
        UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
            self.backgroundView.alpha = 0
            self.backgroundView.transform = CGAffineTransformMakeScale(3, 3)
            }, completion: { finished in
                if finished {
                    self.stopAnimation()
                    self.overlayView.removeFromSuperview()
                }
            })
    }

    private func addOverlayViewToWindow() {
        let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.mainScreen()
            let windowIsVisible = !window.hidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal

            if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                window.addSubview(overlayView)
                break
            }
        }
    }

    private func updateOverlayFrame() {
        overlayView.frame = UIScreen.mainScreen().bounds
        let center = CGPoint(x:overlayView.frame.size.width * 0.5, y:overlayView.frame.size.height * 0.4)
        backgroundView.center = center
    }

    private func startAnimation() {
        keepRotating = true
        keepAnimating()
    }

    private func keepAnimating() {
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, CGFloat(M_PI_2))
            }) { (finished) -> Void in
                if finished {
                    if self.keepRotating {
                        self.keepAnimating()
                    }
                }
        }
    }
    private func stopAnimation() {
        keepRotating = false
    }
}
