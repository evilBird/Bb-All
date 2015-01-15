//
//  BSDConstraintObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDConstraintObject.h"

@implementation BSDConstraintObject

- (void)calculateOutput
{
    id value = self.hotInlet.value;
    if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"remove"]) {
        InstallConstraintsOnViewBlock block = [BSDConstraintObject removeConstraints];
        NSArray *output = @[kContraintsKey,[block copy]];
        [self.mainOutlet output:output];
        return;
    }
}

+ (ALEdge)edgeForNumber:(NSNumber *)number
{
    switch (number.integerValue) {
        case 0:
            return ALEdgeTop;
            break;
        case 1:
            return ALEdgeRight;
            break;
        case 2:
            return ALEdgeBottom;
            break;
        case 3:
            return ALEdgeLeft;
            break;
        case 4:
            return ALEdgeLeading;
            break;
        case 5:
            return ALEdgeTrailing;
            break;
        default:
            return ALEdgeTop;
            break;
    }
}

+ (ALAxis)axisForNumber:(NSNumber *)number
{
    switch (number.integerValue) {
        case 0:
            return ALAxisHorizontal;
            break;
        case 1:
            return ALAxisVertical;
            break;
        case 2:
            return ALAxisBaseline;
            break;
        case 3:
            return ALAxisFirstBaseline;
            break;
        case 4:
            return ALAxisLastBaseline;
            break;
        default:
            return ALAxisHorizontal;
            break;
    }
}

+ (ALDimension)dimensionForNumber:(NSNumber *)number
{
    switch (number.integerValue) {
        case 0:
            return ALDimensionWidth;
            break;
            
        default:
            return ALDimensionHeight;
            break;
    }
}

+ (UIView *)view:(UIView *)view siblingViewWithTag:(NSNumber *)number
{
    UIView *superview = view.superview;
    return [superview viewWithTag:number.integerValue];
}

+ (InstallConstraintsOnViewBlock)removeConstraints
{
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        [view removeConstraints:view.constraints];
    };
    
    return block;
}

@end

@implementation BSDPinEdge2SuperView

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pin 2 super";
}

- (void)calculateOutput
{
    [super calculateOutput];
    
    NSNumber *sideVal = self.hotInlet.value;
    NSNumber *insetVal = self.coldInlet.value;
    ALEdge edge = [BSDConstraintObject edgeForNumber:sideVal];
    CGFloat inset = [insetVal floatValue];
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        [view autoPinEdgeToSuperviewEdge:edge withInset:inset];
    };
    NSArray *output = @[kContraintsKey,[block copy]];
    [self.mainOutlet output:output];
}

@end

@implementation BSDAlignAxis2SuperView

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"align 2 super";
    self.coldInlet.value = @(0);
}

- (void)calculateOutput
{
    [super calculateOutput];
    
    NSNumber *axisVal = self.hotInlet.value;
    NSNumber *offsetVal = self.coldInlet.value;
    ALAxis axis = [BSDConstraintObject axisForNumber:axisVal];
    
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        [view autoAlignAxis:axis toSameAxisOfView:view.superview withOffset:offsetVal.floatValue];
    };
    
    NSArray *output = @[kContraintsKey,[block copy]];
    [self.mainOutlet output:output];
}

@end

@implementation BSDPinEdge2ViewEdge

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pin 2 view";
    self.offsetInlet = [[BSDInlet alloc]initCold];
    self.offsetInlet.name = @"offset";
    [self addPort:self.offsetInlet];
}

- (void)calculateOutput
{
    [super calculateOutput];
    
    NSArray *edges = self.hotInlet.value;
    NSNumber *targetViewTag = self.coldInlet.value;
    NSNumber *offsetVal = self.offsetInlet.value;
    
    ALEdge targetEdge = [BSDConstraintObject edgeForNumber:edges.firstObject];
    ALEdge sourceEdge = [BSDConstraintObject edgeForNumber:edges.lastObject];
    
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        UIView *targetView = [BSDConstraintObject view:view siblingViewWithTag:targetViewTag];
        [view autoPinEdge:targetEdge toEdge:sourceEdge ofView:targetView withOffset:offsetVal.floatValue];
    };
    
    NSArray *output = @[kContraintsKey,[block copy]];
    [self.mainOutlet output:output];
}

@end

@implementation BSDAlignAxis2ViewAxis

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"align 2 view";
    self.offsetInlet = [[BSDInlet alloc]initCold];
    self.offsetInlet.name = @"offset";
    [self addPort:self.offsetInlet];
}

- (void)calculateOutput
{
    [super calculateOutput];
    
    NSNumber *axisVal = self.hotInlet.value;
    NSNumber *targetViewTag = self.coldInlet.value;
    NSNumber *offsetVal = self.offsetInlet.value;

    ALAxis axis = [BSDConstraintObject axisForNumber:axisVal];
    
    
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        UIView *targetView = [BSDConstraintObject view:view siblingViewWithTag:targetViewTag];
        [view autoAlignAxis:axis toSameAxisOfView:targetView withOffset:offsetVal.floatValue];
    };
    
    NSArray *output = @[kContraintsKey,[block copy]];
    [self.mainOutlet output:output];
}

@end

@implementation BSDPinSize

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pin size";
}

- (void)calculateOutput
{
    [super calculateOutput];
    
    NSNumber *dimensionVal = self.hotInlet.value;
    NSNumber *sizeVal = self.coldInlet.value;
    ALDimension dimension = [BSDConstraintObject dimensionForNumber:dimensionVal];
    CGFloat size = sizeVal.floatValue;
    
    InstallConstraintsOnViewBlock block = ^(UIView *view){
        [view autoSetDimension:dimension toSize:size];
    };
    
    NSArray *output = @[kContraintsKey,[block copy]];
    [self.mainOutlet output:output];
}


@end
