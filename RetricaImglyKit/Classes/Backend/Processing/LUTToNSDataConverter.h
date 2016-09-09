//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

/**
 `LUTToNSDataConverter` creates the color cube data needed for a `CIColorCube` filter by reading the
 LUT from an identity image and an effect image and interpolating between them.
 */
@interface LUTToNSDataConverter : NSObject

/**
 *  Returns a newly allocated instance of `LUTToNSDataConverter` with an identity LUT at the given URL.
 *
 *  @param identityLUTURL The url to the identity LUT.
 *
 *  @return An instance of `LUTToNSDataConverter`
 */
- (nonnull instancetype)initWithIdentityLUTAtURL:(nonnull NSURL *)identityLUTURL NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 *  The url of the LUT to use.
 */
@property(nonatomic, nullable, strong) NSURL *lutURL;

/**
 *  The intensity by which the identity and the actual LUT should be interpolated.
 */
@property(nonatomic) float intensity;

/**
 *  The resulting color cube data. Calling this is expensive and the result should be cached.
 */
@property(nonatomic, nullable, readonly) NSData *colorCubeData;

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation
 realised by the LUT is applied with a core image standard filter
 */
+ (nullable NSData *)colorCubeDataFromLUTAtURL:(nonnull NSURL *)lutURL;

@end
