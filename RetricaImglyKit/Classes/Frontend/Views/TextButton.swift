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
 *  A `TextButton` is used within a `FontSelectorView` to present different fonts and their names.
 */
@available(iOS 8, *)
@objc(IMGLYTextButton) public class TextButton: UIButton {

    /// The color of the label.
    public var labelColor = UIColor.whiteColor() {
        didSet {
            updateFontLabel()
        }
    }

    /// The name of the font.
    public var fontName = "" {
        didSet {
            updateFontLabel()
        }
    }

    /// :nodoc:
    public override var frame: CGRect {
        didSet {
            super.frame = frame
            updateFontNameLabelFrame()
        }
    }

    /// The name that is shown to the user.
    public var displayName = "" {
        didSet {
            updateFontLabel()
        }
    }

    private let fontNameLabel = UILabel()

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
        self.contentMode = .Center
        commonInit()
    }

    private func commonInit() {
        configureFontLabel()
        updateFontLabel()
    }

    private func configureFontLabel() {
        fontNameLabel.textAlignment = .Center
        fontNameLabel.isAccessibilityElement = false
        addSubview(fontNameLabel)
    }

    private func updateFontLabel() {
        fontNameLabel.font = fontNameLabel.font.fontWithSize(10)
        fontNameLabel.textColor = labelColor
        if fontName.characters.count > 0 {
            fontNameLabel.text = displayName.characters.count > 0 ? displayName : fontName
        }
    }

    private func updateFontNameLabelFrame() {
        fontNameLabel.frame = CGRect(x: 0, y: self.bounds.height - 15, width: self.bounds.width, height: 15)
    }
}
