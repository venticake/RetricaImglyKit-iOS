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
 *  A `FrameToolController` is reponsible for displaying the UI to add or remove a frame to an image.
 */
@objc(IMGLYFrameToolController) public class FrameToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCollectionViewCellReuseIdentifier = "IconCollectionViewCellReuseIdentifier"
    private static let IconCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private var frameCount = 0
    private var imageRatio = Float(1.0)

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FrameToolController.IconCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCollectionViewCell.self, forCellWithReuseIdentifier: FrameToolController.IconCollectionViewCellReuseIdentifier)
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var options: FrameToolControllerOptions {
        return configuration.frameToolControllerOptions
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        if let mainRenderer = delegate?.photoEditToolControllerMainRenderer(self) {
            let size = mainRenderer.outputImageSize
            imageRatio = Float(size.width / size.height)
        }

        view.userInteractionEnabled = false

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(FrameToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(FrameToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

       // invokeCollectionViewDataFetch()
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let cellCount = collectionView.indexPathsForSelectedItems()?.count where cellCount == 0 && collectionView.numberOfItemsInSection(0) > 0 {
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: .None)
        }

        if frameCount == 0 {
            invokeCollectionViewDataFetch()
        } else {
            updateCollectionOnRatioChange()
        }
    }

    private func updateCollectionOnRatioChange() {
        if let mainRenderer = delegate?.photoEditToolControllerMainRenderer(self) {
            let size = mainRenderer.outputImageSize
            let imageRatio = Float(size.width / size.height)

            if imageRatio != self.imageRatio {
                self.imageRatio = imageRatio
                invokeCollectionViewDataFetch()
            }
        }
    }

    private func invokeCollectionViewDataFetch() {
        options.framesDataSource.frameCount(imageRatio, completionBlock: { (count, error) -> Void in
            self.frameCount = count
            print(self.imageRatio, count)
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }

            if let error = error {
                self.showError(error)
            }
        })
    }

    // MARK: - PhotoEditToolController

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
        undoManager?.removeAllActions()
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        undoManager?.undoAllAndClear()
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }
}

extension FrameToolController: UICollectionViewDataSource {
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
        return frameCount + 1
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FrameToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
                iconCaptionCell.imageView.image = UIImage(named: "icon_frames_no", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("No Frame")
                iconCaptionCell.accessibilityLabel = Localize("No Frame")
                return iconCaptionCell
            }
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FrameToolController.IconCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        options.framesDataSource.thumbnailAndLabelAtIndex(indexPath.item - 1, ratio: imageRatio) { (thumbnail, label, error) -> (Void) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath) as? IconCollectionViewCell {
                        if let thumbnail = thumbnail {
                            updateCell.imageView.image = thumbnail
                        } else {
                            if let error = error {
                                self.showError(error)
                            }
                        }

                        if let accessibilityText = label {
                            updateCell.accessibilityLabel = Localize(accessibilityText)
                        }
                    }
                })
        }

        return cell
    }
}

extension FrameToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let frameController = delegate?.photoEditToolControllerFrameController(self) else {
            return
        }

        let previousFrame = frameController._frame
        let previousImageRatio = frameController._imageRatio
        let previousNormalizedRectInImage = frameController.normalizedRectInImage
        let previouslyLocked = frameController.locked
        let previousImage = frameController.imageView?.image
        let previousImageViewFrame = frameController.imageView?.frame

        undoManager?.registerUndoForTarget(frameController) { frameController in
            frameController._frame = previousFrame
            frameController._imageRatio = previousImageRatio
            frameController.normalizedRectInImage = previousNormalizedRectInImage
            frameController.locked = previouslyLocked
            frameController.imageView?.image = previousImage

            if let previousImageViewFrame = previousImageViewFrame {
                frameController.imageView?.frame = previousImageViewFrame
            }
        }

        if indexPath.item == 0 {
            frameController.unlock()
            frameController.frame = nil
            options.selectedFrameClosure?(nil)
            return
        }

        options.framesDataSource.frameAtIndex(indexPath.item - 1, ratio: imageRatio) { frame, error in
            if let error = error {
                self.showError(error)
            } else {
                frameController.unlock()
                frameController.frame = frame
                frameController.imageRatio = self.imageRatio
                self.options.selectedFrameClosure?(frame)
            }
        }
    }

    /**
    :nodoc:
    */
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        undoManager?.registerUndoForTarget(collectionView) { collectionView in
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
}

extension FrameToolController: UICollectionViewDelegateFlowLayout {
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
