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
 *  An `IconCaptionCollectionViewCell` is a cell that shows an icon, a label and a `selectionIndicator`
 *  when the cell is selected.
 */
@objc(IMGLYIconCaptionCollectionViewCell) public class IconCaptionCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    /// An image view at the top of the cell.
    public let imageView = UIImageView()

    /// A label at the bottom of the cell.
    public let captionLabel = UILabel()

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

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))

        let spacingView1 = UIView()
        spacingView1.translatesAutoresizingMaskIntoConstraints = false
        spacingView1.hidden = true
        contentView.addSubview(spacingView1)
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0))

        let spacingView2 = UIView()
        spacingView2.translatesAutoresizingMaskIntoConstraints = false
        spacingView2.hidden = true
        contentView.addSubview(spacingView2)
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Bottom, relatedBy: .Equal, toItem: captionLabel, attribute: .Top, multiplier: 1, constant: 0))

        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Height, relatedBy: .Equal, toItem: spacingView2, attribute: .Height, multiplier: 1, constant: 0))

        contentView.addSubview(captionLabel)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        captionLabel.font = UIFont.systemFontOfSize(11)
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -12))

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
        captionLabel.text = nil
        imageView.image = nil
    }

    /// :nodoc:
    public override var selected: Bool {
        didSet {
            selectionIndicator.hidden = !selected
        }
    }

    /// :nodoc:
    public override var highlighted: Bool {
        didSet {
            selectionIndicator.hidden = !highlighted
        }
    }

}
