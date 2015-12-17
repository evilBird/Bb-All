//
//  BSDLayer2Image.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLayer2Image.h"

@implementation BSDLayer2Image
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"layer2image";
    
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[CALayer class]]) {
        return;
    }
    
    UIImage *image = [self imageFromLayer:hot];
    [self.mainOutlet output:image];
    
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
