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
 *  A `TextOptionsToolController` is reponsible for displaying the UI to adjust text that has been added
 *  to an image.
 */
@available(iOS 8, *)
@objc(IMGLYTextOptionsToolController) public class TextOptionsToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let LabelCaptionCollectionViewCellReuseIdentifier = "LabelCaptionCollectionViewCellReuseIdentifier"
    private static let LabelCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let SeparatorCollectionViewCellReuseIdentifier = "SeparatorCollectionViewCellReuseIdentifier"
    private static let SeparatorCollectionViewCellSize = CGSize(width: 15, height: 80)

    private let colorButtonGenetator = ColorButtonImageGenerator(imageName: "imgly_icon_option_selected_color", backgroundImageName: "imgly_icon_option_selected_color_bg")

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = TextOptionsToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: TextOptionsToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.registerClass(SeparatorCollectionViewCell.self, forCellWithReuseIdentifier: TextOptionsToolController.SeparatorCollectionViewCellReuseIdentifier)
        collectionView.registerClass(LabelCaptionCollectionViewCell.self, forCellWithReuseIdentifier: TextOptionsToolController.LabelCaptionCollectionViewCellReuseIdentifier)
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

        view.userInteractionEnabled = false

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = options.title

            if let applyButton = toolStackItem.applyButton {
                applyButton.addTarget(self, action: #selector(TextOptionsToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(TextOptionsToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }
    }

    private var options: TextOptionsToolControllerOptions {
        get {
            return configuration.textOptionsToolControllerOptions
        }
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

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
        updateColorButtons()
        updateFontButton()
    }

    /**
     :nodoc:
     */
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }


    private func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(TextOptionsToolController.selectionChanged(_:)),
            name: PhotoEditViewControllerSelectedOverlayViewDidChangeNotification,
            object: nil
        )
    }

    @objc private func selectionChanged(notification: NSNotification) {
        updateColorButtons()
        updateFontButton()
    }

    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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

    private func updateColorButtons() {
        if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
            if let iconCaptionCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as? IconCaptionCollectionViewCell {
                iconCaptionCell.imageView.image = colorButtonGenetator.imageWithColor(textLabel.textColor)
            }
            if let iconCaptionCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as? IconCaptionCollectionViewCell {
                iconCaptionCell.imageView.image = colorButtonGenetator.imageWithColor(textLabel.backgroundColor!)
            }
        }
    }

    private func updateFontButton() {
        if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
            if let fontCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? LabelCaptionCollectionViewCell {
                fontCell.label.font = textLabel.font.fontWithSize(fontCell.label.font.pointSize)
            }
        }
    }
}

@available(iOS 8, *)
extension TextOptionsToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let actionType = options.allowedTextActions[indexPath.item]
        if actionType == .SelectFont {
            // swiftlint:disable force_cast
            let textFontToolController = (configuration.getClassForReplacedClass(TextFontToolController.self) as! TextFontToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
            // swiflint:enable force_cast

            textFontToolController.delegate = delegate
            delegate?.photoEditToolController(self, didSelectToolController: textFontToolController)
        } else if actionType == .SelectColor {
            // swiftlint:disable force_cast
            let textColorToolController = (configuration.getClassForReplacedClass(TextColorToolController.self) as! TextColorToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
            // swiflint:enable force_cast

            textColorToolController.delegate = delegate
            textColorToolController.mode = .Foreground
            delegate?.photoEditToolController(self, didSelectToolController: textColorToolController)
        } else if actionType == .SelectBackgroundColor {
            // swiftlint:disable force_cast
            let textColorToolController = (configuration.getClassForReplacedClass(TextColorToolController.self) as! TextColorToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
            // swiflint:enable force_cast

            textColorToolController.delegate = delegate
            textColorToolController.mode = .Background
            delegate?.photoEditToolController(self, didSelectToolController: textColorToolController)
        }

        options.textActionSelectedClosure?(actionType)
    }
}

@available(iOS 8, *)
extension TextOptionsToolController: UICollectionViewDataSource {
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
        return options.allowedTextActions.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let actionType = options.allowedTextActions[indexPath.item]
        if actionType == .SelectFont {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TextOptionsToolController.LabelCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)
            if let fontCell = cell as? LabelCaptionCollectionViewCell {
                fontCell.label.text = "Ag"
                fontCell.captionLabel.text = Localize("Font")
                fontCell.label.font = UIFont(name: InstanceFactory.availableFontsList[0], size: 28)
                fontCell.accessibilityLabel = Localize("Font")
            }
            options.actionButtonConfigurationClosure?(cell, actionType)
            return cell
        }

        if actionType == .Separator {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TextOptionsToolController.SeparatorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let separatorCell = cell as? SeparatorCollectionViewCell {
                separatorCell.separator.backgroundColor = configuration.separatorColor
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TextOptionsToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if actionType == .SelectColor {
                iconCaptionCell.imageView.image = colorButtonGenetator.imageWithColor(UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0))
                iconCaptionCell.captionLabel.text = Localize("Color")
                iconCaptionCell.accessibilityLabel = Localize("Color")
            } else if actionType == .SelectBackgroundColor {
                iconCaptionCell.imageView.image = colorButtonGenetator.imageWithColor(UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0))
                iconCaptionCell.captionLabel.text = Localize("BGColor")
                iconCaptionCell.accessibilityLabel = Localize("Backgoround color")
            }

            options.actionButtonConfigurationClosure?(cell, actionType)
        }

        return cell
    }
}

@available(iOS 8, *)
extension TextOptionsToolController: UICollectionViewDelegateFlowLayout {
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
        if indexPath.item == 3 {
            return TextOptionsToolController.SeparatorCollectionViewCellSize
        }

        return TextOptionsToolController.IconCaptionCollectionViewCellSize
    }
}
