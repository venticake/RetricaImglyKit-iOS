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
import Photos
import MobileCoreServices

/// The `RecordingMode` determins if a photo or a video should be recorded.
@available(iOS 8, *)
@objc public enum RecordingMode: Int {
    /// Record a Photo.
    case Photo
    /// Record a Video.
    case Video

    var bundle: NSBundle {
        return NSBundle.imglyKitBundle
    }

    var titleForSelectionButton: String {
        switch self {
        case .Photo:
            return Localize("PHOTO")
        case .Video:
            return Localize("VIDEO")
        }
    }

    var selectionButton: UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(titleForSelectionButton, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(red:1, green:0.8, blue:0, alpha:1), forState: .Selected)
        return button
    }

    var actionButton: UIControl {
        switch self {
        case .Photo:
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: "LensAperture_ShapeLayer_00000", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            button.imageView?.animationImages = [UIImage]()
            button.imageView?.animationRepeatCount = 1
            button.adjustsImageWhenHighlighted = false

            for index in 0 ..< 10 {
                let image = String(format: "LensAperture_ShapeLayer_%05d", index)
                button.imageView?.animationImages?.append(UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection:nil)!)
            }

            button.accessibilityLabel = Localize("Take picture")

            return button
        case .Video:
            let button = VideoRecordButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
    }

    var actionSelector: Selector {
        switch self {
        case .Photo:
            return #selector(CameraViewController.takePhoto(_:))
        case .Video:
            return #selector(CameraViewController.recordVideo(_:))
        }
    }

    var sessionPreset: String {
        switch self {
        case .Photo:
            return AVCaptureSessionPresetPhoto
        case .Video:
            return AVCaptureSessionPresetHigh
        }
    }
}
