//
//  BSDOutletBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDOutletBox.h"

@implementation BSDOutletBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDPatchOutlet";
        self.boxClassString = @"BSDOutletBox";
    }
    
    return self;
}

- (NSArray *)inlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *inlets = [self.object inlets];
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    frame.origin.y = 0;
    NSMutableArray *result = [NSMutableArray array];
    BSDInlet *inlet = inlets.firstObject;
    frame.origin.x = 0;
    BSDPortView *portView = [[BSDPortView alloc]initWithName:inlet.name delegate:self];
    portView.frame = frame;
    portView.tag = 0;
    [result addObject:portView];
    [self addSubview:portView];
    
    return result;
}

- (NSArray *)outlets
{
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
