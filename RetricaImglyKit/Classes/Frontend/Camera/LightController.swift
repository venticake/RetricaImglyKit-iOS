//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import AVFoundation

@objc enum LightMode: Int {
    case Off
    case On
    case Auto

    init(flashMode: AVCaptureFlashMode) {
        switch flashMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }

    init(torchMode: AVCaptureTorchMode) {
        switch torchMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

extension AVCaptureFlashMode {
    init(lightMode: LightMode) {
        switch lightMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

extension AVCaptureTorchMode {
    init(lightMode: LightMode) {
        switch lightMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

protocol LightControllable {
    var lightModes: [LightMode] { get set }
    func selectNextLightMode()
    var hasLight: Bool { get }
    var lightMode: LightMode { get }
    var lightAvailable: Bool { get }
}
