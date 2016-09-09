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
 *  A `FocusToolController` is reponsible for displaying the UI to adjust the focus of an image.
 */
@available(iOS 8, *)
@objc(IMGLYFocusToolController) public class FocusToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FocusToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: FocusToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var activeFocusType: IMGLYFocusType = .Off {
        didSet {
            if oldValue != activeFocusType {
                switch activeFocusType {
                case .Off:
                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 0
                        self.boxGradientView?.alpha = 0
                        self.sliderContainerView?.alpha = 0
                        }) { _ in
                            self.circleGradientView?.hidden = true
                            self.boxGradientView?.hidden = true
                    }
                case .Linear:
                    boxGradientView?.hidden = false

                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 0
                        self.boxGradientView?.alpha = 1
                        self.sliderContainerView?.alpha = 1
                        }) { _ in
                            self.circleGradientView?.hidden = true
                    }
                case .Radial:
                    circleGradientView?.hidden = false

                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 1
                        self.boxGradientView?.alpha = 0
                        self.sliderContainerView?.alpha = 1
                        }) { _ in
                            self.boxGradientView?.hidden = true
                    }
                }
            }
        }
    }

    private var boxGradientView: BoxGradientView?
    private var circleGradientView: CircleGradientView?
    private var sliderContainerView: UIView?
    private var slider: Slider?

    private var sliderConstraints: [NSLayoutConstraint]?
    private var gradientViewConstraints: [NSLayoutConstraint]?

    private var didPerformInitialGradientViewLayout = false

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
                applyButton.addTarget(self, action: #selector(FocusToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(FocusToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        let boxGradientView = BoxGradientView()
        boxGradientView.gradientViewDelegate = self
        boxGradientView.hidden = true
        boxGradientView.alpha = 0
        view.addSubview(boxGradientView)
        self.boxGradientView = boxGradientView
        options.boxGradientViewConfigurationClosure?(boxGradientView)

        let circleGradientView = CircleGradientView()
        circleGradientView.gradientViewDelegate = self
        circleGradientView.hidden = true
        circleGradientView.alpha = 0
        view.addSubview(circleGradientView)
        self.circleGradientView = circleGradientView
        options.circleGradientViewConfigurationClosure?(circleGradientView)

        switch photoEditModel.focusType {
        case .Off:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Off.rawValue, inSection: 0), animated: false, scrollPosition: .None)
        case .Linear:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Linear.rawValue, inSection: 0), animated: false, scrollPosition: .None)
            boxGradientView.hidden = false
            boxGradientView.alpha = 1
            activeFocusType = .Linear
        case .Radial:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Radial.rawValue, inSection: 0), animated: false, scrollPosition: .None)
            circleGradientView.hidden = false
            circleGradientView.alpha = 1
            activeFocusType = .Radial
        }

        let sliderContainerView = UIView()
        sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.alpha = photoEditModel.focusType == .Off ? 0 : 1
        view.addSubview(sliderContainerView)
        self.sliderContainerView = sliderContainerView
        options.sliderContainerConfigurationClosure?(sliderContainerView)

        let slider = Slider()
        slider.accessibilityLabel = Localize("Blur intensity")
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 15
        slider.neutralValue = 2
        slider.minimumValue = 2
        slider.neutralPointTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.thumbTintColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.filledTrackColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        slider.value = photoEditModel.focusBlurRadius
        sliderContainerView.addSubview(slider)
        slider.addTarget(self, action: #selector(FocusToolController.changeValue(_:)), forControlEvents: .ValueChanged)
        self.slider = slider
        options.sliderConfigurationClosure?(slider)

        view.setNeedsUpdateConstraints()
    }

    private var options: FocusToolControllerOptions {
        get {
            return configuration.focusToolControllerOptions
        }
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let boxGradientView = boxGradientView, circleGradientView = circleGradientView where gradientViewConstraints == nil {
            var constraints = [NSLayoutConstraint]()

            boxGradientView.translatesAutoresizingMaskIntoConstraints = false
            circleGradientView.translatesAutoresizingMaskIntoConstraints = false

            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            NSLayoutConstraint.activateConstraints(constraints)
            gradientViewConstraints = constraints
        }

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

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let previewView = delegate?.photoEditToolControllerPreviewView(self), previewContainer = delegate?.photoEditToolControllerPreviewViewScrollingContainer(self) else {
            return
        }

        let flippedControlPoint1 = flipNormalizedPointVertically(photoEditModel.focusNormalizedControlPoint1)
        let flippedControlPoint2 = flipNormalizedPointVertically(photoEditModel.focusNormalizedControlPoint2)

        let leftMargin = (previewContainer.bounds.width - previewView.bounds.width) / 2
        let topMargin = (previewContainer.bounds.height - previewView.bounds.height) / 2

        let denormalizedControlPoint1 = CGPoint(x: flippedControlPoint1.x * previewView.bounds.width + leftMargin, y: flippedControlPoint1.y * previewView.bounds.height + topMargin)
        let denormalizedControlPoint2 = CGPoint(x: flippedControlPoint2.x * previewView.bounds.width + leftMargin, y: flippedControlPoint2.y * previewView.bounds.height + topMargin)

        boxGradientView?.controlPoint1 = denormalizedControlPoint1
        boxGradientView?.controlPoint2 = denormalizedControlPoint2

        circleGradientView?.controlPoint1 = denormalizedControlPoint1
        circleGradientView?.controlPoint2 = denormalizedControlPoint2
    }

    // MARK: - PhotoEditToolController

    /**
    :nodoc:
    */
    public override func photoEditModelDidChange(notification: NSNotification) {
        super.photoEditModelDidChange(notification)

        activeFocusType = photoEditModel.focusType
        slider?.value = photoEditModel.focusBlurRadius
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: activeFocusType.rawValue, inSection: 0), animated: true, scrollPosition: .None)
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
            self.photoEditModel.focusBlurRadius = CGFloat(sender.value)
        }

        options.sliderChangedValueClosure?(sender, activeFocusType)
    }

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Helpers

    private func normalizeControlPoint(point: CGPoint) -> CGPoint {
        guard let previewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return point
        }

        if let boxGradientView = boxGradientView where activeFocusType == .Linear {
            let convertedPoint = previewView.convertPoint(point, fromView: boxGradientView)
            return CGPoint(x: convertedPoint.x / previewView.bounds.size.width, y: convertedPoint.y / previewView.bounds.size.height)
        } else if let circleGradientView = circleGradientView where activeFocusType == .Radial {
            let convertedPoint = previewView.convertPoint(point, fromView: circleGradientView)
            return CGPoint(x: convertedPoint.x / previewView.bounds.size.width, y: convertedPoint.y / previewView.bounds.size.height)
        }

        return point
    }

    private func denormalizeControlPoint(point: CGPoint) -> CGPoint {
        guard let previewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return point
        }

        if let boxGradientView = boxGradientView where activeFocusType == .Linear {
            let denormalizedPoint = CGPoint(x: point.x * previewView.bounds.size.width, y: point.y * previewView.bounds.size.height)
            return previewView.convertPoint(denormalizedPoint, toView: boxGradientView)
        } else if let circleGradientView = circleGradientView where activeFocusType == .Radial {
            let denormalizedPoint = CGPoint(x: point.x * previewView.bounds.size.width, y: point.y * previewView.bounds.size.height)
            return previewView.convertPoint(denormalizedPoint, toView: circleGradientView)
        }

        return point
    }

    private func flipNormalizedPointVertically(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x, y: 1 - point.y)
    }

}

