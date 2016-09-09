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
 *  An `OrientationToolController` is reponsible for displaying the UI to change the orientation of an image.
 */
@available(iOS 8, *)
@objc(IMGLYOrientationToolController) public class OrientationToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let SeparatorCollectionViewCellReuseIdentifier = "SeparatorCollectionViewCellReuseIdentifier"
    private static let SeparatorCollectionViewCellSize = CGSize(width: 15, height: 80)

    // MARK: - Properties

    private var snapshotView: UIView?
    private var geometry: ImageGeometry?

    private var _wantsDefaultPreviewView = true {
        didSet {
            delegate?.photoEditToolControllerDidChangeWantsDefaultPreviewView(self)
        }
    }

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = OrientationToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: OrientationToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.registerClass(SeparatorCollectionViewCell.self, forCellWithReuseIdentifier: OrientationToolController.SeparatorCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

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
                applyButton.addTarget(self, action: #selector(OrientationToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(OrientationToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }
    }

    // MARK: - Geometry Handling

    private func performGeometryChange(changes: (ImageGeometry) -> Void, animated: Bool) {
        guard let geometry = geometry else {
            return
        }

        let orientationPreChanges = geometry.appliedOrientation
        changes(geometry)
        let orientationPostChanges = geometry.appliedOrientation

        if orientationPreChanges == orientationPostChanges {
            return
        }

        photoEditModel.appliedOrientation = orientationPostChanges
        delegate?.photoEditToolController(self, didChangeToOrientation: orientationPostChanges, fromOrientation: orientationPreChanges)

        var transform = geometry.transformFromOrientation(orientationPreChanges)
        transform.tx = 0
        transform.ty = 0

        if let snapshotView = snapshotView {
            var snapshotFrame = snapshotView.frame
            snapshotFrame = CGRectApplyAffineTransform(snapshotFrame, transform)
            let fittedRect = CGRect(size: snapshotFrame.size, thatFitsIntoRect: view.frame)

            UIView.animateWithDuration(animated ? 0.25 : 0) {
                snapshotView.transform = CGAffineTransformConcat(snapshotView.transform, transform)
                snapshotView.frame = fittedRect
            }
        }
    }

    // MARK: - PhotoEditToolController

    /**
    :nodoc:
    */
    public override func didBecomeActiveTool() {
        super.didBecomeActiveTool()

        if let mainPreviewView = delegate?.photoEditToolControllerPreviewView(self) {
            let snapshot = mainPreviewView.snapshotViewAfterScreenUpdates(false)
            snapshot.frame = view.convertRect(mainPreviewView.bounds, fromView: mainPreviewView)
            view.addSubview(snapshot)
            snapshotView = snapshot

            geometry = ImageGeometry(inputSize: snapshot.bounds.size)
            geometry?.appliedOrientation = photoEditModel.appliedOrientation
        }

        _wantsDefaultPreviewView = false
        options.didEnterToolClosure?()
    }

    /**
     :nodoc
     */
    public override func didResignActiveTool() {
        super.didResignActiveTool()

        snapshotView?.removeFromSuperview()
        _wantsDefaultPreviewView = true
    }

    /**
     :nodoc:
     */
    public override func willResignActiveTool() {
        super.willResignActiveTool()

        options.willLeaveToolClosure?()
    }

    /// :nodoc:
    public override var wantsDefaultPreviewView: Bool {
        return _wantsDefaultPreviewView
    }

    private var options: OrientationToolControllerOptions {
        get {
            return configuration.orientationToolControllerOptions
        }
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }
}

@available(iOS 8, *)
extension OrientationToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let actionType = options.allowedOrientationActions[indexPath.item]

        if actionType == .RotateLeft {
            performGeometryChange({ geometry in
                geometry.rotateCounterClockwise()
                }, animated: false)
        } else if actionType == .RotateRight {
            performGeometryChange({ geometry in
                geometry.rotateClockwise()
                }, animated: false)
        } else if actionType == .FlipHorizontally {
            performGeometryChange({ geometry in
                geometry.flipHorizontally()
                }, animated: false)
        } else if actionType == .FlipVertically {
            performGeometryChange({ geometry in
                geometry.flipVertically()
                }, animated: false)
        }

        options.orientationActionSelectedClosure?(actionType)
    }
}

@available(iOS 8, *)
extension OrientationToolController: UICollectionViewDataSource {
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
        return options.allowedOrientationActions.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let actionType = options.allowedOrientationActions[indexPath.item]
        if actionType == .Separator {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(OrientationToolController.SeparatorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let separatorCell = cell as? SeparatorCollectionViewCell {
                separatorCell.separator.backgroundColor = configuration.separatorColor
            }

            return cell
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(OrientationToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if actionType == .RotateLeft {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_orientation_rotate_l", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Left")
                iconCaptionCell.accessibilityLabel = Localize("Rotate left")
            } else if actionType == .RotateRight {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_orientation_rotate_r", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Right")
                iconCaptionCell.accessibilityLabel = Localize("Rotate right")
            } else if actionType == .FlipHorizontally {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_orientation_flip_h", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Flip H")
                iconCaptionCell.accessibilityLabel = Localize("Flip horizontally")
            } else if actionType == .FlipVertically {
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_option_orientation_flip_v", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Flip V")
                iconCaptionCell.accessibilityLabel = Localize("Flip vertically")
            }

            options.orientationActionButtonConfigurationClosure?(iconCaptionCell, actionType)
        }

        return cell
    }
}

@available(iOS 8, *)
extension OrientationToolController: UICollectionViewDelegateFlowLayout {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsetsZero
        }

        let cellSpacing = flowLayout.minimumInteritemSpacing
        let cellCount = collectionView.numberOfItemsInSection(section)

        let collectionViewWidth = collectionView.bounds.size.width
        var totalCellWidth: CGFloat = 0

        for i in 0..<cellCount {
            let itemSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: i, inSection: section))
            totalCellWidth = totalCellWidth + itemSize.width
        }

        let totalCellSpacing = cellSpacing * (CGFloat(cellCount) - 1)
        let totalCellsWidth = totalCellWidth + totalCellSpacing
        let edgeInsets = max((collectionViewWidth - totalCellsWidth) / 2.0, cellSpacing)

        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.item == 2 {
            return OrientationToolController.SeparatorCollectionViewCellSize
        }

        return OrientationToolController.IconCaptionCollectionViewCellSize
    }
}
