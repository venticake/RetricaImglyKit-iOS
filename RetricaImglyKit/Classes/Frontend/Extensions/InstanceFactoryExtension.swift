//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation
import CoreGraphics

extension InstanceFactory {
    // MARK: - Editor View Controllers

    /**
     Return the tool controller according to the button-type. This is used by the main menu.

     - parameter actionType:         The type of the button pressed.
     - parameter withPhotoEditModel: The photo edit model that should be passed to the tool controller.
     - parameter configuration:      The configuration object that should be applied to the tool controller.

     - returns: A tool controller according to the button-type or `nil` if no tool controller for the button-type exists.
     */
    public class func toolControllerForEditorActionType(actionType: PhotoEditorAction, withPhotoEditModel photoEditModel: IMGLYPhotoEditMutableModel, configuration: Configuration) -> PhotoEditToolController? {
        // swiftlint:disable force_cast
        switch actionType {
        case .Crop:
            return (configuration.getClassForReplacedClass(CropToolController.self) as! CropToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Orientation:
            return (configuration.getClassForReplacedClass(OrientationToolController.self) as! OrientationToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Filter:
            return (configuration.getClassForReplacedClass(FilterToolController.self) as! FilterToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .RetricaFilter:
            return (configuration.getClassForReplacedClass(RetricaFilterToolController.self) as! RetricaFilterToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Adjust:
            return (configuration.getClassForReplacedClass(AdjustToolController.self) as! AdjustToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Text:
            return (configuration.getClassForReplacedClass(TextToolController.self) as! TextToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Sticker:
            return (configuration.getClassForReplacedClass(StickerToolController.self) as! StickerToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Focus:
            return (configuration.getClassForReplacedClass(FocusToolController.self) as! FocusToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        case .Frame:
            return (configuration.getClassForReplacedClass(FrameToolController.self) as! FrameToolController.Type).init(photoEditModel: photoEditModel, configuration: configuration)
        default:
            return nil
        }
        // swiftlint:enable force_cast
    }

    // MARK: - Gradient Views

    /**
    Creates a circle gradient view.

    - returns: An instance of `CircleGradientView`.
    */
    public class func circleGradientView() -> CircleGradientView {
        return CircleGradientView(frame: CGRect.zero)
    }

    /**
     Creates a box gradient view.

     - returns: An instance of `BoxGradientView`.
     */
    public class func boxGradientView() -> BoxGradientView {
        return BoxGradientView(frame: CGRect.zero)
    }

    // MARK: - Helpers

    /**
    Creates a crop rect component.

    - returns: An instance of `CropRectComponent`.
    */
    public class func cropRectComponent() -> CropRectComponent {
        return CropRectComponent()
    }
}
