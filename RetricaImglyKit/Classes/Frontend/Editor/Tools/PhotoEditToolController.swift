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
 The `PhotoEditToolControllerDelegate` protocol defines methods that allow you respond to the events of an instance of `PhotoEditToolController`.
 */
@objc(IMGLYPhotoEditToolControllerDelegate) public protocol PhotoEditToolControllerDelegate {
    /**
     The photo edit renderer that is being used.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the renderer.

     - returns: An instance of `PhotoEditRenderer`.
     */
    func photoEditToolControllerMainRenderer(photoEditToolController: PhotoEditToolController) -> PhotoEditRenderer?

    /**
     The base image that is being edited.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the base image.

     - returns: An instance of `UIImage`.
     */
    func photoEditToolControllerBaseImage(photoEditToolController: PhotoEditToolController) -> UIImage?

    /**
     The preview view that shows the edited image.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the preview view.

     - returns: An instance of `UIView`.
     */
    func photoEditToolControllerPreviewView(photoEditToolController: PhotoEditToolController) -> UIView?

    /**
     The scrolling container that hosts the preview view.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the scrolling container.

     - returns: An instance of `UIScrollView`.
     */
    func photoEditToolControllerPreviewViewScrollingContainer(photoEditToolController: PhotoEditToolController) -> UIScrollView?

    /**
     The currently selected overlay view.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the overlay view.

     - returns: An instance of `StickerImageView` or `TextLabel`.
     */
    func photoEditToolControllerSelectedOverlayView(photoEditToolController: PhotoEditToolController) -> UIView?

    /**
     The container view that hosts the overlay views.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the container.

     - returns: An instance of `UIView`.
     */
    func photoEditToolControllerOverlayContainerView(photoEditToolController: PhotoEditToolController) -> UIView?

    /**
     The list of currently added overlay views.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the overlay views.

     - returns: An array of `UIView`s.
     */
    func photoEditToolControllerOverlayViews(photoEditToolController: PhotoEditToolController) -> [UIView]?

    /**
     The frame controller that is used to place a frame over the output image.

     - parameter photoEditToolController: The photo edit tool controller that is asking for the frame controller.

     - returns: An instance of `FrameController`.
     */
    func photoEditToolControllerFrameController(photoEditToolController: PhotoEditToolController) -> FrameController?

    /**
     Called when the tool finishes editing.

     - parameter photoEditToolController: The photo edit view controller that finished editing.
     */
    func photoEditToolControllerDidFinish(photoEditToolController: PhotoEditToolController)

    /**
     Called when the tool discards its changes.

     - parameter photoEditToolController: The photo edit tool controller that discarded its changes.
     - parameter photoEditModel:          The photo edit model that should be restored.
     */
    func photoEditToolController(photoEditToolController: PhotoEditToolController, didDiscardChangesInFavorOfPhotoEditModel photoEditModel: IMGLYPhotoEditModel)

    /**
     Called when the tool changes its preferred rendering mode.

     - parameter photoEditToolController: The photo edit tool controller that changed its preferred rendering mode.
     */
    func photoEditToolControllerDidChangePreferredRenderMode(photoEditToolController: PhotoEditToolController)

    /**
     Called when the tool changes whether or not it wants a default preview.

     - parameter photoEditToolController: The photo edit tool controller that changed whether or not the default preview should be visible.
     */
    func photoEditToolControllerDidChangeWantsDefaultPreviewView(photoEditToolController: PhotoEditToolController)

    /**
     Called when the tool adds an overlay.

     - parameter photoEditToolController: The photo edit tool controller that added an overlay.
     - parameter view:                    The overlay that was added.
     */
    func photoEditToolController(photoEditToolController: PhotoEditToolController, didAddOverlayView view: UIView)

    /**
     Called when the tool changes the image's orientation.

     - parameter photoEditToolController: The photo edit tool controller that changed the orientation.
     - parameter orientation:             The orientation that was changed to.
     - parameter fromOrientation:         The orientation that was changed from.
     */
    func photoEditToolController(photoEditToolController: PhotoEditToolController, didChangeToOrientation orientation: IMGLYOrientation, fromOrientation: IMGLYOrientation)

    /**
     Called when the tool wants to present another tool on top of it.

     - parameter photoEditToolController: The photo edit tool controller that wants to present another tool.
     - parameter toolController:          The tool that should be presented.
     */
    func photoEditToolController(photoEditToolController: PhotoEditToolController, didSelectToolController toolController: PhotoEditToolController)
}

