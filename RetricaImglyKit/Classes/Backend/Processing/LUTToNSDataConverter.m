//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "LUTToNSDataConverter.h"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <AppKit/AppKit.h>
#import <imglyKit/imglyKit-Swift.h>
#endif
#import <Accelerate/Accelerate.h>

static const int kDimension = 64;
static NSData *identityLUT;

@interface LUTToNSDataConverter ()

@property(nonatomic, nonnull, strong) NSURL *identityLUTURL;
@property(nonatomic, nonnull, copy) NSData *identityLUT;
@property(nonatomic, nullable, copy) NSData *lut;

@end

@implementation LUTToNSDataConverter

@synthesize identityLUTURL = _identityLUTURL;

#pragma mark - Accessors

- (NSData *)identityLUT {
    if (!_identityLUT) {
        _identityLUT = [[LUTToNSDataConverter colorCubeDataFromLUTAtURL:self.identityLUTURL] copy];
        NSAssert(_identityLUT != nil, @"Unable to create identity LUT from given name.");
    }

    return _identityLUT;
}

- (void)setLutURL:(NSURL *)lutURL {
    if (![_lutURL isEqual:lutURL]) {
        _lutURL = lutURL;
        _lut = [[LUTToNSDataConverter colorCubeDataFromLUTAtURL:lutURL] copy];
        NSAssert(_lut != nil, @"Unable to create lut from given name.");
    }
}

- (NSData *)colorCubeData {
    if (self.intensity < 0 || self.intensity > 1 || self.lut == nil || self.lut.length != self.identityLUT.length) {
        return nil;
    }

    NSUInteger size = self.lut.length;

    const float *lutData = (const float *)self.lut.bytes;
    const float *identityData = (const float *)self.identityLUT.bytes;

    float *data = malloc(size);
    vDSP_vsbsm(lutData, 1, identityData, 1, &_intensity, data, 1, size / sizeof(float));
    vDSP_vadd(data, 1, identityData, 1, data, 1, size / sizeof(float));

    // This is basically Accelerate Framework's way of doing this:
    //        for (int i = 0; i < size / sizeof(float); i++) {
    //            data[i] = (lutData[i] - identityData[i]) * intensity + identityData[i];
    //        }

    return [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
}

#pragma mark - Initializers

- (instancetype)initWithIdentityLUTAtURL:(nonnull NSURL *)identityLUTURL {
    if ((self = [super init])) {
        _identityLUTURL = identityLUTURL;
        _intensity = 1;
    }

    return self;
}

#pragma mark - LUT Generation

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation
 realised by the LUT is applied with a core image standard filter
 */
+ (nullable NSData *)colorCubeDataFromLUTAtURL:(nonnull NSURL *)lutURL {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:lutURL.path];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    NSImage *image = [[NSImage alloc] initWithContentOfURL:lutURL];
#endif

    if (!image) {
        return nil;
    }

    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    NSInteger rowNum = height / kDimension;
    NSInteger columnNum = width / kDimension;

    if ((width % kDimension != 0) || (height % kDimension != 0) || (rowNum * columnNum != kDimension)) {
        NSLog(@"Invalid colorLUT %@", lutURL);
        return nil;
    }

    float *bitmap = [self createRGBABitmapFromImage:image.CGImage];

    if (bitmap == NULL) {
        return nil;
    }

    NSInteger size = kDimension * kDimension * kDimension * sizeof(float) * 4;
    float *data = malloc(size);
    int bitmapOffset = 0;
    int z = 0;
    for (int row = 0; row < rowNum; row++) {
        for (int y = 0; y < kDimension; y++) {
            int tmp = z;
            for (int col = 0; col < columnNum; col++) {
                NSInteger dataOffset = (z * kDimension * kDimension + y * kDimension) * 4;

                const float divider = 255.0;
                vDSP_vsdiv(&bitmap[bitmapOffset], 1, &divider, &data[dataOffset], 1, kDimension * 4);

                bitmapOffset += kDimension * 4;
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }

    free(bitmap);

    return [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
}

+ (float *)createRGBABitmapFromImage:(CGImageRef)image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmap;
    NSInteger bitmapSize;
    NSInteger bytesPerRow;

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    bytesPerRow = (width * 4);
    bitmapSize = (bytesPerRow * height);

    bitmap = malloc(bitmapSize);
    if (bitmap == NULL) {
        return NULL;
    }

    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        free(bitmap);
        return NULL;
    }

    context = CGBitmapContextCreate(bitmap, width, height, 8, bytesPerRow, colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);

    if (context == NULL) {
        free(bitmap);
        return NULL;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);

    float *convertedBitmap = malloc(bitmapSize * sizeof(float));
    vDSP_vfltu8(bitmap, 1, convertedBitmap, 1, bitmapSize);
    free(bitmap);

    return convertedBitmap;
}

@end
