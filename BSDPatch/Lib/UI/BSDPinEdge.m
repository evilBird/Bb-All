//
//  BSDConstraintAlignEdge.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPinEdge.h"
#import "PureLayout.h"

@implementation BSDPinEdge

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    
    self.name = @"align edge";
    if (arguments && [arguments isKindOfClass:[NSArray class]] && [arguments count]>1) {
        //Cold inlet input is an array containing two elements:1) the (NSNumber *) tag of the view to be which will be the alignment source, 2) the aligning (NSNumber*)edge (top = 0, right = 1, bottom = 2, left = 3) of the source view
        self.coldInlet = arguments;
    }
    
}

- (void)calculateOutput
{
    NSArray *target = self.hotInlet.value;
    NSArray *source = self.coldInlet.value;
    NSArray *views = self.viewsInlet.value;
    if (!target || !source || ![target isKindOfClass:[NSArray class]] || ![source isKindOfClass:[NSArray class]] || target.count < 2|| source.count < 2 || !views || ![views isKindOfClass:[NSArray class]] || views.count < 2) {
        return;
    }
    
    UIView *targetView = [self viewForTag:target[0] inArray:views];
    UIView *sourceView = [self viewForTag:source[0] inArray:views];
    ALEdge targetEdge = [self edgeForNumber:target[1]];
    ALEdge sourceEdge = [self edgeForNumber:source[1]];
    CGFloat offset = 0;
    if (target.count > 2) {
        offset = [target[2] floatValue];
    }
    
    [targetView autoPinEdge:targetEdge toEdge:sourceEdge ofView:sourceView withOffset:offset];
}

- (UIView *)viewForTag:(NSNumber *)tag inArray:(NSArray *)array
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tag == %@",tag];
    NSArray *filt = [array filteredArrayUsingPredicate:pred];
    if (filt) {
        return filt.firstObject;
    }
    
    return nil;
}

- (ALEdge)edgeForNumber:(NSNumber *)edgeNumber
{
    switch (edgeNumber.integerValue) {
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
            return ALEdgeRight;
            break;
            
            
        default:
            return ALEdgeTop;
            break;
    }
}

@end
