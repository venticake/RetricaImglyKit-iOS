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
 *  A `StickerToolController` is reponsible for displaying the UI to add stickers to an image.
 */
@available(iOS 8, *)
@objc(IMGLYStickerToolController) public class StickerToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCollectionViewCellReuseIdentifier = "IconCollectionViewCellReuseIdentifier"
    private static let IconCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private var stickerCount = 0

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = StickerToolController.IconCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCollectionViewCell.self, forCellWithReuseIdentifier: StickerToolController.IconCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var options: StickerToolControllerOptions {
        return configuration.stickerToolControllerOptions
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.userInteractionEnabled = false

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(StickerToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(StickerToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }
    }

    /**
    :nodoc:
    */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if stickerCount == 0 {
            invokeCollectionViewDataFetch()
        }
    }

    private func invokeCollectionViewDataFetch() {
        options.stickersDataSource.stickerCount({ count, error in
            self.stickerCount = count
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
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

@available(iOS 8, *)
extension StickerToolController: UICollectionViewDataSource {
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
        return stickerCount
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickerToolController.IconCollectionViewCellReuseIdentifier, forIndexPath: indexPath)
        options.stickersDataSource.thumbnailAndLabelAtIndex(indexPath.item, completionBlock: { (thumbnail, label, error) -> (Void) in
            if let thumbnail = thumbnail {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath)
                    if let updateCell = updateCell as? IconCollectionViewCell {
                        updateCell.imageView.image = thumbnail
                        if let accessibilityText = label {
                            updateCell.accessibilityLabel = Localize(accessibilityText)
                        }
                        self.options.stickerButtonConfigurationClosure?(updateCell)
                    }
                })
            } else {
                if let error = error {
                    self.showError(error)
                }
            }
        })

        return cell
    }
}

@available(iOS 8, *)
extension StickerToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        guard let overlayContainerView = delegate?.photoEditToolControllerOverlayContainerView(self) else {
            return
        }

        options.stickersDataSource.stickerAtIndex(indexPath.item, completionBlock: { sticker, error in
            if let sticker = sticker {
                sticker.image { (image, error) -> () in
                    if let image = image {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let imageView = StickerImageView(sticker: sticker)
                            imageView.layer.minificationFilter = kCAFilterTrilinear
                            imageView.image = image
                            imageView.sizeToFit()

                            // One third of the size of the photo's smaller side should be the size of the sticker's longest side
                            let longestStickerSide = min(overlayContainerView.bounds.width, overlayContainerView.bounds.height) * 0.33
                            let initialStickerScale = longestStickerSide / max(image.size.height, image.size.width)

                            imageView.center = CGPoint(x: overlayContainerView.bounds.midX, y: overlayContainerView.bounds.midY)

                            if let accessibilityText = sticker.accessibilityText {
                                imageView.accessibilityLabel = Localize(accessibilityText)
                            }

                            imageView.decrementHandler = { [unowned imageView] in
                                // Decrease by 10 %
                                imageView.transform = CGAffineTransformScale(imageView.transform, 0.9, 0.9)
                                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                            }

                            imageView.incrementHandler = { [unowned imageView] in
                                // Increase by 10 %
                                imageView.transform = CGAffineTransformScale(imageView.transform, 1.1, 1.1)
                                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                            }

                            imageView.rotateLeftHandler = { [unowned imageView] in
                                // Rotate by 10 degrees to the left
                                imageView.transform = CGAffineTransformRotate(imageView.transform, -10 * CGFloat(M_PI) / 180)
                                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                            }

                            imageView.rotateRightHandler = { [unowned imageView] in
                                // Rotate by 10 degrees to the right
                                imageView.transform = CGAffineTransformRotate(imageView.transform, 10 * CGFloat(M_PI) / 180)
                                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                            }

                            imageView.transform = CGAffineTransformMakeScale(0, 0)
                            overlayContainerView.addSubview(imageView)

                            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                                imageView.transform = CGAffineTransformMakeScale(initialStickerScale, initialStickerScale)
                                self.options.addedStickerClosure?(sticker)
                                self.delegate?.photoEditToolController(self, didAddOverlayView: imageView)
                                }) { _ in
                                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, imageView)
                            }
                        })
                    } else {
                        if let error = error {
                            self.showError(error)
                        }
                    }
                }
            } else {
                if let error = error {
                    self.showError(error)
                }
            }
        })
    }
}
