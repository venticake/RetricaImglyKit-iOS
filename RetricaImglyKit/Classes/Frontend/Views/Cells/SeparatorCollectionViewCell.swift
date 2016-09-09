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
 *  A `SeparatorCollectionViewCell` is a cell that shows a single 1 pt wide vertical line. It is
 *  usually used to represent a seperator between other cells.
 */
@available(iOS 8, *)
@objc(IMGLYSeparatorCollectionViewCell) public class SeparatorCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    /// A vertical line 1 pt wide line in the center of the cell.
    public let separator = UIView()

    // MARK: - Initializers

    /**
    :nodoc:
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = false
        contentView.addSubview(separator)

        separator.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: separator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 16))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -16))

        NSLayoutConstraint.activateConstraints(constraints)
    }
}
