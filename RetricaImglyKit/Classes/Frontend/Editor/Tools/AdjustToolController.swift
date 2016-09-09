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
 *  An `AdjustToolController` is reponsible for displaying the UI to adjust the brightness, contrast and saturation
 *  of an image.
 */
@objc(IMGLYAdjustToolController) public class AdjustToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = AdjustToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: AdjustToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var activeAdjustTool: AdjustTool? {
        didSet {
            if oldValue == nil || activeAdjustTool == nil {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.sliderContainerView?.alpha = 1
                    }, completion: nil)
            } else if activeAdjustTool == nil {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.sliderContainerView?.alpha = 0
                    }, completion: nil)
            }
        }
    }

    private var sliderContainerView: UIView?
    private var slider: Slider?

    private var sliderConstraints: [NSLayoutConstraint]?

    // MARK: - Actions

    @objc private func changeValue(sender: Slider) {
        guard let activeAdjustTool = activeAdjustTool else {
            return
        }

        switch activeAdjustTool {
        case .Brightness:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.brightness = sender.value
            }
        case .Contrast:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.contrast = sender.value
            }
        case .Saturation:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.saturation = sender.value
            }
        case .Shadows:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.shadows = sender.value
            }
        case .Highlights:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.highlights = sender.value
            }
        case .Exposure:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.exposure = sender.value
            }
        case .Clarity:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.clarity = sender.value
            }
        }

        options.sliderChangedValueClosure?(sender, activeAdjustTool)
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(AdjustToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(AdjustToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        let sliderContainerView = UIView()
        sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.alpha = activeAdjustTool == nil ? 0 : 1
        view.addSubview(sliderContainerView)
        self.sliderContainerView = sliderContainerView
        options.sliderContainerConfigurationClosure?(sliderContainerView)

        let slider = TooltipSlider()
        slider.neutralPointTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.thumbTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.filledTrackColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.addSubview(slider)
        slider.addTarget(self, action: #selector(AdjustToolController.changeValue(_:)), forControlEvents: .ValueChanged)
        self.slider = slider
        options.sliderConfigurationClosure?(slider)

        view.setNeedsUpdateConstraints()
    }

    private var options: AdjustToolControllerOptions {
        get {
            return configuration.adjustToolControllerOptions
        }
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let sliderContainerView = sliderContainerView, slider = slider where sliderConstraints == nil {
            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))

            constraints.append(NSLayoutConstraint(item: slider, attribute: .CenterY, relatedBy: .Equal, toItem: sliderContainerView, attribute: .CenterY, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: slider, attribute: .Left, relatedBy: .Equal, toItem: sliderContainerView, attribute: .Left, multiplier: 1, constant: 20))
            constraints.append(NSLayoutConstraint(item: slider, attribute: .Right, relatedBy: .Equal, toItem: sliderContainerView, attribute: .Right, multiplier: 1, constant: -20))

            NSLayoutConstraint.activateConstraints(constraints)
            sliderConstraints = constraints
        }
    }

    // MARK: - PhotoEditToolController

    /**
    :nodoc:
    */
    public override func photoEditModelDidChange(notification: NSNotification) {
        super.photoEditModelDidChange(notification)

        if let activeAdjustTool = activeAdjustTool {
            switch activeAdjustTool {
            case .Brightness:
                slider?.value = photoEditModel.brightness
            case .Contrast:
                slider?.value = photoEditModel.contrast
            case .Saturation:
                slider?.value = photoEditModel.saturation
            case .Shadows:
                slider?.value = photoEditModel.shadows
            case .Highlights:
                slider?.value = photoEditModel.highlights
            case .Exposure:
                slider?.value = photoEditModel.exposure
            case .Clarity:
                slider?.value = photoEditModel.clarity
            }
        }
    }

    /**
     :nodoc:
     */
    public override func didBecomeActiveTool() {
        super.didBecomeActiveTool()

        options.didEnterToolClosure?()
    }

    /**
     :nodoc:
     */
    public override func willResignActiveTool() {
        super.willResignActiveTool()

        options.willLeaveToolClosure?()
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }
}

extension AdjustToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let adjustTool = options.allowedAdjustTools[indexPath.item]

        if adjustTool == .Brightness {
            activeAdjustTool = .Brightness
            slider?.minimumValue = -1
            slider?.maximumValue = 1
            slider?.neutralValue = 0
            slider?.value = photoEditModel.brightness
        } else if adjustTool == .Contrast {
            activeAdjustTool = .Contrast
            slider?.minimumValue = 0
            slider?.maximumValue = 2
            slider?.neutralValue = 1
            slider?.value = photoEditModel.contrast
        } else if adjustTool == .Saturation {
            activeAdjustTool = .Saturation
            slider?.minimumValue = 0
            slider?.maximumValue = 2
            slider?.neutralValue = 1
            slider?.value = photoEditModel.saturation
        } else if adjustTool == .Shadows {
            activeAdjustTool = .Shadows
            slider?.minimumValue = -1
            slider?.maximumValue = 1
            slider?.neutralValue = 0
            slider?.value = photoEditModel.shadows
        } else if adjustTool == .Highlights {
            activeAdjustTool = .Highlights
            slider?.minimumValue = 0
            slider?.maximumValue = 1
            slider?.neutralValue = 1
            slider?.value = photoEditModel.highlights
        } else if adjustTool == .Exposure {
            activeAdjustTool = .Exposure
            slider?.minimumValue = -1
            slider?.maximumValue = 1
            slider?.neutralValue = 0
            slider?.value = photoEditModel.exposure
        } else if adjustTool == .Clarity {
            activeAdjustTool = .Clarity
            slider?.minimumValue = 0
            slider?.maximumValue = 1
            slider?.neutralValue = 0
            slider?.value = photoEditModel.clarity
        }

        options.adjustToolSelectedClosure?(adjustTool)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, slider)
    }
}

extension AdjustToolController: UICollectionViewDataSource {
    /**
     :nodoc:
     */
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.allowedAdjustTools.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AdjustToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            let actionType = options.allowedAdjustTools[indexPath.item]

            if actionType == .Brightness {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_brightness", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Brightness")
                iconCaptionCell.accessibilityLabel = Localize("Brightness")
            } else if actionType == .Contrast {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_contrast", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Contrast")
                iconCaptionCell.accessibilityLabel = Localize("Contrast")
            } else if actionType == .Saturation {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_saturation", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Saturation")
                iconCaptionCell.accessibilityLabel = Localize("Saturation")
            } else if actionType == .Exposure {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_exposure", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Exposure")
                iconCaptionCell.accessibilityLabel = Localize("Exposure")
            } else if actionType == .Shadows {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_shadows", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Shadows")
                iconCaptionCell.accessibilityLabel = Localize("Shadows")
            } else if actionType == .Highlights {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_highlights", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Highlights")
                iconCaptionCell.accessibilityLabel = Localize("Highlights")
            } else if actionType == .Clarity {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_clarity", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Clarity")
                iconCaptionCell.accessibilityLabel = Localize("Clarity")
            }

            options.adjustToolButtonConfigurationClosure?(iconCaptionCell, actionType)
        }

        return cell
    }
}

extension AdjustToolController: UICollectionViewDelegateFlowLayout {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsetsZero
        }

        let cellSpacing = flowLayout.minimumLineSpacing
        let cellWidth = flowLayout.itemSize.width
        let cellCount = collectionView.numberOfItemsInSection(section)
        let inset = max((collectionView.bounds.width - (CGFloat(cellCount) * (cellWidth + cellSpacing))) * 0.5, 0)

        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
    }
}
