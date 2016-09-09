//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit
import GLKit
import ImageIO
import MobileCoreServices

/// Posted immediately after the selected overlay view was changed.
/// The notification object is the view that was selected. The `userInfo` dictionary is `nil`.
public let PhotoEditViewControllerSelectedOverlayViewDidChangeNotification = "PhotoEditViewControllerSelectedOverlayViewDidChangeNotification"

/**
 The `PhotoEditViewControllerDelegate` protocol defines methods that allow you respond to the events of an instance of `PhotoEditViewController`.
 */
@available(iOS 8, *)
@objc(IMGLYPhotoEditViewControllerDelegate) public protocol PhotoEditViewControllerDelegate {
    /**
     Called when a new tool was selected.

     - parameter photoEditViewController:  The photo edit view controller that was used to select the new tool.
     - parameter toolController:           The tool that was selected.
     - parameter replaceTopToolController: Whether or not the tool controller should be placed above the previous tool or whether it should be replaced.
     */
    func photoEditViewController(photoEditViewController: PhotoEditViewController, didSelectToolController toolController: PhotoEditToolController, wantsCurrentTopToolControllerReplaced replaceTopToolController: Bool)

    /**
     Called when a tool should be dismissed.

     - parameter photoEditViewController: The photo edit view controller that was used to dismiss the tool.
     */
    func photoEditViewControllerPopToolController(photoEditViewController: PhotoEditViewController)

    /**
     The currently active editing tool.

     - parameter photoEditViewController: The photo edit view controller that is asking for the active editing tool.

     - returns: An instance of `PhotoEditToolController` that is currently at the top.
     */
    func photoEditViewControllerCurrentEditingTool(photoEditViewController: PhotoEditViewController) -> PhotoEditToolController?

    /**
     Called when the output image was generated.

     - parameter photoEditViewController: The photo edit view controller that created the output image.
     - parameter image:                   The output image that was generated.
     */
    func photoEditViewController(photoEditViewController: PhotoEditViewController, didSaveImage image: UIImage)

    /**
     Called when the output image could not be generated.

     - parameter photoEditViewController: The photo edit view controller that was unable to generate the output image.
     */
    func photoEditViewControllerDidFailToGeneratePhoto(photoEditViewController: PhotoEditViewController)

    /**
     Called when the user wants to dismiss the editor.

     - parameter photoEditviewController: The photo edit view controller that is asking to be cancelled.
     */
    func photoEditViewControllerDidCancel(photoEditviewController: PhotoEditViewController)
}

/**
 *  A `PhotoEditViewController` is responsible for presenting and rendering an edited image.
 */
