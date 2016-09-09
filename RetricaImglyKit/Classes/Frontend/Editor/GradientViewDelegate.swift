//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/**
 The `GradientViewDelegate` protocol defines methods that allow you respond to the events of an instance of `CircleGradientView` or `BoxGradientView`.
 */
@objc(IMGLYGradientViewDelegate) public protocol GradientViewDelegate {
    /**
     Called when the user interaction starts in a gradient view.

     - parameter gradientView: The gradient view that started the user interaction.
     */
    func gradientViewUserInteractionStarted(gradientView: UIView)

    /**
     Called when the user interaction ends in a gradient view.

     - parameter gradientView: The gradient view that ended the user interaction.
     */
    func gradientViewUserInteractionEnded(gradientView: UIView)

    /**
     Called when the control points changed in a gradient view.

     - parameter gradientView: The gradient view of which the control points changed.
     */
    func gradientViewControlPointChanged(gradientView: UIView)
}
