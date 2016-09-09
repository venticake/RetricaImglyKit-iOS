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
 *  A `TextFontToolController` is reponsible for displaying the UI to adjust the font of text that
 *  has been added to an image.
 */
@objc(IMGLYTextFontToolController) public class TextFontToolController: PhotoEditToolController {

    // MARK: - Statics
    private let handleSize = CGFloat(22)
    private let FontSize = CGFloat(20)
    private static let LabelCaptionCollectionViewCellReuseIdentifier = "LabelCaptionCollectionViewCellReuseIdentifier"
    private static let LabelCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private var textFont: UIFont {
        get {
            let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel
            if let textLabel = textLabel {
                return textLabel.font
            }
            return UIFont()
        }
        set {
            let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel
            if let textLabel = textLabel {
                textLabel.font = newValue
                textLabel.sizeToFit()
            }
        }
    }

    private var initialFont = UIFont()
    private var bottomConstraint = NSLayoutConstraint()
    private var dimmingView = UIView()
    private var handleButton = UIButton()
    private var fontSelectorVisible = false
    private var fontSelectorView = FontSelectorView()

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = TextFontToolController.LabelCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(LabelCaptionCollectionViewCell.self, forCellWithReuseIdentifier: TextFontToolController.LabelCaptionCollectionViewCellReuseIdentifier)
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
                applyButton.addTarget(self, action: #selector(TextFontToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(TextFontToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        configureDimmingView()
        configureHandleButton()
        configureFontSelectorView()
    }

    private var options: TextFontToolControllerOptions {
        get {
            return configuration.textFontToolControllerOptions
        }
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initialFont = textFont
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        centerButtonForSelectedFont()
    }

    // MARK: - Configuration

    private func configureDimmingView() {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.addSubview(dimmingView)
        let views: [String : AnyObject] = [
            "dimmingView" : dimmingView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dimmingView]|", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: dimmingView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0))
        bottomConstraint = NSLayoutConstraint(item: dimmingView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -handleSize)
        view.addConstraint(bottomConstraint)
    }

    private func configureHandleButton() {
        handleButton.translatesAutoresizingMaskIntoConstraints = false
        handleButton.userInteractionEnabled = true
        let views: [String : AnyObject] = [
            "handleButton" : handleButton
        ]
        dimmingView.addSubview(handleButton)
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[handleButton]|", options: [], metrics: nil, views: views))
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[handleButton(\(handleSize))]", options: [], metrics: nil, views: views))
        handleButton.accessibilityHint = Localize("Double-tap to show or hide font preview")
        handleButton.addTarget(self, action: #selector(TextFontToolController.toggleFontPicker(_:)), forControlEvents: .TouchUpInside)
        handleButton.setImage(UIImage(named: "imgly_icon_handle", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil), forState: .Normal)
    }

    private func configureFontSelectorView() {
        fontSelectorView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.addSubview(fontSelectorView)
        let views: [String : AnyObject] = [
            "fontSelectorView" : fontSelectorView
        ]
        fontSelectorView.selectorDelegate = self
        dimmingView.contentMode = .Center
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorView]|", options: [], metrics: nil, views: views))
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(handleSize)-[fontSelectorView]|", options: [], metrics: nil, views: views))
    }

    // MARK: - PhotoEditToolController

    /// :nodoc:
    public override var wantsScrollingInDefaultPreviewViewEnabled: Bool {
        return false
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
        textFont = initialFont
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Font picker

    @objc private func toggleFontPicker(sender: UIButton) {
        if fontSelectorVisible {
            hideFontPicker()
        } else {
            showFontPicker()
        }

        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }

    private func showFontPicker() {
        let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel
        if let textLabel = textLabel {
            fontSelectorView.text = textLabel.text!
        }

        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.bottomConstraint.constant = -self.view.frame.size.height
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.fontSelectorVisible = true
        })
    }

    private func hideFontPicker() {
        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.bottomConstraint.constant = -self.handleSize
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.fontSelectorVisible = false
        })
    }

    private func centerButtonForSelectedFont() {
        let fontName = textFont.fontName
        for name in InstanceFactory.availableFontsList {
            if fontName == name {
                let index = InstanceFactory.availableFontsList.indexOf(name)
                let indexPath = NSIndexPath(forItem: index!, inSection: 0)
                collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
            }
        }
    }
}

extension TextFontToolController: UICollectionViewDataSource {
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
        return InstanceFactory.availableFontsList.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TextFontToolController.LabelCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        let index = indexPath.item
        let fontName = InstanceFactory.availableFontsList[index]
        if let fontCell = cell as? LabelCaptionCollectionViewCell {
            fontCell.label.text = "Ag"
            fontCell.captionLabel.text = fontName
            if let displayName = InstanceFactory.fontDisplayNames[fontName] {
                fontCell.captionLabel.text = displayName
                fontCell.accessibilityLabel = displayName
            }

            fontCell.accessibilityLabel = fontCell.captionLabel.text
            if let font = UIFont(name: fontName, size: self.FontSize) {
                fontCell.label.font = font
            }
            options.actionButtonConfigurationClosure?(fontCell, fontName)
        }
        return cell
    }
}

extension TextFontToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? LabelCaptionCollectionViewCell {

            if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
                let currentTextFont = textFont

                undoManager?.registerUndoForTarget(textLabel) { textLabel in
                    textLabel.font = currentTextFont
                    textLabel.sizeToFit()
                }
            }

            let size = textFont.pointSize
            textFont = cell.label.font.fontWithSize(size)
            fontSelectorView.selectedFontName = cell.label.font.fontName
        }
    }
}

extension TextFontToolController: UICollectionViewDelegateFlowLayout {
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

        for _ in 0..<cellCount {
            let itemSize = flowLayout.itemSize
            totalCellWidth = totalCellWidth + itemSize.width
        }

        let totalCellSpacing = cellSpacing * (CGFloat(cellCount) - 1)
        let totalCellsWidth = totalCellWidth + totalCellSpacing
        let edgeInsets = max((collectionViewWidth - totalCellsWidth) / 2.0, cellSpacing)

        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
}

extension TextFontToolController: FontSelectorViewDelegate {
    /**
     :nodoc:
     */
    public func fontSelectorView(fontSelectorView: FontSelectorView, didSelectFontWithName fontName: String) {
        if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
            let currentTextFont = textFont

            undoManager?.registerUndoForTarget(textLabel) { textLabel in
                textLabel.font = currentTextFont
                textLabel.sizeToFit()
            }
        }

        if let font = UIFont(name: fontName, size: textFont.pointSize) {
            textFont = font
            options.textFontActionSelectedClosure?(fontName)
        }

        centerButtonForSelectedFont()
    }
}
