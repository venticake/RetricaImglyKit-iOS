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
 The `FontSelectorViewDelegate` protocol defines methods that allow you respond to the events of an instance of `FontSelectorView`.
 */
@objc(IMGLYFontSelectorViewDelegate) public protocol FontSelectorViewDelegate {
    /**
     Called when the font selector selected a font.

     - parameter fontSelectorView: The font selector that selected the font.
     - parameter fontName:         The name of the font that was selected.
     */
    func fontSelectorView(fontSelectorView: FontSelectorView, didSelectFontWithName fontName: String)
}

/**
 The `FontSelectorView` class provides a class that is used to select a font.
 */
@objc(IMGLYFontSelectorView) public class FontSelectorView: UIScrollView {

    /// The receiver’s delegate.
    /// - seealso: `FontSelectorViewDelegate`.
    public weak var selectorDelegate: FontSelectorViewDelegate?

    /// The text color for the selected font.
    public var selectedTextColor = UIColor(red: 0.22, green: 0.62, blue: 0.85, alpha: 1) {
        didSet {
            updateTextColor()
        }
    }

    /// The text color for the fonts.
    public var textColor = UIColor.whiteColor() {
        didSet {
            updateTextColor()
        }
    }

    /// The text color for the font's label.
    public var labelColor = UIColor.whiteColor() {
        didSet {
            updateTextColor()
        }
    }

    /// The name of the currently selected font.
    public var selectedFontName = "" {
        didSet {
            updateTextColor()
            scrollToButton()
        }
    }

    /// The preview text.
    public var text = "" {
        didSet {
            updateFontButtonText()
            layoutSubviews()
        }
    }

    private let kDistanceBetweenButtons = CGFloat(60)
    private let kFontSize = CGFloat(28)
    private var fontNames = [String]()

    /**
     :nodoc:
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        fontNames = InstanceFactory.availableFontsList
        configureFontButtons()
        updateFontButtonText()
    }

    private func configureFontButtons() {
        for fontName in fontNames {
            let button = TextButton(type: UIButtonType.Custom)
            button.setTitle(fontName, forState:UIControlState.Normal)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center

            if let font = UIFont(name: fontName, size: kFontSize) {
                button.titleLabel?.font = font
                button.fontName = fontName
                button.accessibilityLabel = fontName

                if let displayName = InstanceFactory.fontDisplayNames[button.fontName] {
                    button.displayName = displayName
                    button.accessibilityLabel = displayName
                }

                button.setTitleColor(textColor, forState: .Normal)
                addSubview(button)
                button.addTarget(self, action: #selector(FontSelectorView.buttonTouchedUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }

    private func updateFontButtonText() {
        for subview in subviews where subview is TextButton {
            // swiftlint:disable force_cast
            let button = subview as! TextButton
            // swiftlint:enable force_cast
            button.setTitle(text, forState: .Normal)
        }
    }

    /**
     :nodoc:
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        for index in 0 ..< subviews.count {
            if let button = subviews[index] as? TextButton {
                button.frame = CGRect(x: 0,
                    y: CGFloat(index) * kDistanceBetweenButtons,
                    width: frame.size.width,
                    height: kDistanceBetweenButtons)
                button.layoutIfNeeded()
            }
        }
        contentSize = CGSize(width: frame.size.width - 1.0, height: kDistanceBetweenButtons * CGFloat(subviews.count - 2) + 100)
    }

    @objc private func buttonTouchedUpInside(button: TextButton) {
        let fontName = button.fontName
        selectedFontName = fontName
        updateTextColor()
        selectorDelegate?.fontSelectorView(self, didSelectFontWithName: fontName)
    }

    private func updateTextColor() {
        for view in subviews where view is TextButton {
            if let button = view as? TextButton {
                if button.fontName == selectedFontName {
                    button.accessibilityTraits |= UIAccessibilityTraitSelected
                } else {
                    button.accessibilityTraits &= ~UIAccessibilityTraitSelected
                }

                let color = button.fontName == selectedFontName ? selectedTextColor : textColor
                button.setTitleColor(color, forState: .Normal)
            }
        }
    }

    private func scrollToButton() {
        var selectedButton: UIButton?
        for view in subviews where view is TextButton {
            if let button = view as? TextButton {
                if button.fontName == selectedFontName {
                    selectedButton = button
                }
            }
        }
        if  let button = selectedButton {
            let centerOffset = frame.height / 2.0
            var target = button.center
            target.x = 0
            target.y -= centerOffset
            target.y = max(target.y, 0.0)
            target.y = min(target.y, contentSize.height - frame.height)
            self.setContentOffset(target, animated: true)
        }
    }
}
