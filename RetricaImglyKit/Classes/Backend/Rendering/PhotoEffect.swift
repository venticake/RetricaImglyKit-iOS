//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import CoreImage

/**
 *  The `PhotoEffect` class describes an effect that can be applied to a photo.
 */
@available(iOS 8, *)
@objc(IMGLYPhotoEffect) public class PhotoEffect: NSObject {

    // MARK: - Accessors

    /// The identifier of the effect.
    public let identifier: String
    /// The name of the `CIFilter` that should be used to apply this effect.
    public let CIFilterName: String?
    /// The URL of the lut image that should be used to generate a color cube. This is only used if `CIFilterName` is
    /// `CIColorCube` or `CIColorCubeWithColorSpace` and `options` does not include a key named `inputCubeData`.
    public let lutURL: NSURL?
    /// The name that is displayed to the user.
    public let displayName: String
    /// Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.
    public let options: [String: AnyObject]?

    // MARK: - Initializers

    /**
    Returns a newly initialized photo effect.

    - parameter identifier:  An identifier that uniquely identifies the effect.
    - parameter filterName:  The name of the `CIFilter` that should be used to apply this effect.
    - parameter lutURL:      The URL of the lut image that should be used to generate a color cube. This is only used if `filterName` is `CIColorCube` or `CIColorCubeWithColorSpace` and `options` does not include a key named `inputCubeData`.
    - parameter displayName: The name that is displayed to the user.
    - parameter options:     Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.

    - returns: A newly initialized `PhotoEffect` object.
    */
    public init(identifier: String, CIFilterName filterName: String?, lutURL: NSURL?, displayName: String, options: [String: AnyObject]?) {
        self.identifier = identifier
        self.CIFilterName = filterName
        self.lutURL = lutURL
        self.displayName = displayName
        self.options = options
        super.init()
    }

    /**
     Returns a newly initialized photo effect that uses a `CIColorCubeWithColorSpace` filter and the LUT at url `lutURL` to generate the color cube data.

     - parameter identifier:  An identifier that uniquely identifies the effect.
     - parameter lutURL:      The URL of the lut image that should be used to generate a color cube.
     - parameter displayName: The name that is displayed to the user.

     - returns: A newly initialized `PhotoEffect` object.
     */
    public init(identifier: String, lutURL: NSURL?, displayName: String) {
        self.identifier = identifier
        self.CIFilterName = "CIColorCubeWithColorSpace"
        self.lutURL = lutURL
        self.displayName = displayName

        var options: [String: AnyObject] = ["inputCubeDimension": 64]

        if let colorSpace = CGColorSpaceCreateDeviceRGB() {
            options["inputColorSpace"] = colorSpace
        }

        self.options = options
        super.init()
    }

    /// Returns a new `CIFilter` object with the given name and options.
    public var newEffectFilter: CIFilter? {
        guard let CIFilterName = CIFilterName, filter = CIFilter(name: CIFilterName, withInputParameters: options) else {
            return nil
        }

        return filter
    }

    // MARK: - Statics

