//
//  BSDShader.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDShader.h"

@implementation BSDShader
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}
- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"shader";
}

- (void)filterImage:(UIImage *)sourceImage withFilterKey:(NSString *)filterKey
{
    //since the filter and picture are configured, we'll force the filter to render at the size of the image
    [self.myFilter forceProcessingAtSize:sourceImage.size];
    //void update filter parms as needed
    //Everything should be set up, let's process the image...
    self.prevFilterKey = filterKey;
    self.previousImage = sourceImage;
    [self.myFilter useNextFrameForImageCapture];
    [self.picture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainOutlet output:[self.myFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];
        });
    }];
}

- (GPUImageFilter *)filterWithName:(NSString *)filterName
{
    GPUImageFilter *filter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"k1.fsh"];
    return filter;
}

@end
