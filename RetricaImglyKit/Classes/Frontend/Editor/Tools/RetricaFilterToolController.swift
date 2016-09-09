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
@objc(IMGLYRetricaFilterToolController) public class RetricaFilterToolController: PhotoEditToolController, RELensSelectorViewDelegate {

    // MARK: - Properties

    private var filterSelectionController: RetricaFilterSelectionController?

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

        filterSelectionController = RetricaFilterSelectionController(inputImage: delegate?.photoEditToolControllerBaseImage(self))

        toolStackItem.performChanges {
            let lensSelectorView = RELensSelectorView(frame: CGRectMake(0,0,CGRectGetWidth(self.view.frame), RELensSelectorView.defaultHeight()))
            
            lensSelectorView.delegate = self
            
            toolStackItem.mainToolbarView = lensSelectorView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(RetricaFilterToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(RetricaFilterToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        view.setNeedsUpdateConstraints()
    }
    
    public func lensSelectorView(lensSelectorView: RELensSelectorView, didSelectedLens lens: RELensWrapper) {
        print("select lens : ",lens)
        
        photoEditModel.lensWrapper = lens;
    }

    private var options: RetricaFilterToolControllerOptions {
        get {
            return configuration.retricaFilterToolControllerOptions
        }
    }

    /**
    :nodoc:
    */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    // MARK: - PhotoEditToolController

    /**
    :nodoc:
    */
    public override func photoEditModelDidChange(notification: NSNotification) {
        super.photoEditModelDidChange(notification)
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

//extension RetricaFilterToolController : RELensSelectorViewDelegate {
//    public func lensSelectorView(lensSelectorView: RELensSelectorView, didSelectedLens lens: RELensWrapper) {
//        print("ddddd : ",lens)
//    }
//}
