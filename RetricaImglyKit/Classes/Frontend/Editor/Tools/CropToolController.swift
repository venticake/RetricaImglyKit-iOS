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
 *  A `CropToolController` is reponsible for displaying the UI to crop an image.
 */
@available(iOS 8, *)
@objc(IMGLYCropToolController) public class CropToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    private static let MinimumCropSize = CGFloat(50)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CropToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: CropToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var clipView = UIView()

    private let cropRectComponent = InstanceFactory.cropRectComponent()

    /// The currently active selection mode.
    public var selectionMode: CropRatio?

    private var cropRectLeftBound = CGFloat(0)
    private var cropRectRightBound = CGFloat(0)
    private var cropRectTopBound = CGFloat(0)
    private var cropRectBottomBound = CGFloat(0)
    private var dragOffset = CGPoint.zero
    private var didPresentCropRect = false

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        if let firstCropAction = options.allowedCropRatios.first {
            selectionMode = firstCropAction
        }

        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: .None)

        preferredRenderMode = [.AutoEnhancement, .Orientation, .Focus, .PhotoEffect, .ColorAdjustments, .RetricaFilter]

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(CropToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(CropToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        clipView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.addSubview(clipView)

        configureCropRect()
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        clipView.alpha = 0

        UIView.animateWithDuration(0.25) {
            self.delegate?.photoEditToolControllerFrameController(self)?.imageView?.alpha = 0
        }
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let previewView = delegate?.photoEditToolControllerPreviewView(self) {
            clipView.frame = view.convertRect(previewView.bounds, fromView: previewView).integral

            UIView.animateWithDuration(animated ? 0.25 : 0) {
                self.clipView.alpha = 1
            }
        }

        reCalculateCropRectBounds()

        if !didPresentCropRect {
            setCropRectForSelectionRatio()
            cropRectComponent.present()
            didPresentCropRect = true
        } else {
            resetCropRectToMatchActiveCropRect()
        }
    }

    /**
     :nodoc:
     */
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animateWithDuration(0.25) {
            self.delegate?.photoEditToolControllerFrameController(self)?.imageView?.alpha = 1
        }
    }

    // MARK: - PhotoEditToolController

    /// :nodoc:
    public override var preferredDefaultPreviewViewScale: CGFloat {
        return 0.9
    }

    /**
     :nodoc:
     */
    public override func didBecomeActiveTool() {
        super.didBecomeActiveTool()

        calculateNewOverlayPlacementWithCropEnabled(false)
        options.didEnterToolClosure?()
    }

    /**
     :nodoc:
     */
    public override func willResignActiveTool() {
        super.willResignActiveTool()

        calculateNewOverlayPlacementWithCropEnabled(true)
        options.willLeaveToolClosure?()
    }

    // MARK: - Helpers

    private func denormalizePoint(point: CGPoint, inView view: UIView, baseImageSize: CGSize, containerSize: CGSize, normalizedCropRect: CGRect) -> CGPoint {
        if normalizedCropRect == IMGLYPhotoEditModel.identityNormalizedCropRect() {
            return CGPoint(x: point.x * view.bounds.width, y: point.y * view.bounds.height)
        }

        let convertedNormalizedCropRect = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.size.height, width: normalizedCropRect.size.width, height: normalizedCropRect.size.height)

        let denormalizedCropRect = CGRect(
            x: convertedNormalizedCropRect.origin.x * baseImageSize.width,
            y: convertedNormalizedCropRect.origin.y * baseImageSize.height,
            width: convertedNormalizedCropRect.size.width * baseImageSize.width,
            height: convertedNormalizedCropRect.size.height * baseImageSize.height
        )

        let viewToCroppedImageScale = min(containerSize.width / denormalizedCropRect.width, containerSize.height / denormalizedCropRect.height)

        let denormalizedPoint = CGPoint(x: point.x * baseImageSize.width, y: point.y * baseImageSize.height)
        let pointInCropRect = CGPoint(x: denormalizedPoint.x - denormalizedCropRect.origin.x, y: denormalizedPoint.y - denormalizedCropRect.origin.y)

        return CGPoint(x: pointInCropRect.x * viewToCroppedImageScale, y: pointInCropRect.y * viewToCroppedImageScale)
    }

    private func calculateNewOverlayPlacementWithCropEnabled(cropEnabled: Bool) {
        guard let mainPreviewView = delegate?.photoEditToolControllerPreviewView(self), previewViewScrollingContainer = delegate?.photoEditToolControllerPreviewViewScrollingContainer(self), overlays = delegate?.photoEditToolControllerOverlayViews(self), photoEditRenderer = delegate?.photoEditToolControllerMainRenderer(self) else {
            return
        }

        let cachedRenderMode = photoEditRenderer.renderMode
        photoEditRenderer.renderMode = photoEditRenderer.renderMode.subtract(.Crop)
        let outputImageSize = photoEditRenderer.outputImageSize
        photoEditRenderer.renderMode = cachedRenderMode

        let previewBounds = mainPreviewView.bounds
        let containerBounds = previewViewScrollingContainer.bounds
        let normalizedCropRect = photoEditModel.normalizedCropRect
        let convertedNormalizedCropRect = CGRect(
            x: normalizedCropRect.origin.x,
            y: 1 - normalizedCropRect.origin.y - normalizedCropRect.size.height,
            width: normalizedCropRect.size.width,
            height: normalizedCropRect.size.height
        )

        let denormalizedCropRect = CGRect(
            x: convertedNormalizedCropRect.origin.x * previewBounds.size.width,
            y: convertedNormalizedCropRect.origin.y * previewBounds.size.height,
            width: convertedNormalizedCropRect.size.width * previewBounds.size.width,
            height: convertedNormalizedCropRect.size.height * previewBounds.size.height
        )

        let baseScale = min(containerBounds.width / denormalizedCropRect.width, containerBounds.height / denormalizedCropRect.height)
        let scale = cropEnabled ? baseScale : 1 / baseScale

        for overlay in overlays ?? [] {
            overlay.transform = CGAffineTransformScale(overlay.transform, scale, scale)

            if let stickerImageView = overlay as? StickerImageView {
                stickerImageView.center = denormalizePoint(stickerImageView.normalizedCenterInImage, inView: mainPreviewView, baseImageSize: outputImageSize, containerSize: containerBounds.size, normalizedCropRect: cropEnabled ? normalizedCropRect : IMGLYPhotoEditModel.identityNormalizedCropRect())
            } else if let textLabel = overlay as? TextLabel {
                textLabel.center = denormalizePoint(textLabel.normalizedCenterInImage, inView: mainPreviewView, baseImageSize: outputImageSize, containerSize: containerBounds.size, normalizedCropRect: cropEnabled ? normalizedCropRect : IMGLYPhotoEditModel.identityNormalizedCropRect())
            }
        }
    }

    private func configureCropRect() {
        cropRectComponent.cropRect = photoEditModel.normalizedCropRect
        cropRectComponent.setup(clipView, parentView: view, showAnchors: true)
        addGestureRecognizerToTransparentView()
        addGestureRecognizerToAnchors()
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        photoEditModel.normalizedCropRect = normalizedCropRect()

        if let frameController = delegate?.photoEditToolControllerFrameController(self), indexPath = collectionView.indexPathsForSelectedItems()?.last {
            let cropRatio = options.allowedCropRatios[indexPath.item]
            frameController.unlock()
            frameController.imageRatio = Float(cropRatio.ratio ?? (cropRectComponent.cropRect.size.width / cropRectComponent.cropRect.size.height))
        }

        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Helpers

    private var options: CropToolControllerOptions {
        return self.configuration.cropToolControllerOptions
    }

    // MARK: - Crop Rect Related Methods

    private func addGestureRecognizerToTransparentView() {
        clipView.userInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CropToolController.handlePan(_:)))
        clipView.addGestureRecognizer(panGestureRecognizer)
    }

    private func addGestureRecognizerToAnchors() {
        addGestureRecognizerToAnchor(cropRectComponent.topLeftAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.topRightAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomRightAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomLeftAnchor!)
    }

    private func addGestureRecognizerToAnchor(anchor: UIImageView) {
        anchor.userInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CropToolController.handlePan(_:)))
        anchor.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.view!.isEqual(cropRectComponent.topRightAnchor) {
            handlePanOnTopRight(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.topLeftAnchor) {
            handlePanOnTopLeft(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.bottomLeftAnchor) {
            handlePanOnBottomLeft(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.bottomRightAnchor) {
            handlePanOnBottomRight(recognizer)
        } else if recognizer.view!.isEqual(clipView) {
            handlePanOnTransparentView(recognizer)
        }

        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }

    @objc private func handlePanOnTopLeft(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        var sizeX = cropRectComponent.bottomRightAnchor!.center.x - location.x
        var sizeY = cropRectComponent.bottomRightAnchor!.center.y - location.y

        sizeX = CGFloat(Int(sizeX))
        sizeY = CGFloat(Int(sizeY))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopLeftAnchor(size)
        var center = cropRectComponent.topLeftAnchor!.center
        center.x += (cropRectComponent.cropRect.size.width - size.width)
        center.y += (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.topLeftAnchor!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForTopLeftAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)

            if (cropRectComponent.bottomRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor!.center.x - cropRectLeftBound
                newSize.height = newSize.width / CGFloat(selectionRatio)
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.bottomRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
            }
        }
        return newSize
    }

    private func recalculateCropRectFromTopLeftAnchor() {
        cropRectComponent.cropRect = CGRect(x: cropRectComponent.topLeftAnchor!.center.x,
            y: cropRectComponent.topLeftAnchor!.center.y,
            width: cropRectComponent.bottomRightAnchor!.center.x - cropRectComponent.topLeftAnchor!.center.x,
            height: cropRectComponent.bottomRightAnchor!.center.y - cropRectComponent.topLeftAnchor!.center.y)
    }

    private func handlePanOnTopRight(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        var sizeX = cropRectComponent.bottomLeftAnchor!.center.x - location.x
        var sizeY = cropRectComponent.bottomLeftAnchor!.center.y - location.y

        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopRightAnchor(size)
        var center = cropRectComponent.topRightAnchor!.center
        center.x = (cropRectComponent.bottomLeftAnchor!.center.x + size.width)
        center.y = (cropRectComponent.bottomLeftAnchor!.center.y - size.height)
        cropRectComponent.topRightAnchor!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForTopRightAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height =  cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
            }
        }
        return newSize
    }

    private func recalculateCropRectFromTopRightAnchor() {
        cropRectComponent.cropRect = CGRect(x: cropRectComponent.bottomLeftAnchor!.center.x,
            y: cropRectComponent.topRightAnchor!.center.y,
            width: cropRectComponent.topRightAnchor!.center.x - cropRectComponent.bottomLeftAnchor!.center.x,
            height: cropRectComponent.bottomLeftAnchor!.center.y - cropRectComponent.topRightAnchor!.center.y)
    }


    private func handlePanOnBottomLeft(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        var sizeX = cropRectComponent.topRightAnchor!.center.x - location.x
        var sizeY = cropRectComponent.topRightAnchor!.center.y - location.y

        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomLeftAnchor(size)
        var center = cropRectComponent.bottomLeftAnchor!.center
        center.x = (cropRectComponent.topRightAnchor!.center.x - size.width)
        center.y = (cropRectComponent.topRightAnchor!.center.y + size.height)
        cropRectComponent.bottomLeftAnchor!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForBottomLeftAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)

            if (cropRectComponent.topRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor!.center.x - cropRectLeftBound
                newSize.height = newSize.width / CGFloat(selectionRatio)
            }

            if (cropRectComponent.topRightAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor!.center.y
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.topRightAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor!.center.y
            }
        }
        return newSize
    }

    private func handlePanOnBottomRight(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        var sizeX = cropRectComponent.topLeftAnchor!.center.x - location.x
        var sizeY = cropRectComponent.topLeftAnchor!.center.y - location.y
        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomRightAnchor(size)
        var center = cropRectComponent.bottomRightAnchor!.center
        center.x -= (cropRectComponent.cropRect.size.width - size.width)
        center.y -= (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.bottomRightAnchor!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForBottomRightAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)
            if (cropRectComponent.topLeftAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topLeftAnchor!.center.y
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            if (cropRectComponent.topLeftAnchor!.center.y + newSize.height) >  cropRectBottomBound {
                newSize.height =  cropRectBottomBound - cropRectComponent.topLeftAnchor!.center.y
            }
        }
        return newSize
    }

    private func handlePanOnTransparentView(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        if cropRectComponent.cropRect.contains(location) {
            calculateDragOffsetOnNewDrag(recognizer:recognizer)
            let newLocation = clampedLocationToBounds(location)
            var rect = cropRectComponent.cropRect
            rect.origin.x = newLocation.x - dragOffset.x
            rect.origin.y = newLocation.y - dragOffset.y
            cropRectComponent.cropRect = rect
            cropRectComponent.layoutViewsForCropRect()
        }
    }

    private func calculateDragOffsetOnNewDrag(recognizer recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(clipView)
        if recognizer.state == UIGestureRecognizerState.Began {
            dragOffset = CGPoint(x: location.x - cropRectComponent.cropRect.origin.x, y: location.y - cropRectComponent.cropRect.origin.y)
        }
    }

    private func clampedLocationToBounds(location: CGPoint) -> CGPoint {
        let rect = cropRectComponent.cropRect
        var locationX = location.x
        var locationY = location.y
        let left = locationX - dragOffset.x
        let right = left + rect.size.width
        let top  = locationY - dragOffset.y
        let bottom = top + rect.size.height

        if left < cropRectLeftBound {
            locationX = cropRectLeftBound + dragOffset.x
        }

        if right > cropRectRightBound {
            locationX = cropRectRightBound - cropRectComponent.cropRect.size.width  + dragOffset.x
        }

        if top < cropRectTopBound {
            locationY = cropRectTopBound + dragOffset.y
        }

        if bottom > cropRectBottomBound {
            locationY = cropRectBottomBound - cropRectComponent.cropRect.size.height + dragOffset.y
        }

        return CGPoint(x: locationX, y: locationY)
    }

    private func normalizedCropRect() -> CGRect {
        reCalculateCropRectBounds()
        let boundWidth = cropRectRightBound - cropRectLeftBound
        let boundHeight = cropRectBottomBound - cropRectTopBound
        let x = (cropRectComponent.cropRect.origin.x - cropRectLeftBound) / boundWidth
        let y = (cropRectComponent.cropRect.origin.y - cropRectTopBound) / boundHeight

        let normalizedRect = CGRect(x: x, y: 1 - y - cropRectComponent.cropRect.size.height / boundHeight, width: cropRectComponent.cropRect.size.width / boundWidth, height: cropRectComponent.cropRect.size.height / boundHeight)
        return normalizedRect
    }

    private func reCalculateCropRectBounds() {
        let width = clipView.frame.size.width
        let height = clipView.frame.size.height
        cropRectLeftBound = (width - clipView.bounds.width) / 2.0
        cropRectRightBound = width - cropRectLeftBound
        cropRectTopBound = (height - clipView.bounds.height) / 2.0
        cropRectBottomBound = height - cropRectTopBound
    }

    private func applyMinimumAreaRuleToSize(size: CGSize) -> CGSize {
        var newSize = size
        if newSize.width < CropToolController.MinimumCropSize {
            newSize.width = CropToolController.MinimumCropSize
        }

        if newSize.height < CropToolController.MinimumCropSize {
            newSize.height = CropToolController.MinimumCropSize
        }

        return newSize
    }

    private func setCropRectForSelectionRatio() {
        let size = CGSize(width: cropRectRightBound - cropRectLeftBound,
            height: cropRectBottomBound - cropRectTopBound)
        var rectWidth = size.width
        var rectHeight = rectWidth

        if size.width > size.height {
            rectHeight = size.height
            rectWidth = rectHeight
        }

        let selectionRatio = selectionMode?.ratio ?? 1

        if selectionRatio >= 1 {
            rectHeight /= CGFloat(selectionRatio)
        } else {
            rectWidth *= CGFloat(selectionRatio)
        }

        let sizeDeltaX = (size.width - rectWidth) / 2.0
        let sizeDeltaY = (size.height - rectHeight) / 2.0

        cropRectComponent.cropRect = CGRect(
            x: cropRectLeftBound  + sizeDeltaX,
            y: cropRectTopBound + sizeDeltaY,
            width: rectWidth,
            height: rectHeight)
    }

    private func resetCropRectToMatchActiveCropRect() {
        var cropRect = photoEditModel.normalizedCropRect
        cropRect = CGRect(x: cropRect.origin.x, y: 1 - cropRect.origin.y - cropRect.height, width: cropRect.width, height: cropRect.height)
        cropRect = CGRect(x: cropRect.origin.x * clipView.bounds.width, y: cropRect.origin.y * clipView.bounds.height, width: cropRect.width * clipView.bounds.width, height: cropRect.height * clipView.bounds.height)
        cropRectComponent.cropRect = cropRect

        cropRectComponent.layoutViewsForCropRect()
    }

    private func updateCropRectForSelectionMode() {
        if let _ = selectionMode?.ratio {
            setCropRectForSelectionRatio()
            cropRectComponent.layoutViewsForCropRect()
        }
    }
}

@available(iOS 8, *)
extension CropToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cropRatio = options.allowedCropRatios[indexPath.item]
        options.cropRatioSelectedClosure?(cropRatio)
        selectionMode = cropRatio
        updateCropRectForSelectionMode()
    }
}

@available(iOS 8, *)
extension CropToolController: UICollectionViewDataSource {
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
        return options.allowedCropRatios.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CropToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            let cropRatio = options.allowedCropRatios[indexPath.item]
            iconCaptionCell.imageView.image = cropRatio.icon
            iconCaptionCell.captionLabel.text = cropRatio.title
            iconCaptionCell.accessibilityLabel = cropRatio.accessibilityLabel
            options.cropRatioButtonConfigurationClosure?(iconCaptionCell, cropRatio)
        }

        return cell
    }
}

@available(iOS 8, *)
extension CropToolController: UICollectionViewDelegateFlowLayout {
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
