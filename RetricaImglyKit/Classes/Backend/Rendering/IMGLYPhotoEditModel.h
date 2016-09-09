//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

@import Foundation;
@import CoreGraphics;
@import CoreImage;

#import "Enums.h"

/**
 An `IMGLYPhotoEditModel` holds information about everything that should be applied to an image.
 */
@interface IMGLYPhotoEditModel : NSObject <NSCopying> {
  @protected
    IMGLYOrientation _appliedOrientation;
    BOOL _autoEnhancementEnabled;
    CGFloat _brightness;
    CGFloat _contrast;
    CGFloat _shadows;
    CGFloat _highlights;
    NSString *_effectFilterIdentifier;
    CGFloat _effectFilterIntensity;
    CGPoint _focusNormalizedControlPoint1;
    CGPoint _focusNormalizedControlPoint2;
    CGFloat _focusBlurRadius;
    IMGLYFocusType _focusType;
    CGRect _normalizedCropRect;
    CIImage *_overlayImage;
    CGFloat _saturation;
    CGFloat _straightenAngle;
    CGFloat _exposure;
    CGFloat _clarity;
    RELensWrapper *_lensWrapper;
}

NS_ASSUME_NONNULL_BEGIN

/**
 *  The orientation of the image.
 */
@property(nonatomic, readonly) IMGLYOrientation appliedOrientation;

/**
 *  Enable auto enhancement.
 */
@property(nonatomic, readonly, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;

/**
 *  The brightness of the image.
 */
@property(nonatomic, readonly) CGFloat brightness;

/**
 *  The contrast of the image.
 */
@property(nonatomic, readonly) CGFloat contrast;

/**
 *  The shadow amount of the image.
 */
@property(nonatomic, readonly) CGFloat shadows;

/**
 *  The highlights amount of the image.
 */
@property(nonatomic, readonly) CGFloat highlights;

/**
 *  The exposure amount of the image.
 */
@property(nonatomic, readonly) CGFloat exposure;

/**
 *  The clarity amount of the image.
 */
@property(nonatomic, readonly) CGFloat clarity;

/**
 *  The identifier of the effect filter to apply to the image.
 */
@property(nonatomic, readonly, copy) NSString *effectFilterIdentifier;

/**
 *  The intensity of the effect filter.
 */
@property(nonatomic, readonly) CGFloat effectFilterIntensity;

/**
 *  The Retrica Lens Wrapper
 */
@property(nonatomic, readonly, strong) RELensWrapper *lensWrapper;

/**
 *  The first normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic, readonly) CGPoint focusNormalizedControlPoint1;

/**
 *  The second normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic, readonly) CGPoint focusNormalizedControlPoint2;

/**
 *  The blur radius to use for focus. Default is 10.
 */
@property(nonatomic, readonly) CGFloat focusBlurRadius;

/**
 *  The `IMGLYFocusType` to apply to the image.
 */
@property(nonatomic, readonly) IMGLYFocusType focusType;

/**
 *  This property is `true` if the image has neither been cropped nor rotated.
 */
@property(nonatomic, readonly, getter=isGeometryIdentity) BOOL geometryIdentity;

/**
 *  The normalized crop rect of the image.
 */
@property(nonatomic, readonly) CGRect normalizedCropRect;

/**
 *  An image that should be placed on top of the input image after all other effects have been applied.
 */
@property(nonatomic, readonly, nullable) CIImage *overlayImage;

/**
 *  The saturation of the image.
 */
@property(nonatomic, readonly) CGFloat saturation;

/**
 *  The straighten angle of the image.
 */
@property(nonatomic, readonly) CGFloat straightenAngle;

/**
 *  Check if two photo edit models are equal.
 *
 *  @param photoEditModel The photo edit model to compare to the receiver.
 *
 *  @return `YES` if both photo edit models are equal, `NO` otherwise.
 */
- (BOOL)isEqualToPhotoEditModel:(IMGLYPhotoEditModel *)photoEditModel;

/**
 *  The identity orientation of a photo edit model.
 *
 *  @return An `IMGLYOrientation`.
 */
+ (IMGLYOrientation)identityOrientation;

/**
 *  The identity cropping area of a photo edit model.
 *
 *  @return A `CGRect`.
 */
+ (CGRect)identityNormalizedCropRect;

NS_ASSUME_NONNULL_END

@end
