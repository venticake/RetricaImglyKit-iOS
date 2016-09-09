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
 *  A `TextToolController` is reponsible for displaying the UI to add text to an image.
 */
@available(iOS 8, *)
@objc(IMGLYTextToolController) public class TextToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let TextLabelInitialMargin: CGFloat = 40

    // MARK: - Properties

    private var dimmingView: UIView?
    private var textField: UITextField?

    private var dimmingViewConstraints: [NSLayoutConstraint]?
    private var textFieldConstraints: [NSLayoutConstraint]?

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        InstanceFactory.fontImporter().importFonts()

        toolStackItem.performChanges {
            toolStackItem.titleLabel?.text = options.title
            toolStackItem.titleLabel?.accessibilityLabel = Localize("Add text")

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(TextToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Add text")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(TextToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Cancel")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.addSubview(dimmingView)
        self.dimmingView = dimmingView

        let textField = UITextField()
        textField.textColor = UIColor.whiteColor()
        textField.backgroundColor = UIColor.clearColor()
        textField.returnKeyType = .Done
        textField.delegate = self
        dimmingView.addSubview(textField)
        self.textField = textField
        options.textFieldConfigurationClosure?(textField)

        view.setNeedsUpdateConstraints()
    }

    private var options: TextToolControllerOptions {
        get {
            return configuration.textToolControllerOptions
        }
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        textField?.becomeFirstResponder()
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let dimmingView = dimmingView where dimmingViewConstraints == nil {
            dimmingView.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: dimmingView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: dimmingView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: dimmingView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: dimmingView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            NSLayoutConstraint.activateConstraints(constraints)
            dimmingViewConstraints = constraints
        }

        if let dimmingView = dimmingView, textField = textField where textFieldConstraints == nil {
            textField.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: textField, attribute: .Left, relatedBy: .Equal, toItem: dimmingView, attribute: .Left, multiplier: 1, constant: 20))
            constraints.append(NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: dimmingView, attribute: .Top, multiplier: 1, constant: 20))
            constraints.append(NSLayoutConstraint(item: textField, attribute: .Right, relatedBy: .Equal, toItem: dimmingView, attribute: .Right, multiplier: 1, constant: -20))

            NSLayoutConstraint.activateConstraints(constraints)
            textFieldConstraints = constraints
        }
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
        createLabelFromTextField()
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Label Creation

    private func calculateInitialFontSizeForLabel(textLabel: TextLabel) -> CGFloat {
        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        guard let mainPreviewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return 0
        }

        if let text = textLabel.text {
            var currentTextSize: CGFloat = 1
            var size = CGSize.zero
            if !text.isEmpty {
                repeat {
                    currentTextSize += 1
                    let font = textLabel.font.fontWithSize(currentTextSize)
                    size = text.sizeWithAttributes([ NSFontAttributeName: font, NSParagraphStyleAttributeName:customParagraphStyle])
                } while ((size.width < (mainPreviewView.bounds.width - TextToolController.TextLabelInitialMargin)) && (size.height < (mainPreviewView.bounds.size.height - TextToolController.TextLabelInitialMargin)))

                return currentTextSize
            }
        }

        return 0
    }

    private func createLabelFromTextField() {
        guard let overlayContainerView = delegate?.photoEditToolControllerOverlayContainerView(self) else {
            return
        }

        guard let newText = textField?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else {
            delegate?.photoEditToolControllerDidFinish(self)
            return
        }

        if newText.characters.count > 0 {
            let label = TextLabel()

            label.decrementHandler = { [unowned label] in
                // Decrease by 10 %
                let fontSize = label.font.pointSize
                label.font = label.font.fontWithSize(fontSize * 0.9)
                label.sizeToFit()
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            }

            label.incrementHandler = { [unowned label] in
                // Increase by 10 %
                let fontSize = label.font.pointSize
                label.font = label.font.fontWithSize(fontSize * 1.1)
                label.sizeToFit()
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            }

            label.rotateLeftHandler = { [unowned label] in
                // Rotate by 10 degrees to the left
                label.transform = CGAffineTransformRotate(label.transform, -10 * CGFloat(M_PI) / 180)
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            }

            label.rotateRightHandler = { [unowned label] in
                // Rotate by 10 degrees to the right
                label.transform = CGAffineTransformRotate(label.transform, 10 * CGFloat(M_PI) / 180)
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            }

            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.whiteColor()
            label.textAlignment = .Center
            label.text = newText
            label.userInteractionEnabled = true
            label.font = UIFont(name: InstanceFactory.availableFontsList[0], size: 1)
            label.font = label.font.fontWithSize(calculateInitialFontSizeForLabel(label))
            label.sizeToFit()

            label.center = CGPoint(x: overlayContainerView.bounds.midX, y: overlayContainerView.bounds.midY)

            overlayContainerView.addSubview(label)
            delegate?.photoEditToolController(self, didAddOverlayView: label)
            textField?.text = nil
        }
    }

}

@available(iOS 8, *)
extension TextToolController: UITextFieldDelegate {
    /**
     :nodoc:
     */
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        createLabelFromTextField()
        return true
    }
}
