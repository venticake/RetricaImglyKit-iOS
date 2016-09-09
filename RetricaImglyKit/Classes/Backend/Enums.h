//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

/**
 *  Represents the type of focus that should be used in an image.
 */
typedef NS_ENUM(NSInteger, IMGLYFocusType) {
    /**
     *  Focus should be disabled.
     */
    IMGLYFocusTypeOff,
    /**
     *  A linear focus should be used.
     */
    IMGLYFocusTypeLinear,
    /**
     *  A radial focus should be used.
     */
    IMGLYFocusTypeRadial
};

/**
 *  Represents the orientation of an image and has the same meaning as the corresponding EXIF value.
 */
typedef NS_ENUM(NSInteger, IMGLYOrientation) {
    /**
     *  Row 0 is at the top, column 0 is on the left.
     */
    IMGLYOrientationNormal = 1,
    /**
     *  Row 0 is at the top, column 0 is on the right.
     */
    IMGLYOrientationFlipX,
    /**
     *  Row 0 is at the bottom, column 0 is on the right.
     */
    IMGLYOrientationRotate180,
    /**
     *  Row 0 is at the bottom, column 0 is on the left.
     */
    IMGLYOrientationFlipY,
    /**
     *  Row 0 is on the left, column 0 is at the top.
     */
    IMGLYOrientationTranspose,
    /**
     *  Row 0 is on the right, column 0 is at the top.
     */
    IMGLYOrientationRotate90,
    /**
     *  Row 0 is on the right, column 0 is at the bottom.
     */
    IMGLYOrientationTransverse,
    /**
     *  Row 0 is on the left, column 0 is at the bottom.
     */
    IMGLYOrientationRotate270
};
