//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "IMGLYPhotoEditModel+Private.h"
#import "IMGLYPhotoEditModel.h"
#import "IMGLYPhotoEditMutableModel.h"

@implementation IMGLYPhotoEditModel

#pragma mark - Initializers

- (instancetype)init {
    if ((self = [super init])) {
        _appliedOrientation = IMGLYOrientationNormal;
        _autoEnhancementEnabled = false;
        _brightness = 0;
        _contrast = 1;
        _shadows = 0;
        _highlights = 1;
        _effectFilterIdentifier = @"None";
        _effectFilterIntensity = 0.75;
        _focusNormalizedControlPoint1 = CGPointMake(0.5, 0.8);
        _focusNormalizedControlPoint2 = CGPointMake(0.5, 0.2);
        _focusBlurRadius = 10;
        _focusType = IMGLYFocusTypeOff;
        _normalizedCropRect = [[self class] identityNormalizedCropRect];
        _overlayImage = nil;
        _saturation = 1;
        _straightenAngle = 0;
        _exposure = 0;
        _clarity = 0;
        _lensWrapper = nil;
    }

    return self;
}

#pragma mark - Public API

+ (IMGLYOrientation)identityOrientation {
    return IMGLYOrientationNormal;
}

+ (CGRect)identityNormalizedCropRect {
    return CGRectMake(0, 0, 1, 1);
}

- (BOOL)isGeometryIdentity {
    if (self.appliedOrientation != IMGLYOrientationNormal) {
        return NO;
    }

    if (self.straightenAngle != 0) {
        return NO;
    }

    if (!CGRectEqualToRect(self.normalizedCropRect, CGRectMake(0, 0, 1, 1))) {
        return NO;
    }

    return YES;
}

#pragma mark - Copying

- (void)_copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel {
    _appliedOrientation = photoEditModel.appliedOrientation;
    _autoEnhancementEnabled = photoEditModel.isAutoEnhancementEnabled;
    _brightness = photoEditModel.brightness;
    _contrast = photoEditModel.contrast;
    _effectFilterIdentifier = photoEditModel.effectFilterIdentifier.copy;
    _effectFilterIntensity = photoEditModel.effectFilterIntensity;
    _focusNormalizedControlPoint1 = photoEditModel.focusNormalizedControlPoint1;
    _focusNormalizedControlPoint2 = photoEditModel.focusNormalizedControlPoint2;
    _focusBlurRadius = photoEditModel.focusBlurRadius;
    _focusType = photoEditModel.focusType;
    _normalizedCropRect = photoEditModel.normalizedCropRect;
    _overlayImage = photoEditModel.overlayImage;
    _saturation = photoEditModel.saturation;
    _straightenAngle = photoEditModel.straightenAngle;
    _shadows = photoEditModel.shadows;
    _highlights = photoEditModel.highlights;
    _exposure = photoEditModel.exposure;
    _clarity = photoEditModel.clarity;
    _lensWrapper = photoEditModel.lensWrapper;
}

#pragma mark - NSObject

- (id)mutableCopy {
    IMGLYPhotoEditMutableModel *photoEditMutableModel = [[IMGLYPhotoEditMutableModel alloc] init];
    [photoEditMutableModel _copyValuesFromModel:self];

    return photoEditMutableModel;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:IMGLYPhotoEditModel.class]) {
        return NO;
    }

    return [object isEqualToPhotoEditModel:self];
}

- (BOOL)isEqualToPhotoEditModel:(IMGLYPhotoEditModel *)photoEditModel {
    if (photoEditModel.appliedOrientation != self.appliedOrientation) {
        return NO;
    }

    if (photoEditModel.isAutoEnhancementEnabled != self.isAutoEnhancementEnabled) {
        return NO;
    }

    if (photoEditModel.brightness != self.brightness) {
        return NO;
    }

    if (photoEditModel.contrast != self.contrast) {
        return NO;
    }

    if (photoEditModel.shadows != self.shadows) {
        return NO;
    }

    if (photoEditModel.highlights != self.highlights) {
        return NO;
    }

    if (photoEditModel.exposure != self.exposure) {
        return NO;
    }

    if (photoEditModel.clarity != self.clarity) {
        return NO;
    }

    if (![photoEditModel.effectFilterIdentifier isEqualToString:self.effectFilterIdentifier]) {
        return NO;
    }

    if (photoEditModel.effectFilterIntensity != self.effectFilterIntensity) {
        return NO;
    }

    if (!CGPointEqualToPoint(photoEditModel.focusNormalizedControlPoint1, self.focusNormalizedControlPoint1)) {
        return NO;
    }

    if (!CGPointEqualToPoint(photoEditModel.focusNormalizedControlPoint2, self.focusNormalizedControlPoint2)) {
        return NO;
    }

    if (photoEditModel.focusBlurRadius != self.focusBlurRadius) {
        return NO;
    }

    if (photoEditModel.focusType != self.focusType) {
        return NO;
    }

    if (!CGRectEqualToRect(photoEditModel.normalizedCropRect, self.normalizedCropRect)) {
        return NO;
    }

    if (photoEditModel.overlayImage != self.overlayImage) {
        return NO;
    }

    if (photoEditModel.saturation != self.saturation) {
        return NO;
    }

    if (photoEditModel.straightenAngle != self.straightenAngle) {
        return NO;
    }
    
    if (photoEditModel.lensWrapper != self.lensWrapper) {
        return NO;
    }

    return YES;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
