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
 *  A `ColorCollectionViewCell` is a cell that shows a solid color and an image view on top of that color when the cell
 *  is selected. It also has a `selectionIndicator` to show whether or not the cell is currently selected.
 */
@objc(IMGLYColorCollectionViewCell) public class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    /// A view that represents a solid color.
    public let colorView = UIView()

    /// An image view that is above the solid color and only visible when the cell is selected.
    public let imageView = UIImageView()

    /// A selection indicator at the bottom of the cell.
    public let selectionIndicator = UIView()

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
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitButton

        var constraints = [NSLayoutConstraint]()

        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 1
        colorView.clipsToBounds = true
        constraints.append(NSLayoutConstraint(item: colorView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: colorView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: colorView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: colorView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -8))

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.hidden = true
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))

        contentView.addSubview(selectionIndicator)
        selectionIndicator.hidden = true
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.backgroundColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2))

        NSLayoutConstraint.activateConstraints(constraints)
    }

    // MARK: - UICollectionViewCell

    /**
    :nodoc:
    */
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    /// :nodoc:
    public override var selected: Bool {
        didSet {
            selectionIndicator.hidden = !selected
            imageView.hidden = !selected
        }
    }

    /// :nodoc:
    public override var highlighted: Bool {
        didSet {
            selectionIndicator.hidden = !highlighted
            imageView.hidden = !highlighted
        }
    }
}
