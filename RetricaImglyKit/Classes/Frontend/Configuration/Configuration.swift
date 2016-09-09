//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import UIKit

/**
 Used to represent the possible errors that can occur when configuring a `Configuration` object.

 - ReplacingClassNotASubclass:  The class that is used to replace another class is not a subclass of that class.
 */
public enum ConfigurationError: ErrorType {
    /// The class that is used to replace another class is not a subclass of that class.
    case ReplacingClassNotASubclass
}

/// This type is used when configuring a button.
public typealias ButtonConfigurationClosure = (UIButton) -> ()

/// This type is used when configuring a slider.
public typealias SliderConfigurationClosure = (Slider) -> ()

/// This type is used when configuring a view.
public typealias ViewConfigurationClosure = (UIView) -> ()

/// This type is used when a tool becomes active.
public typealias DidEnterToolClosure = () -> ()

/// This type is used when a tool is about to resign being active.
public typealias WillLeaveToolClosure = () -> ()

/**
 An Configuration defines behaviour and look of all view controllers
 provided by the imglyKit. It uses the builder pattern to create an
 immutable object via a closure. To configure the different editors and
 viewControllers contained in the SDK, edit their options in the corresponding
 `configure*ViewController` method of the `ConfigurationBuilder`.
*/
@objc(IMGLYConfiguration) public class Configuration: NSObject {

    // MARK: Properties

    /// The background color. Defaults to black.
    public let backgroundColor: UIColor
    /// The color of the separator that is drawn to separate different menu items.
    public let separatorColor: UIColor
    /// The background color of the context menu.
    public let contextMenuBackgroundColor: UIColor
    /// Options for the `CameraViewController`.
    public let cameraViewControllerOptions: CameraViewControllerOptions
    /// Options for the `PhotoEditViewController`.
    public let photoEditViewControllerOptions: PhotoEditViewControllerOptions
    /// Options for the `FilterEditorViewController`.
    public let filterToolControllerOptions: FilterToolControllerOptions
    /// Options for the `RetricaFilterEditorViewController`.
    public let retricaFilterToolControllerOptions: RetricaFilterToolControllerOptions
    /// Options for the `StickersEditorViewController`.
    public let stickerToolControllerOptions: StickerToolControllerOptions
    /// Options for the `FrameEditorViewController`.
    public let frameToolControllerOptions: FrameToolControllerOptions
    /// Options for the `OrientationEditorViewController`.
    public let orientationToolControllerOptions: OrientationToolControllerOptions
    /// Options for the `FocusEditorViewController`.
    public let focusToolControllerOptions: FocusToolControllerOptions
    /// Options for the `CropToolControllerOptions`.
    public let cropToolControllerOptions: CropToolControllerOptions
    /// Options for the `TextEditorViewController`.
    public let textToolControllerOptions: TextToolControllerOptions
    /// Options for the `ToolStackController`.
    public let toolStackControllerOptions: ToolStackControllerOptions
    /// Options for the `TextOptionsToolController`.
    public let textOptionsToolControllerOptions: TextOptionsToolControllerOptions
    /// Options for the `TextFontToolControllerOptions`.
    public let textFontToolControllerOptions: TextFontToolControllerOptions
    /// Options for the `TextColorToolControllerOptions`.
    public let textColorToolControllerOptions: TextColorToolControllerOptions
    /// Options for the `AdjustToolControllerOptions`.
    public let adjustToolControllerOptions: AdjustToolControllerOptions

    //  MARK: Initialization

    /**
    Returns a newly allocated instance of a `Configuration` using the default builder.

    - returns: An instance of a `Configuration`.
    */
    override convenience init() {
        self.init(builder: { _ in })
    }

