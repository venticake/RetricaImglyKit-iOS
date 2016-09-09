//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import AVFoundation

@available(iOS 8, *)
extension AVCaptureDevice {
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition? = nil) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devicesWithMediaType(mediaType) as? [AVCaptureDevice] else {
            return nil
        }

        for device in devices where device.position == position {
            return device
        }

        return devices.first
    }
}
