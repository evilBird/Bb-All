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
    NSLog(@"\n%@print: %@\n",self.text,self.hotInlet.value);
}

@end
