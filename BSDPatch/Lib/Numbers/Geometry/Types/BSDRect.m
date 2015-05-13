//
//  BSDRect.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRect.h"
#import "BSDCreate.h"
#import <UIKit/UIKit.h>

@interface BSDRect (){
    CGRect kRect;
}


@end

@implementation BSDRect

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"BSDRect";
    
    self.originXInlet = [[BSDNumberInlet alloc]initHot];
    self.originXInlet.name = @"originX";
    self.originXInlet.delegate = self;
    self.originYInlet = [[BSDNumberInlet alloc]initHot];
    self.originYInlet.name = @"originY";
    self.widthInlet = [[BSDNumberInlet alloc]initHot];
    self.widthInlet.name = @"width";
    self.heightInlet = [[BSDNumberInlet alloc]initHot];
    self.heightInlet.name = @"height";
    self.originXInlet.value = @(0);
    self.originYInlet.value = @(0);
    self.widthInlet.value = @(0);
    self.heightInlet.value = @(0);
    [self addPort:self.originXInlet];
    [self addPort:self.originYInlet];
    [self addPort:self.widthInlet];
    [self addPort:self.heightInlet];
    
    NSArray *initialRect = (NSArray *)arguments;
    
    if (initialRect && [initialRect isKindOfClass:[NSArray class]] && initialRect.count == 4) {
        self.originXInlet.value = initialRect[0];
        self.originYInlet.value = initialRect[1];
        self.widthInlet.value = initialRect[2];
        self.heightInlet.value = initialRect[3];
    }else{
        self.originXInlet.value = @(0);
        self.originYInlet.value = @(0);
        self.widthInlet.value = @(44);
        self.heightInlet.value = @(44);
    }
    
    kRect = CGRectMake([self.originXInlet.value floatValue],
                       [self.originYInlet.value floatValue],
                       [self.widthInlet.value floatValue],
                       [self.heightInlet.value floatValue]
                       );

}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.originXInlet) {
        [self calculateOutput];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (![value isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    if (inlet == self.originXInlet) {
        kRect.origin.x = [value floatValue];
    }else if (inlet == self.originYInlet){
        kRect.origin.y = [value floatValue];
    }else if (inlet == self.widthInlet){
        kRect.size.width = [value floatValue];
    }else if (inlet == self.heightInlet){
        kRect.size.height = [value floatValue];
    }
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSValue *output = [NSValue wrapRect:kRect];
    [self.mainOutlet output:output];
    
    /*
    if (![self typeCheck]) {
        return;
    }
    
    CGRect result;
    result.size.height = [self.heightInlet.value floatValue];
    result.size.width = [self.widthInlet.value floatValue];
    result.origin.y = [self.originYInlet.value floatValue];
    result.origin.x = [self.originXInlet.value floatValue];
    NSValue *output = [NSValue wrapRect:result];
    [self.mainOutlet output:output];
     */
}
- (BOOL)typeCheck
{
    NSNumber *x = self.originXInlet.value;
    NSNumber *y = self.originYInlet.value;
    NSNumber *w = self.widthInlet.value;
    NSNumber *h = self.heightInlet.value;
    
    if (!x || ![x isKindOfClass:[NSNumber class]] || !y || ![y isKindOfClass:[NSNumber class]] || !w || ![w isKindOfClass:[NSNumber class]] || !h || ![h isKindOfClass:[NSNumber class]]) {
        
        return NO;
    }
    
    return YES;
}
                                    


@end