@available(iOS 8, *)
extension FocusToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let actionType = options.allowedFocusTypes[indexPath.item]

        photoEditModel.focusType = actionType

        switch actionType {
        case .Off:
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        case .Linear:
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(boxGradientView?.controlPoint1 ?? CGPoint.zero))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(boxGradientView?.controlPoint2 ?? CGPoint.zero))
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, boxGradientView)
        case.Radial:
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(circleGradientView?.controlPoint1 ?? CGPoint.zero))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(circleGradientView?.controlPoint2 ?? CGPoint.zero))
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, circleGradientView)
        }

        options.focusTypeSelectedClosure?(activeFocusType)
    }
}

@available(iOS 8, *)
extension FocusToolController: UICollectionViewDataSource {
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
        return options.allowedFocusTypes.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FocusToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)
        let actionType = options.allowedFocusTypes[indexPath.item]

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if actionType == .Off {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_focus_off", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("No Focus")
                iconCaptionCell.accessibilityLabel = Localize("No Focus")
            } else if actionType == .Linear {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_focus_linear", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Linear")
                iconCaptionCell.accessibilityLabel = Localize("Linear focus")
            } else if actionType == .Radial {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_focus_radial", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Radial")
                iconCaptionCell.accessibilityLabel = Localize("Radial focus")
            }

            options.focusTypeButtonConfigurationClosure?(iconCaptionCell, actionType)
        }

        return cell
    }
}

@available(iOS 8, *)
extension FocusToolController: UICollectionViewDelegateFlowLayout {
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

@available(iOS 8, *)
extension FocusToolController: GradientViewDelegate {
    /**
     :nodoc:
     */
    public func gradientViewUserInteractionStarted(gradientView: UIView) {
    }

    /**
     :nodoc:
     */
    public func gradientViewUserInteractionEnded(gradientView: UIView) {
    }

    /**
     :nodoc:
     */
    public func gradientViewControlPointChanged(gradientView: UIView) {
        if let gradientView = gradientView as? CircleGradientView where gradientView == circleGradientView {
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint1))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint2))
        } else if let gradientView = gradientView as? BoxGradientView where gradientView == boxGradientView {
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint1))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint2))
        }

    }
}
