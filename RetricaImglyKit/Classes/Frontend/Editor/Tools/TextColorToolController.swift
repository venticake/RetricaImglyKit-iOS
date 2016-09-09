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
 The different modes that an instance of `TextColorToolController` can handle.

 - Foreground: The mode to handle the foreground appearance of the text.
 - Background: The mode to handle the background appearance of the text.
 */
@objc public enum TextColorToolControllerMode: Int {
    /// The mode to handle the foreground appearance of the text.
    case Foreground
    /// The mode to handle the background appearance of the text.
    case Background
}

/**
 *  A `TextColorToolController` is reponsible for displaying the UI to adjust the text color of text
 *  that has been added to an image.
 */
@available(iOS 8, *)
@objc(IMGLYTextColorToolController) public class TextColorToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let ColorCollectionViewCellReuseIdentifier = "ColorCollectionViewCellReuseIdentifier"
    private static let ColorCollectionViewCellSize = CGSize(width: 48, height: 80)
    private var bottomConstraint = NSLayoutConstraint()
    private var colorPickerVisible = false
    private var lastSelectedIndexPath: NSIndexPath = NSIndexPath()
    private var initialColor = UIColor()
    private var availableColors: [UIColor] {
        get {
            if let colors = self.configuration.textColorToolControllerOptions.availableFontColors {
                return colors
            }
            return self.defaultColorArray()
        }
    }

    private var availableColorNames: [String] {
        get {
            if let names = self.configuration.textColorToolControllerOptions.availableFontColorNames {
                return names
            }
            return self.defaultColorNames()
        }
    }

    private var dimmingView = UIView()
    private var colorPickerView = ColorPickerView()

    /// The `TextColorToolControllerMode` that this tool is handling.
    public var mode = TextColorToolControllerMode.Foreground
    private var textColor: UIColor {
        get {
            let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel
            if let textLabel = textLabel {
                return mode == .Foreground ? textLabel.textColor : textLabel.backgroundColor
            }
            return UIColor.blackColor()
        }
        set {
            let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel
            if let textLabel = textLabel {
                if mode == .Foreground {
                    textLabel.textColor = newValue
                } else {
                    textLabel.backgroundColor = newValue
                }
            }
        }
    }

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = TextColorToolController.ColorCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(ColorCollectionViewCell.self, forCellWithReuseIdentifier: TextColorToolController.ColorCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private func defaultColorArray() -> [UIColor] {
        return [
            UIColor.whiteColor(),
            UIColor(red:0.49, green:0.49, blue:0.49, alpha:1), // gray
            UIColor.blackColor(),
            UIColor(red:0.4, green:0.8, blue:1, alpha:1), // light blue
            UIColor(red:0.4, green:0.53, blue:1, alpha:1), // blue
            UIColor(red:0.53, green:0.4, blue:1, alpha:1), // purple
            UIColor(red:0.87, green:0.4, blue:1, alpha:1), // orchid
            UIColor(red:1, green:0.4, blue:0.8, alpha:1), // pink
            UIColor(red:1, green:0.4, blue:0.53, alpha:1), // red
            UIColor(red:1, green:0.53, blue:0.4, alpha:1), // orange
            UIColor(red:1, green:0.8, blue:0.4, alpha:1), // gold
            UIColor(red:1, green:0.97, blue:0.39, alpha:1), // yellow
            UIColor(red:0.8, green:1, blue:0.4, alpha:1),  // olive
            UIColor(red:0.33, green:1, blue:0.53, alpha:1), // green
            UIColor(red:0.33, green:1, blue:0.92, alpha:1), // aquamarin
        ]
    }

    private func defaultColorNames() -> [String] {
        return [
            Localize("White"),
            Localize("Gray"),
            Localize("Black"),
            Localize("Light blue"),
            Localize("Blue"),
            Localize("Purple"),
            Localize("Orchid"),
            Localize("Pink"),
            Localize("Red"),
            Localize("Orange"),
            Localize("Gold"),
            Localize("Yellow"),
            Localize("Olive"),
            Localize("Green"),
            Localize("Aquamarin")
        ]
    }

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
                applyButton.addTarget(self, action: #selector(TextColorToolController.apply(_:)), forControlEvents: .TouchUpInside)
                applyButton.accessibilityLabel = Localize("Apply changes")
                options.applyButtonConfigurationClosure?(applyButton)
            }

            if let discardButton = toolStackItem.discardButton {
                discardButton.addTarget(self, action: #selector(TextColorToolController.discard(_:)), forControlEvents: .TouchUpInside)
                discardButton.accessibilityLabel = Localize("Discard changes")
                options.discardButtonConfigurationClosure?(discardButton)
            }
        }

        configureDimmingView()
        configureColorPicker()
        assert(availableColorNames.count == availableColors.count, "Color and color name array must have the same length")
    }

    private var options: TextColorToolControllerOptions {
        get {
            return configuration.textColorToolControllerOptions
        }
    }

    private func configureDimmingView() {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.addSubview(dimmingView)
        let views: [String : AnyObject] = [
            "dimmingView" : dimmingView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dimmingView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[dimmingView(300)]", options: [], metrics: nil, views: views))
        bottomConstraint = NSLayoutConstraint(item: dimmingView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(bottomConstraint)
    }

    private func configureColorPicker() {
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.userInteractionEnabled = true
        colorPickerView.pickerDelegate = self
        let views: [String : AnyObject] = [
            "colorPickerView" : colorPickerView
        ]
        dimmingView.addSubview(colorPickerView)
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[colorPickerView]|", options: [], metrics: nil, views: views))
        dimmingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[colorPickerView(300)]", options: [], metrics: nil, views: views))
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        initialColor = textColor
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
        textColor = initialColor
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Color picker

    private func toggleColorPicker() {
        if colorPickerVisible {
            hideColorPicker()
        } else {
            showColorPicker()
        }
    }

    private func showColorPicker() {
        colorPickerView.color =  textColor
        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.bottomConstraint.constant = -296.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.colorPickerVisible = true
        })
    }

    private func hideColorPicker() {
        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.bottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.colorPickerVisible = false
        })
    }

}

