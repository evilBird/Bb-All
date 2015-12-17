//
//  BbObject2.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject2.h"

@implementation BbPort2

- (void)setValue:(id)value
{
}

- (void)connectToPort:(BbPort2 *)port
{
    
}

- (void)disconnectFromPort:(BbPort2 *)port
{
    
}

@end


@implementation BbObject2

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hotInlet = [[BbPort2 alloc]init];
        _hotInlet.hot = YES;
        _coldInlet = [[BbPort2 alloc]init];
        _mainOutlet = [[BbPort2 alloc]init];
    }
    
    return self;
}

@end
