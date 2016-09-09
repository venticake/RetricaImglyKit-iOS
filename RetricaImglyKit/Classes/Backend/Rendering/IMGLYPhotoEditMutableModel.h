//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "IMGLYPhotoEditModel.h"

/**
 Posted immediately after any value of a photo edit model changed. The notification object is the
 photo edit model that was changed. The `userInfo` dictionary is `nil`.
 */
extern NSString *__nonnull const IMGLYPhotoEditModelDidChangeNotification;

/**
 An `IMGLYPhotoEditMutableModel` is a mutable subclass of `IMGLYPhotoEditModel`.
 */

@interface IMGLYPhotoEditMutableModel : IMGLYPhotoEditModel

NS_ASSUME_NONNULL_BEGIN

/**
 *  The orientation of the image.
 */
@property(nonatomic) IMGLYOrientation appliedOrientation;

/**
 *  Enable auto enhancement.
 */
@property(nonatomic, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;

/**
 *  The brightness of the image.
 */
@property(nonatomic) CGFloat brightness;

/**
 *  The contrast of the image.
 */
@property(nonatomic) CGFloat contrast;

/**
 *  The shadows of the image.
 */
@property(nonatomic) CGFloat shadows;

/**
 *  The highlights of the image.
 */
@property(nonatomic) CGFloat highlights;

/**
 *  The exposure of the image.
 */
@property(nonatomic) CGFloat exposure;

/**
 *  The clarity of the image.
 */
@property(nonatomic) CGFloat clarity;

/**
 *  The identifier of the effect filter to apply to the image.
 */
@property(nonatomic, copy) NSString *effectFilterIdentifier;

/**
 *  The intensity of the effect filter.
 */
@property(nonatomic) CGFloat effectFilterIntensity;

/**
 *  The Retrica Lens Wrapper
 */
@property(nonatomic, strong) RELensWrapper *lensWrapper;

/**
 *  The first normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic) CGPoint focusNormalizedControlPoint1;

/**
 *  The second normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic) CGPoint focusNormalizedControlPoint2;

/**
 *  The blur radius to use for focus. Default is 10.
 */
@property(nonatomic) CGFloat focusBlurRadius;

/**
 *  The `IMGLYFocusType` to apply to the image.
 */
@property(nonatomic) IMGLYFocusType focusType;

/**
 *  The normalized crop rect of the image.
 */
@property(nonatomic) CGRect normalizedCropRect;

/**
 *  An image that should be placed on top of the input image after all other effects have been applied.
 */
@property(nonatomic, nullable) CIImage *overlayImage;

/**
 *  The saturation of the image.
 */
@property(nonatomic) CGFloat saturation;

/**
 *  The straighten angle of the image.
 */
@property(nonatomic) CGFloat straightenAngle;

/**
 *  Uses this method to apply multiple changes to a photo edit model at the same time, so that only
 *  one update notification is posted.
 *
 *  @param changesBlock The changes to apply to the photo edit model.
 */
- (void)performChangesWithBlock:(void (^)())changesBlock;

/**
 *  Copies all values from the given photo edit model to the receiver.
 *
 *  @param photoEditModel The photo edit model to copy the values from.
 */
- (void)copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel;

NS_ASSUME_NONNULL_END

@end
