//
//  BSDObjectDescription.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObjectDescription.h"

@implementation BSDObjectDescription

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

- (NSUInteger)hash
{
    return [self.uniqueId hash];
}

@end
