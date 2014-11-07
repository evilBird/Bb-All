//
//  BSDPredicate.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/6/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPredicate.h"
#import "BSDArrayInlet.h"
#import "BSDStringInlet.h"

@implementation BSDPredicate

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initCold];
    inlet.name = @"cold";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDStringInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"predicate";
}

- (void)calculateOutput
{
    NSString *hot = self.hotInlet.value;
    NSArray *cold = self.coldInlet.value;
    
    if (!hot || ![hot isKindOfClass:[NSString class]]) {
        return;
    }
    if (!cold || ![cold isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSString *formatString = [NSString stringWithString:hot];
    NSArray *args = cold.mutableCopy;
    NSPredicate *output = [self predicateWithFormatString:formatString arguments:args];
    [self.mainOutlet output:output];
}

- (NSPredicate *)predicateWithFormatString:(NSString *)formatString arguments:(NSArray *)args
{
    NSPredicate *result = nil;
    if (!formatString || !args) {
        return nil;
    }
    
    if (args.count > 5) {
        NSLog(@"\nBSDPREDICATE ERROR:\nToo many input arguments. 5 or less, buddy");
        return nil;
    }
    
    NSUInteger count = args.count;
    switch (count) {
        case 1:
            result = [NSPredicate predicateWithFormat:formatString,args.firstObject];
            break;
        case 2:
            result = [NSPredicate predicateWithFormat:formatString,args.firstObject,args.lastObject];
            break;
        case 3:
            result = [NSPredicate predicateWithFormat:formatString,args.firstObject,args[1],args.lastObject];
            break;
        case 4:
            result = [NSPredicate predicateWithFormat:formatString,args.firstObject,args[1],args[2],args.lastObject];
            break;
        case 5:
            result = [NSPredicate predicateWithFormat:formatString,args.firstObject,args[1],args[2],args[3],args.lastObject];
            break;
        default:
            break;
    }
    
    return result;
    
}

@end
