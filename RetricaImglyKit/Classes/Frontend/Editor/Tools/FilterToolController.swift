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
 *  A `FilterToolController` is reponsible for displaying the UI to apply an effect filter to an image.
 */
@available(iOS 8, *)
@objc(IMGLYFilterToolController) public class FilterToolController: PhotoEditToolController {

    // MARK: - Properties

    private var filterSelectionController: FilterSelectionController?

    private var sliderContainerView: UIView?
    private var slider: Slider?

    private var sliderConstraints: [NSLayoutConstraint]?
    private var didPerformInitialScrollToReveal = false

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        filterSelectionController = FilterSelectionController(inputImage: delegate?.photoEditToolControllerBaseImage(self))
        filterSelectionController?.activePhotoEffectBlock = { [weak self] in
            guard let strongSelf = self else {
                return nil
            }

            return PhotoEffect.effectWithIdentifier(strongSelf.photoEditModel.effectFilterIdentifier) ?? PhotoEffect.effectWithIdentifier("None")
        }

        filterSelectionController?.selectedBlock = { [weak self] photoEffect in
            guard let strongSelf = self else {
                return
            }

            if photoEffect.identifier == "None" {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    strongSelf.sliderContainerView?.alpha = 0
                    }, completion: { _ in
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                })
            } else {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    strongSelf.sliderContainerView?.alpha = 1
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                    }, completion: nil)
            }

            strongSelf.photoEditModel.performChangesWithBlock {
                strongSelf.photoEditModel.effectFilterIntensity = strongSelf.options.initialFilterIntensity
                strongSelf.photoEditModel.effectFilterIdentifier = photoEffect.identifier
            }

            strongSelf.slider?.value = strongSelf.options.initialFilterIntensity
            strongSelf.options.filterSelectedClosure?(photoEffect)
        }

        filterSelectionController?.cellConfigurationClosure = { [weak self] cell, filter in
            self?.options.filterCellConfigurationClosure?(cell, filter)
        }

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = filterSelectionController?.collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(FilterToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(FilterToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        let photoEffect = PhotoEffect.effectWithIdentifier(photoEditModel.effectFilterIdentifier)

        if options.showFilterIntensitySlider {
            let sliderContainerView = UIView()
            sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
            sliderContainerView.alpha = photoEffect?.identifier == "None" ? 0 : 1
            view.addSubview(sliderContainerView)
            self.sliderContainerView = sliderContainerView
            options.filterIntensitySliderContainerConfigurationClosure?(sliderContainerView)

            let slider = Slider()
            slider.neutralPointTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
            slider.thumbTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
            slider.filledTrackColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.neutralValue = 0
            slider.value = photoEditModel.effectFilterIntensity
            sliderContainerView.addSubview(slider)
            slider.addTarget(self, action: #selector(FilterToolController.changeValue(_:)), forControlEvents: .ValueChanged)
            self.slider = slider
            options.filterIntensitySliderConfigurationClosure?(slider)
        }

        view.setNeedsUpdateConstraints()
    }

    private var options: FilterToolControllerOptions {
        get {
            return configuration.filterToolControllerOptions
        }
    }

    /**
    :nodoc:
    */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let photoEffect = PhotoEffect.effectWithIdentifier(photoEditModel.effectFilterIdentifier), index = PhotoEffect.allEffects.indexOf(photoEffect) where !didPerformInitialScrollToReveal {
            filterSelectionController?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: animated)
            didPerformInitialScrollToReveal = true
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

        if let selectedIndexPath = filterSelectionController?.collectionView.indexPathsForSelectedItems()?.first {
            if photoEditModel.effectFilterIdentifier != PhotoEffect.allEffects[selectedIndexPath.item].identifier {
                filterSelectionController?.updateSelectionAnimated(true)
            }
        } else {
            filterSelectionController?.updateSelectionAnimated(true)
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

    @objc private func changeValue(sender: Slider) {
        photoEditModel.performChangesWithBlock {
            self.photoEditModel.effectFilterIntensity = CGFloat(sender.value)
        }

        if let photoEffect = PhotoEffect.effectWithIdentifier(photoEditModel.effectFilterIdentifier) {
            options.filterIntensityChangedClosure?(sender, photoEffect)
        }
    }

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

}
