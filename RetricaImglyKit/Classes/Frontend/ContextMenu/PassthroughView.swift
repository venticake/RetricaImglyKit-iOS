//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

internal class PassthroughView: UIView {

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }

    // MARK: - Properties

    internal var passthroughViews = [UIView]()

    // MARK: - UIView

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)

        if hitView == self {
            for passthroughView in passthroughViews {
                hitView = passthroughView.hitTest(convertPoint(point, toView: passthroughView), withEvent: event)

                if hitView != nil {
                    break
                }
            }
        }

        return hitView
    }

}
