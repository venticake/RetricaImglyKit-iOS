//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

@objc private class UndoBlockInvocation: NSObject {
    weak var target: AnyObject?
    let handler: (AnyObject) -> Void

    init(target: AnyObject, handler: (AnyObject) -> Void) {
        self.target = target
        self.handler = handler
        super.init()
    }

    @objc private func invoke() {
        guard let target = target else {
            return
        }

        handler(target)
    }
}

extension NSUndoManager {
    func registerUndoForTarget<TargetType: AnyObject>(target: TargetType, handler: (TargetType) -> Void) {
        if #available(iOS 9, *) {
            registerUndoWithTarget(target, handler: handler)
        } else {
            let objcCompatibleHandler: (AnyObject) -> Void = { internalTarget in
                // swiftlint:disable force_cast
                handler(internalTarget as! TargetType)
                // swiftlint:enable force_cast
            }

            let block = UndoBlockInvocation(target: target, handler: objcCompatibleHandler)
            registerUndoWithTarget(block, selector: #selector(UndoBlockInvocation.invoke), object: block)
        }
    }

    func undoAll() {
        while canUndo {
            undo()
        }
    }

    func undoAllAndClear() {
        undoAll()
        removeAllActions()
    }
}