    /**
     Returns a newly allocated instance of a `Configuration` using the given builder.

     - parameter builder: A `ConfigurationBuilder` instance.

     - returns: An instance of a `Configuration`.
     */
    public init(builder: (ConfigurationBuilder -> Void)) {
        let builderForClosure = ConfigurationBuilder()
        builder(builderForClosure)
        self.backgroundColor = builderForClosure.backgroundColor
        self.contextMenuBackgroundColor = builderForClosure.contextMenuBackgroundColor
        self.cameraViewControllerOptions = builderForClosure.cameraViewControllerOptions
        self.photoEditViewControllerOptions = builderForClosure.photoEditViewControllerOptions
        self.filterToolControllerOptions = builderForClosure.filterToolControllerOptions
        self.retricaFilterToolControllerOptions = builderForClosure.retricaFilterToolControllerOptions
        self.stickerToolControllerOptions = builderForClosure.stickerToolControllerOptions
        self.orientationToolControllerOptions = builderForClosure.orientationToolControllerOptions
        self.focusToolControllerOptions = builderForClosure.focusToolControllerOptions
        self.cropToolControllerOptions = builderForClosure.cropToolControllerOptions
        self.textToolControllerOptions = builderForClosure.textToolControllerOptions
        self.frameToolControllerOptions = builderForClosure.frameToolControllerOptions
        self.toolStackControllerOptions = builderForClosure.toolStackControllerOptions
        self.classReplacingMap = builderForClosure.classReplacingMap
        self.separatorColor = builderForClosure.separatorColor
        self.textOptionsToolControllerOptions = builderForClosure.textOptionsToolControllerOptions
        self.textFontToolControllerOptions = builderForClosure.textFontToolControllerOptions
        self.adjustToolControllerOptions = builderForClosure.adjustToolControllerOptions
        self.textColorToolControllerOptions = builderForClosure.textColorToolControllerOptions
        super.init()
    }

    /// Used internally to fetch a replacement class for framework classes.
    func getClassForReplacedClass(replacedClass: NSObject.Type) -> NSObject.Type {
        guard let replacingClassName = classReplacingMap[String(replacedClass)] else {
            return replacedClass
        }

        // swiftlint:disable force_cast
        return NSClassFromString(replacingClassName) as! NSObject.Type
        // swiftlint:enable force_cast
    }

    private let classReplacingMap: [String: String]
}

/**
 The configuration builder object offers all properties of `Configuration` in
 a mutable version, in order to build an immutable `Configuration` object. To
 further configure the different viewcontrollers, use the `configureXYZViewController`
 methods to edit the given options.
*/
@objc(IMGLYConfigurationBuilder) public class ConfigurationBuilder: NSObject {

    /// The background color. Defaults to black.
    public var backgroundColor: UIColor = UIColor.blackColor()

    /// The color of the separator that is drawn to separate different menu items
    public var separatorColor: UIColor = UIColor(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)

    /// The background color of the context menu.
    public var contextMenuBackgroundColor = UIColor(hue: 0.59, saturation: 0.58, brightness: 0.96, alpha: 1.00)

    private var cameraViewControllerOptions: CameraViewControllerOptions = CameraViewControllerOptions()
    private var photoEditViewControllerOptions: PhotoEditViewControllerOptions = PhotoEditViewControllerOptions()
    private var filterToolControllerOptions: FilterToolControllerOptions = FilterToolControllerOptions()
    private var retricaFilterToolControllerOptions: RetricaFilterToolControllerOptions = RetricaFilterToolControllerOptions()
    private var stickerToolControllerOptions: StickerToolControllerOptions = StickerToolControllerOptions()
    private var frameToolControllerOptions: FrameToolControllerOptions = FrameToolControllerOptions()
    private var orientationToolControllerOptions: OrientationToolControllerOptions = OrientationToolControllerOptions()
    private var focusToolControllerOptions: FocusToolControllerOptions = FocusToolControllerOptions()
    private var cropToolControllerOptions: CropToolControllerOptions = CropToolControllerOptions()
    private var textToolControllerOptions: TextToolControllerOptions = TextToolControllerOptions()
    private var textOptionsToolControllerOptions: TextOptionsToolControllerOptions = TextOptionsToolControllerOptions()
    private var textFontToolControllerOptions: TextFontToolControllerOptions = TextFontToolControllerOptions()
    private var textColorToolControllerOptions: TextColorToolControllerOptions = TextColorToolControllerOptions()
    private var adjustToolControllerOptions: AdjustToolControllerOptions = AdjustToolControllerOptions()
    private var toolStackControllerOptions: ToolStackControllerOptions = ToolStackControllerOptions()

