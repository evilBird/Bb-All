//
//  BSDComment.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDComment.h"

@implementation BSDComment

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    if ([arguments isKindOfClass:[NSArray class]]) {
        self.name = [NSString stringWithFormat:@"%@",[(NSArray *)arguments firstObject]];
    }else {
        self.name = arguments;
    }
}

@end
