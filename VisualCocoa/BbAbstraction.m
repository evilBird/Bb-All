//
//  BbAbstraction.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbAbstraction.h"
#import "BbObject+Decoder.h"
#import "NSMutableArray+Stack.h"

@implementation BbAbstraction

- (void)setupWithArguments:(id)arguments
{
    self.name = @"";
    NSString *text = [arguments toString];
    [self createChildObjectsWithText:text];
}

- (NSArray *)filterDescriptions:(NSArray *)descriptions
{
    return descriptions;
}


@end