    /// Options for the `CameraViewController`.
    public func configureCameraViewController(builder: (CameraViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = CameraViewControllerOptionsBuilder()
        builder(builderForClosure)
        cameraViewControllerOptions = CameraViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `PhotoEditorViewController`.
    public func configurePhotoEditorViewController(builder: (PhotoEditViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = PhotoEditViewControllerOptionsBuilder()
        builder(builderForClosure)
        photoEditViewControllerOptions = PhotoEditViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `FilterToolController`.
    public func configureFilterToolController(builder: (FilterToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = FilterToolControllerOptionsBuilder()
        builder(builderForClosure)
        filterToolControllerOptions = FilterToolControllerOptions(builder: builderForClosure)
    }
    
    /// Options for the `RetricaFilterToolController`.
    public func configureRetricaFilterToolController(builder: (RetricaFilterToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = RetricaFilterToolControllerOptionsBuilder()
        builder(builderForClosure)
        retricaFilterToolControllerOptions = RetricaFilterToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `StickerToolController`.
    public func configureStickerToolController(builder: (StickerToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = StickerToolControllerOptionsBuilder()
        builder(builderForClosure)
        stickerToolControllerOptions = StickerToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `OrientationToolController`.
    public func configureOrientationToolController(builder: (OrientationToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = OrientationToolControllerOptionsBuilder()
        builder(builderForClosure)
        orientationToolControllerOptions = OrientationToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `FocusToolController`.
    public func configureFocusToolController(builder: (FocusToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = FocusToolControllerOptionsBuilder()
        builder(builderForClosure)
        focusToolControllerOptions = FocusToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `CropToolController`.
    public func configureCropToolController(builder: (CropToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = CropToolControllerOptionsBuilder()
        builder(builderForClosure)
        cropToolControllerOptions = CropToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `TextToolController`.
    public func configureTextToolController(builder: (TextToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = TextToolControllerOptionsBuilder()
        builder(builderForClosure)
        textToolControllerOptions = TextToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `FrameToolController`.
    public func configureFrameToolController(builder: (FrameToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = FrameToolControllerOptionsBuilder()
        builder(builderForClosure)
        frameToolControllerOptions = FrameToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `ToolStackController`.
    public func configureToolStackController(builder: (ToolStackControllerOptionsBuilder -> Void)) {
        let builderForClosure = ToolStackControllerOptionsBuilder()
        builder(builderForClosure)
        toolStackControllerOptions = ToolStackControllerOptions(builder: builderForClosure)
    }

    /// Options for the `TextOptionsToolController`.
    public func configureTextOptionsToolController(builder: (TextOptionsToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = TextOptionsToolControllerOptionsBuilder()
        builder(builderForClosure)
        textOptionsToolControllerOptions = TextOptionsToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `TextFontToolController`.
    public func configureTextFontToolController(builder: (TextFontToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = TextFontToolControllerOptionsBuilder()
        builder(builderForClosure)
        textFontToolControllerOptions = TextFontToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `TextColorToolController`.
    public func configureTextColorToolController(builder: (TextColorToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = TextColorToolControllerOptionsBuilder()
        builder(builderForClosure)
        textColorToolControllerOptions = TextColorToolControllerOptions(builder: builderForClosure)
    }

    /// Options for the `AdjustToolController`.
    public func configureAdjustToolController(builder: (AdjustToolControllerOptionsBuilder -> Void)) {
        let builderForClosure = AdjustToolControllerOptionsBuilder()
        builder(builderForClosure)
        adjustToolControllerOptions = AdjustToolControllerOptions(builder: builderForClosure)
    }

    // MARK: Class replacement

    /**
    Use this to use a specific subclass instead of the default imglyKit **view controller** classes. This works
    across all the whole framework and allows you to subclass all usages of a class. As of now, only **view
    controller** can be replaced!

    - parameter builtinClass:   The built in class, that should be replaced.
    - parameter replacingClass: The class that replaces the builtin class.
    - parameter namespace:      The namespace of the replacing class (e.g. Your_App). Usually
                                the module name of your app. Can be found under 'Product Module Name'
                                in your app targets build settings.

    - throws: An exception if the replacing class is not a subclass of the replaced class.
    */
    public func replaceClass(builtinClass: NSObject.Type, replacingClass: NSObject.Type, namespace: String) throws {
        if !replacingClass.isSubclassOfClass(builtinClass) {
            throw ConfigurationError.ReplacingClassNotASubclass
        }

        let builtinClassName = String(builtinClass)
        let replacingClassName = "\(namespace).\(String(replacingClass))"

        classReplacingMap[builtinClassName] = replacingClassName
        print("imglyKit: Using \(replacingClassName) instead of \(builtinClassName)")
    }

    // MARK: Private properties

    var classReplacingMap: [String: String] = [:]
}
