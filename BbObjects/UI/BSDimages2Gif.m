//
//  BSDimages2Gif.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDimages2Gif.h"
#import "BSDArrayInlet.h"
#import "BSDStringInlet.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation BSDimages2Gif

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"images2gif";
    self.imagesInlet = [[BSDArrayInlet alloc]initCold];
    self.imagesInlet.name = @"images";
    [self addPort:self.imagesInlet];
}

- (BSDInlet *)makeLeftInlet
{
    BSDStringInlet *inlet = [[BSDStringInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    return inlet;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (!hot) {
        return;
    }
    id delay = self.coldInlet.value;
    if (!delay) {
        return;
    }
    id images = self.imagesInlet.value;
    if (!images) {
        return;
    }
    
    NSString *output = [self exportAnimatedGif:hot fromImages:images delaytime:delay];
    [self.mainOutlet output:output];
}

- (NSString *)exportAnimatedGif:(NSString *)gifName fromImages:(NSArray*)images delaytime:(NSNumber *)delaytime
{
    NSMutableArray *imagesc = images.mutableCopy;
    NSString *fileName = [gifName stringByAppendingPathExtension:@"gif"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path],
                                                                        kUTTypeGIF,
                                                                        imagesc.count,
                                                                        NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:delaytime forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                                                                forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    for (UIImage *image in imagesc){
        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSLog(@"animated GIF file created at %@", path);
    return path;
}

@end
