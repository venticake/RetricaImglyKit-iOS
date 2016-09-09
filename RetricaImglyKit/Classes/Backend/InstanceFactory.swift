//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

/**
  A helper class that is used to create instances of classes. It is used within the SDK to
  create filters, views, view controllers and so on.
*/
@available(iOS 8, *)
@objc(IMGLYInstanceFactory) public class InstanceFactory: NSObject {

    // MARK: - Font Related

    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.

    - returns: An array of fontnames.
    */
    public class var availableFontsList: [String] {
        return [
            "Helvetica",
            "AmericanTypewriter",
            "Avenir-Heavy",
            "ChalkboardSE-Regular",
            "ArialMT",
            "KohinoorBangla-Regular",
            "Liberator",
            "Muncie",
            "AbrahamLincoln",
            "Airship27",
            "ArvilSans",
            "Bender-Inline",
            "Blanch-Condensed",
            "Cubano-Regular",
            "Franchise-Bold",
            "GearedSlab-Regular",
            "Governor",
            "Haymaker",
            "Homestead-Regular",
            "MavenProLight200-Regular",
            "MenschRegular",
            "Sullivan-Regular",
            "Tommaso",
            "ValenciaRegular",
            "Vevey"
        ]
    }

    /**
     Some font names are long and ugly therefor.
     In that case its possible to add an entry into this dictionary.
     The SDK will perform a lookup first and will use that name in the UI.

     - returns: A map to beautfy the names.
     */
    public class var fontDisplayNames: [String:String] {
        return [
            "AmericanTypewriter" : "Typewriter",
             "Avenir-Heavy" :"Avenir",
            "ChalkboardSE-Regular" : "Chalkboard",
            "ArialMT" : "Arial",
            "KohinoorBangla-Regular" : "Kohinoor",
            "AbrahamLincoln" : "Lincoln",
            "Airship27" : "Airship",
            "ArvilSans" : "Arvil",
            "Bender-Inline" : "Bender",
            "Blanch-Condensed" : "Blanch",
            "Cubano-Regular" : "Cubano",
            "Franchise-Bold" : "Franchise",
            "GearedSlab-Regular" : "Geared",
            "Homestead-Regular" : "Homestead",
            "MavenProLight200-Regular" : "Maven Pro",
            "MenschRegular" : "Mensch",
            "Sullivan-Regular" : "Sullivan",
            "ValenciaRegular" : "Valencia"
        ]
    }

    /**
     Returns a newly allocated font importer.

     - returns: An instance of `FontImporter`.
     */
    public class func fontImporter() -> FontImporter {
        return FontImporter()
    }

}