    /// Change this array to only support a subset of all available filters or to include custom
    /// filters. By default this array includes all available filters.
    public static var allEffects: [PhotoEffect] = [
        PhotoEffect(identifier: "None", CIFilterName: nil, lutURL: nil, displayName: Localize("None"), options: nil),
        PhotoEffect(identifier: "K1", lutURL: NSBundle.imglyKitBundle.URLForResource("K1", withExtension: "png"), displayName: Localize("K1")),
        PhotoEffect(identifier: "K2", lutURL: NSBundle.imglyKitBundle.URLForResource("K2", withExtension: "png"), displayName: Localize("K2")),
        PhotoEffect(identifier: "K6", lutURL: NSBundle.imglyKitBundle.URLForResource("K6", withExtension: "png"), displayName: Localize("K6")),
        PhotoEffect(identifier: "Dynamic", lutURL: NSBundle.imglyKitBundle.URLForResource("Dynamic", withExtension: "png"), displayName: Localize("Dynamic")),
        PhotoEffect(identifier: "Fridge", lutURL: NSBundle.imglyKitBundle.URLForResource("Fridge", withExtension: "png"), displayName: Localize("Fridge")),
        PhotoEffect(identifier: "Breeze", lutURL: NSBundle.imglyKitBundle.URLForResource("Breeze", withExtension: "png"), displayName: Localize("Breeze")),
        PhotoEffect(identifier: "Orchid", lutURL: NSBundle.imglyKitBundle.URLForResource("Orchid", withExtension: "png"), displayName: Localize("Orchid")),
        PhotoEffect(identifier: "Chest", lutURL: NSBundle.imglyKitBundle.URLForResource("Chest", withExtension: "png"), displayName: Localize("Chest")),
        PhotoEffect(identifier: "Front", lutURL: NSBundle.imglyKitBundle.URLForResource("Front", withExtension: "png"), displayName: Localize("Front")),
        PhotoEffect(identifier: "Fixie", lutURL: NSBundle.imglyKitBundle.URLForResource("Fixie", withExtension: "png"), displayName: Localize("Fixie")),
        PhotoEffect(identifier: "X400", lutURL: NSBundle.imglyKitBundle.URLForResource("X400", withExtension: "png"), displayName: Localize("X400")),
        PhotoEffect(identifier: "BW", lutURL: NSBundle.imglyKitBundle.URLForResource("BW", withExtension: "png"), displayName: Localize("BW")),
        PhotoEffect(identifier: "AD1920", lutURL: NSBundle.imglyKitBundle.URLForResource("AD1920", withExtension: "png"), displayName: Localize("AD1920")),
        PhotoEffect(identifier: "Lenin", lutURL: NSBundle.imglyKitBundle.URLForResource("Lenin", withExtension: "png"), displayName: Localize("Lenin")),
        PhotoEffect(identifier: "Quozi", lutURL: NSBundle.imglyKitBundle.URLForResource("Quozi", withExtension: "png"), displayName: Localize("Quozi")),
        PhotoEffect(identifier: "669", lutURL: NSBundle.imglyKitBundle.URLForResource("669", withExtension: "png"), displayName: Localize("669")),
        PhotoEffect(identifier: "SX", lutURL: NSBundle.imglyKitBundle.URLForResource("SX", withExtension: "png"), displayName: Localize("SX")),
        PhotoEffect(identifier: "Food", lutURL: NSBundle.imglyKitBundle.URLForResource("Food", withExtension: "png"), displayName: Localize("Food")),
        PhotoEffect(identifier: "Glam", lutURL: NSBundle.imglyKitBundle.URLForResource("Glam", withExtension: "png"), displayName: Localize("Glam")),
        PhotoEffect(identifier: "Celsius", lutURL: NSBundle.imglyKitBundle.URLForResource("Celsius", withExtension: "png"), displayName: Localize("Celsius")),
        PhotoEffect(identifier: "Texas", lutURL: NSBundle.imglyKitBundle.URLForResource("Texas", withExtension: "png"), displayName: Localize("Texas")),
        PhotoEffect(identifier: "Lomo", lutURL: NSBundle.imglyKitBundle.URLForResource("Lomo", withExtension: "png"), displayName: Localize("Lomo")),
        PhotoEffect(identifier: "Goblin", lutURL: NSBundle.imglyKitBundle.URLForResource("Goblin", withExtension: "png"), displayName: Localize("Goblin")),
        PhotoEffect(identifier: "Sin", lutURL: NSBundle.imglyKitBundle.URLForResource("Sin", withExtension: "png"), displayName: Localize("Sin")),
        PhotoEffect(identifier: "Mellow", lutURL: NSBundle.imglyKitBundle.URLForResource("Mellow", withExtension: "png"), displayName: Localize("Mellow")),
        PhotoEffect(identifier: "Soft", lutURL: NSBundle.imglyKitBundle.URLForResource("Soft", withExtension: "png"), displayName: Localize("Soft")),
        PhotoEffect(identifier: "Blues", lutURL: NSBundle.imglyKitBundle.URLForResource("Blues", withExtension: "png"), displayName: Localize("Blues")),
        PhotoEffect(identifier: "Elder", lutURL: NSBundle.imglyKitBundle.URLForResource("Elder", withExtension: "png"), displayName: Localize("Elder")),
        PhotoEffect(identifier: "Sunset", lutURL: NSBundle.imglyKitBundle.URLForResource("Sunset", withExtension: "png"), displayName: Localize("Sunset")),
        PhotoEffect(identifier: "Evening", lutURL: NSBundle.imglyKitBundle.URLForResource("Evening", withExtension: "png"), displayName: Localize("Evening")),
        PhotoEffect(identifier: "Steel", lutURL: NSBundle.imglyKitBundle.URLForResource("Steel", withExtension: "png"), displayName: Localize("Steel")),
        PhotoEffect(identifier: "70s", lutURL: NSBundle.imglyKitBundle.URLForResource("70s", withExtension: "png"), displayName: Localize("70s")),
        PhotoEffect(identifier: "Hicon", lutURL: NSBundle.imglyKitBundle.URLForResource("Hicon", withExtension: "png"), displayName: Localize("Hicon")),
        PhotoEffect(identifier: "Blue Shade", lutURL: NSBundle.imglyKitBundle.URLForResource("BlueShade", withExtension: "png"), displayName: Localize("Blue Shade")),
        PhotoEffect(identifier: "Carb", lutURL: NSBundle.imglyKitBundle.URLForResource("Carb", withExtension: "png"), displayName: Localize("Carb")),
        PhotoEffect(identifier: "80s", lutURL: NSBundle.imglyKitBundle.URLForResource("80s", withExtension: "png"), displayName: Localize("80s")),
        PhotoEffect(identifier: "Colorful", lutURL: NSBundle.imglyKitBundle.URLForResource("Colorful", withExtension: "png"), displayName: Localize("Colorful")),
        PhotoEffect(identifier: "Lomo 100", lutURL: NSBundle.imglyKitBundle.URLForResource("Lomo100", withExtension: "png"), displayName: Localize("Lomo 100")),
        PhotoEffect(identifier: "Pro 400", lutURL: NSBundle.imglyKitBundle.URLForResource("Pro400", withExtension: "png"), displayName: Localize("Pro 400")),
        PhotoEffect(identifier: "Twilight", lutURL: NSBundle.imglyKitBundle.URLForResource("Twilight", withExtension: "png"), displayName: Localize("Twilight")),
        PhotoEffect(identifier: "Candy", lutURL: NSBundle.imglyKitBundle.URLForResource("Candy", withExtension: "png"), displayName: Localize("Candy")),
        PhotoEffect(identifier: "Pale", lutURL: NSBundle.imglyKitBundle.URLForResource("Pale", withExtension: "png"), displayName: Localize("Pale")),
        PhotoEffect(identifier: "Settled", lutURL: NSBundle.imglyKitBundle.URLForResource("Settled", withExtension: "png"), displayName: Localize("Settled")),
        PhotoEffect(identifier: "Cool", lutURL: NSBundle.imglyKitBundle.URLForResource("Cool", withExtension: "png"), displayName: Localize("Cool")),
        PhotoEffect(identifier: "Litho", lutURL: NSBundle.imglyKitBundle.URLForResource("Litho", withExtension: "png"), displayName: Localize("Litho")),
        PhotoEffect(identifier: "Ancient", lutURL: NSBundle.imglyKitBundle.URLForResource("Ancient", withExtension: "png"), displayName: Localize("Ancient")),
        PhotoEffect(identifier: "Pitched", lutURL: NSBundle.imglyKitBundle.URLForResource("Pitched", withExtension: "png"), displayName: Localize("Pitched")),
        PhotoEffect(identifier: "Lucid", lutURL: NSBundle.imglyKitBundle.URLForResource("Lucid", withExtension: "png"), displayName: Localize("Lucid")),
        PhotoEffect(identifier: "Creamy", lutURL: NSBundle.imglyKitBundle.URLForResource("Creamy", withExtension: "png"), displayName: Localize("Creamy")),
        PhotoEffect(identifier: "Keen", lutURL: NSBundle.imglyKitBundle.URLForResource("Keen", withExtension: "png"), displayName: Localize("Keen")),
        PhotoEffect(identifier: "Tender", lutURL: NSBundle.imglyKitBundle.URLForResource("Tender", withExtension: "png"), displayName: Localize("Tender")),
        PhotoEffect(identifier: "Bleached", lutURL: NSBundle.imglyKitBundle.URLForResource("Bleached", withExtension: "png"), displayName: Localize("Bleached")),
        PhotoEffect(identifier: "B-Blue", lutURL: NSBundle.imglyKitBundle.URLForResource("B-Blue", withExtension: "png"), displayName: Localize("B-Blue")),
        PhotoEffect(identifier: "Fall", lutURL: NSBundle.imglyKitBundle.URLForResource("Fall", withExtension: "png"), displayName: Localize("Fall")),
        PhotoEffect(identifier: "Winter", lutURL: NSBundle.imglyKitBundle.URLForResource("Winter", withExtension: "png"), displayName: Localize("Winter")),
        PhotoEffect(identifier: "Sepia High", lutURL: NSBundle.imglyKitBundle.URLForResource("SepiaHigh", withExtension: "png"), displayName: Localize("Sepia High")),
        PhotoEffect(identifier: "Summer", lutURL: NSBundle.imglyKitBundle.URLForResource("Summer", withExtension: "png"), displayName: Localize("Summer")),
        PhotoEffect(identifier: "Classic", lutURL: NSBundle.imglyKitBundle.URLForResource("Classic", withExtension: "png"), displayName: Localize("Classic")),
        PhotoEffect(identifier: "No Green", lutURL: NSBundle.imglyKitBundle.URLForResource("NoGreen", withExtension: "png"), displayName: Localize("No Green")),
        PhotoEffect(identifier: "Neat", lutURL: NSBundle.imglyKitBundle.URLForResource("Neat", withExtension: "png"), displayName: Localize("Neat")),
        PhotoEffect(identifier: "Plate", lutURL: NSBundle.imglyKitBundle.URLForResource("Plate", withExtension: "png"), displayName: Localize("Plate"))
    ]

    /**
     This method returns the photo effect with the given identifier if such an effect exists.

     - parameter identifier: The identifier of the photo effect.

     - returns: A `PhotoEffect` object.
     */
    public static func effectWithIdentifier(identifier: String) -> PhotoEffect? {
        guard let index = allEffects.indexOf({ $0.identifier == identifier }) else {
            return nil
        }

        return allEffects[index]
    }
}
