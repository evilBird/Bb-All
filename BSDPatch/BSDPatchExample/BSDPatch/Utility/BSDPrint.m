//
//  BSDPrint.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPrint.h"



@implementation BSDPrint
- (void)setupWithArguments:(id)arguments
{
    self.name = @"print";
    NSString *text = arguments;
    if (text) {
        self.text = text;
    }
}

- (void)calculateOutput
{
    id value = self.hotInlet.value;
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        id toPrint = [value mutableCopy];
        NSLog(@"\n%@print: %@\n",self.text,toPrint);
    }else{
        NSLog(@"\n%@print: %@\n",self.text,value);
    }
}

@end
