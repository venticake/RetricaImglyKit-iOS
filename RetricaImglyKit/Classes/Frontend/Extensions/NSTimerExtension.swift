//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

// Taken from https://github.com/radex/SwiftyTimer

private class NSTimerActor {
    var block: () -> ()

    init(_ block: () -> ()) {
        self.block = block
    }

    @objc func fire() {
        block()
    }
}

extension NSTimer {
    class func new(after interval: NSTimeInterval, _ block: () -> ()) -> NSTimer {
        return new(after: interval, repeats: false, block)
    }

    class func new(after interval: NSTimeInterval, repeats: Bool, _ block: () -> ()) -> NSTimer {
        let actor = NSTimerActor(block)
        return self.init(timeInterval: interval, target: actor, selector: #selector(NSTimerActor.fire), userInfo: nil, repeats: repeats)
    }

    class func after(interval: NSTimeInterval, _ block: () -> ()) -> NSTimer {
        let timer = NSTimer.new(after: interval, block)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        return timer
    }

    class func after(interval: NSTimeInterval, repeats: Bool, _ block: () -> ()) -> NSTimer {
        let timer = NSTimer.new(after: interval, repeats: repeats, block)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        return timer
    }
}
