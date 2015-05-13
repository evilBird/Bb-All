//
//  HBVImageBlur.m
//  Herbivore
//
//  Created by Travis Henspeter on 5/9/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import "HBVImageBlur.h"
#import <Accelerate/Accelerate.h>
#import <CoreImage/CoreImage.h>

CGFloat clip_blur(CGFloat blur){
    
    if (blur > 1.0f) {
        blur = 1.0f;
    }
    if (blur < 0.025f) {
        blur = 0.025f;
    }
    
    return blur;
}

@implementation HBVImageBlur

+ (UIImage *)applyBlurType:(HBVImageBlurType)type onImage: (UIImage *)imageToBlur withRadius: (CGFloat)blurRadius
{
    UIImage *result = nil;
    
    if (type == HBVImageBlurTypeCoreImage) {
        
        result = [HBVImageBlur CIApplyBlurOnImage:imageToBlur withRadius:blurRadius];
        
    }else if (type == HBVImageBlurTypevImage){
        
        result = [HBVImageBlur vImageApplyBlurOnImage:imageToBlur withRadius:blurRadius];
    }
    
    return result;
}

+ (UIImage *)CIApplyBlurOnImage:(UIImage *)imageToBlur withRadius:(CGFloat)blurRadius
{
    CIImage *originalImage = [CIImage imageWithCGImage: imageToBlur.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur" keysAndValues: kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage: outputImage fromRect: [outputImage extent]];
    
    return [UIImage imageWithCGImage: outImage];
}

+ (UIImage *)vImageApplyBlurOnImage:(UIImage *)imageToBlur withRadius:(CGFloat)blurRadius
{
    if (imageToBlur != nil) {
        blurRadius = clip_blur(blurRadius);
        
        int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
        CGImageRef rawImage = imageToBlur.CGImage; vImage_Buffer inBuffer, outBuffer;
        vImage_Error error;
        void *pixelBuffer;
        CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
        CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
        inBuffer.width = CGImageGetWidth(rawImage);
        inBuffer.height = CGImageGetHeight(rawImage);
        inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
        inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
        pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
        outBuffer.data = pixelBuffer;
        outBuffer.width = CGImageGetWidth(rawImage);
        outBuffer.height = CGImageGetHeight(rawImage);
        outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(imageToBlur.CGImage));
        CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
        UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
        //clean up
        CGContextRelease(ctx);
        CGColorSpaceRelease(colorSpace);
        free(pixelBuffer);
        CFRelease(inBitmapData);
        CGImageRelease(imageRef);
        return returnImage;

    }
    return [UIImage imageNamed:@"placeholder_profile"];
}


@end
