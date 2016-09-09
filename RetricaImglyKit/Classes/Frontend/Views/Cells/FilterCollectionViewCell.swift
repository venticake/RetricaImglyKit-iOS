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
 *  A `FilterCollectionViewCell` is a cell that shows an image (usually with a filter applied to it) and a label at the bottom.
 *  When selected the cell has an overlay and an selection indicator at the bottom.
 */
@available(iOS 8, *)
@objc(IMGLYFilterCollectionViewCell) public class FilterCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    /// The image view that display the image.
    public let imageView = UIImageView()

    /// A gradient from transparent to black that is behind the label for better readability.
    public let gradientView = GradientView(topColor: UIColor.clearColor(), bottomColor: UIColor.blackColor().colorWithAlphaComponent(0.6))

    /// An overlay that is visible when the cell is selected
    public let selectionOverlay = UIView()

    /// A label at the bottom of the cell
    public let captionLabel = UILabel()

    /// A selection indicator at the bottom of the cell.
    public let selectionIndicator = UIView()

    /// An activity indicator that is centered above the image and usually only shown while the image is loading.
    public let activityIndicator = UIActivityIndicatorView()

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

        imageView.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0))

        let spacingView1 = UIView()
        spacingView1.translatesAutoresizingMaskIntoConstraints = false
        spacingView1.hidden = true
        imageView.addSubview(spacingView1)
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Right, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Bottom, relatedBy: .Equal, toItem: activityIndicator, attribute: .Top, multiplier: 1, constant: 0))

        let spacingView2 = UIView()
        spacingView2.translatesAutoresizingMaskIntoConstraints = false
        spacingView2.hidden = true
        imageView.addSubview(spacingView2)
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Right, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Top, relatedBy: .Equal, toItem: activityIndicator, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Bottom, relatedBy: .Equal, toItem: captionLabel, attribute: .Top, multiplier: 1, constant: 0))

        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Height, relatedBy: .Equal, toItem: spacingView2, attribute: .Height, multiplier: 1, constant: 0))

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 1
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -8))

        imageView.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: gradientView, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: gradientView, attribute: .Top, relatedBy: .Equal, toItem: captionLabel, attribute: .Top, multiplier: 1, constant: -4))
        constraints.append(NSLayoutConstraint(item: gradientView, attribute: .Right, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: gradientView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0))

        imageView.addSubview(selectionOverlay)
        selectionOverlay.hidden = true
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        selectionOverlay.backgroundColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1).colorWithAlphaComponent(0.8)
        constraints.append(NSLayoutConstraint(item: selectionOverlay, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionOverlay, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionOverlay, attribute: .Right, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionOverlay, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0))

        imageView.addSubview(captionLabel)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        captionLabel.font = UIFont.systemFontOfSize(11)
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: -4))

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
        activityIndicator.stopAnimating()
        captionLabel.text = nil
        imageView.image = nil
    }

    /// :nodoc:
    public override var selected: Bool {
        didSet {
            selectionIndicator.hidden = !selected
            selectionOverlay.hidden = !selected
            captionLabel.textColor = selected ? UIColor.whiteColor() : UIColor.whiteColor().colorWithAlphaComponent(0.7)
            gradientView.hidden = selected
        }
    }

    /// :nodoc:
    public override var highlighted: Bool {
        didSet {
            selectionIndicator.hidden = !highlighted
            selectionOverlay.hidden = !highlighted
            captionLabel.textColor = selected ? UIColor.whiteColor() : UIColor.whiteColor().colorWithAlphaComponent(0.7)
            gradientView.hidden = selected
        }
    }

}