@available(iOS 8, *)
@objc(IMGLYPhotoEditViewController) public class PhotoEditViewController: UIViewController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let SeparatorCollectionViewCellReuseIdentifier = "SeparatorCollectionViewCellReuseIdentifier"
    private static let SeparatorCollectionViewCellSize = CGSize(width: 15, height: 80)

    // MARK: - View Properties

    private var collectionView: UICollectionView?
    private var previewViewScrollingContainer: UIScrollView?
    private var mainPreviewView: GLKView?
    private var overlayContainerView: UIView?
    private var frameImageView: UIImageView?
    private var placeholderImageView: UIImageView?

    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    private var rotationGestureRecognizer: UIRotationGestureRecognizer?

    // MARK: - Constraint Properties

    private var placeholderImageViewConstraints: [NSLayoutConstraint]?
    private var previewViewScrollingContainerConstraints: [NSLayoutConstraint]?

    // MARK: - Model Properties

    /// The tool stack item for this controller.
    /// - seealso: `ToolStackItem`.
    public private(set) lazy var toolStackItem = ToolStackItem()

    private var photo: UIImage? {
        didSet {
            updatePlaceholderImage()
        }
    }

    private var photoImageOrientation: UIImageOrientation = .Up
    private var photoFileURL: NSURL?

    private let configuration: Configuration

    private var photoEditModel: IMGLYPhotoEditMutableModel? {
        didSet {
            if oldValue != photoEditModel {
                if let oldPhotoEditModel = oldValue {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: IMGLYPhotoEditModelDidChangeNotification, object: oldPhotoEditModel)
                }

                if let photoEditModel = photoEditModel {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhotoEditViewController.photoEditModelDidChange(_:)), name: IMGLYPhotoEditModelDidChangeNotification, object: photoEditModel)
                    updateMainRenderer()
                }
            }
        }
    }

    @NSCopying private var uneditedPhotoEditModel: IMGLYPhotoEditModel?

    private var baseWorkUIImage: UIImage? {
        didSet {
            if oldValue != baseWorkUIImage {

                let ciImage: CIImage?
                if let baseWorkUIImage = baseWorkUIImage {
                    ciImage = orientedCIImageFromUIImage(baseWorkUIImage)
                } else {
                    ciImage = nil
                }

                baseWorkCIImage = ciImage
                updateMainRenderer()
                loadFrameControllerIfNeeded()

                if baseWorkUIImage != nil {
                    if let photo = photo {
                        // Save original photo image orientation
                        photoImageOrientation = photo.imageOrientation

                        // Write full resolution image to disc to free memory
                        let fileName = "\(NSProcessInfo.processInfo().globallyUniqueString)_photo.png"
                        let fileURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileName))
                        UIImagePNGRepresentation(photo)?.writeToURL(fileURL, atomically: true)
                        photoFileURL = fileURL
                        self.photo = nil
                    }
                }
            }
        }
    }

    private var baseWorkCIImage: CIImage?
    private var mainRenderer: PhotoEditRenderer?
    private var nextRenderCompletionBlock: (() -> Void)?

    private var frameController: FrameController?

    // MARK: - State Properties

    private var previewViewScrollingContainerLayoutValid = false
    private var lastKnownWorkImageSize = CGSize.zero
    private var lastKnownPreviewViewSize = CGSize.zero

    /// The identifier of the photo effect to apply to the photo immediately. This is useful if you
    /// pass a photo that already has an effect applied by the `CameraViewController`. Note that you
    /// must set this property before presenting the view controller.
    public var initialPhotoEffectIdentifier: String?

    /// The intensity of the photo effect that is applied to the photo immediately. See
    /// `initialPhotoEffectIdentifier` for more information.
    public var initialPhotoEffectIntensity: CGFloat?

    private var toolForAction: [PhotoEditorAction: PhotoEditToolController]?

    private var selectedOverlayView: UIView? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(PhotoEditViewControllerSelectedOverlayViewDidChangeNotification, object: selectedOverlayView)

            oldValue?.layer.borderWidth = 0
            oldValue?.layer.shadowOffset = CGSize.zero
            oldValue?.layer.shadowColor = UIColor.clearColor().CGColor

            // Reset zoom
            updateScrollViewZoomScaleAnimated(true)

            if let selectedOverlayView = selectedOverlayView {
                selectedOverlayView.layer.borderWidth = 2 / (0.5 * (selectedOverlayView.transform.xScale + selectedOverlayView.transform.yScale))
                selectedOverlayView.layer.borderColor = UIColor.whiteColor().CGColor
                selectedOverlayView.layer.shadowOffset = CGSize(width: 0, height: 2)
                selectedOverlayView.layer.shadowRadius = 2
                selectedOverlayView.layer.shadowOpacity = 0.12
                selectedOverlayView.layer.shadowColor = UIColor.blackColor().CGColor
            }
        }
    }

    private var draggedOverlayView: UIView?

    // MARK: - Other Properties

    weak var delegate: PhotoEditViewControllerDelegate?

    private lazy var stickerContextMenuController: ContextMenuController = {
        let flipHorizontallyAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_orientation_flip_h", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? StickerImageView else {
                return
            }

            self?.undoManager?.registerUndoForTarget(overlayView) { view in
                view.flipHorizontally()
            }

            overlayView.flipHorizontally()
            self?.configuration.stickerToolControllerOptions.stickerActionSelectedClosure?(.FlipHorizontally)
        }

        flipHorizontallyAction.accessibilityLabel = Localize("Flip horizontally")

        let flipVerticallyAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_orientation_flip_v", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? StickerImageView else {
                return
            }

            self?.undoManager?.registerUndoForTarget(overlayView) { view in
                view.flipVertically()
            }

            overlayView.flipVertically()
            self?.configuration.stickerToolControllerOptions.stickerActionSelectedClosure?(.FlipVertically)
        }

        flipVerticallyAction.accessibilityLabel = Localize("Flip vertically")

        let bringToFrontAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_bringtofront", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? StickerImageView else {
                return
            }

            if let overlayViewSuperview = overlayView.superview, currentOrder = overlayViewSuperview.subviews.indexOf(overlayView) {
                self?.undoManager?.registerUndoForTarget(overlayViewSuperview) { superview in
                    superview.insertSubview(overlayView, atIndex: currentOrder)
                }
            }

            overlayView.superview?.bringSubviewToFront(overlayView)

            self?.configuration.stickerToolControllerOptions.stickerActionSelectedClosure?(.BringToFront)
        }

        bringToFrontAction.accessibilityLabel = Localize("Bring to front")

        let deleteAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_delete", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? StickerImageView, overlayContainerView = self?.overlayContainerView else {
                return
            }

            self?.undoManager?.registerUndoForTarget(overlayContainerView) { view in
                view.addSubview(overlayView)
            }

            self?.removeStickerOverlay(overlayView)

            if self?.selectedOverlayView == overlayView {
                self?.selectedOverlayView = nil
                self?.hideOptionsForOverlayIfNeeded()
            }

            self?.configuration.stickerToolControllerOptions.stickerActionSelectedClosure?(.Delete)
        }

        deleteAction.accessibilityLabel = Localize("Delete")

        let contextMenu = ContextMenuController()
        contextMenu.menuColor = self.configuration.contextMenuBackgroundColor

        let actions: [ContextMenuAction] = self.configuration.stickerToolControllerOptions.allowedStickerContextActions.map({
            switch $0 {
            case .FlipHorizontally:
                self.configuration.stickerToolControllerOptions.contextActionConfigurationClosure?(flipHorizontallyAction, .FlipHorizontally)
                return flipHorizontallyAction
            case .FlipVertically:
                self.configuration.stickerToolControllerOptions.contextActionConfigurationClosure?(flipVerticallyAction, .FlipVertically)
                return flipVerticallyAction
            case .BringToFront:
                self.configuration.stickerToolControllerOptions.contextActionConfigurationClosure?(bringToFrontAction, .BringToFront)
                return bringToFrontAction
            case .Delete:
                self.configuration.stickerToolControllerOptions.contextActionConfigurationClosure?(deleteAction, .Delete)
                return deleteAction
            case .Separator:
                return ContextMenuDividerAction()
            }
        })

        actions.forEach { contextMenu.addAction($0) }

        return contextMenu
    }()

    private lazy var textContextMenuController: ContextMenuController = {
        let bringToFrontAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_bringtofront", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? TextLabel else {
                return
            }

            if let overlayViewSuperview = overlayView.superview, currentOrder = overlayViewSuperview.subviews.indexOf(overlayView) {
                self?.undoManager?.registerUndoForTarget(overlayViewSuperview) { superview in
                    superview.insertSubview(overlayView, atIndex: currentOrder)
                }
            }

            overlayView.superview?.bringSubviewToFront(overlayView)

            self?.configuration.textOptionsToolControllerOptions.textContextActionSelectedClosure?(.BringToFront)
        }

        bringToFrontAction.accessibilityLabel = Localize("Bring to front")

        let deleteAction = ContextMenuAction(image: UIImage(named: "imgly_icon_option_delete", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!) { [weak self] _ in
            guard let overlayView = self?.selectedOverlayView as? TextLabel, overlayContainerView = self?.overlayContainerView else {
                return
            }

            self?.undoManager?.registerUndoForTarget(overlayContainerView) { view in
                view.addSubview(overlayView)
            }

            overlayView.removeFromSuperview()

            if let elements = self?.previewViewScrollingContainer?.accessibilityElements as? [NSObject], index = elements.indexOf({$0 == overlayView}) {
                self?.previewViewScrollingContainer?.accessibilityElements?.removeAtIndex(index)
            }

            self?.selectedOverlayView = nil
            self?.hideOptionsForOverlayIfNeeded()
            self?.configuration.textOptionsToolControllerOptions.textContextActionSelectedClosure?(.Delete)
        }

        deleteAction.accessibilityLabel = Localize("Delete")

        let contextMenu = ContextMenuController()
        contextMenu.menuColor = self.configuration.contextMenuBackgroundColor

        let actions: [ContextMenuAction] = self.configuration.textOptionsToolControllerOptions.allowedTextContextActions.map({
            switch $0 {
            case .BringToFront:
                self.configuration.textOptionsToolControllerOptions.contextActionConfigurationClosure?(bringToFrontAction, .BringToFront)
                return bringToFrontAction
            case .Delete:
                self.configuration.textOptionsToolControllerOptions.contextActionConfigurationClosure?(deleteAction, .Delete)
                return deleteAction
            case .Separator:
                return ContextMenuDividerAction()
            }
        })

        actions.forEach { contextMenu.addAction($0) }

        return contextMenu
    }()

    // MARK: - Initializers

    /**
    Returns a newly initialized photo edit view controller for the given photo with a default configuration.

    - parameter photo: The photo to edit.

    - returns: A newly initialized `PhotoEditViewController` object.
    */
    convenience public init(photo: UIImage) {
        self.init(photo: photo, configuration: Configuration())
    }

    /**
     Returns a newly initialized photo edit view controller for the given photo with the given configuration options.

     - parameter photo:         The photo to edit.
     - parameter configuration: The configuration options to apply.

     - returns: A newly initialized and configured `PhotoEditViewController` object.
     */
    required public init(photo: UIImage, configuration: Configuration) {
        self.photo = photo
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)

        updateLastKnownImageSize()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private var options: PhotoEditViewControllerOptions {
        return self.configuration.photoEditViewControllerOptions
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        previewViewScrollingContainer = UIScrollView()
        view.addSubview(previewViewScrollingContainer!)
        previewViewScrollingContainer!.delegate = self
        previewViewScrollingContainer!.alwaysBounceHorizontal = true
        previewViewScrollingContainer!.alwaysBounceVertical = true
        previewViewScrollingContainer!.showsHorizontalScrollIndicator = false
        previewViewScrollingContainer!.showsVerticalScrollIndicator = false
        previewViewScrollingContainer!.maximumZoomScale = 3
        previewViewScrollingContainer!.minimumZoomScale = 1
        previewViewScrollingContainer!.clipsToBounds = false

        automaticallyAdjustsScrollViewInsets = false

        let context = EAGLContext(API: .OpenGLES2)
        mainPreviewView = GLKView(frame: CGRect.zero, context: context)
        mainPreviewView!.delegate = self
        mainPreviewView!.isAccessibilityElement = true
        mainPreviewView!.accessibilityLabel = Localize("Photo")
        mainPreviewView!.accessibilityTraits |= UIAccessibilityTraitImage

        previewViewScrollingContainer!.addSubview(mainPreviewView!)
        previewViewScrollingContainer!.accessibilityElements = [mainPreviewView!]

        overlayContainerView = UIView()
        overlayContainerView!.clipsToBounds = true
        mainPreviewView!.addSubview(overlayContainerView!)

        frameImageView = UIImageView()
        frameImageView!.contentMode = options.frameScaleMode
        overlayContainerView!.addSubview(frameImageView!)

        view.setNeedsUpdateConstraints()
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loadPhotoEditModelIfNecessary()
        loadToolsIfNeeded()
        installGestureRecognizersIfNeeded()
        updateToolStackItem()
        updateBackgroundColor()
        updatePlaceholderImage()
        updateRenderedPreviewForceRender(false)
    }

    /**
     :nodoc:
     */
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateScrollViewContentSize()
    }

    /**
     :nodoc:
     */
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    /**
     :nodoc:
     */
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()

        updatePreviewContainerLayout()

        if let placeholderImageView = placeholderImageView, _ = previewViewScrollingContainer where placeholderImageViewConstraints == nil {
            placeholderImageView.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .Width, relatedBy: .Equal, toItem: mainPreviewView, attribute: .Width, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .Height, relatedBy: .Equal, toItem: mainPreviewView, attribute: .Height, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .CenterX, relatedBy: .Equal, toItem: mainPreviewView, attribute: .CenterX, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .CenterY, relatedBy: .Equal, toItem: mainPreviewView, attribute: .CenterY, multiplier: 1, constant: 0))

            placeholderImageViewConstraints = constraints
            NSLayoutConstraint.activateConstraints(constraints)
        }
    }

    // MARK: - Notification Callbacks

    @objc private func photoEditModelDidChange(notification: NSNotification) {
        updateRenderedPreviewForceRender(false)
    }

    // MARK: - Setup

    internal func updateLayoutForNewToolController() {
        updateRenderedPreviewForceRender(false)
        previewViewScrollingContainerLayoutValid = false
        updateLastKnownImageSize()
        updatePreviewContainerLayout()
        updateScrollViewZoomScaleAnimated(false)
        view.layoutIfNeeded()
        updateScrollViewContentSize()
        updateBackgroundColor()

        if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) {
            previewViewScrollingContainer?.panGestureRecognizer.enabled = currentEditingTool.wantsScrollingInDefaultPreviewViewEnabled
            previewViewScrollingContainer?.pinchGestureRecognizer?.enabled = currentEditingTool.wantsScrollingInDefaultPreviewViewEnabled
        } else {
            previewViewScrollingContainer?.panGestureRecognizer.enabled = true
            previewViewScrollingContainer?.pinchGestureRecognizer?.enabled = true
        }
    }

    private func loadPhotoEditModelIfNecessary() {
        if photoEditModel == nil {
            let editModel = IMGLYPhotoEditMutableModel()

            if let photoEffectIdentifier = initialPhotoEffectIdentifier where editModel.effectFilterIdentifier != photoEffectIdentifier {
                editModel.effectFilterIdentifier = photoEffectIdentifier
            }

            if let photoEffectIntensity = initialPhotoEffectIntensity where editModel.effectFilterIntensity != CGFloat(photoEffectIntensity) {
                editModel.effectFilterIntensity = CGFloat(photoEffectIntensity)
            }

            loadBaseImageIfNecessary()
            photoEditModel = editModel
            uneditedPhotoEditModel = editModel
        }
    }

    private func installGestureRecognizersIfNeeded() {
        if tapGestureRecognizer == nil {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handleTap(_:)))
            view.addGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = tapGestureRecognizer
        }

        if panGestureRecognizer == nil {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handlePan(_:)))
            panGestureRecognizer.delegate = self
            view.addGestureRecognizer(panGestureRecognizer)
            self.panGestureRecognizer = panGestureRecognizer
        }

        if pinchGestureRecognizer == nil {
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handlePinch(_:)))
            pinchGestureRecognizer.delegate = self
            view.addGestureRecognizer(pinchGestureRecognizer)
            self.pinchGestureRecognizer = pinchGestureRecognizer
        }

        if rotationGestureRecognizer == nil {
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handleRotation(_:)))
            rotationGestureRecognizer.delegate = self
            view.addGestureRecognizer(rotationGestureRecognizer)
            self.rotationGestureRecognizer = rotationGestureRecognizer
        }
    }

    private func updateToolStackItem() {
        if collectionView == nil {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .Horizontal
            flowLayout.minimumLineSpacing = 8

            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PhotoEditViewController.IconCaptionCollectionViewCellReuseIdentifier)
            collectionView.registerClass(SeparatorCollectionViewCell.self, forCellWithReuseIdentifier: PhotoEditViewController.SeparatorCollectionViewCellReuseIdentifier)

            self.collectionView = collectionView

            toolStackItem.performChanges {
                toolStackItem.mainToolbarView = collectionView

                if let applyButton = toolStackItem.applyButton {
                    applyButton.addTarget(self, action: #selector(PhotoEditViewController.save(_:)), forControlEvents: .TouchUpInside)
                    applyButton.accessibilityLabel = Localize("Save photo")
                    options.applyButtonConfigurationClosure?(applyButton)
                }

                if let discardButton = toolStackItem.discardButton {
                    discardButton.addTarget(self, action: #selector(PhotoEditViewController.cancel(_:)), forControlEvents: .TouchUpInside)
                    discardButton.accessibilityLabel = Localize("Discard photo")
                    options.discardButtonConfigurationClosure?(discardButton)
                }

                toolStackItem.titleLabel?.text = options.title
            }
        }
    }

    private func updateBackgroundColor() {
        view.backgroundColor = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredPreviewBackgroundColor ?? (options.backgroundColor ?? configuration.backgroundColor)
    }

    private func loadBaseImageIfNecessary() {
        if let _ = baseWorkUIImage {
            return
        }

        guard let photo = photo else {
            return
        }

        let screen = UIScreen.mainScreen()
        var targetSize = workImageSizeForScreen(screen)

        if photo.size.width > photo.size.height {
            let aspectRatio = photo.size.height / photo.size.width
            targetSize = CGSize(width: targetSize.width, height: targetSize.height * aspectRatio)
        } else if photo.size.width < photo.size.height {
            let aspectRatio = photo.size.width / photo.size.height
            targetSize = CGSize(width: targetSize.width * aspectRatio, height: targetSize.height)
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let resizedImage = photo.normalizedImageOfSize(targetSize)

            dispatch_async(dispatch_get_main_queue()) {
                self.baseWorkUIImage = resizedImage
                self.updateRenderedPreviewForceRender(false)
            }
        }
    }

    private func updateMainRenderer() {
        if mainRenderer == nil {
            if let photoEditModel = photoEditModel, baseWorkCIImage = baseWorkCIImage {
                mainRenderer = PhotoEditRenderer()
                mainRenderer!.photoEditModel = photoEditModel
                mainRenderer!.originalImage = baseWorkCIImage
                updateLastKnownImageSize()
                view.setNeedsLayout()
                updateRenderedPreviewForceRender(false)
            }
        }
    }

    internal func updateLastKnownImageSize() {
        let workImageSize: CGSize

        if let renderer = mainRenderer {
            workImageSize = renderer.outputImageSize
        } else if let photo = photo {
            workImageSize = photo.size * UIScreen.mainScreen().scale
        } else {
            workImageSize = CGSize.zero
        }

        if workImageSize != lastKnownWorkImageSize {
            lastKnownWorkImageSize = workImageSize
            updateScrollViewContentSize()
            updateRenderedPreviewForceRender(false)
        }
    }

    private func updatePlaceholderImage() {
        if isViewLoaded() {
            let showPlaceholderImageView: Bool

            if let _ = baseWorkUIImage {
                showPlaceholderImageView = false
            } else {
                showPlaceholderImageView = true
            }

            if let photo = photo where showPlaceholderImageView {
                if placeholderImageView == nil {
                    placeholderImageView = UIImageView(image: photo)
                    placeholderImageView!.contentMode = .ScaleAspectFit
                    previewViewScrollingContainer?.addSubview(placeholderImageView!)
                    updateSubviewsOrdering()
                    view.setNeedsUpdateConstraints()
                }

                placeholderImageView?.hidden = false
            } else {
                if let placeholderImageView = placeholderImageView {
                    placeholderImageView.hidden = true

                    if photo == nil {
                        placeholderImageView.removeFromSuperview()
                        self.placeholderImageView = nil
                        placeholderImageViewConstraints = nil
                    }
                }
            }
        }
    }

    private func updateSubviewsOrdering() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        view.sendSubviewToBack(previewViewScrollingContainer)

        if let mainPreviewView = mainPreviewView {
            previewViewScrollingContainer.sendSubviewToBack(mainPreviewView)
        }

        if let placeholderImageView = placeholderImageView {
            previewViewScrollingContainer.sendSubviewToBack(placeholderImageView)
        }
    }

    private func updatePreviewContainerLayout() {
        if previewViewScrollingContainerLayoutValid {
            return
        }

        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        if let previewViewScrollingContainerConstraints = previewViewScrollingContainerConstraints {
            NSLayoutConstraint.deactivateConstraints(previewViewScrollingContainerConstraints)
            self.previewViewScrollingContainerConstraints = nil
        }

        previewViewScrollingContainer.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        var previewViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 124, right: 0)
        if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) {
            previewViewInsets = previewViewInsets + currentEditingTool.preferredPreviewViewInsets
        }

        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Left, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Left, multiplier: 1, constant: previewViewInsets.left))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Right, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Right, multiplier: 1, constant: -1 * previewViewInsets.right))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Top, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Top, multiplier: 1, constant: previewViewInsets.top))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Bottom, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Bottom, multiplier: 1, constant: -1 * previewViewInsets.bottom))

        NSLayoutConstraint.activateConstraints(constraints)
        previewViewScrollingContainerConstraints = constraints
        previewViewScrollingContainerLayoutValid = true
    }

    internal func updateRenderedPreviewForceRender(forceRender: Bool) {
        mainRenderer?.renderMode = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredRenderMode ?? [.AutoEnhancement, .Crop, .Orientation, .Focus, .PhotoEffect, .ColorAdjustments, .RetricaFilter]

        let updatePreviewView: Bool

        if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) where !currentEditingTool.wantsDefaultPreviewView {
            updatePreviewView = false
        } else {
            updatePreviewView = baseWorkUIImage == nil ? false : true
        }

        mainPreviewView?.hidden = !updatePreviewView

        if let _ = mainRenderer where updatePreviewView || forceRender {
            mainPreviewView?.setNeedsDisplay()
        }

        frameController?.updatePositioning()
    }

    // MARK: - Helpers

    private func workImageSizeForScreen(screen: UIScreen) -> CGSize {
        let screenSize = screen.bounds.size
        let screenScale = screen.scale

        let scaledScreenSize = screenSize * screenScale
        let maxLength = max(scaledScreenSize.width, scaledScreenSize.height)

        return CGSize(width: maxLength, height: maxLength)
    }

    private func orientedCIImageFromUIImage(image: UIImage) -> CIImage {
        guard let cgImage = image.CGImage else {
            return CIImage.emptyImage()
        }

        var ciImage = CIImage(CGImage: cgImage)
        ciImage = ciImage.imageByApplyingOrientation(Int32(image.imageOrientation.rawValue))
        return ciImage
    }

    private func scaleSize(size: CGSize, toFitSize targetSize: CGSize) -> CGSize {
        if size == CGSize.zero {
            return CGSize.zero
        }

        let scale = min(targetSize.width / size.width, targetSize.height / size.height)

        return size * scale
    }

    // MARK: - Tools

    private func loadToolsIfNeeded() {
        if toolForAction == nil {
            var toolForAction = [PhotoEditorAction: PhotoEditToolController]()

            for i in 0 ..< options.allowedPhotoEditorActions.count {
                let action = options.allowedPhotoEditorActions[i]

                if let photoEditModel = photoEditModel, toolController = InstanceFactory.toolControllerForEditorActionType(action, withPhotoEditModel: photoEditModel, configuration: configuration) {
                    toolController.delegate = self
                    toolForAction[action] = toolController
                }
            }

            self.toolForAction = toolForAction
        }
    }

    // MARK: - Overlays

    @objc private func removeStickerOverlay(overlayView: StickerImageView?) {
        guard let overlayView = overlayView else {
            return
        }

        configuration.stickerToolControllerOptions.removedStickerClosure?(overlayView.sticker)
        overlayView.removeFromSuperview()

        if let elements = previewViewScrollingContainer?.accessibilityElements as? [NSObject], index = elements.indexOf({$0 == overlayView}) {
            previewViewScrollingContainer?.accessibilityElements?.removeAtIndex(index)
        }
    }

    private func loadFrameControllerIfNeeded() {
        loadToolsIfNeeded()

        if let _ = toolForAction?[.Frame] where frameController == nil {
            frameController = FrameController()
            frameController!.delegate = self
            frameController!.imageView = frameImageView
            frameController!.imageViewContainerView = mainPreviewView

            if let baseWorkUIImage = baseWorkUIImage {
                frameController!.imageRatio = Float(baseWorkUIImage.size.width / baseWorkUIImage.size.height)
            }
        }
    }

    // MARK: - Actions

    /**
    Applies all changes to the photo and passes the edited image to the `delegate`.

    - parameter sender: The object that initiated the request.
    */
    public func save(sender: AnyObject?) {
        ProgressView.sharedView.showWithMessage(Localize("Exporting image..."))
        // Load photo from disc
        if let photoFileURL = photoFileURL, path = photoFileURL.path, photo = UIImage(contentsOfFile: path) {
            if let mainPreviewView = mainPreviewView where photoEditModel == uneditedPhotoEditModel && mainPreviewView.subviews.count == 0 {
                ProgressView.sharedView.hide()
                delegate?.photoEditViewController(self, didSaveImage: photo)
            } else if let cgImage = photo.CGImage {
                var ciImage = CIImage(CGImage: cgImage)
                ciImage = ciImage.imageByApplyingOrientation(Int32(IMGLYOrientation(imageOrientation: photoImageOrientation).rawValue))

                let photoEditRenderer = PhotoEditRenderer()
                photoEditRenderer.photoEditModel = photoEditModel?.mutableCopy() as? IMGLYPhotoEditMutableModel
                photoEditRenderer.originalImage = ciImage

                // Generate overlay if needed
                if let overlayContainerView = self.overlayContainerView where overlayContainerView.subviews.count > 0 {
                    // Scale overlayContainerView to match the size of the high resolution photo
                    let scale = photoEditRenderer.outputImageSize.width / overlayContainerView.bounds.width
                    let scaledSize = overlayContainerView.bounds.size * scale
                    let rect = CGRect(origin: .zero, size: scaledSize)

                    // Create new image context
                    UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1)

                    let cachedTransform = overlayContainerView.transform
                    overlayContainerView.transform = CGAffineTransformScale(overlayContainerView.transform, scale, scale)

                    // Draw the overlayContainerView on top of the image
                    overlayContainerView.drawViewHierarchyInRect(rect, afterScreenUpdates: false)

                    // Restore old transform
                    overlayContainerView.transform = cachedTransform

                    // Fetch image and end context
                    if let cgImage = UIGraphicsGetImageFromCurrentImageContext().CGImage {
                        (photoEditRenderer.photoEditModel as? IMGLYPhotoEditMutableModel)?.overlayImage = CIImage(CGImage: cgImage)
                    }

                    UIGraphicsEndImageContext()
                }

                let compressionQuality = CGFloat(0.9)

                photoEditRenderer.generateOutputImageDataWithCompressionQuality(compressionQuality, metadataSourceImageURL: photoFileURL) { imageData, imageWidth, imageHeight in
                    dispatch_async(dispatch_get_main_queue()) {
                        ProgressView.sharedView.hide()

                        guard let imageData = imageData, image = UIImage(data: imageData) else {
                            dispatch_async(dispatch_get_main_queue()) {
                                ProgressView.sharedView.hide()
                            }

                            self.delegate?.photoEditViewControllerDidFailToGeneratePhoto(self)
                            return
                        }

                        self.delegate?.photoEditViewController(self, didSaveImage: image)

                        // Remove temporary file from disc
                        _ = try? NSFileManager.defaultManager().removeItemAtURL(photoFileURL)
                    }
                }
            }
        }
    }

    /**
     Discards all changes to the photo and call the `delegate`.

     - parameter sender: The object that initiated the request.
     */
    public func cancel(sender: AnyObject?) {
        if let photoFileURL = photoFileURL {
            // Remove temporary file from disc
            _ = try? NSFileManager.defaultManager().removeItemAtURL(photoFileURL)
        }

        delegate?.photoEditViewControllerDidCancel(self)
    }

    // MARK: - Gesture Handling

    private func hideOptionsForOverlayIfNeeded() {
        if selectedOverlayView == nil {
            if presentedViewController is ContextMenuController {
                dismissViewControllerAnimated(true, completion: nil)
            }

            if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) {
                if currentEditingTool is TextOptionsToolController {
                    delegate?.photoEditViewControllerPopToolController(self)
                } else if currentEditingTool is StickerToolController {
                    delegate?.photoEditViewControllerPopToolController(self)
                }
            }
        }
    }

    private func showOptionsForOverlayIfNeeded(view: UIView?) {
        if let view = view as? StickerImageView {
            showOptionsForStickerIfNeeded(view)
        } else if let view = view as? TextLabel {
            showOptionsForTextIfNeeded(view)
        }
    }

    private func showOptionsForStickerIfNeeded(stickerImageView: StickerImageView) {
        guard let photoEditModel = photoEditModel else {
            return
        }

        if !(delegate?.photoEditViewControllerCurrentEditingTool(self) is StickerToolController) {
            // swiftlint:disable force_cast
            let stickerOptionsToolController = (configuration.getClassForReplacedClass(StickerToolController.self) as! StickerToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
            // swiftlint:enable force_cast

            stickerOptionsToolController.delegate = self

            if delegate?.photoEditViewControllerCurrentEditingTool(self) is TextOptionsToolController {
                delegate?.photoEditViewController(self, didSelectToolController: stickerOptionsToolController, wantsCurrentTopToolControllerReplaced: true)
            } else {
                delegate?.photoEditViewController(self, didSelectToolController: stickerOptionsToolController, wantsCurrentTopToolControllerReplaced: false)
            }
        }

        let configurePresentationController = {
            if let contextMenuPresentationController = self.stickerContextMenuController.presentationController as? ContextMenuPresentationController {
                var viewController: UIViewController = self

                while let parent = viewController.parentViewController {
                    viewController = parent
                }

                contextMenuPresentationController.passthroughViews = [viewController.view]
                contextMenuPresentationController.contentFrame = self.previewViewScrollingContainer?.convertRect(self.previewViewScrollingContainer?.bounds ?? .zero, toView: nil)

                if var contentFrame = contextMenuPresentationController.contentFrame where contentFrame.origin.y < self.topLayoutGuide.length {
                    contentFrame.size.height = contentFrame.size.height - self.topLayoutGuide.length - contentFrame.origin.y
                    contentFrame.origin.y = self.topLayoutGuide.length
                    contextMenuPresentationController.contentFrame = contentFrame
                }
            }
        }

        if presentedViewController == nil {
            presentViewController(stickerContextMenuController, animated: true, completion: nil)
            configurePresentationController()
        } else if presentedViewController == textContextMenuController {
            dismissViewControllerAnimated(false) {
                self.presentViewController(self.stickerContextMenuController, animated: false, completion: nil)
                configurePresentationController()
            }
        }
    }

    private func showOptionsForTextIfNeeded(label: TextLabel) {
        guard let photoEditModel = photoEditModel else {
            return
        }

        if !(delegate?.photoEditViewControllerCurrentEditingTool(self) is TextOptionsToolController) {
            // swiftlint:disable force_cast
            let textOptionsToolController = (configuration.getClassForReplacedClass(TextOptionsToolController.self) as! TextOptionsToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
            // swiftlint:enable force_cast

            textOptionsToolController.delegate = self

            if delegate?.photoEditViewControllerCurrentEditingTool(self) is TextToolController || delegate?.photoEditViewControllerCurrentEditingTool(self) is StickerToolController {
                delegate?.photoEditViewController(self, didSelectToolController: textOptionsToolController, wantsCurrentTopToolControllerReplaced: true)
            } else {
                delegate?.photoEditViewController(self, didSelectToolController: textOptionsToolController, wantsCurrentTopToolControllerReplaced: false)
            }
        }

        let configurePresentationController = {
            if let contextMenuPresentationController = self.textContextMenuController.presentationController as? ContextMenuPresentationController {
                var viewController: UIViewController = self

                while let parent = viewController.parentViewController {
                    viewController = parent
                }

                contextMenuPresentationController.passthroughViews = [viewController.view]
                contextMenuPresentationController.contentFrame = self.previewViewScrollingContainer?.convertRect(self.previewViewScrollingContainer?.bounds ?? .zero, toView: nil)

                if var contentFrame = contextMenuPresentationController.contentFrame where contentFrame.origin.y < self.topLayoutGuide.length {
                    contentFrame.size.height = contentFrame.size.height - self.topLayoutGuide.length - contentFrame.origin.y
                    contentFrame.origin.y = self.topLayoutGuide.length
                    contextMenuPresentationController.contentFrame = contentFrame
                }
            }
        }

        if presentedViewController == nil {
            presentViewController(textContextMenuController, animated: true, completion: nil)
            configurePresentationController()
        } else if presentedViewController == stickerContextMenuController {
            dismissViewControllerAnimated(false) {
                self.presentViewController(self.textContextMenuController, animated: false, completion: nil)
                configurePresentationController()
            }
        }
    }

    @objc private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let view = gestureRecognizer.view
        let location = gestureRecognizer.locationInView(view)
        let target = view?.hitTest(location, withEvent: nil)

        if let target = target as? StickerImageView {
            selectedOverlayView = target
            showOptionsForStickerIfNeeded(target)
        } else if let target = target as? TextLabel {
            selectedOverlayView = target
            showOptionsForTextIfNeeded(target)
        } else {
            selectedOverlayView = nil
            hideOptionsForOverlayIfNeeded()
            undoManager?.removeAllActions()
        }
    }

    @objc private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let mainPreviewView = mainPreviewView, mainRenderer = mainRenderer else {
            return
        }

        let location = gestureRecognizer.locationInView(mainPreviewView)
        let translation = gestureRecognizer.translationInView(mainPreviewView)

        let targetView = mainPreviewView.hitTest(location, withEvent: nil)

        switch gestureRecognizer.state {
        case .Began:
            if targetView is StickerImageView || targetView is TextLabel {
                draggedOverlayView = targetView
                selectedOverlayView = targetView
                showOptionsForOverlayIfNeeded(targetView)
            }
        case .Changed:
            if let draggedOverlayView = draggedOverlayView {

                let center = draggedOverlayView.center

                undoManager?.registerUndoForTarget(draggedOverlayView) { view in
                    view.center = center
                }

                draggedOverlayView.center = center + translation
            }

            let renderMode = mainRenderer.renderMode
            mainRenderer.renderMode = mainRenderer.renderMode.subtract(.Crop)
            let outputImageSize = mainRenderer.outputImageSize
            mainRenderer.renderMode = renderMode

            if let stickerImageView = draggedOverlayView as? StickerImageView, photoEditModel = photoEditModel {
                stickerImageView.normalizedCenterInImage = normalizePoint(stickerImageView.center, inView: mainPreviewView, baseImageSize: outputImageSize, normalizedCropRect: photoEditModel.normalizedCropRect)
            } else if let textLabel = draggedOverlayView as? TextLabel, photoEditModel = photoEditModel {
                textLabel.normalizedCenterInImage = normalizePoint(textLabel.center, inView: mainPreviewView, baseImageSize: outputImageSize, normalizedCropRect: photoEditModel.normalizedCropRect)
            }

            gestureRecognizer.setTranslation(CGPoint.zero, inView: mainPreviewView)
        case .Cancelled, .Ended:
            draggedOverlayView = nil
        default:
            break
        }
    }

    @objc private func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        guard let mainPreviewView = mainPreviewView else {
            return
        }

        if gestureRecognizer.numberOfTouches() >= 2 {
            let point1 = gestureRecognizer.locationOfTouch(0, inView: mainPreviewView)
            let point2 = gestureRecognizer.locationOfTouch(1, inView: mainPreviewView)
            let midPoint = point1 + CGVector(startPoint: point1, endPoint: point2) * 0.5
            let scale = gestureRecognizer.scale

            let targetView = mainPreviewView.hitTest(midPoint, withEvent: nil)

            switch gestureRecognizer.state {
            case .Began:
                if targetView is StickerImageView || targetView is TextLabel {
                    draggedOverlayView = targetView
                    selectedOverlayView = targetView
                    showOptionsForOverlayIfNeeded(targetView)
                }
            case .Changed:
                if let draggedOverlayView = draggedOverlayView as? StickerImageView {
                    let transform = draggedOverlayView.transform

                    undoManager?.registerUndoForTarget(draggedOverlayView) { view in
                        draggedOverlayView.transform = transform
                    }

                    draggedOverlayView.transform = CGAffineTransformScale(transform, scale, scale)

                    if let selectedOverlayView = selectedOverlayView {
                        selectedOverlayView.layer.borderWidth = 2 / (0.5 * (draggedOverlayView.transform.xScale + draggedOverlayView.transform.yScale))
                    }
                } else if let draggedOverlayView = draggedOverlayView as? TextLabel {
                    let fontSize = draggedOverlayView.font.pointSize

                    undoManager?.registerUndoForTarget(draggedOverlayView) { view in
                        view.font = draggedOverlayView.font.fontWithSize(fontSize)
                        view.sizeToFit()
                    }

                    draggedOverlayView.font = draggedOverlayView.font.fontWithSize(fontSize * scale)
                    draggedOverlayView.sizeToFit()
                }

                gestureRecognizer.scale = 1
            case .Cancelled, .Ended:
                draggedOverlayView = nil
            default:
                break
            }
        }
    }

    @objc private func handleRotation(gestureRecognizer: UIRotationGestureRecognizer) {
        guard let mainPreviewView = mainPreviewView else {
            return
        }

        if gestureRecognizer.numberOfTouches() >= 2 {
            let point1 = gestureRecognizer.locationOfTouch(0, inView: mainPreviewView)
            let point2 = gestureRecognizer.locationOfTouch(1, inView: mainPreviewView)
            let midPoint = point1 + CGVector(startPoint: point1, endPoint: point2) * 0.5
            let rotation = gestureRecognizer.rotation

            let targetView = mainPreviewView.hitTest(midPoint, withEvent: nil)

            switch gestureRecognizer.state {
            case .Began:
                if targetView is StickerImageView || targetView is TextLabel {
                    draggedOverlayView = targetView
                    selectedOverlayView = targetView
                    showOptionsForOverlayIfNeeded(targetView)
                }
            case .Changed:
                if let draggedOverlayView = draggedOverlayView {
                    let transform = draggedOverlayView.transform

                    undoManager?.registerUndoForTarget(draggedOverlayView) { view in
                        draggedOverlayView.transform = transform
                    }

                    draggedOverlayView.transform = CGAffineTransformRotate(transform, rotation)
                }

                gestureRecognizer.rotation = 0
            case .Cancelled, .Ended:
                draggedOverlayView = nil
            default:
                break
            }
        }
    }

    // MARK: - Orientation Handling

    private func normalizePoint(point: CGPoint, inView view: UIView, baseImageSize: CGSize, normalizedCropRect: CGRect) -> CGPoint {
        if normalizedCropRect == IMGLYPhotoEditModel.identityNormalizedCropRect() {
            return CGPoint(x: point.x / view.bounds.width, y: point.y / view.bounds.height)
        }

        let convertedNormalizedCropRect = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.size.height, width: normalizedCropRect.size.width, height: normalizedCropRect.size.height)

        let denormalizedCropRect = CGRect(
            x: convertedNormalizedCropRect.origin.x * baseImageSize.width,
            y: convertedNormalizedCropRect.origin.y * baseImageSize.height,
            width: convertedNormalizedCropRect.size.width * baseImageSize.width,
            height: convertedNormalizedCropRect.size.height * baseImageSize.height
        )

        let viewToCroppedImageScale = denormalizedCropRect.size.width / view.bounds.width
        let pointInCropRect = CGPoint(x: point.x * viewToCroppedImageScale, y: point.y * viewToCroppedImageScale)
        let pointInImage = CGPoint(x: pointInCropRect.x + denormalizedCropRect.origin.x, y: pointInCropRect.y + denormalizedCropRect.origin.y)

        return CGPoint(x: pointInImage.x / baseImageSize.width, y: pointInImage.y / baseImageSize.height)
    }

    private func updateFromOrientation(fromOrientation: IMGLYOrientation, toOrientation: IMGLYOrientation) {
        if fromOrientation != toOrientation {
            updateCropRectFromOrientation(fromOrientation, toOrientation: toOrientation)
            updateOverlaysFromOrientation(fromOrientation, toOrientation: toOrientation)
            updateFocusControlPointsFromOrientation(fromOrientation, toOrientation: toOrientation)
        }
    }

    private func updateOverlaysFromOrientation(fromOrientation: IMGLYOrientation, toOrientation: IMGLYOrientation) {
        guard let overlayContainerView = overlayContainerView, mainPreviewView = mainPreviewView, mainRenderer = mainRenderer, containerBounds = previewViewScrollingContainer?.bounds else {
            return
        }

        let outputImageSize = mainRenderer.outputImageSize
        let newPreviewSize = scaleSize(outputImageSize, toFitSize: containerBounds.size)

        let scale: CGFloat
        if newPreviewSize == mainPreviewView.bounds.size {
            scale = 1
        } else {
            scale = min(newPreviewSize.width / overlayContainerView.bounds.height, newPreviewSize.height / overlayContainerView.bounds.width)
        }

        let geometry = ImageGeometry(inputSize: overlayContainerView.bounds.size)
        geometry.appliedOrientation = toOrientation

        let transform = geometry.transformFromOrientation(fromOrientation)

        for overlay in overlayContainerView.subviews {
            if overlay is StickerImageView || overlay is TextLabel {
                overlay.center = CGPointApplyAffineTransform(overlay.center, transform)
                overlay.center = CGPoint(x: overlay.center.x * scale, y: overlay.center.y * scale)
                overlay.transform = CGAffineTransformScale(overlay.transform, scale, scale)

                var stickerTransform = transform
                stickerTransform.tx = 0
                stickerTransform.ty = 0
                overlay.transform = CGAffineTransformConcat(overlay.transform, stickerTransform)
            }

            if let stickerImageView = overlay as? StickerImageView {
                let normalizedGeometry = ImageGeometry(inputSize: CGSize(width: 1, height: 1))
                normalizedGeometry.appliedOrientation = geometry.appliedOrientation
                stickerImageView.normalizedCenterInImage = CGPointApplyAffineTransform(stickerImageView.normalizedCenterInImage, normalizedGeometry.transformFromOrientation(fromOrientation))
            } else if let textLabel = overlay as? TextLabel {
                let normalizedGeometry = ImageGeometry(inputSize: CGSize(width: 1, height: 1))
                normalizedGeometry.appliedOrientation = geometry.appliedOrientation
                textLabel.normalizedCenterInImage = CGPointApplyAffineTransform(textLabel.normalizedCenterInImage, normalizedGeometry.transformFromOrientation(fromOrientation))
            }
        }
    }

    private func updateCropRectFromOrientation(fromOrientation: IMGLYOrientation, toOrientation: IMGLYOrientation) {
        guard let photoEditModel = photoEditModel else {
            return
        }

        let geometry = ImageGeometry(inputSize: CGSize(width: 1, height: 1))
        geometry.appliedOrientation = toOrientation

        let transform = geometry.transformFromOrientation(fromOrientation)

        var normalizedCropRect = photoEditModel.normalizedCropRect

        // Change origin from bottom left to top left, otherwise the transform won't work
        normalizedCropRect = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.height, width: normalizedCropRect.width, height: normalizedCropRect.height)

        // Apply transform
        normalizedCropRect = CGRectApplyAffineTransform(normalizedCropRect, transform)

        // Change origin from top left to bottom left again
        normalizedCropRect = CGRect(x: normalizedCropRect.origin.x, y: 1 - normalizedCropRect.origin.y - normalizedCropRect.height, width: normalizedCropRect.width, height: normalizedCropRect.height)

        photoEditModel.normalizedCropRect = normalizedCropRect
    }

    private func updateFocusControlPointsFromOrientation(fromOrientation: IMGLYOrientation, toOrientation: IMGLYOrientation) {
        guard let photoEditModel = photoEditModel else {
            return
        }

        let geometry = ImageGeometry(inputSize: CGSize(width: 1, height: 1))
        geometry.appliedOrientation = toOrientation

        let transform = geometry.transformFromOrientation(fromOrientation)

        var controlPoint1 = photoEditModel.focusNormalizedControlPoint1
        var controlPoint2 = photoEditModel.focusNormalizedControlPoint2

        // Change origin from bottom left to top left, otherwise the transform won't work
        controlPoint1 = CGPoint(x: controlPoint1.x, y: 1 - controlPoint1.y)
        controlPoint2 = CGPoint(x: controlPoint2.x, y: 1 - controlPoint2.y)

        // Apply transform
        controlPoint1 = CGPointApplyAffineTransform(controlPoint1, transform)
        controlPoint2 = CGPointApplyAffineTransform(controlPoint2, transform)

        // Change origin from top left to bottom left again
        controlPoint1 = CGPoint(x: controlPoint1.x, y: 1 - controlPoint1.y)
        controlPoint2 = CGPoint(x: controlPoint2.x, y: 1 - controlPoint2.y)

        photoEditModel.focusNormalizedControlPoint1 = controlPoint1
        photoEditModel.focusNormalizedControlPoint2 = controlPoint2
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: GLKViewDelegate {
    /**
     :nodoc:
     */
    public func glkView(view: GLKView, drawInRect rect: CGRect) {
        if let renderer = mainRenderer {
            renderer.drawOutputImageInContext(view.context, inRect: CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight), viewportWidth: view.drawableWidth, viewportHeight: view.drawableHeight)

            nextRenderCompletionBlock?()
            nextRenderCompletionBlock = nil
        }
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: UIScrollViewDelegate {
    private func updateScrollViewCentering() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        let containerSize = previewViewScrollingContainer.bounds.size
        let contentSize = previewViewScrollingContainer.contentSize

        let horizontalCenterOffset: CGFloat

        if contentSize.width < containerSize.width {
            horizontalCenterOffset = (containerSize.width - contentSize.width) * 0.5
        } else {
            horizontalCenterOffset = 0
        }

        let verticalCenterOffset: CGFloat

        if contentSize.height < containerSize.height {
            verticalCenterOffset = (containerSize.height - contentSize.height) * 0.5
        } else {
            verticalCenterOffset = 0
        }

        mainPreviewView?.center = CGPoint(
            x: contentSize.width * 0.5 + horizontalCenterOffset,
            y: contentSize.height * 0.5 + verticalCenterOffset
        )
    }

    private func updateScrollViewContentSize() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        let zoomScale = previewViewScrollingContainer.zoomScale
        let workImageSize = lastKnownWorkImageSize
        let containerSize = previewViewScrollingContainer.bounds.size

        let fittedSize = scaleSize(workImageSize, toFitSize: containerSize)

        if lastKnownPreviewViewSize != fittedSize {
            previewViewScrollingContainer.zoomScale = 1
            lastKnownPreviewViewSize = fittedSize

            mainPreviewView?.frame = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
            overlayContainerView?.frame = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
            previewViewScrollingContainer.contentSize = fittedSize
            previewViewScrollingContainer.zoomScale = zoomScale
        }

        updateScrollViewCentering()
    }

    private func updateScrollViewZoomScaleAnimated(animated: Bool) {
        if selectedOverlayView != nil {
            previewViewScrollingContainer?.minimumZoomScale = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1
            previewViewScrollingContainer?.maximumZoomScale = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1
            previewViewScrollingContainer?.setZoomScale(delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1, animated: animated)
            previewViewScrollingContainer?.scrollEnabled = false
        } else {
            previewViewScrollingContainer?.minimumZoomScale = min(delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1, 1)
            previewViewScrollingContainer?.maximumZoomScale = max(delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1, 3)
            previewViewScrollingContainer?.setZoomScale(delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredDefaultPreviewViewScale ?? 1, animated: animated)
            previewViewScrollingContainer?.scrollEnabled = true
        }
    }

    /**
     :nodoc:
     */
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        if previewViewScrollingContainer == scrollView {
            updateScrollViewCentering()
        }
    }

    /**
     :nodoc:
     */
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if previewViewScrollingContainer == scrollView {
            mainPreviewView?.contentScaleFactor = scale * UIScreen.mainScreen().scale
            updateRenderedPreviewForceRender(false)
        }
    }

    /**
     :nodoc:
     */
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if !options.allowsPreviewImageZoom {
            return nil
        }

        if previewViewScrollingContainer == scrollView {
            return mainPreviewView
        }

        return nil
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: UICollectionViewDataSource {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.allowedPhotoEditorActions.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let actionType = options.allowedPhotoEditorActions[indexPath.item]

        if actionType == .Separator {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoEditViewController.SeparatorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let separatorCell = cell as? SeparatorCollectionViewCell {
                separatorCell.separator.backgroundColor = configuration.separatorColor
            }

            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoEditViewController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            switch actionType {
            case .Separator:
                fallthrough
            case .Crop:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_crop", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Crop")
                iconCaptionCell.accessibilityLabel = Localize("Crop")
            case .Orientation:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_orientation", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Orientation")
                iconCaptionCell.accessibilityLabel = Localize("Orientation")
            case .Filter:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_filters", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Filter")
                iconCaptionCell.accessibilityLabel = Localize("Filter")
            case .RetricaFilter:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_filters", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Filter")
                iconCaptionCell.accessibilityLabel = Localize("Filter")
            case .Adjust:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_adjust", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Adjust")
                iconCaptionCell.accessibilityLabel = Localize("Adjust")
            case .Text:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_text", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Text")
                iconCaptionCell.accessibilityLabel = Localize("Text")
            case .Sticker:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_sticker", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Sticker")
                iconCaptionCell.accessibilityLabel = Localize("Sticker")
            case .Focus:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_focus", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Focus")
                iconCaptionCell.accessibilityLabel = Localize("Focus")
            case .Frame:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_frame", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Frame")
                iconCaptionCell.accessibilityLabel = Localize("Frame")
            case .Magic:
                iconCaptionCell.imageView.image = UIImage(named: "imgly_icon_tool_magic", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                iconCaptionCell.captionLabel.text = Localize("Magic")
                iconCaptionCell.accessibilityLabel = Localize("Magic")
            }

            options.actionButtonConfigurationClosure?(iconCaptionCell, actionType)
        }
        return cell
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let actionType = options.allowedPhotoEditorActions[indexPath.item]

        if actionType == .Separator {
            return PhotoEditViewController.SeparatorCollectionViewCellSize
        }

        return PhotoEditViewController.IconCaptionCollectionViewCellSize
    }

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
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let actionType = options.allowedPhotoEditorActions[indexPath.item]

        if actionType == .Separator {
            return
        }

        options.photoEditorActionSelectedClosure?(actionType)

        if actionType == .Magic {
            guard let photoEditModel = photoEditModel else {
                return
            }

            photoEditModel.performChangesWithBlock {
                photoEditModel.autoEnhancementEnabled = !photoEditModel.autoEnhancementEnabled
            }
        } else {
            selectedOverlayView = nil
            hideOptionsForOverlayIfNeeded()

            if let toolController = toolForAction?[actionType] {
                delegate?.photoEditViewController(self, didSelectToolController: toolController, wantsCurrentTopToolControllerReplaced: false)
            }
        }

        collectionView.reloadItemsAtIndexPaths([indexPath])
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let actionType = options.allowedPhotoEditorActions[indexPath.item]
        if actionType == .Magic {
            if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
                if photoEditModel?.autoEnhancementEnabled ?? false {
                    iconCaptionCell.accessibilityTraits |= UIAccessibilityTraitSelected
                    iconCaptionCell.imageView.image = iconCaptionCell.imageView.image?.imageWithRenderingMode(.AlwaysTemplate)
                    iconCaptionCell.imageView.tintAdjustmentMode = .Dimmed
                } else {
                    iconCaptionCell.accessibilityTraits &= ~UIAccessibilityTraitSelected
                    iconCaptionCell.imageView.image = iconCaptionCell.imageView.image?.imageWithRenderingMode(.AlwaysTemplate)
                    iconCaptionCell.imageView.tintAdjustmentMode = .Normal
                }
            }
        }
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: PhotoEditToolControllerDelegate {
    /**
     :nodoc:
     */
    public func photoEditToolControllerMainRenderer(photoEditToolController: PhotoEditToolController) -> PhotoEditRenderer? {
        return mainRenderer
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerBaseImage(photoEditToolController: PhotoEditToolController) -> UIImage? {
        return baseWorkUIImage
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerPreviewViewScrollingContainer(photoEditToolController: PhotoEditToolController) -> UIScrollView? {
        return previewViewScrollingContainer
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerPreviewView(photoEditToolController: PhotoEditToolController) -> UIView? {
        return mainPreviewView
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerOverlayContainerView(photoEditToolController: PhotoEditToolController) -> UIView? {
        return overlayContainerView
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerOverlayViews(photoEditToolController: PhotoEditToolController) -> [UIView]? {
        return overlayContainerView?.subviews
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerFrameController(photoEditToolController: PhotoEditToolController) -> FrameController? {
        return frameController
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerDidFinish(photoEditToolController: PhotoEditToolController) {
        if presentedViewController is ContextMenuController && !(photoEditToolController is TextFontToolController || photoEditToolController is TextColorToolController) {
            selectedOverlayView = nil
            dismissViewControllerAnimated(true, completion: nil)
        }

        delegate?.photoEditViewControllerPopToolController(self)
    }

    /**
     :nodoc:
     */
    public func photoEditToolController(photoEditToolController: PhotoEditToolController, didDiscardChangesInFavorOfPhotoEditModel photoEditModel: IMGLYPhotoEditModel) {
        if presentedViewController is ContextMenuController && !(photoEditToolController is TextFontToolController || photoEditToolController is TextColorToolController) {
            selectedOverlayView = nil
            dismissViewControllerAnimated(true, completion: nil)
        }

        if let discardedPhotoEditModel = self.photoEditModel {
            updateFromOrientation(discardedPhotoEditModel.appliedOrientation, toOrientation: photoEditModel.appliedOrientation)
        }

        self.photoEditModel?.copyValuesFromModel(photoEditModel)

        delegate?.photoEditViewControllerPopToolController(self)
    }

    /**
     :nodoc:
     */
    public func photoEditToolController(photoEditToolController: PhotoEditToolController, didChangeToOrientation orientation: IMGLYOrientation, fromOrientation: IMGLYOrientation) {
        updateFromOrientation(fromOrientation, toOrientation: orientation)
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerDidChangePreferredRenderMode(photoEditToolController: PhotoEditToolController) {
        updateRenderedPreviewForceRender(false)
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerDidChangeWantsDefaultPreviewView(photoEditToolController: PhotoEditToolController) {
        updateRenderedPreviewForceRender(false)
    }

    /**
     :nodoc:
     */
    public func photoEditToolController(photoEditToolController: PhotoEditToolController, didAddOverlayView view: UIView) {
        guard let mainRenderer = mainRenderer else {
            return
        }

        let renderMode = mainRenderer.renderMode
        mainRenderer.renderMode = mainRenderer.renderMode.subtract(.Crop)
        let outputImageSize = mainRenderer.outputImageSize
        mainRenderer.renderMode = renderMode

        if let stickerImageView = view as? StickerImageView, photoEditModel = photoEditModel, mainPreviewView = mainPreviewView {
            undoManager?.registerUndoForTarget(self) { photoEditViewController in
                photoEditViewController.removeStickerOverlay(stickerImageView)
            }

            stickerImageView.normalizedCenterInImage = normalizePoint(stickerImageView.center, inView: mainPreviewView, baseImageSize: outputImageSize, normalizedCropRect: photoEditModel.normalizedCropRect)
        } else if let textLabel = view as? TextLabel, photoEditModel = photoEditModel, mainPreviewView = mainPreviewView {
            textLabel.activateHandler = { [weak self, unowned textLabel] in
                self?.selectedOverlayView = textLabel
                self?.showOptionsForTextIfNeeded(textLabel)
            }

            textLabel.normalizedCenterInImage = normalizePoint(textLabel.center, inView: mainPreviewView, baseImageSize: outputImageSize, normalizedCropRect: photoEditModel.normalizedCropRect)
        }

        selectedOverlayView = view
        showOptionsForOverlayIfNeeded(view)
        previewViewScrollingContainer?.accessibilityElements?.append(view)
    }

    /**
     :nodoc:
     */
    public func photoEditToolController(photoEditToolController: PhotoEditToolController, didSelectToolController toolController: PhotoEditToolController) {
        delegate?.photoEditViewController(self, didSelectToolController: toolController, wantsCurrentTopToolControllerReplaced: false)
    }

    /**
     :nodoc:
     */
    public func photoEditToolControllerSelectedOverlayView(photoEditToolController: PhotoEditToolController) -> UIView? {
        return selectedOverlayView
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: UIGestureRecognizerDelegate {
    /**
     :nodoc:
     */
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /**
     :nodoc:
     */
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer || gestureRecognizer == pinchGestureRecognizer || gestureRecognizer == rotationGestureRecognizer {
            if presentedViewController == stickerContextMenuController {
                return true
            }

            if presentedViewController == textContextMenuController {
                return true
            }

            return false
        }

        return true
    }
}

@available(iOS 8, *)
extension PhotoEditViewController: FrameControllerDelegate {
    /**
     :nodoc:
     */
    public func frameControllerBaseImageSize(frameController: FrameController) -> CGSize {
        guard let mainRenderer = mainRenderer else {
            return .zero
        }

        let renderMode = mainRenderer.renderMode
        mainRenderer.renderMode = mainRenderer.renderMode.subtract(.Crop)
        let outputImageSize = mainRenderer.outputImageSize
        mainRenderer.renderMode = renderMode

        return outputImageSize
    }

    /**
     :nodoc:
     */
    public func frameControllerNormalizedCropRect(frameController: FrameController) -> CGRect {
        return photoEditModel?.normalizedCropRect ?? .zero
    }
}
