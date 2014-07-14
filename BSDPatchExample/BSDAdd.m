//
//  BSDAdd.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAdd.h"

@implementation BSDAdd

- (id)calculateOutputValue
{
    double result = [self.hotInlet.value doubleValue] + [self.coldInlet.value doubleValue];
    return [NSNumber numberWithDouble:result];
}

@end
