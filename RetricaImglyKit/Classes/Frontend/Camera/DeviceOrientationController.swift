//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import CoreMotion
import AVFoundation

/**
 Used to determine device orientation even if orientation lock is active.
 */
@objc(IMGLYDeviceOrientationController) public class DeviceOrientationController: NSObject {

    // MARK: - Properties

    private let motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        return motionManager
    }()

    private let motionManagerQueue = NSOperationQueue()
    private var started = false

    /// Use this to get the current capture orientation.
    public private(set) var captureVideoOrientation: AVCaptureVideoOrientation?

    // MARK: - Public API

    /**
    Starts to observe the accelerometer to update the capture video orientation.
    This needs to be done, to capture with the correct device orientation.
    */
    public func start() {
        if started {
            return
        }

        motionManager.startAccelerometerUpdatesToQueue(motionManagerQueue, withHandler: { accelerometerData, _ in
            guard let accelerometerData = accelerometerData else {
                return
            }

            if abs(accelerometerData.acceleration.y) < abs(accelerometerData.acceleration.x) {
                if accelerometerData.acceleration.x > 0 {
                    self.captureVideoOrientation = .LandscapeLeft
                } else {
                    self.captureVideoOrientation = .LandscapeRight
                }
            } else {
                if accelerometerData.acceleration.y > 0 {
                    self.captureVideoOrientation = .PortraitUpsideDown
                } else {
                    self.captureVideoOrientation = .Portrait
                }
            }
        })

        started = true
    }

    /**
     Stops observing the acceleronmenter.
     */
    public func stop() {
        if !started {
            return
        }

        motionManager.stopAccelerometerUpdates()
        started = false
    }
}