@available(iOS 8, *)
extension TextColorToolController: UICollectionViewDataSource {
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
        return self.availableColors.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TextColorToolController.ColorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let colorCell = cell as? ColorCollectionViewCell {
            let color = availableColors[indexPath.item]
            colorCell.colorView.backgroundColor = color
            colorCell.imageView.image = UIImage(named: "imgly_icon_tool_adjust", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)
            let colorName = availableColorNames[indexPath.item]
            colorCell.accessibilityLabel = colorName
            options.textColorActionButtonConfigurationClosure?(colorCell, color, colorName)
        }
        return cell
    }
}

@available(iOS 8, *)
extension TextColorToolController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if lastSelectedIndexPath == indexPath {
            toggleColorPicker()
        }

        if let colorCell = collectionView.cellForItemAtIndexPath(indexPath) as? ColorCollectionViewCell {
            if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
                let mode = self.mode
                let currentColor = mode == .Foreground ? textLabel.textColor : textLabel.backgroundColor

                undoManager?.registerUndoForTarget(textLabel) { textLabel in
                    if mode == .Foreground {
                        textLabel.textColor = currentColor
                    } else {
                        textLabel.backgroundColor = currentColor
                    }
                }
            }

            textColor = colorCell.colorView.backgroundColor!
            if colorPickerVisible {
                colorPickerView.color = textColor
            }

            options.textColorActionSelectedClosure?(textColor, colorCell.accessibilityLabel!)
        }

        lastSelectedIndexPath = indexPath
    }
}

@available(iOS 8, *)
extension TextColorToolController: ColorPickerViewDelegate {
    /**
     :nodoc:
     */
    public func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor) {
        if let textLabel = delegate?.photoEditToolControllerSelectedOverlayView(self) as? TextLabel {
            let mode = self.mode
            let currentColor = mode == .Foreground ? textLabel.textColor : textLabel.backgroundColor

            undoManager?.registerUndoForTarget(textLabel) { textLabel in
                if mode == .Foreground {
                    textLabel.textColor = currentColor
                } else {
                    textLabel.backgroundColor = currentColor
                }
            }
        }

        textColor = color
    }

    /**
     :nodoc:
     */
    public func canceledColorPicking(colorPickerView: ColorPickerView) {

    }
}

@available(iOS 8, *)
extension TextColorToolController: UICollectionViewDelegateFlowLayout {
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
