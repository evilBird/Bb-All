//
//  BSDImageBlur.m
//  VideoBlurExample
//
//  Created by Travis Henspeter on 8/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDImageBlur.h"
#import "HBVImageBlur.h"

@implementation BSDImageBlur

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}


- (void)setupWithArguments:(id)arguments
{
    self.name = @"image blur";
    if (arguments && [arguments isKindOfClass:[NSNumber class]]) {
        self.coldInlet.value = arguments;
    }else{
        self.coldInlet.value = @(0);
    }
}

- (void)calculateOutput
{
    UIImage *hot = self.hotInlet.value;
    NSNumber *cold = self.coldInlet.value;
    
    if (!hot || !cold || ![hot isKindOfClass:[UIImage class]] || ![cold isKindOfClass:[NSNumber class]]) {
        return;
    }
    CGFloat blur = cold.floatValue;
    UIImage *output = [HBVImageBlur applyBlurType:HBVImageBlurTypevImage onImage:hot withRadius:blur];
    [self.mainOutlet output:output];
}


@end
