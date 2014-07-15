//
//  BSDRoute.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRoute.h"

@implementation BSDRoute

- (void)setupWithArguments:(id)arguments
{
    self.name = @"route";
    
    if ([arguments isKindOfClass:[NSArray class]]) {
        NSArray *selectors = (NSArray *)arguments;
        for (NSString *aSelector in selectors) {
            
            BSDOutlet *outlet = [[BSDOutlet alloc]init];
            outlet.name = aSelector;
            [self addOutlet:outlet named:aSelector];
        }
    }
}

- (id)calculateOutputValue
{
    //Override point for calculatng output
    NSArray *inputArray = [self hotInletValue];
    
    if ([inputArray respondsToSelector:@selector(objectAtIndex:)]
        && inputArray.count >= 2)
    {
        NSString *selector = inputArray.firstObject;
        self.activeOutletName = selector;
        return inputArray[1];
    }
    
    return nil;
}


@end