/**
 *  A `PhotoEditToolController` is the base class for any tool controllers. Subclass this class if you
 *  want to add additional tools to the editor.
 */
@objc(IMGLYPhotoEditToolController) public class PhotoEditToolController: UIViewController {

    // MARK: - Configuration Properties

    /// The render mode that the preview image should be rendered with when this tool is active.
    public var preferredRenderMode: IMGLYRenderMode {
        didSet {
            delegate?.photoEditToolControllerDidChangePreferredRenderMode(self)
        }
    }

    /// The photo edit model that must be updated.
    public let photoEditModel: IMGLYPhotoEditMutableModel

    @NSCopying internal var uneditedPhotoEditModel: IMGLYPhotoEditModel

    /// The configuration object that configures this tool.
    public let configuration: Configuration

    weak var delegate: PhotoEditToolControllerDelegate?

    // MARK: - Initializers

    /**
    Initializes and returns a newly created tool stack controller with the given configuration.

    - parameter configuration: The configuration options to apply.

    - returns: The initialized and configured tool stack controller object.
    */
    public required init(photoEditModel: IMGLYPhotoEditMutableModel, configuration: Configuration) {
        preferredRenderMode = [.AutoEnhancement, .Orientation, .Crop, .Focus, .PhotoEffect, .ColorAdjustments, .RetricaFilter]
        self.photoEditModel = photoEditModel
        // swiftlint:disable force_cast
        self.uneditedPhotoEditModel = photoEditModel.copy() as! IMGLYPhotoEditModel
        // swiftlint:enable force_cast
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhotoEditToolController.photoEditModelDidChange(_:)), name: IMGLYPhotoEditModelDidChangeNotification, object: photoEditModel)
    }

    /**
    :nodoc:
    */
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: IMGLYPhotoEditModelDidChangeNotification, object: photoEditModel)
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    /**
     :nodoc:
     */
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PhotoEditToolController

    /// If set to `true`, the default preview view is used. If set to `false`, the default preview view
    /// is hidden and you are responsible for displaying the image.
    public var wantsDefaultPreviewView: Bool {
        return true
    }

    /// The scale factor that should be applied to the main preview view when this tool is on top of the stack.
    /// Defaults to `1.0`.
    public var preferredDefaultPreviewViewScale: CGFloat {
        return 1
    }

    /// If set to `true`, scrolling in the default preview view is enabled while this tool is on top of the stack.
    /// Defaults to `false`.
    public var wantsScrollingInDefaultPreviewViewEnabled: Bool {
        return false
    }

    /// The background color that should be used when this tool is active.
    public var preferredPreviewBackgroundColor: UIColor? {
        return nil
    }

    /// The insets that should be applied to the preview view when this tool is active.
    public var preferredPreviewViewInsets: UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    /// The tool stack configuration item.
    public private(set) lazy var toolStackItem = ToolStackItem()

    /**
     Called when any property of the photo edit model changes.

     - parameter notification: The notification that was sent.
     */
    public func photoEditModelDidChange(notification: NSNotification) {

    }

    /**
     Notifies the tool controller that it is about to become the active tool.

     **Discussion:** If you override this method, you must call `super` at some point in your implementation.
     */
    public func willBecomeActiveTool() {
        if uneditedPhotoEditModel != photoEditModel {
            uneditedPhotoEditModel = photoEditModel
        }
    }

    /**
     Notifies the tool controller that it became the active tool.

     **Discussion:** If you override this method, you must call `super` at some point in your implementation.
     */
    public func didBecomeActiveTool() {

    }

    /**
     Notifies the tool controller that it is about to resign being the active tool.

     **Discussion:** This method will **not** be called if another tool is pushed above this tool.
     It is only called if you pop the tool from the tool stack controller. If you override this method,
     you must call `super` at some point in your implementation.
     */
    public func willResignActiveTool() {
    }

    /**
     Notifies the tool controller that it resigned being the active tool.

     **Discussion:** This method will **not** be called if another tool is pushed above this tool.
     It is only called if you pop the tool from the tool stack controller. If you override this method,
     you must call `super` at some point in your implementation.
     */
    public func didResignActiveTool() {

    }

    // MARK: - Helpers

    internal func showError(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            var errorString = error.userInfo["NSLocalizedDescription"] as? String
            if errorString == nil {
                errorString = Localize("Unknown error")
            }

            let alertController = UIAlertController(title: Localize("Error"), message: errorString, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {}
        }
    }
}
